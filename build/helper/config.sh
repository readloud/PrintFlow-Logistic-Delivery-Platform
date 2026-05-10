# Initialize
npx prisma init

# Set DATABASE_URL in .env
DATABASE_URL="postgresql://user:password@localhost:5432/printflow"

# Run migration
npx prisma migrate dev --name init

# Generate Prisma Client
npx prisma generate

# Generate DH parameters
openssl dhparam -out /etc/nginx/dhparam.pem 2048

# Configure SSL in Nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
ssl_dhparam /etc/nginx/dhparam.pem;

# Push Docker images to ECR
aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-1.amazonaws.com

docker tag printflow-backend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-1.amazonaws.com/printflow-backend:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-southeast-1.amazonaws.com/printflow-backend:latest

# Update ECS service
aws ecs update-service --cluster printflow-cluster --service printflow-backend --force-new-deployment

cd deployment/terraform

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply infrastructure
terraform apply -auto-approve