# Run all tests
cd backend && npm run test:coverage
cd frontend-web && npm run test

# Check security vulnerabilities
npm audit
snyk test

# Performance testing
artillery run load-test.yml

# Check all services
curl https://api.printflow.com/health
curl https://printflow.com
redis-cli ping
psql -d printflow -c "SELECT 1"

# Start PM2 Web
pm2 web

# Monitor logs
pm2 logs
docker-compose logs --tail=100