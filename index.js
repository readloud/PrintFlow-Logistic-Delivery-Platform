const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const { PrismaClient } = require('@prisma/client');
const http = require('http');
const socketio = require('socket.io');
const authRoutes = require('./routes/auth');
const orderRoutes = require('./routes/orders');
const driverRoutes = require('./routes/drivers');
const adminRoutes = require('./routes/admin');
const aiRoutes = require('./routes/ai');

dotenv.config();
const app = express();
const server = http.createServer(app);
const io = socketio(server, { cors: { origin: '*' } });
const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/drivers', driverRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/ai', aiRoutes);

// Socket.io for realtime tracking
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  
  socket.on('driver-location', async (data) => {
    const { driverId, lat, lng } = data;
    await prisma.driver.update({
      where: { id: driverId },
      data: { currentLat: lat, currentLng: lng }
    });
    io.emit(`driver-${driverId}-location`, { lat, lng });
  });
  
  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});