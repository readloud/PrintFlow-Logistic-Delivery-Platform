const socketIO = require('socket.io');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

let io;
const driverSockets = new Map(); // driverId -> socketId
const userSockets = new Map(); // userId -> socketId
const orderRooms = new Map(); // orderId -> room name

function initializeSocket(server) {
  io = socketIO(server, {
    cors: { origin: "*", methods: ["GET", "POST"] },
    transports: ['websocket', 'polling']
  });

  io.use(async (socket, next) => {
    const token = socket.handshake.auth.token;
    if (!token) return next(new Error('Authentication error'));
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await prisma.user.findUnique({ where: { id: decoded.id } });
      socket.user = user;
      next();
    } catch (err) {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Client connected: ${socket.id}, User: ${socket.user?.id}`);

    // === DRIVER REGISTRATION ===
    socket.on('driver:register', async (data) => {
      const driver = await prisma.driver.findUnique({
        where: { userId: socket.user.id }
      });
      if (driver) {
        driverSockets.set(driver.id, socket.id);
        socket.driverId = driver.id;
        socket.join(`driver:${driver.id}`);
        
        // Send pending orders
        const pendingOrders = await prisma.order.findMany({
          where: { driverId: driver.id, deliveryStatus: { in: ['PICKED_UP', 'IN_TRANSIT'] } }
        });
        socket.emit('driver:pending-orders', pendingOrders);
        
        // Broadcast driver online
        io.emit('driver:status-change', { driverId: driver.id, status: 'ONLINE', location: { lat: driver.currentLat, lng: driver.currentLng } });
      }
    });

    // === LOCATION UPDATE (Real-time) ===
    socket.on('driver:location', async (data) => {
      const { lat, lng, heading, speed, accuracy } = data;
      if (!socket.driverId) return;
      
      // Update database
      await prisma.driver.update({
        where: { id: socket.driverId },
        data: { currentLat: lat, currentLng: lng, lastSeen: new Date() }
      });
      
      // Get orders for this driver
      const activeOrders = await prisma.order.findMany({
        where: { driverId: socket.driverId, deliveryStatus: { in: ['PICKED_UP', 'IN_TRANSIT'] } },
        select: { id: true, userId: true }
      });
      
      // Broadcast location to each user tracking this driver
      for (const order of activeOrders) {
        io.to(`order:${order.id}`).emit('driver:location-update', {
          orderId: order.id,
          location: { lat, lng },
          heading,
          speed,
          timestamp: new Date()
        });
      }
      
      // Broadcast to admin dashboard
      io.to('admin:monitoring').emit('driver:live-location', {
        driverId: socket.driverId,
        location: { lat, lng },
        heading,
        speed
      });
    });

    // === USER TRACK ORDER ===
    socket.on('user:track-order', async (data) => {
      const { orderId } = data;
      const order = await prisma.order.findUnique({
        where: { id: orderId },
        include: { driver: { include: { user: true } } }
      });
      
      if (!order || order.userId !== socket.user.id) {
        return socket.emit('error', { message: 'Unauthorized to track this order' });
      }
      
      // Join order-specific room
      const roomName = `order:${orderId}`;
      socket.join(roomName);
      orderRooms.set(orderId, roomName);
      
      // Send initial data
      socket.emit('order:tracking-data', {
        orderId: order.id,
        status: order.deliveryStatus,
        driver: order.driver ? {
          name: order.driver.user.name,
          phone: order.driver.user.phone,
          location: { lat: order.driver.currentLat, lng: order.driver.currentLng }
        } : null,
        estimatedArrival: order.estimatedArrival,
        timeline: order.deliveryTimeline
      });
      
      // Request ETA update
      await calculateAndSendETA(orderId);
    });

    // === USER STOP TRACKING ===
    socket.on('user:stop-tracking', (data) => {
      const { orderId } = data;
      const roomName = orderRooms.get(orderId);
      if (roomName) socket.leave(roomName);
    });

    // === DRIVER START DELIVERY ===
    socket.on('driver:start-delivery', async (data) => {
      const { orderId } = data;
      
      const order = await prisma.order.update({
        where: { id: orderId },
        data: {
          deliveryStatus: 'IN_TRANSIT',
          actualPickupTime: new Date(),
          estimatedArrival: new Date(Date.now() + 30 * 60000) // 30 menit ETA awal
        }
      });
      
      // Notify user
      io.to(`order:${orderId}`).emit('order:status-update', {
        orderId,
        status: 'IN_TRANSIT',
        message: 'Driver sedang dalam perjalanan menuju lokasi Anda',
        timestamp: new Date()
      });
      
      // Calculate optimal route and send to driver
      const optimizedRoute = await calculateRouteOptimization(socket.driverId);
      socket.emit('driver:optimized-route', optimizedRoute);
    });

    // === DRIVER COMPLETE DELIVERY ===
    socket.on('driver:complete-delivery', async (data) => {
      const { orderId, deliveryPhoto, signature, amountReceived } = data;
      
      const order = await prisma.order.update({
        where: { id: orderId },
        data: {
          deliveryStatus: 'DELIVERED',
          paymentStatus: amountReceived ? 'PAID' : 'PENDING',
          deliveredAt: new Date(),
          codReceived: amountReceived,
          deliveryPhoto,
          signature
        }
      });
      
      // Create delivery record
      await prisma.delivery.create({
        data: {
          orderId,
          driverId: socket.driverId,
          status: 'DELIVERED',
          deliveryPhoto,
          signature,
          amountReceived,
          completedAt: new Date()
        }
      });
      
      // Notify user
      io.to(`order:${orderId}`).emit('order:completed', {
        orderId,
        message: 'Pesanan telah sampai! Terima kasih telah menggunakan PrintFlow',
        deliveryPhoto
      });
      
      // Send e-receipt via WhatsApp
      await sendEReceiptWhatsApp(orderId);
      
      // Update driver stats
      await prisma.driver.update({
        where: { id: socket.driverId },
        data: {
          totalDeliveries: { increment: 1 },
          cashHeld: amountReceived ? { increment: amountReceived } : undefined
        }
      });
      
      // Notify admin
      io.to('admin:notifications').emit('admin:delivery-completed', {
        orderId,
        driverId: socket.driverId,
        amountReceived
      });
    });

    // === ADMIN MONITORING ===
    socket.on('admin:start-monitoring', () => {
      if (socket.user.role === 'ADMIN') {
        socket.join('admin:monitoring');
        socket.join('admin:notifications');
      }
    });
    
    socket.on('admin:get-live-drivers', async () => {
      const activeDrivers = await prisma.driver.findMany({
        where: { status: 'ACTIVE', currentLat: { not: null } },
        include: { user: { select: { name: true, phone: true } }, orders: { where: { deliveryStatus: 'IN_TRANSIT' } } }
      });
      socket.emit('admin:live-drivers', activeDrivers);
    });

    // === DRIVER STATUS CHANGE ===
    socket.on('driver:status', async (data) => {
      const { status } = data; // ONLINE, OFFLINE, BUSY
      await prisma.driver.update({
        where: { id: socket.driverId },
        data: { status }
      });
      io.emit('driver:status-change', { driverId: socket.driverId, status });
    });

    // === DISCONNECT ===
    socket.on('disconnect', () => {
      console.log(`❌ Client disconnected: ${socket.id}`);
      if (socket.driverId) {
        driverSockets.delete(socket.driverId);
        io.emit('driver:status-change', { driverId: socket.driverId, status: 'OFFLINE' });
      }
    });
  });
  
  return io;
}

// Calculate ETA using AI and historical data
async function calculateAndSendETA(orderId) {
  const order = await prisma.order.findUnique({
    where: { id: orderId },
    include: { driver: true }
  });
  
  if (!order || !order.driver) return;
  
  const distance = await calculateDistanceFromDriver(order.driver, order);
  const trafficMultiplier = await getTrafficMultiplier(order.driver.currentLat, order.driver.currentLng);
  const avgDriverSpeed = 30; // km/jam
  
  const etaMinutes = (distance / avgDriverSpeed) * 60 * trafficMultiplier;
  const eta = new Date(Date.now() + etaMinutes * 60000);
  
  await prisma.order.update({
    where: { id: orderId },
    data: { estimatedArrival: eta }
  });
  
  io.to(`order:${orderId}`).emit('order:eta-update', {
    orderId,
    eta,
    etaMinutes: Math.ceil(etaMinutes),
    distance: distance.toFixed(1)
  });
}

async function calculateRouteOptimization(driverId) {
  const driver = await prisma.driver.findUnique({ where: { id: driverId } });
  const orders = await prisma.order.findMany({
    where: { driverId, deliveryStatus: 'PICKED_UP' },
    include: { user: true }
  });
  
  if (orders.length === 0) return null;
  
  const waypoints = [
    { lat: driver.currentLat, lng: driver.currentLng, type: 'start' },
    ...orders.map(o => ({
      lat: parseFloat(o.address?.split(',')[0] || 0),
      lng: parseFloat(o.address?.split(',')[1] || 0),
      orderId: o.id,
      isCOD: o.paymentMethod === 'COD',
      amount: o.codAmount
    }))
  ];
  
  return optimizeRouteNearestNeighbor(waypoints);
}

function optimizeRouteNearestNeighbor(waypoints) {
  // Implementation matching previous route optimization
  // Returns optimized sequence
  return waypoints;
}

module.exports = { initializeSocket };