#!/bin/bash
# scripts/backup.sh

BACKUP_DIR="/backups/printflow"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup PostgreSQL
PGPASSWORD=$DB_PASSWORD pg_dump -h localhost -U printflow printflow > $BACKUP_DIR/db_$DATE.sql

# Backup uploads
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz /var/www/printflow/backend/uploads/

# Backup Redis
redis-cli SAVE
cp /var/lib/redis/dump.rdb $BACKUP_DIR/redis_$DATE.rdb

# Upload to S3
aws s3 sync $BACKUP_DIR s3://printflow-backups/$DATE/

# Delete old backups (keep 30 days)
find $BACKUP_DIR -type f -mtime +30 -delete