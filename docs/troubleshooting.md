🧪 docs/troubleshooting.md

# Troubleshooting Guide

This document lists common operational issues encountered in a self-hosted
Immich deployment and provides recommended investigation and resolution steps.

The focus is on **safe diagnosis**, **minimal disruption**, and **repeatable fixes**.

---

## 🟥 Immich Web UI Not Loading

**Symptoms**
- Browser shows connection error
- Port 2283 not responding
- Containers appear to be running

**Checks**
```bash
docker ps
docker logs immich_server


Common causes

Port conflict on host

Database not ready

Redis unavailable

Resolution

Verify port 2283 is free

Check PostgreSQL health

Restart dependent services if required

🟥 Uploads Fail or Stall

Symptoms

Upload progress stuck

Files do not appear in library

Checks

docker logs immich_server
df -h


Common causes

NAS mount unavailable or read-only

Insufficient disk space

Permission issues on upload directory

Resolution

Verify NAS is mounted correctly

Confirm write permissions

Ensure sufficient free space

🟥 Machine Learning Features Not Working

Symptoms

Face recognition not available

Search results incomplete

No ML-related logs

Checks

docker ps
docker logs immich_machine_learning


Common causes

ML container not running

Insufficient CPU resources

Misconfigured ML service URL

Resolution

Restart ML container

Reduce concurrent workloads

Verify IMMICH_MACHINE_LEARNING_URL

🟥 High CPU Usage

Symptoms

System fans running constantly

Slow UI responses

Checks

docker stats


Common causes

Large ML indexing backlog

Initial face recognition pass

Limited CPU resources

Resolution

Allow initial processing to complete

Schedule heavy processing off-peak

Temporarily stop ML service if required

🟥 PostgreSQL Container Restarting

Symptoms

Immich fails to start

Database container restarts repeatedly

Checks

docker logs immich_postgres
df -h


Common causes

Disk full

Corrupted database volume

Incorrect database credentials

Resolution

Free disk space

Restore from last known good backup

Verify .env credentials

🟥 Redis Connection Errors

Symptoms

Errors related to Redis in logs

Sluggish UI behaviour

Checks

docker logs immich_redis


Common causes

Redis container not running

Host memory pressure

Resolution

Restart Redis container

Verify available system memory

🧹 Disk Space Issues

Symptoms

Containers stop unexpectedly

Database errors

Upload failures

Checks

df -h
docker system df


Resolution

Ensure Docker data resides on SSD

Remove unused images

Clean up old backups

🟢 General Debugging Tips

Always check logs first

Verify storage mounts before restarting services

Avoid deleting Docker volumes without backups

Use incremental changes during troubleshooting

Prefer restart of individual services over full stack

📌 When in Doubt

Stop containers safely

Verify storage and disk health

Review logs carefully

Restore from backup if required

This approach minimises risk and downtime.