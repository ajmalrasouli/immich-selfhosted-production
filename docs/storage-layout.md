💾 docs/storage-layout.md

# Storage Layout

This document explains how storage is intentionally structured for the Immich
deployment to ensure **performance, reliability, and safe recovery**.

---

## 🎯 Design Objectives

- Keep the root filesystem clean and stable
- Use fast storage for databases and caches
- Store large, immutable media files on NAS
- Allow host rebuilds without data loss
- Minimise coupling between components

---

## 🗂️ Storage Overview



Local Host
├── / (Root filesystem)
│ └── Operating system only
│
├── /mnt/docker (M.2 SSD)
│ ├── Docker runtime data
│ ├── PostgreSQL database
│ ├── Redis data
│ └── Immich cache files
│
└── /mnt/synology_photos (NAS via NFS)
└── Photos and videos


---

## 📍 Component Placement

| Component | Location | Reason |
|--------|---------|-------|
OS | Root disk | Stability |
Docker runtime | SSD | Prevent root disk exhaustion |
PostgreSQL | SSD | Low latency, data integrity |
Redis | SSD | Fast queue & cache access |
Photo/video files | NAS | Large, persistent storage |

---

## ❌ What Is Deliberately Avoided

- Databases stored on NAS
- Docker data stored on `/`
- Media files stored on local disk
- Mixing cache and persistent media data

---

## 🧠 Why This Layout Works

✔ Predictable performance  
✔ Easy recovery and migration  
✔ Independent scaling of storage and compute  
✔ Reduced risk during disk failures  

This layout reflects **production best practices** for stateful applications.
