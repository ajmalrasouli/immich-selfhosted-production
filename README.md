# Immich – Production Self-Hosted Deployment (NAS + SSD)

This repository documents a **production-grade Immich deployment** focused on reliability, performance, and clean storage separation. It is designed for large personal photo libraries and modern self-hosted environments.

[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🎯 Design Goals

- **NAS-backed photo and video storage** – Scalable, high-capacity media storage
- **SSD-backed database and cache** – Fast metadata operations and quick access
- **Machine-learning workloads isolated from storage** – Prevent I/O bottlenecks
- **Safe upgrades and recoverability** – Battle-tested migration paths
- **No secrets committed to source control** – Security-first approach

---

## 🧱 Architecture Overview

```
+---------------------------+
|     Client Browser        |
|  (Web / Mobile / Apps)    |
+-------------+-------------+
              |
              v
+---------------------------+
|     Immich Server         |
|   (API + Web + Nginx)     |
+-------------+-------------+
              |
      +-------+-------+-------+
      |               |       |
      v               v       v
+-----------+   +-------+   +----------------+
|   Redis   |   |  ML   |   |  PostgreSQL    |
| (Caching) |   | (AI)  |   |  (Metadata)    |
+-----------+   +-------+   +----------------+
      |               |             |
      +-------+-------+-------------+
              |
              v
+---------------------------+
|    NAS Storage (NFS)      |
|  Photos, Videos, Thumbs   |
+---------------------------+
```

### Core Services

| Service | Purpose | Dependencies |
|---------|---------|--------------|
| **Immich Server** | Web UI, API, photo serving | PostgreSQL, Redis |
| **PostgreSQL** | Metadata, user data, albums | - |
| **Redis** | Job queues, session caching | - |
| **Machine Learning** | Face recognition, smart search, CLIP | - |
| **Immich Proxy** | Reverse proxy (optional) | Immich Server |

All services are orchestrated using **Docker Compose**.

---

## 💾 Storage Layout (Critical Design Choice)

| Component | Location | Reason |
|-----------|----------|--------|
| Photos & Videos | NAS (NFS/SMB) | Large, persistent, scalable |
| Thumbnails | NAS (NFS/SMB) | Generated assets, persistent |
| PostgreSQL data | Local SSD (M.2) | Low-latency metadata queries |
| Redis data | Local SSD (M.2) | Fast job queue operations |
| Docker runtime | Local SSD (M.2) | Prevent root filesystem exhaustion |
| ML models/cache | Local SSD (M.2) | Fast inference operations |

> **Key principle:** Databases and Docker runtime stay on fast local storage. Only media files live on NAS.

---

## ⚙️ Getting Started

### Prerequisites

- Docker Engine 24.0+ and Docker Compose v2
- NAS with NFS or SMB share configured
- Local SSD for database (recommended: 50GB+)
- (Optional) GPU for ML acceleration

### 1️⃣ Clone repository

```bash
git clone https://github.com/<your-username>/immich-production-nas.git
cd immich-production-nas
```

### 2️⃣ Configure environment

```bash
cp .env.example .env
```

Edit `.env` and configure:
- Database credentials
- NAS mount paths
- Upload directories
- ML model settings
- Timezone and locale

### 3️⃣ Mount NAS storage

Ensure your NAS is mounted before starting services:

```bash
# Example NFS mount (adjust for your environment)
sudo mount -t nfs nas.local:/volume1/photos /mnt/nas/immich
```

Or configure via `/etc/fstab` for persistence.

### 4️⃣ Start services

```bash
docker compose up -d
```

Check service health:

```bash
docker compose ps
docker compose logs -f immich-server
```

### 5️⃣ Access Immich

Open your browser:

```
http://<host-ip>:2283
```

Create your admin account on first login.

---

## 📦 Data Management

### Backup Strategy

**What to backup:**
- PostgreSQL database (critical)
- `.env` configuration
- `docker-compose.yml`
- Photos/videos on NAS (handled by NAS backup)

**Backup commands:**

```bash
# Database backup
docker exec -t immich-postgres pg_dumpall -c -U postgres > backup_$(date +%Y%m%d).sql

# Restore database
cat backup_20240101.sql | docker exec -i immich-postgres psql -U postgres
```

### Migration from Existing Library

If you have an existing photo library:

1. Copy/move photos to NAS mount point
2. Use Immich's external library feature (scan existing directories)
3. Or use the bulk upload CLI tool

See: `docs/migration-guide.md` (if you create one)

---

## 🎛️ Machine Learning Configuration

### Face Recognition

Immich uses ML for face detection and recognition. This can be resource-intensive.

**Optimization options:**
- Disable face recognition if not needed
- Limit concurrent ML jobs in `.env`
- Use GPU acceleration for faster processing

### CLIP Search

Smart search uses CLIP models for natural language photo queries.

**Model storage:** Models are cached locally on SSD for performance.

---

## 🔐 Security & Secrets

### Environment Variables

- ✅ All secrets stored in `.env`
- ✅ `.env.example` provided as template
- ✅ `.env` is gitignored
- ✅ No credentials committed to version control

### Access Control

- Configure reverse proxy (Nginx/Traefik) for HTTPS
- Set strong database passwords
- Enable two-factor authentication in Immich settings
- Regularly update Docker images

### Network Security

- Bind services to `127.0.0.1` if using reverse proxy
- Use firewall rules to restrict access
- Consider VPN for external access

---

## 🛠️ Operational Best Practices

### Monitoring

- ✔ Monitor disk usage on both SSD and NAS
- ✔ Track database size growth
- ✔ Monitor ML job queue length
- ✔ Set up log rotation

### Maintenance

- ✔ Regular PostgreSQL vacuuming
- ✔ Periodic backup testing
- ✔ Keep Docker images updated
- ✔ Clean old thumbnails if needed

### Performance Tuning

- ✔ Increase PostgreSQL shared buffers for large libraries
- ✔ Tune Redis memory limits
- ✔ Adjust ML worker concurrency based on CPU/GPU
- ✔ Enable thumbnail generation on upload

---

## 🧪 Health & Observability

### Health Checks

Monitor service health:

```bash
./scripts/health-check.sh
```

### Logging

View service logs:

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f immich-server
docker compose logs -f immich-machine-learning
```

### Metrics (Optional)

Extend with:
- Prometheus for metrics collection
- Grafana for dashboards
- Alertmanager for notifications

---

## 🚀 Upgrade Process

### Safe Upgrade Steps

1. **Backup database** (always backup first!)
2. **Read release notes** for breaking changes
3. **Pull new images:**
   ```bash
   docker compose pull
   ```
4. **Stop services:**
   ```bash
   docker compose down
   ```
5. **Start with new images:**
   ```bash
   docker compose up -d
   ```
6. **Check logs:**
   ```bash
   docker compose logs -f
   ```

### Rollback

If issues occur:

```bash
# Stop services
docker compose down

# Edit docker-compose.yml to use previous image tags
# Then restart
docker compose up -d
```

---

## 📌 Skills Demonstrated

- **Docker & Docker Compose** – Multi-container orchestration
- **Linux storage architecture** – NFS/SMB integration, mount management
- **NAS integration** – Network storage for media files
- **PostgreSQL operations** – Database management, backups, tuning
- **Redis configuration** – Caching and job queue optimization
- **ML service orchestration** – Face recognition, CLIP search
- **Production documentation** – Clear, maintainable documentation
- **Security best practices** – Secrets management, access control
- **System monitoring** – Health checks, logging strategies

---

## 📚 Additional Resources

- [Official Immich Documentation](https://immich.app/docs/)
- [Immich GitHub Repository](https://github.com/immich-app/immich)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Tuning Guide](https://wiki.postgresql.org/wiki/Performance_Optimization)

---

## 🤝 Contributing

Contributions are welcome! Please:
- Fork the repository
- Create a feature branch
- Submit a pull request with clear description

---

## ⚠️ Disclaimer

This repository is provided as a **reference architecture** and showcase of production deployment practices. Adapt paths, configurations, and resource limits to match your specific environment and requirements.

**Not affiliated with Immich.** This is an independent deployment guide.

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 🙏 Acknowledgments

- **Immich Team** – For building an amazing open-source photo management solution
- **Community Contributors** – For sharing deployment experiences and best practices
