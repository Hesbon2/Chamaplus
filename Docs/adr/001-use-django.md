# ADR 001: Use Django with Django REST Framework

**Status:** Accepted  
**Date:** 2026-07  
**Deciders:** ChamaPlus engineering team

---

## Context

ChamaPlus requires a backend platform to serve a Flutter mobile client for informal savings groups in Kenya. The system must support:

- RESTful APIs with versioning and documentation
- Role-based access control across multiple Chamas
- Complex business logic (contributions, loans, voting, credit scoring)
- Relational data with 16+ tables and foreign key integrity
- Rapid, maintainable development by a small team

Candidates considered:

| Option | Pros | Cons |
|--------|------|------|
| **Django + DRF** | Mature ORM, admin, auth, large ecosystem | Heavier than micro-frameworks |
| **FastAPI** | Fast, modern, async | Less built-in admin/auth; team less familiar |
| **Node.js (Express/Nest)** | JS ecosystem | Weaker ORM for complex relational model |
| **Firebase/BaaS** | Fast prototype | Limited control, costly at scale, poor fit for RBAC |

The master specification (`MASTER_PROJECT_SPEC.md`) explicitly selects Django REST Framework.

---

## Decision

We will use **Django 5.0** with **Django REST Framework** as the backend framework for ChamaPlus.

Key configuration:

- Class-based API views
- Split settings (`base`, `development`, `production`)
- `django-environ` for configuration
- `drf-spectacular` for OpenAPI/Swagger documentation
- API versioning via URL prefix `/api/v1/`

---

## Consequences

### Positive

- Django ORM maps cleanly to the 16-table relational schema
- Built-in admin panel for development and platform administration
- Mature authentication, migration, and testing tooling
- DRF provides serializers, permissions, and pagination out of the box
- Large community and documentation for long-term maintainability
- Aligns with master spec and team tooling (Cursor AI, pytest)

### Negative

- Django is synchronous by default; high-concurrency async is not a priority for v1
- Framework overhead is higher than minimal API frameworks
- Django 5.1+ requires MariaDB 10.5+; XAMPP ships 10.4, so we pin Django 5.0.x

### Neutral

- Repository pattern is applied selectively (not Django's default pattern)
- Flutter team consumes JSON API only; backend framework is invisible to mobile client

---

## References

- `Docs/MASTER_PROJECT_SPEC.md` — Technology Stack, Backend Standards
- `Backend/chamaplus_backend/settings/` — project configuration
- ADR 003 — Service layer pattern on top of Django
