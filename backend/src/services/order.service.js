const { prisma } = require('../config/database');
const AIService = require('./ai.service');
const SocketService = require('./socket.service');
const NotificationService = require('./notification.service');
const { generateOrderNumber } = require('../utils/helpers');
const logger = require('../utils/logger');

class OrderService {
  /**
   * Create new order with AI validation
   */
  async createOrder(userId, orderData) {
    const {
      items,
      deliveryMethod,
      deliveryAddress,
      pickupAddress,
      hubPointId,
      paymentMethod,
      scheduledAt
    } = orderData;

    // AI Validation on first file
    const firstItem = items[0];
    let aiValidation = null;
    
    if (firstItem.fileUrl) {
      const fileBuffer = await this.downloadFile(firstItem.fileUrl);
      aiValidation = await AIService.validatePrintQuality(fileBuffer);
      
      // Auto-upscale if needed
      if (aiValidation.score < 70 && aiValidation.issues.some(i => i.type === 'low_resolution')) {
        const upscaled = await AIService.upscaleImage(fileBuffer);
        if (upscaled.upscaled) {
          firstItem.fileUrl = await this.uploadFile(upscaled.buffer);
          aiValidation.autoFixed = true;
        }
      }
    }

    // Calculate costs
    let deliveryFee = 0;
    let hubPoint = null;
    
    if (deliveryMethod === 'courier') {
      deliveryFee = await this.calculateDeliveryFee(deliveryAddress);
    } else if (deliveryMethod === 'hub_pickup' && hubPointId) {
      hubPoint = await prisma.hubPoint.findUnique({ where: { id: hubPointId } });
      deliveryFee = hubPoint?.flatFee || 0;
    }

    const totalPrintCost = items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    const totalAmount = totalPrintCost + deliveryFee;

    // Create order
    const order = await prisma.order.create({
      data: {
        orderNumber: generateOrderNumber(),
        userId,
        items,
        totalPrintCost,
        deliveryFee,
        totalAmount,
        deliveryMethod,
        deliveryAddress,
        pickupAddress: pickupAddress || null,
        hubPointId: hubPointId || null,
        paymentMethod,
        paymentStatus: paymentMethod === 'COD' ? 'PENDING' : 'PENDING',
        status: paymentMethod === 'COD' ? 'PENDING' : 'PENDING',
        scheduledAt: scheduledAt || null,
        aiVerified: aiValidation?.isValid || false,
        aiValidationData: aiValidation
      }
    });

    // Send notification to user
    await NotificationService.send(userId, {
      title: 'Pesanan Dibuat',
      body: `Pesanan #${order.orderNumber} berhasil dibuat`,
      data: { orderId: order.id, type: 'order_created' }
    });

    // Notify admin/partner if COD order
    if (paymentMethod === 'COD') {
      await this.notifyAdminsForCOD(order);
    }

    return order;
  }

