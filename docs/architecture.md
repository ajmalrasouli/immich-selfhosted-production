🧱 docs/architecture.md



\# Immich – Architecture Overview



This document describes the \*\*system architecture\*\* of the Immich deployment

used in this repository, including service roles, data flow, and storage

decisions.



The architecture is designed for \*\*large personal photo/video libraries\*\*

with modern features such as machine learning–based search and face recognition,

while remaining reliable and easy to operate.



---



\## 🎯 Design Goals



\- Store large photo/video libraries on NAS

\- Keep metadata and indexes fast and reliable

\- Isolate machine-learning workloads

\- Avoid root filesystem exhaustion

\- Support safe upgrades and recovery

\- Maintain clear separation of responsibilities



---



\## 🧩 High-Level Architecture







┌─────────────────────────┐

│ Client │

│ Web / Mobile App │

└─────────────┬───────────┘

│ HTTP

▼

┌─────────────────────────┐

│ Immich Server │

│ API + Web Interface │

└─────────────┬───────────┘

│

┌───────┼────────┬──────────┐

│ │ │ │

▼ ▼ ▼ ▼

┌────────┐ ┌────────┐ ┌──────────┐

│ Redis │ │ ML │ │ PostgreSQL│

│ Cache │ │ Service│ │ Database │

└────────┘ └────────┘ └──────────┘

│

▼

┌──────────────────┐

│ NAS Storage │

│ Photos \& Videos │

└──────────────────┘





---



\## 🐳 Container Responsibilities



\### Immich Server

\- Serves web UI and API

\- Handles uploads and metadata operations

\- Coordinates background tasks

\- Reads and writes media files on NAS

\- Communicates with ML service for analysis



\### Machine Learning Service

\- Performs face recognition

\- Generates embeddings

\- Supports semantic search features

\- CPU-intensive workload

\- Stateless (rebuildable)



\### PostgreSQL

\- Stores metadata and indexes

\- User accounts and permissions

\- Face recognition metadata

\- Album and search data



\### Redis

\- Caching layer

\- Background task coordination

\- Improves responsiveness



---



\## 💾 Storage Architecture







Local Host

├── / (Root filesystem)

│ └── OS only (kept minimal)

│

├── /mnt/docker (M.2 SSD)

│ ├── Docker runtime

│ ├── PostgreSQL data

│ ├── Redis data

│ └── Application cache

│

└── /mnt/synology\_photos (NAS via NFS)

└── Photos \& Videos





---



\## 📍 Key Storage Decisions



\- Media files are stored \*\*only on NAS\*\*

\- Databases and caches are stored \*\*only on SSD\*\*

\- Docker runtime is isolated from `/`

\- ML containers do not store persistent data



This ensures predictable performance and safe recovery.



---



\## 🔄 Data Flow



\### Media Upload





Client → Immich Server → NAS

→ PostgreSQL (metadata)





\### Media Browsing





Client → Immich Server → NAS (read)





\### Machine Learning Processing





Immich Server → ML Service → PostgreSQL





\### Search \& Face Recognition





Client → Immich Server → PostgreSQL

→ ML Service (when required)





---



\## 🛡️ Fault Tolerance \& Recovery



\### NAS Unavailable

\- Application remains online

\- Media access fails gracefully

\- No metadata corruption



\### Database Restart

\- Immich Server reconnects automatically

\- No manual intervention required



\### ML Service Failure

\- Core application remains usable

\- ML features temporarily unavailable

\- Service can be restarted independently



---



\## 🔐 Security Considerations



\- Secrets stored in `.env` only

\- `.env` excluded from version control

\- No credentials committed

\- NAS mounted with restricted permissions



---



\## 🧪 Observability



\- Docker health checks for core services

\- `docker stats` for resource monitoring

\- Disk usage monitored at host level

\- Logs available via Docker logging



---



\## 📌 Why This Architecture Works Well



✔ Scales media storage independently of compute  

✔ Keeps metadata operations fast  

✔ Isolates ML workloads  

✔ Prevents root disk exhaustion  

✔ Simplifies rebuilds and upgrades  



This design prioritises \*\*operational clarity and reliability\*\* over complexity.



---



\## 🧠 Future Enhancements



\- GPU-accelerated ML workloads

\- Prometheus \& Grafana monitoring

\- Object storage backends

\- Read-only replica support



---



\## 📄 Summary



This architecture reflects a \*\*production-first approach\*\* to self-hosting Immich,

balancing modern features with maintainability and operational safety.



It is suitable for:

\- Personal photo libraries

\- Home servers

\- Small teams

\- Portfolio demonstration of real-world DevOps skills



