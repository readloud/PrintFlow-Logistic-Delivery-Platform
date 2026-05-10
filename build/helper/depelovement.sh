# Development
npm run dev           # Start development server
npm run test          # Run tests
npm run lint          # Lint code

# Database
npx prisma studio     # Open Prisma Studio
npx prisma migrate dev --name migration_name
npx prisma db seed    # Seed database

# Docker
docker-compose up -d           # Start all services
docker-compose down            # Stop all services
docker-compose logs -f backend # View backend logs
docker exec -it backend sh     # Enter container

# PM2
pm2 list              # List all processes
pm2 logs printflow    # View logs
pm2 restart all       # Restart all
pm2 monit             # Monitoring

# Flutter
flutter clean         # Clean build
flutter pub get       # Get packages
flutter build apk --release  # Build APK
flutter run --release # Run release mode