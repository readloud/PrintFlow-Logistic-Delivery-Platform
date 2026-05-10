const express = require('express');
const router = express.Router();
const { protect, restrictTo } = require('../middleware/auth');
const upload = require('../middleware/upload');
const orderController = require('../controllers/order.controller');

// User routes
router.post('/', protect, upload.single('file'), orderController.createOrder);
router.get('/:id/track', protect, orderController.trackOrder);

// Admin routes
router.patch('/:id/process', protect, restrictTo('ADMIN'), orderController.processOrder);
router.post('/:id/pickup', protect, restrictTo('ADMIN'), orderController.requestPickup);

// Driver routes
router.post('/delivery/:deliveryId/start', protect, restrictTo('DRIVER'), orderController.startDelivery);
router.post('/delivery/:deliveryId/complete', protect, restrictTo('DRIVER'), orderController.completeDelivery);
router.post('/settlement', protect, restrictTo('DRIVER'), orderController.driverSettlement);

// AI routes
router.post('/validate-file', protect, upload.single('file'), orderController.validateFile);
router.post('/ocr', protect, upload.single('file'), orderController.ocrDocument);

module.exports = router;