  /**
   * Process order (after payment or admin confirmation)
   */
  async processOrder(orderId, adminId) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: { user: true }
    });

    if (!order) throw new Error('Order not found');

    const updatedOrder = await prisma.order.update({
      where: { id: orderId },
      data: {
        status: 'PROCESSING',
        processingAt: new Date()
      }
    });

    // Send notification
    await NotificationService.send(order.userId, {
      title: 'Pesanan Diproses',
      body: `Pesanan #${order.orderNumber} sedang diproses`,
      data: { orderId: order.id, status: 'PROCESSING' }
    });

    // Socket update
    SocketService.emitToUser(order.userId, 'order_updated', updatedOrder);

    return updatedOrder;
  }

  /**
   * Request pickup - setelah admin selesai cetak
   */
  async requestPickup(orderId, adminId, sealedPhotoUrl) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: { hubPoint: true }
    });

    if (!order) throw new Error('Order not found');

    // Update order status
    const updatedOrder = await prisma.order.update({
      where: { id: orderId },
      data: {
        status: 'READY_FOR_PICKUP',
        readyAt: new Date(),
        sealedPhotoUrl
      }
    });

    // Find available drivers
    const availableDrivers = await prisma.driver.findMany({
      where: {
        status: 'ONLINE',
        isActive: true
      },
      include: { user: true }
    });

    // Use AI to find best driver based on location
    const bestDriver = await this.findBestDriver(availableDrivers, order);

    if (bestDriver) {
      await this.assignDriverToOrder(orderId, bestDriver.id);
      
      // Send notification to driver
      await NotificationService.send(bestDriver.userId, {
        title: 'Pickup Request',
        body: `Ada pesanan siap diambil - #${order.orderNumber}`,
        data: { orderId, type: 'pickup_request' }
      });
    } else {
      // Queue for later or notify admin
      logger.info(`No available driver for order ${orderId}`);
    }

    // Send notification to user
    await NotificationService.send(order.userId, {
      title: 'Pesanan Siap',
      body: `Pesanan #${order.orderNumber} siap diambil driver`,
      data: { orderId, status: 'READY_FOR_PICKUP' }
    });

    SocketService.emitToAdmins('pickup_requested', updatedOrder);

    return updatedOrder;
  }

  /**
   * Assign driver to order
   */
  async assignDriverToOrder(orderId, driverId) {
    const order = await prisma.order.findUnique({ where: { id: orderId } });
    
    const updated = await prisma.order.update({
      where: { id: orderId },
      data: {
        driverId,
        status: order.status === 'READY_FOR_PICKUP' ? 'PICKED_UP' : order.status,
        pickedUpAt: order.status === 'READY_FOR_PICKUP' ? new Date() : undefined
      }
    });

    // Create delivery record
    await prisma.delivery.create({
      data: {
        orderId,
        driverId,
        status: 'PICKED_UP',
        startedAt: new Date()
      }
    });

    // Send notification
    const driver = await prisma.driver.findUnique({
      where: { id: driverId },
      include: { user: true }
    });

    await NotificationService.send(driver.userId, {
      title: 'Pesanan Diambil',
      body: `Anda telah mengambil pesanan #${order.orderNumber}`,
      data: { orderId }
    });

    return updated;
  }

  /**
   * Driver starts delivery (with sealed bag photo)
   */
  async startDelivery(deliveryId, driverId, startPhotoUrl) {
    const delivery = await prisma.delivery.findUnique({
      where: { id: deliveryId },
      include: { order: true }
    });

    if (!delivery || delivery.driverId !== driverId) {
      throw new Error('Invalid delivery');
    }

    // AI check photo quality
    const photoBuffer = await this.downloadFile(startPhotoUrl);
    const photoQC = await AIService.checkPhotoQuality(photoBuffer);

    if (!photoQC.isPass) {
      throw new Error(`Photo quality check failed: ${photoQC.message}`);
    }

    const updated = await prisma.delivery.update({
      where: { id: deliveryId },
      data: {
        startPhoto: startPhotoUrl,
        startedAt: new Date()
      }
    });

    await prisma.order.update({
      where: { id: delivery.order.id },
      data: { status: 'IN_TRANSIT' }
    });

    // Notify user
    await NotificationService.send(delivery.order.userId, {
      title: 'Pesanan Dalam Perjalanan',
      body: `Driver sedang mengantar pesanan #${delivery.order.orderNumber}`,
      data: { orderId: delivery.order.id }
    });

    return updated;
  }

  /**
   * Complete delivery - COD verification
   */
  async completeDelivery(deliveryId, driverId, codReceived, deliveryPhotoUrl) {
    const delivery = await prisma.delivery.findUnique({
      where: { id: deliveryId },
      include: { 
        order: true,
        driver: true
      }
    });

    if (!delivery || delivery.driverId !== driverId) {
      throw new Error('Invalid delivery');
    }

    const order = delivery.order;

    // AI check delivery photo
    const photoBuffer = await this.downloadFile(deliveryPhotoUrl);
    const photoQC = await AIService.checkPhotoQuality(photoBuffer);

    if (!photoQC.isPass) {
      throw new Error(`Delivery photo quality check failed: ${photoQC.message}`);
    }

    // Verify COD amount
    if (order.paymentMethod === 'COD') {
      if (codReceived < order.totalAmount) {
        throw new Error(`COD amount mismatch. Expected: ${order.totalAmount}, Received: ${codReceived}`);
      }
    }

    // Update delivery
    const updatedDelivery = await prisma.delivery.update({
      where: { id: deliveryId },
      data: {
        status: 'COMPLETED',
        codReceived: order.paymentMethod === 'COD' ? codReceived : null,
        endPhoto: deliveryPhotoUrl,
        completedAt: new Date()
      }
    });

    // Update order
    const updatedOrder = await prisma.order.update({
      where: { id: order.id },
      data: {
        status: order.paymentMethod === 'COD' ? 'COMPLETED' : 'DELIVERED',
        deliveredAt: new Date(),
        completedAt: order.paymentMethod === 'COD' ? new Date() : undefined,
        codAmount: order.paymentMethod === 'COD' ? codReceived : null,
        codVerifiedAt: order.paymentMethod === 'COD' ? new Date() : null,
        paymentStatus: order.paymentMethod === 'COD' ? 'SUCCESS' : order.paymentStatus,
        deliveryPhotoUrl
      }
    });

    // Update driver earnings
    const deliveryFee = order.deliveryFee;
    await prisma.driver.update({
      where: { id: driverId },
      data: {
        totalEarnings: { increment: deliveryFee },
        currentBalance: { increment: deliveryFee },
        totalDeliveries: { increment: 1 }
      }
    });

    // Send e-receipt via WhatsApp
    if (order.paymentMethod === 'COD') {
      await this.sendEReceipt(order, codReceived);
    }

    // Notify user
    await NotificationService.send(order.userId, {
      title: 'Pesanan Selesai',
      body: `Pesanan #${order.orderNumber} telah selesai`,
      data: { orderId: order.id, status: 'COMPLETED' }
    });

    SocketService.emitToUser(order.userId, 'order_completed', updatedOrder);
    SocketService.emitToAdmins('delivery_completed', { orderId: order.id, driverId });

    return { delivery: updatedDelivery, order: updatedOrder };
  }

  /**
   * Send E-Receipt via WhatsApp
   */
  async sendEReceipt(order, amountReceived) {
    const user = await prisma.user.findUnique({
      where: { id: order.userId }
    });

    const message = `
*PRINTFLOW - Digital Receipt*
━━━━━━━━━━━━━━━━━━━━━
Order Number: #${order.orderNumber}
Date: ${new Date().toLocaleString('id-ID')}

Items:
${order.items.map(item => `- ${item.name} x${item.quantity} = Rp ${(item.price * item.quantity).toLocaleString()}`).join('\n')}

Subtotal: Rp ${order.totalPrintCost.toLocaleString()}
Delivery: Rp ${order.deliveryFee.toLocaleString()}
━━━━━━━━━━━━━━━━━━━━━
TOTAL: Rp ${order.totalAmount.toLocaleString()}
PAID: Rp ${amountReceived.toLocaleString()}
Change: Rp ${(amountReceived - order.totalAmount).toLocaleString()}

Payment Method: COD ✅
━━━━━━━━━━━━━━━━━━━━━
Thank you for using PRINTFLOW!
    `;

    // Send via WhatsApp (Twilio)
    const whatsappService = require('./whatsapp.service');
    await whatsappService.sendMessage(user.phone, message);
  }

  /**
   * Driver settlement - end of day cash remittance
   */
  async driverSettlement(driverId, amountRemitted, proofPhotoUrl) {
    const driver = await prisma.driver.findUnique({
      where: { id: driverId }
    });

    if (!driver) throw new Error('Driver not found');

    const newBalance = driver.currentBalance - amountRemitted;
    
    if (newBalance < 0) {
      throw new Error(`Cannot remit more than current balance. Current: ${driver.currentBalance}`);
    }

    const updated = await prisma.driver.update({
      where: { id: driverId },
      data: {
        currentBalance: newBalance
      }
    });

    // Log settlement
    await prisma.driverShift.updateMany({
      where: { driverId, endTime: null },
      data: {
        endTime: new Date()
      }
    });

    await NotificationService.send(driver.userId, {
      title: 'Settlement Berhasil',
      body: `Setoran ${amountRemitted} berhasil. Sisa saldo: ${newBalance}`,
      data: { type: 'settlement' }
    });

    return updated;
  }

  /**
   * Track order with real-time location
   */
  async trackOrder(orderId, userId) {
    const order = await prisma.order.findUnique({
      where: { id: orderId },
      include: {
        driver: {
          include: { user: true }
        },
        hubPoint: true
      }
    });

    if (!order || order.userId !== userId) {
      throw new Error('Order not found');
    }

    // Get driver real-time location
    let driverLocation = null;
    if (order.driver && order.status === 'IN_TRANSIT') {
      driverLocation = {
        lat: order.driver.currentLat,
        lng: order.driver.currentLng,
        updatedAt: new Date()
      };
    }

    // Predict ETA using AI
    let predictedETA = null;
    if (driverLocation && order.deliveryAddress) {
      const eta = await AIService.calculateETA(
        { lat: driverLocation.lat, lng: driverLocation.lng },
        order.deliveryAddress
      );
      predictedETA = eta;
    }

    return {
      order: {
        id: order.id,
        orderNumber: order.orderNumber,
        status: order.status,
        totalAmount: order.totalAmount
      },
      driver: order.driver ? {
        name: order.driver.user.fullName,
        phone: order.driver.user.phone,
        vehiclePlate: order.driver.vehiclePlate,
        rating: order.driver.rating,
        location: driverLocation
      } : null,
      hubPoint: order.hubPoint,
      estimatedETA: predictedETA,
      timeline: this.getOrderTimeline(order)
    };
  }

  getOrderTimeline(order) {
    const timeline = [];
    
    if (order.createdAt) {
      timeline.push({
        status: 'Pesanan Dibuat',
        timestamp: order.createdAt,
        completed: true
      });
    }
    
    if (order.paymentStatus === 'SUCCESS' || order.paymentMethod === 'COD') {
      timeline.push({
        status: order.paymentMethod === 'COD' ? 'Menunggu COD' : 'Pembayaran Diterima',
        timestamp: order.paidAt || order.createdAt,
        completed: true
      });
    }
    
    if (order.processingAt) {
      timeline.push({
        status: 'Sedang Diproses',
        timestamp: order.processingAt,
        completed: true
      });
    }
    
    if (order.readyAt) {
      timeline.push({
        status: 'Siap Diambil',
        timestamp: order.readyAt,
        completed: true
      });
    }
    
    if (order.pickedUpAt) {
      timeline.push({
        status: 'Diambil Driver',
        timestamp: order.pickedUpAt,
        completed: true
      });
    }
    
    if (order.deliveredAt) {
      timeline.push({
        status: 'Telah Sampai',
        timestamp: order.deliveredAt,
        completed: true
      });
    }
    
    if (order.completedAt) {
      timeline.push({
        status: 'Pesanan Selesai',
        timestamp: order.completedAt,
        completed: true
      });
    }
    
    return timeline;
  }

  async findBestDriver(drivers, order) {
    if (drivers.length === 0) return null;
    
    // Calculate score for each driver based on:
    // 1. Distance to pickup location
    // 2. Rating
    // 3. Current load (deliveries in progress)
    // 4. Shift duration remaining
    
    const scoredDrivers = await Promise.all(drivers.map(async driver => {
      let score = 100;
      
      // Distance penalty (closer = better)
      if (driver.currentLat && driver.currentLng && order.pickupAddress) {
        const distance = AIService.calculateDistance(
          { lat: driver.currentLat, lng: driver.currentLng },
          order.pickupAddress
        );
        score -= Math.min(50, distance * 10);
      }
      
      // Rating bonus
      score += (driver.rating - 4) * 10;
      
      // Current deliveries load
      const activeDeliveries = await prisma.delivery.count({
        where: {
          driverId: driver.id,
          status: { in: ['PICKED_UP', 'IN_TRANSIT'] }
        }
      });
      score -= activeDeliveries * 5;
      
      return { driver, score };
    }));
    
    scoredDrivers.sort((a, b) => b.score - a.score);
    return scoredDrivers[0].driver;
  }

  async calculateDeliveryFee(address) {
    // Implement delivery fee calculation based on distance
    // For now, return base fee
    return 10000;
  }

  async downloadFile(fileUrl) {
    // Implement file download from S3
    return Buffer.from(''); // Placeholder
  }

  async uploadFile(buffer) {
    // Implement file upload to S3
    return 'https://example.com/file.pdf'; // Placeholder
  }

  async notifyAdminsForCOD(order) {
    const admins = await prisma.user.findMany({
      where: { role: 'ADMIN' }
    });
    
    for (const admin of admins) {
      await NotificationService.send(admin.id, {
        title: 'COD Order Created',
        body: `Order #${order.orderNumber} requires COD verification`,
        data: { orderId: order.id, type: 'cod_order' }
      });
    }
  }
}

module.exports = new OrderService();