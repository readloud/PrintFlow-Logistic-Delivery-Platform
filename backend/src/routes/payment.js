const express = require('express');
const crypto = require('crypto');
const axios = require('axios');
const { PrismaClient } = require('@prisma/client');
const { authMiddleware } = require('../middleware/auth');
const router = express.Router();
const prisma = new PrismaClient();

// Midtrans Configuration
const MIDTRANS_SERVER_KEY = process.env.MIDTRANS_SERVER_KEY;
const MIDTRANS_CLIENT_KEY = process.env.MIDTRANS_CLIENT_KEY;
const IS_PRODUCTION = process.env.NODE_ENV === 'production';
const API_URL = IS_PRODUCTION 
  ? 'https://app.midtrans.com/snap/v1/transactions'
  : 'https://app.sandbox.midtrans.com/snap/v1/transactions';

// Create Midtrans Transaction
router.post('/create-transaction', authMiddleware, async (req, res) => {
  try {
    const { orderId, paymentMethod } = req.body;
    
    const order = await prisma.order.findUnique({
      where: { id: orderId, userId: req.user.id },
      include: { user: true }
    });
    
    if (!order) return res.status(404).json({ error: 'Order not found' });
    
    const transactionDetails = {
      transaction_details: {
        order_id: `PRINTFLOW-${order.id}-${Date.now()}`,
        gross_amount: order.totalPrice
      },
      customer_details: {
        first_name: order.user.name,
        email: order.user.email,
        phone: order.user.phone
      },
      item_details: [
        {
          id: order.id,
          name: order.fileName,
          price: order.totalPrice,
          quantity: 1,
          category: 'Printing Service'
        }
      ],
      callbacks: {
        finish: 'https://printflow.com/payment/finish',
        error: 'https://printflow.com/payment/error',
        pending: 'https://printflow.com/payment/pending'
      },
      enabled_payments: paymentMethod === 'BANK_TRANSFER' 
        ? ['bca_va', 'bni_va', 'bri_va', 'mandiri_va']
        : paymentMethod === 'QRIS' 
          ? ['qris'] 
          : ['credit_card', 'gopay', 'shopeepay']
    };
    
    // Generate signature
    const signature = crypto
      .createHmac('sha512', MIDTRANS_SERVER_KEY)
      .update(`${transactionDetails.transaction_details.order_id}${transactionDetails.transaction_details.gross_amount}`)
      .digest('hex');
    
    const response = await axios.post(API_URL, transactionDetails, {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${Buffer.from(MIDTRANS_SERVER_KEY + ':').toString('base64')}`
      }
    });
    
    // Save transaction to database
    await prisma.paymentTransaction.create({
      data: {
        orderId: order.id,
        transactionId: response.data.transaction_id,
        orderIdMidtrans: transactionDetails.transaction_details.order_id,
        amount: order.totalPrice,
        status: 'PENDING',
        paymentMethod: paymentMethod,
        snapToken: response.data.token,
        snapUrl: response.data.redirect_url
      }
    });
    
    res.json({
      success: true,
      snapToken: response.data.token,
      snapUrl: response.data.redirect_url
    });
    
  } catch (error) {
    console.error('Midtrans error:', error.response?.data || error.message);
    res.status(500).json({ error: 'Failed to create payment transaction' });
  }
});

// Midtrans Webhook (Notification Handler)
router.post('/midtrans-webhook', async (req, res) => {
  try {
    const notification = req.body;
    
    // Verify signature
    const isValid = verifyMidtransSignature(notification);
    if (!isValid) return res.status(401).json({ error: 'Invalid signature' });
    
    const { order_id, transaction_status, fraud_status, payment_type, gross_amount } = notification;
    
    // Extract original order ID from PRINTFLOW-xxx-xxx format
    const originalOrderId = order_id.split('-')[1];
    
    // Update payment transaction
    await prisma.paymentTransaction.updateMany({
      where: { orderIdMidtrans: order_id },
      data: {
        status: transaction_status,
        paymentType: payment_type,
        updatedAt: new Date()
      }
    });
    
    // Update order payment status based on transaction status
    let paymentStatus = 'PENDING';
    let deliveryStatus = 'PENDING';
    
    if (transaction_status === 'capture') {
      if (fraud_status === 'accept') {
        paymentStatus = 'PAID';
        deliveryStatus = 'PROCESSING';
      }
    } else if (transaction_status === 'settlement') {
      paymentStatus = 'PAID';
      deliveryStatus = 'PROCESSING';
    } else if (transaction_status === 'pending') {
      paymentStatus = 'PENDING';
    } else if (transaction_status === 'deny' || transaction_status === 'cancel' || transaction_status === 'expire') {
      paymentStatus = 'FAILED';
      deliveryStatus = 'FAILED';
    }
    
    await prisma.order.update({
      where: { id: originalOrderId },
      data: {
        paymentStatus: paymentStatus,
        deliveryStatus: deliveryStatus,
        paymentMethod: payment_type?.toUpperCase() || 'TRANSFER'
      }
    });
    
    // Send notification to user via socket
    const io = req.app.get('io');
    io.to(`user:${originalOrderId}`).emit('payment:status-update', {
      orderId: originalOrderId,
      status: paymentStatus,
      message: getPaymentStatusMessage(transaction_status)
    });
    
    res.status(200).json({ message: 'OK' });
    
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Check transaction status
router.get('/transaction-status/:orderId', authMiddleware, async (req, res) => {
  const { orderId } = req.params;
  
  const transaction = await prisma.paymentTransaction.findFirst({
    where: { orderId: orderId },
    orderBy: { createdAt: 'desc' }
  });
  
  if (!transaction) return res.json({ status: 'NOT_FOUND' });
  
  res.json({
    status: transaction.status,
    snapUrl: transaction.snapUrl,
    amount: transaction.amount,
    paymentMethod: transaction.paymentMethod
  });
});

// Cancel transaction
router.post('/cancel-transaction/:orderId', authMiddleware, async (req, res) => {
  const { orderId } = req.params;
  
  const transaction = await prisma.paymentTransaction.findFirst({
    where: { orderId: orderId, status: 'PENDING' }
  });
  
  if (!transaction) return res.status(404).json({ error: 'Transaction not found' });
  
  const response = await axios.post(
    `https://api.sandbox.midtrans.com/v2/${transaction.orderIdMidtrans}/cancel`,
    {},
    {
      headers: {
        'Authorization': `Basic ${Buffer.from(MIDTRANS_SERVER_KEY + ':').toString('base64')}`
      }
    }
  );
  
  await prisma.paymentTransaction.update({
    where: { id: transaction.id },
    data: { status: 'CANCELLED' }
  });
  
  res.json({ success: true });
});

function verifyMidtransSignature(notification) {
  const signatureKey = crypto
    .createHmac('sha512', MIDTRANS_SERVER_KEY)
    .update(`${notification.order_id}${notification.status_code}${notification.gross_amount}`)
    .digest('hex');
  return signatureKey === notification.signature_key;
}

function getPaymentStatusMessage(status) {
  const messages = {
    'capture': 'Pembayaran berhasil diterima. Pesanan akan segera diproses.',
    'settlement': 'Pembayaran telah diverifikasi. Pesanan sedang diproses.',
    'pending': 'Menunggu pembayaran. Segera selesaikan pembayaran Anda.',
    'deny': 'Pembayaran ditolak. Silakan coba lagi.',
    'expire': 'Pembayaran kadaluwarsa. Silakan buat pesanan baru.',
    'cancel': 'Pembayaran dibatalkan.'
  };
  return messages[status] || 'Status pembayaran tidak diketahui';
}

module.exports = router;