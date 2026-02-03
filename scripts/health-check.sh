🧪 scripts/health-check.sh
#!/bin/bash
# Immich Health Check Script

echo "=== DISK USAGE (above 80%) ==="
df -h | awk '$5+0 > 80 {print $0}'

echo
echo "=== DOCKER CONTAINERS ==="
docker ps --format "table {{.Names}}\t{{.Status}}"

echo
echo "=== DOCKER RESOURCE USAGE ==="
docker stats --no-stream