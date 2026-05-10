// Background Removal menggunakan OpenCV.js atau API eksternal
router.post('/remove-background', upload.single('image'), async (req, res) => {
  try {
    // Integrasi dengan remove.bg API atau OpenCV
    const formData = new FormData();
    formData.append('image_file', fs.createReadStream(req.file.path));
    formData.append('size', 'auto');
    
    const response = await axios.post('https://api.remove.bg/v1.0/removebg', formData, {
      headers: { 'X-Api-Key': process.env.REMOVE_BG_API_KEY, ...formData.getHeaders() },
      responseType: 'arraybuffer'
    });
    
    res.set('Content-Type', 'image/png');
    res.send(response.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// AI Demand Forecasting (Simple Moving Average)
router.get('/forecast-demand', authMiddleware, adminMiddleware, async (req, res) => {
  const orders = await prisma.order.findMany({
    where: { createdAt: { gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) } },
    select: { createdAt: true, pages: true }
  });
  
  // Group by day
  const dailyDemand = {};
  orders.forEach(order => {
    const day = order.createdAt.toISOString().split('T')[0];
    dailyDemand[day] = (dailyDemand[day] || 0) + order.pages;
  });
  
  // Calculate 7-day moving average
  const days = Object.keys(dailyDemand).sort();
  const forecast = {};
  for (let i = 7; i < days.length; i++) {
    const sum = days.slice(i-7, i).reduce((s, d) => s + dailyDemand[d], 0);
    forecast[days[i]] = sum / 7;
  }
  
  res.json({ demand: dailyDemand, forecast7day: forecast });
});