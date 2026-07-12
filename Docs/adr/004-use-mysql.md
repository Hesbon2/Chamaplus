# ADR 004: Use MySQL as the Database

**Status:** Accepted  
**Date:** 2026-07  
**Deciders:** ChamaPlus engineering team

---

## Context

ChamaPlus stores relational data across 16 tables with foreign key relationships: users, roles, chamas, memberships, contributions, loans, votes, credit scores, and more. The system requires:

- ACID transactions for financial records (contributions, repayments)
- Referential integrity across Chama-scoped entities
- UUID primary keys on all tables
- utf8mb4 character set for full Unicode support
- Local development on XAMPP (Windows)

The master specification explicitly selects **MySQL**.

Candidates considered:

| Option | Pros | Cons |
|--------|------|------|
| **MySQL / MariaDB** | Spec-mandated, XAMPP default, mature | MariaDB version constraints with Django |
| **PostgreSQL** | Richer features, JSON support | Not in spec; team uses XAMPP |
| **SQLite** | Simple for dev | No production fit; weak concurrency |
| **MongoDB** | Flexible schema | Poor fit for relational financial data |

---

## Decision

We will use **MySQL** (via XAMPP MariaDB 10.4 in development) as the database for ChamaPlus.

Configuration:

| Setting | Source |
|---------|--------|
| Engine | `django.db.backends.mysql` |
| Driver | `mysqlclient` |
| Config | `django-environ` from `.env` |
| Charset | `utf8mb4` |
| SQL mode | `STRICT_TRANS_TABLES` |
| Timezone | `Africa/Nairobi` |
| Primary keys | UUID on all domain tables |

### Environment variables

```
DB_ENGINE=django.db.backends.mysql
DB_NAME=chamaplus_db
DB_USER=root
DB_PASSWORD=
DB_HOST=127.0.0.1
DB_PORT=3306
```

### Django version constraint

XAMPP ships MariaDB 10.4. Django 5.1+ requires MariaDB 10.5+. We pin **Django 5.0.x** for compatibility.

---

## Consequences

### Positive

- Aligns with master specification
- XAMPP provides zero-config local development on Windows
- MySQL handles relational financial data with proven ACID compliance
- `utf8mb4` supports Kenyan names and future internationalization
- Django migrations manage schema evolution

### Negative

- MariaDB 10.4 limits Django version upgrades until XAMPP is updated or MySQL 10.5+ is installed separately
- MySQL lacks some advanced PostgreSQL features (not needed for v1)
- Production hosting must provide managed MySQL with backups and replication

### Neutral

- Repository pattern (ADR 003) abstracts some query complexity; database remains swappable in theory but not planned
- Future M-Pesa integration stores payment references in existing tables, not a separate document store

---

## Data conventions

| Rule | Standard |
|------|----------|
| Table names | `snake_case` plural per spec (`users`, `chamas`, `memberships`) |
| Primary keys | `UUIDField` — never auto-increment integers |
| Foreign keys | `on_delete` chosen per relationship (PROTECT for financial, CASCADE for membership) |
| Soft delete | `is_active` flag on Chamas; financial records are immutable |
| Migrations | Committed with every model change; never edit applied migrations |

---

## Production considerations (future)

- Managed MySQL (e.g. AWS RDS, DigitalOcean) with automated backups
- Connection pooling for concurrent mobile users
- Read replicas if reporting queries impact write performance
- Migration to MariaDB 10.5+ or MySQL 8.0 to unlock Django 5.1+

---

## References

- `Docs/MASTER_PROJECT_SPEC.md` — Database, Technology Stack
- `Backend/chamaplus_backend/settings/base.py` — `DATABASES` configuration
- `Backend/.env.example` — database environment template
- ADR 001 — Django as ORM host
