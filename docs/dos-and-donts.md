📄 docs/dos-and-donts.md

# Do’s and Don’ts

Operational guidelines for running Immich reliably in production.

---

## ✅ DO

- Store photos and videos on NAS
- Keep PostgreSQL and Redis on SSD
- Monitor disk usage regularly
- Backup the database frequently
- Allow ML jobs to complete during initial indexing
- Test upgrades in a controlled manner

---

## ❌ DON’T

- Store database files on NAS
- Run Docker using the root filesystem
- Commit `.env` files to Git
- Interrupt database writes abruptly
- Enable unnecessary services
- Ignore disk space warnings

---

## ⚠️ Operational Advice

- Initial ML indexing is CPU-intensive — this is normal
- Performance stabilises after first full scan
- Prefer targeted container restarts over full stack restarts
- Keep backups outside the host filesystem