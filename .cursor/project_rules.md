# ChamaPlus — Cursor Project Rules

**Version:** 1.0  
**Project:** ChamaPlus — Mobile Decision Support System for Informal Savings Groups

---

## Project context

ChamaPlus digitizes informal savings groups (Chamas) in Kenya. The system provides contribution management, loan administration, committee voting, financial reporting, and transparent credit scoring for loan decision support.

**Stack:** Flutter (mobile) + Django REST Framework (API) + MySQL

---

## Mandatory reading before implementation

Always read before making decisions:

1. `Docs/MASTER_PROJECT_SPEC.md` — product and technical specification
2. `Docs/API_SPEC.md` — REST API contract
3. `Docs/CODING_STANDARDS.md` — coding conventions
4. `Docs/PERMISSIONS.md` — RBAC rules
5. `Docs/IMPLEMENTATION_PLAYBOOK.md` — sprint workflow

---

## Hard rules

1. **Never generate business logic in views** — use services
2. **Never hardcode business rules** — use constants, settings, or env vars
3. **Never skip the API envelope** — all responses: `{ success, message, data }`
4. **Never use integer primary keys** — UUID only
5. **Never implement modules outside the current sprint scope**
6. **Never commit secrets** — use `.env`
7. **Never duplicate code** — extract to `core` or shared utilities
8. **Always validate input** — serializers + service checks
9. **Always add OpenAPI annotations** — `@extend_schema` on views
10. **Always add unit tests** for new services and endpoints

---

## Architecture

```
Flutter → REST API (/api/v1/) → DRF Views → Services → [Repositories] → MySQL
```

- Chama-scoped tenancy: most data under `/chamas/{chama_id}/`
- JWT authentication (phone + password)
- RBAC via membership roles

---

## Implemented modules

- Authentication & users (phone-based JWT)
- Roles (catalog)
- Chamas & memberships

## Not yet implemented

- Contributions, loans, governance, credit scoring, reports, notifications, audit, dashboard

---

## Sprint order

Follow `Docs/IMPLEMENTATION_PLAYBOOK.md` development order. Do not skip ahead.

---

## Documentation updates

When implementing a feature, update:

- `Docs/API_SPEC.md` — mark endpoints as Implemented
- `Docs/PERMISSIONS.md` — if RBAC changes
- `Docs/IMPLEMENTATION_PLAYBOOK.md` — sprint status

---

## References

- `.cursor/coding_standards.md` — quick coding reference
- `.cursor/workflow.md` — step-by-step implementation workflow
- `Docs/adr/` — architecture decision records
