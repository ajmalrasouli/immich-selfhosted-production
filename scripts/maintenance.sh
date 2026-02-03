🛠️ scripts/maintenance.sh
#!/bin/bash
# Immich Maintenance Script
# Safe cleanup and inspection tasks

echo "Starting maintenance tasks..."

echo
echo "Pruning unused Docker images..."
docker image prune -f

echo
echo "Pruning unused Docker volumes (dangling only)..."
docker volume prune -f

echo
echo "Docker disk usage summary:"
docker system df

echo
echo "Maintenance complete."


⚠️ Safe by design:

No running containers affected

No named volumes removed