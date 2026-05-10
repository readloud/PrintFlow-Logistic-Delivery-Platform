provider "aws" {
  region = "ap-southeast-1" # Singapore
}

# ECR Repository
resource "aws_ecr_repository" "printflow_backend" {
  name = "printflow-backend"
}

resource "aws_ecr_repository" "printflow_frontend" {
  name = "printflow-frontend"
}

# RDS PostgreSQL
resource "aws_db_instance" "printflow_db" {
  identifier     = "printflow-db"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.medium"
  allocated_storage = 100
  
  db_name  = "printflow"
  username = "printflow"
  password = random_password.db_password.result
  
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = 7
  backup_window = "03:00-04:00"
  maintenance_window = "mon:04:00-mon:05:00"
  
  skip_final_snapshot = false
}

# ElastiCache Redis (for Socket.io)
resource "aws_elasticache_cluster" "printflow_redis" {
  cluster_id = "printflow-redis"
  engine = "redis"
  node_type = "cache.t3.micro"
  num_cache_nodes = 1
  parameter_group_name = "default.redis7"
  port = 6379
  security_group_ids = [aws_security_group.redis.id]
}

# ECS Cluster
resource "aws_ecs_cluster" "printflow_cluster" {
  name = "printflow-cluster"
}

# ECS Task Definition - Backend
resource "aws_ecs_task_definition" "printflow_backend" {
  family = "printflow-backend"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "512"
  memory = "1024"
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn = aws_iam_role.ecs_task.arn
  
  container_definitions = jsonencode([{
    name = "printflow-backend"
    image = "${aws_ecr_repository.printflow_backend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      protocol = "tcp"
    }]
    environment = [
      { name = "DATABASE_URL", value = "postgresql://printflow:${random_password.db_password.result}@${aws_db_instance.printflow_db.address}:5432/printflow" }
    ]
    secrets = [
      { name = "JWT_SECRET", valueFrom = aws_secretsmanager_secret.jwt_secret.arn }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group" = "/ecs/printflow-backend"
        "awslogs-region" = "ap-southeast-1"
        "awslogs-stream-prefix" = "backend"
      }
    }
  }])
}

# Application Load Balancer
resource "aws_lb" "printflow_alb" {
  name = "printflow-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "backend_tg" {
  name = "printflow-backend-tg"
  port = 3000
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  health_check {
    enabled = true
    path = "/health"
    interval = 30
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.printflow_alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.printflow_cert.arn
  
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# S3 Bucket for File Storage
resource "aws_s3_bucket" "printflow_uploads" {
  bucket = "printflow-uploads-${random_id.bucket_suffix.hex}"
  
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = ["https://*.printflow.com"]
    max_age_seconds = 3000
  }
}

# CloudFront CDN
resource "aws_cloudfront_distribution" "printflow_cdn" {
  origin {
    domain_name = aws_s3_bucket.printflow_uploads.bucket_regional_domain_name
    origin_id = "S3Uploads"
  }
  
  enabled = true
  default_root_object = "index.html"
  
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "S3Uploads"
    
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 86400
    max_ttl = 31536000
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.printflow_cert.arn
    ssl_support_method = "sni-only"
  }
}