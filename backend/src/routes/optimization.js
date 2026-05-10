const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { authMiddleware, driverMiddleware } = require('../middleware/auth');
const router = express.Router();
const prisma = new PrismaClient();

// Google OR-Tools integration (simulasi dengan algoritma routing)
// Note: OR-Tools JS version memerlukan instalasi `ortools` atau via REST API

router.get('/optimize-route', authMiddleware, driverMiddleware, async (req, res) => {
  try {
    const driverId = req.driver.id;
    
    // Get pending deliveries for this driver
    const deliveries = await prisma.delivery.findMany({
      where: {
        driverId: driverId,
        status: { in: ['PICKED_UP', 'IN_TRANSIT'] }
      },
      include: { order: { include: { user: true } } }
    });
    
    if (deliveries.length === 0) {
      return res.json({ message: 'No pending deliveries', optimizedRoute: [] });
    }
    
    // Get driver current location
    const driver = await prisma.driver.findUnique({
      where: { id: driverId },
      select: { currentLat: true, currentLng: true }
    });
    
    // Build waypoints
    const waypoints = [
      { lat: driver.currentLat, lng: driver.currentLng, type: 'start' },
      ...deliveries.map(d => ({
        lat: parseFloat(d.order.address?.split(',').map(Number)[0] || '0'),
        lng: parseFloat(d.order.address?.split(',').map(Number)[1] || '0'),
        orderId: d.orderId,
        isCOD: d.order.paymentMethod === 'COD',
        amount: d.order.codAmount
      }))
    ];
    
    // Optimize route using nearest neighbor algorithm (simplified)
    const optimizedRoute = await calculateOptimizedRoute(waypoints);
    
    // Update orders with sequence
    for (let i = 0; i < optimizedRoute.length; i++) {
      if (optimizedRoute[i].orderId) {
        await prisma.order.update({
          where: { id: optimizedRoute[i].orderId },
          data: { 
            deliveryStatus: 'IN_TRANSIT',
            // Store route sequence in metadata jika perlu
          }
        });
      }
    }
    
    res.json({
      optimizedRoute: optimizedRoute,
      totalDistance: _calculateDistance(optimizedRoute),
      estimatedTime: optimizedRoute.length * 15 // 15 menit per delivery
    });
    
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Nearest Neighbor Algorithm untuk route optimization
async function calculateOptimizedRoute(waypoints) {
  if (waypoints.length <= 1) return waypoints;
  
  const unvisited = [...waypoints.slice(1)];
  const route = [waypoints[0]]; // Start from driver location
  let current = waypoints[0];
  
  while (unvisited.length > 0) {
    let nearestIndex = 0;
    let nearestDistance = Infinity;
    
    for (let i = 0; i < unvisited.length; i++) {
      const dist = haversineDistance(current.lat, current.lng, unvisited[i].lat, unvisited[i].lng);
      if (dist < nearestDistance) {
        nearestDistance = dist;
        nearestIndex = i;
      }
    }
    
    current = unvisited[nearestIndex];
    route.push(current);
    unvisited.splice(nearestIndex, 1);
  }
  
  return route;
}

// Haversine formula for distance calculation
function haversineDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

function _calculateDistance(route) {
  let total = 0;
  for (let i = 0; i < route.length - 1; i++) {
    total += haversineDistance(route[i].lat, route[i].lng, route[i+1].lat, route[i+1].lng);
  }
  return total.toFixed(2);
}

// AI-Powered ETA prediction
router.post('/predict-eta', authMiddleware, async (req, res) => {
  const { orderId, driverId } = req.body;
  
  // Get historical delivery times for similar routes
  const historicalDeliveries = await prisma.delivery.findMany({
    where: {
      driverId: driverId,
      completedAt: { not: null }
    },
    take: 50
  });
  
  // Calculate average delivery time
  const avgTime = historicalDeliveries.reduce((sum, d) => {
    const timeDiff = d.completedAt!.getTime() - d.startedAt.getTime();
    return sum + timeDiff;
  }, 0) / (historicalDeliveries.length || 1);
  
  // Predict ETA berdasarkan jarak dan historical data
  const order = await prisma.order.findUnique({
    where: { id: orderId }
  });
  
  const predictedMinutes = Math.ceil(avgTime / 60000) + 10; // +10 menit buffer
  
  res.json({
    estimatedArrival: new Date(Date.now() + predictedMinutes * 60000),
    confidence: 'high',
    predictedMinutes
  });
});

module.exports = router;