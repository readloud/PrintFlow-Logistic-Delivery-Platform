const OrderService = require('../services/order.service');
const AIService = require('../services/ai.service');

exports.createOrder = async (req, res) => {
  try {
    const order = await OrderService.createOrder(req.user.id, req.body);
    res.status(201).json({
      success: true,
      data: order,
      message: 'Pesanan berhasil dibuat'
    });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.processOrder = async (req, res) => {
  try {
    const order = await OrderService.processOrder(req.params.id, req.user.id);
    res.json({ success: true, data: order });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.requestPickup = async (req, res) => {
  try {
    const { sealedPhotoUrl } = req.body;
    const order = await OrderService.requestPickup(req.params.id, req.user.id, sealedPhotoUrl);
    res.json({ success: true, data: order });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.startDelivery = async (req, res) => {
  try {
    const { startPhotoUrl } = req.body;
    const delivery = await OrderService.startDelivery(req.params.deliveryId, req.user.driverId, startPhotoUrl);
    res.json({ success: true, data: delivery });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.completeDelivery = async (req, res) => {
  try {
    const { codReceived, deliveryPhotoUrl } = req.body;
    const result = await OrderService.completeDelivery(
      req.params.deliveryId,
      req.user.driverId,
      codReceived,
      deliveryPhotoUrl
    );
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.driverSettlement = async (req, res) => {
  try {
    const { amountRemitted, proofPhotoUrl } = req.body;
    const driver = await OrderService.driverSettlement(req.user.driverId, amountRemitted, proofPhotoUrl);
    res.json({ success: true, data: driver });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.trackOrder = async (req, res) => {
  try {
    const tracking = await OrderService.trackOrder(req.params.id, req.user.id);
    res.json({ success: true, data: tracking });
  } catch (error) {
    res.status(404).json({ success: false, error: error.message });
  }
};

exports.validateFile = async (req, res) => {
  try {
    const file = req.file;
    const validation = await AIService.validatePrintQuality(file.buffer);
    
    let upscaled = null;
    if (!validation.isValid && validation.score < 70) {
      upscaled = await AIService.upscaleImage(file.buffer);
    }
    
    res.json({
      success: true,
      data: {
        validation,
        upscaled: upscaled ? {
          performed: true,
          fileUrl: upscaled.buffer ? 'Upload first' : null
        } : null
      }
    });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};

exports.ocrDocument = async (req, res) => {
  try {
    const { documentType } = req.body;
    const file = req.file;
    const result = await AIService.extractText(file.buffer, documentType);
    res.json({ success: true, data: result });
  } catch (error) {
    res.status(400).json({ success: false, error: error.message });
  }
};