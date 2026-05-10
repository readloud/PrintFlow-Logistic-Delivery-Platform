# PrintFlow - Logistic Delivery Platform [Master Plan]

PrintFlow is a comprehensive logistics and delivery platform connecting customers, drivers, partners, and administrators.

## 🚀 Features

- **Multi-Platform Support**: Web dashboard, customer app, driver app, partner app
- **Real-time Tracking**: Live order tracking with WebSocket
- **AI Integration**: Route optimization, fraud detection, demand forecasting
- **Payment Gateway**: Midtrans integration with multiple payment methods
- **Email Marketing**: SES integration for campaigns and notifications
- **Secure Authentication**: JWT with Cognito and passkey support
- **Scalable Architecture**: Microservices ready with Kubernetes support

### ✅ **Fitur COD/NON COD Complete:**
- Verifikasi COD dengan input jumlah uang
- E-Receipt via WhatsApp otomatis
- Settlement driver end-of-day
- Fraud detection untuk COD

### ✅ **AI Integration:**
- Image Upscaler & Denoising
- Print Quality Validator
- OCR untuk ekstraksi dokumen
- Face recognition untuk driver/partner
- Photo Quality Control
- Route Optimization dengan real-time traffic
- Demand forecasting
- Fraud detection

### ✅ **Alur Logistik Hybrid:**
- Pickup request system
- Driver assignment dengan AI matching
- Real-time tracking
- Hub points untuk sekolah/kantor
- Multiple delivery optimization

### ✅ **Security:**
- reCAPTCHA untuk signup
- Face verification untuk shift driver
- Sealed bag photo requirement
- Photo QC untuk bukti delivery

## 📋 Prerequisites

- Node.js 18+
- PostgreSQL 15+
- Redis 7+
- Flutter 3.0+ (for mobile apps)
- Docker & Kubernetes (for production)

## 🛠️ Installation

### Backend Setup

```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your configuration
npx prisma migrate dev
npm run seed
npm run dev
```

### Frontend Web Setup

```bash
cd frontend-web
npm install
cp .env.example .env
npm run dev
```

### Mobile Apps Setup

```bash
# Customer App
cd mobile-user
flutter pub get
flutter run

# Driver App
cd mobile-driver
flutter pub get
flutter run

# Partner App
cd mobile-partner
flutter pub get
flutter run
```

## 🐳 Docker Deployment

```bash
docker-compose up -d
```

## ☸️ Kubernetes Deployment

```bash
cd infrastructure/kubernetes
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f secrets.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

## 📊 Architecture

- **Backend**: Express.js + Prisma + PostgreSQL
- **Cache**: Redis for rate limiting and session storage
- **Queue**: Bull for background jobs
- **Real-time**: Socket.io for live updates
- **Storage**: AWS S3 for file uploads
- **Email**: AWS SES for email campaigns
- **Auth**: AWS Cognito + JWT
- **Container**: Docker + Kubernetes (EKS)
- **CI/CD**: GitHub Actions

## 🔒 Environment Variables

See `.env.example` for all required environment variables.

## 📝 API Documentation

After running the server, visit:
- Swagger UI: `http://localhost:3000/api-docs`
- Postman Collection: `/docs/api/postman_collection.json`

## 🧪 Testing

```bash
# Backend
cd backend
npm test

# Frontend
cd frontend-web
npm test
```

## 📈 Monitoring

- **Logs**: Winston logger with rotation
- **Metrics**: Prometheus + Grafana (optional)
- **Errors**: Sentry integration

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👥 Support

For support, email support@printflow.com or join our Slack channel.
```
