# Build all images
docker-compose -f docker-compose.prod.yml build

# Run all services
docker-compose -f docker-compose.prod.yml up -d

# Check logs
docker-compose -f docker-compose.prod.yml logs -f

# Scale backend (3 instances)
docker-compose -f docker-compose.prod.yml up -d --scale backend=3