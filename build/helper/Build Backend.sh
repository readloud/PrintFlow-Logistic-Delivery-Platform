cd backend
npm install

# Install additional system dependencies
sudo apt-get install -y poppler-utils  # for PDF processing
sudo apt-get install -y tesseract-ocr  # for OCR
sudo apt-get install -y tesseract-ocr-ind  # Indonesian language

# Build TypeScript (if using TS)
npm run build

# Run tests
npm run test
npm run test:integration

# Start with PM2 (development)
pm2 start ecosystem.config.js
pm2 save
pm2 startup

# Create database
sudo -u postgres psql << EOF
CREATE DATABASE printflow;
CREATE USER printflow WITH PASSWORD 'your_strong_password';
GRANT ALL PRIVILEGES ON DATABASE printflow TO printflow;
EOF

# Run Prisma migrations
npx prisma migrate dev --name init
npx prisma generate

# Seed initial data
node prisma/seed.js

# Configure Redis for Socket.io
sudo nano /etc/redis/redis.conf
# Set: maxmemory 256mb
# Set: maxmemory-policy allkeys-lru

sudo systemctl restart redis