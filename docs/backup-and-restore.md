💾 docs/backup-and-restore.md

# Backup & Restore Strategy

This document describes the **backup and restore strategy** for the Immich
deployment defined in this repository.

The objective is to enable **safe, predictable recovery** from:
- Host failure
- Database corruption
- Accidental deletion
- Upgrade or migration scenarios

The strategy intentionally keeps backups **simple, portable, and testable**.

---

## 🎯 What Needs to Be Backed Up

| Component | Backup Required | Reason |
|--------|----------------|-------|
PostgreSQL | ✅ Yes | Metadata, albums, face recognition data |
Redis | ❌ No | Ephemeral cache and queues |
Photos & videos | ❌ Separate | Already stored on NAS |
Docker images | ❌ No | Rebuildable |
ML artifacts | ❌ No | Regenerated automatically |

---

## 📁 Backup Locations

- **PostgreSQL backups** → NAS
- **Photos & videos** → NAS (managed independently)
- **Configuration & docs** → GitHub repository

---

## 🧠 Backup Philosophy

- Backups are **logical SQL dumps**, not raw volume copies
- Dumps are **portable across versions**
- Restore does not depend on Docker internals
- Backups can be inspected and verified manually

---

## 🗄️ PostgreSQL Backup

### Manual Backup

```bash
docker exec immich_postgres \
  pg_dump -U immich immich \
  > /mnt/synology_photos/backups/immich-db-$(date +%F).sql


This creates a full logical backup of Immich metadata.

Automated Backup Script

Example script:

scripts/db-backup.sh

#!/bin/bash
set -e

BACKUP_ROOT="/mnt/synology_photos/backups/immich"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
BACKUP_FILE="$BACKUP_ROOT/immich-db-$TIMESTAMP.sql"

mkdir -p "$BACKUP_ROOT"

docker exec immich_postgres \
  pg_dump -U immich immich \
  > "$BACKUP_FILE"

echo "Immich database backup created:"
echo "  $BACKUP_FILE"

# Optional retention (keep last 14 days)
find "$BACKUP_ROOT" -type f -mtime +14 -name "*.sql" -delete

Scheduled Backups (Cron)
crontab -e

0 3 * * * /path/to/immich-selfhosted-production/scripts/db-backup.sh


Runs nightly at 03:00.

🔁 Restore Procedure
1️⃣ Prepare clean database container
docker compose down
docker compose up -d postgres


Wait until PostgreSQL is healthy.

2️⃣ Restore database from backup
cat immich-backup.sql | \
docker exec -i immich_postgres psql -U immich immich

3️⃣ Start full stack
docker compose up -d


Immich will reconnect automatically and rebuild caches.

🧪 Verification After Restore

After restore, verify:

Immich UI loads correctly

Users and albums exist

Media listings are present

Random photos/videos open correctly

Face recognition data appears as expected

🚨 Disaster Recovery Scenarios
Full Host Rebuild

Reinstall OS

Install Docker

Clone repository

Mount NAS

Restore PostgreSQL backup

Start containers

Database Corruption

Stop Immich services

Restore last known good backup

Restart containers

⚠️ What Is NOT Backed Up (By Design)

Redis cache

Transcoded thumbnails

ML cache data

Docker images

These are regenerated automatically.

🛡️ Best Practices

✔ Test restore procedures periodically
✔ Keep multiple backup generations
✔ Store backups off the root filesystem
✔ Automate backups where possible
✔ Document restore steps clearly

📌 Summary

This backup and restore strategy ensures:

Fast recovery

Minimal complexity

Safe public documentation

Predictable behaviour during failures

It reflects a production-first operational mindset suitable for long-term
self-hosted deployments.