# Scale to production
docker-compose -f docker-compose.prod.yml up -d --scale backend=5

# Enable auto-scaling (AWS)
aws application-autoscaling register-scalable-target \
    --service-namespace ecs \
    --scalable-dimension ecs:service:DesiredCount \
    --resource-id service/printflow-cluster/printflow-backend \
    --min-capacity 2 --max-capacity 10

# Setup CloudWatch alarms
aws cloudwatch put-metric-alarm \
    --alarm-name "HighCPU" \
    --comparison-operator GreaterThanThreshold \
    --evaluation-periods 2 \
    --metric-name CPUUtilization \
    --namespace AWS/ECS \
    --period 300 \
    --statistic Average \
    --threshold 70 \
    --alarm-actions arn:aws:sns:region:account:auto-scaling