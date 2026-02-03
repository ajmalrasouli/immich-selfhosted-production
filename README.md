📘 README.md (Immich-specific, polished)


# Immich – Production Self-Hosted Deployment (NAS + SSD)

This repository documents a **production-grade Immich deployment**
focused on reliability, performance, and clean storage separation.

It is designed for large personal photo libraries and modern
self-hosted environments.

---

## 🎯 Design Goals

- NAS-backed photo and video storage
- SSD-backed database and cache
- Machine-learning workloads isolated from storage
- Safe upgrades and recoverability
- No secrets committed to source control

---

## 🧱 Architecture Overview

- Immich Server (API + Web)
- PostgreSQL (metadata)
- Redis (caching & queues)
- Machine Learning service (face recognition, search)
- NAS storage for photos/videos

---

## 💾 Storage Layout

| Component | Location |
|--------|---------|
Photos & videos | NAS |
PostgreSQL data | SSD (M.2) |
Redis data | SSD |
Docker runtime | SSD |

---

## ⚙️ Getting Started

```bash
cp .env.example .env
docker compose up -d


Access Immich:

http://<host-ip>:2283

🔐 Security

Secrets stored in .env

.env.example provided

No credentials committed

Public-safe repository

🧠 Skills Demonstrated

Docker & Compose

Linux storage architecture

NAS integration

PostgreSQL operations

ML service orchestration

Production documentation