#!/bin/bash

# Variables
DB_VOLUME_NAME="docker-compose-wordpress-nginx_db_data"
WP_VOLUME_NAME="docker-compose-wordpress-nginx_wp_data"
BACKUP_DIR="/home/ubuntu/backup"
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
DB_BACKUP_FILE="$BACKUP_DIR/db_backup_$TIMESTAMP.tar.gz"
WP_BACKUP_FILE="$BACKUP_DIR/wp_backup_$TIMESTAMP.tar.gz"
S3_BUCKET="s3://docker-compose-wordpress-nginx-backup"  #update your s3 bucket

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Create a backup of the db_data Docker volume
docker run --rm -v $DB_VOLUME_NAME:/volume -v $BACKUP_DIR:/backup alpine \
    sh -c "tar czf /backup/db_backup_$TIMESTAMP.tar.gz -C /volume ."

# Create a backup of the wp_data Docker volume
docker run --rm -v $WP_VOLUME_NAME:/volume -v $BACKUP_DIR:/backup alpine \
    sh -c "tar czf /backup/wp_backup_$TIMESTAMP.tar.gz -C /volume ."

# Upload the backups to S3
aws s3 cp $DB_BACKUP_FILE $S3_BUCKET
aws s3 cp $WP_BACKUP_FILE $S3_BUCKET

# Optional: Delete old backups (e.g., older than 30 days)
find $BACKUP_DIR -type f -mtime +30 -name '*.tar.gz' -exec rm {} \;

echo "Backup completed and uploaded to S3"
