const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authMiddleware, partnerMiddleware } = require('../middleware/auth');
const { sendEReceiptWhatsApp } = require('../services/whatsapp.service');
const router = express.Router();
const prisma = new PrismaClient();

// Get dashboard data
router.get('/dashboard', authMiddleware, partnerMiddleware, async (req, res) => {
  const partner = req.partner;
  
  const [queueCount, processingCount, completedCount, printers, queueOrders] = await Promise.all([
    prisma.order.count({ where: { deliveryStatus: 'PENDING', partnerId: partner.id } }),
    prisma.order.count({ where: { deliveryStatus: 'PROCESSING', partnerId: partner.id } }),
    prisma.order.count({ where: { deliveryStatus: 'DELIVERED', partnerId: partner.id } }),
    prisma.printer.findMany({ where: { partnerId: partner.id } }),
    prisma.order.findMany({
      where: { deliveryStatus: { in: ['PENDING', 'PROCESSING'] }, partnerId: partner.id },
      include: { user: true },
      orderBy: { createdAt: 'asc' },
      take: 20
    })
  ]);
  
  res.json({
    queueCount,
    processingCount,
    completedCount,
    printers,
    queueOrders
  });
});

// Update order status
router.put('/orders/:orderId/status', authMiddleware, partnerMiddleware, async (req, res) => {
  const { status } = req.body; // PENDING, PROCESSING, READY
  const order = await prisma.order.update({
    where: { id: req.params.orderId, partnerId: req.partner.id },
    data: { deliveryStatus: status }
  });
  
  // Notify via socket
  const io = req.app.get('io');
  io.to(`order:${order.id}`).emit('order:status-update', {
    orderId: order.id,
    status,
    message: `Pesanan sedang ${status === 'PROCESSING' ? 'diproses' : 'siap diambil'}`
  });
  
  res.json(order);
});

// Request pickup from driver
router.post('/request-pickup', authMiddleware, partnerMiddleware, async (req, res) => {
  const { orderIds } = req.body;
  
  // Find nearest available driver
  const availableDriver = await prisma.driver.findFirst({
    where: { status: 'ACTIVE', currentLat: { not: null } },
    orderBy: { createdAt: 'asc' }
  });
  
  if (!availableDriver) {
    return res.status(404).json({ error: 'No available drivers' });
  }
  
  // Assign driver to orders
  await prisma.order.updateMany({
    where: { id: { in: orderIds } },
    data: {
      driverId: availableDriver.id,
      deliveryStatus: 'PICKED_UP'
    }
  });
  
  // Notify driver via socket
  const io = req.app.get('io');
  io.to(`driver:${availableDriver.id}`).emit('driver:new-pickup', {
    orderIds,
    partnerId: req.partner.id,
    pickupLocation: req.partner.address
  });
  
  res.json({ success: true, driverId: availableDriver.id });
});

// Stock management
router.get('/stock', authMiddleware, partnerMiddleware, async (req, res) => {
  const stock = await prisma.stock.findMany({
    where: { partnerId: req.partner.id }
  });
  res.json(stock);
});

router.put('/stock', authMiddleware, partnerMiddleware, async (req, res) => {
  const { items } = req.body;
  
  for (const item of items) {
    await prisma.stock.upsert({
      where: { id: item.id || 'none' },
      update: { quantity: item.quantity },
      create: {
        partnerId: req.partner.id,
        name: item.name,
        type: item.type,
        quantity: item.quantity,
        minThreshold: item.minThreshold
      }
    });
  }
  
  res.json({ success: true });
});

// Generate report
router.get('/reports/daily', authMiddleware, partnerMiddleware, async (req, res) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const orders = await prisma.order.findMany({
    where: {
      partnerId: req.partner.id,
      createdAt: { gte: today }
    }
  });
  
  const totalRevenue = orders.reduce((sum, o) => sum + o.totalPrice, 0);
  const totalOrders = orders.length;
  
  res.json({
    date: today,
    totalRevenue,
    totalOrders,
    averageOrderValue: totalOrders > 0 ? totalRevenue / totalOrders : 0,
    orders
  });
});

// Print document via connected printer
router.post('/print/:orderId', authMiddleware, partnerMiddleware, async (req, res) => {
  const order = await prisma.order.findUnique({
    where: { id: req.params.orderId }
  });
  
  // Generate PDF for printing
  const pdfDoc = await generatePrintPDF(order);
  
  // Send to printer (ESC/POS or network printer)
  const printResult = await sendToPrinter(pdfDoc, req.body.printerId);
  
  await prisma.order.update({
    where: { id: order.id },
    data: { printedAt: new Date(), printedBy: req.user.id }
  });
  
  res.json({ success: true, printResult });
});

module.exports = router;