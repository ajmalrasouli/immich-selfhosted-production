🗄️ scripts/db-backup.sh
#!/bin/bash
# Immich PostgreSQL Backup Script

set -e

BACKUP_ROOT="/mnt/synology_photos/backups/immich"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_FILE="$BACKUP_ROOT/immich-db-$TIMESTAMP.sql"

echo "Starting Immich database backup..."

mkdir -p "$BACKUP_ROOT"

docker exec immich_postgres \
  pg_dump -U immich immich \
  > "$BACKUP_FILE"

echo "Backup completed:"
echo "  $BACKUP_FILE"

# Retention: keep last 14 days
find "$BACKUP_ROOT" -type f -mtime +14 -name "*.sql" -delete

echo "Old backups cleaned up."


Make executable:

chmod +x scripts/db-backup.sh