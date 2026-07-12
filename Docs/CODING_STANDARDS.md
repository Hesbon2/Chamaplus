# ChamaPlus Coding Standards

**Version:** 1.0  
**Status:** Active  
**Aligned with:** `MASTER_PROJECT_SPEC.md`, `API_SPEC.md`

---

## 1. Purpose

This document defines coding conventions for the ChamaPlus project. All contributors — human and AI — must follow these standards to keep the codebase consistent, maintainable, and aligned with the master specification.

---

## 2. General Principles

From `MASTER_PROJECT_SPEC.md`:

| Rule | Requirement |
|------|-------------|
| No duplication | Extract shared logic; do not copy-paste |
| No hardcoded business rules | Use settings, constants, or configuration |
| Business logic in services | Views and serializers stay thin |
| Validate every request | Serializers + service-level checks |
| Document every API | OpenAPI annotations + `API_SPEC.md` |
| Readable code | Clear names, small functions, minimal nesting |
| Small functions | One responsibility per function or method |

---

## 3. Repository Structure

```
Chamaplus/
├── Backend/                    # Django REST API
│   ├── apps/
│   │   ├── core/               # Shared infrastructure
│   │   ├── accounts/           # Authentication & users
│   │   ├── roles/              # Role catalog
│   │   ├── chamas/             # Chama management
│   │   ├── memberships/        # Member–Chama links
│   │   └── ...                 # Future domain apps
│   └── chamaplus_backend/      # Project settings & URLs
├── Docs/                       # Project documentation
└── (Flutter app — future)
```

Each Django app follows this internal layout:

```
apps/<module>/
├── models/           # or models.py
├── serializers.py
├── views.py
├── urls.py
├── services/         # Business logic
├── permissions.py    # When RBAC is module-specific
├── constants.py      # Module-specific constants
├── admin.py
├── migrations/
└── tests/
```

---

## 4. Backend Standards (Django / DRF)

### 4.1 Language and style

- **Python:** PEP 8, 4-space indentation, max line length 88–100 characters
- **Imports:** Standard library → third party → local apps; grouped with blank lines
- **Type hints:** Encouraged on service methods and complex functions

### 4.2 Naming conventions

| Element | Convention | Example |
|---------|------------|---------|
| Variables, functions | `snake_case` | `create_chama`, `phone_number` |
| Classes | `PascalCase` | `ChamaService`, `RegisterView` |
| Constants | `UPPER_SNAKE_CASE` | `CHAIRPERSON`, `DEFAULT_CURRENCY` |
| Database tables | `snake_case` plural | `users`, `chamas`, `memberships` |
| URL paths | `kebab-case` or `snake_case` | `/api/v1/chamas/`, `/change-password/` |
| Files | `snake_case.py` | `auth_service.py`, `chama_service.py` |

### 4.3 Models

- All primary keys are **UUID v4** (`UUIDField`, non-editable)
- Extend `TimeStampedModel` from `apps.core.models` for domain entities
- Set explicit `db_table` matching the spec schema names
- Use `Meta.constraints` for uniqueness (e.g. one membership per user per Chama)
- Add `__str__` for admin and debugging
- Migrations must be committed with model changes

### 4.4 Serializers

- One serializer per use case when shapes differ (create, update, list, detail)
- Validation in serializers; business rules in services
- Use `read_only_fields` explicitly on output serializers
- Reuse shared fields (e.g. `KenyanPhoneField`) from `apps.core` or `accounts`

### 4.5 Views

- **Class-based views only** (`APIView` subclasses, typically `EnvelopeAPIView`)
- Views: authenticate → permission check → validate → call service → return envelope
- No ORM queries or business logic in views
- Decorate with `@extend_schema` for OpenAPI (tags, summary, request/response)

### 4.6 Services

- Static methods or small service classes in `services/<name>_service.py`
- Own transactions (`transaction.atomic()` for multi-step writes)
- Raise `DomainError` for business rule violations (not generic `Exception`)
- Return model instances or plain dicts; never HTTP responses

### 4.7 Repositories

- Use **only where appropriate** (spec): complex aggregations, reports, credit scoring
- Simple CRUD stays in services + ORM
- Place in `repositories/` under the relevant app

### 4.8 API responses

Every response uses the standard envelope:

```json
{
  "success": true,
  "message": "Human-readable summary.",
  "data": {}
}
```

Use `success_response()` and `error_response()` from `apps.core.responses`.

### 4.9 Authentication

- JWT via `djangorestframework-simplejwt`
- Default permission: `IsAuthenticated`
- Public endpoints must explicitly set `AllowAny`
- Phone number is the user identifier (`USERNAME_FIELD = "phone_number"`)

### 4.10 Configuration

- Secrets and environment-specific values in `.env` (never committed)
- Use `django-environ` in split settings: `base.py`, `development.py`, `production.py`
- Business tunables (e.g. credit score weights) via settings/env, not hardcoded

### 4.11 Error handling

- DRF validation errors → handled by `custom_exception_handler`
- `DomainError` → envelope with appropriate HTTP status
- Do not leak stack traces or internal details in production responses

---

## 5. Frontend Standards (Flutter)

### 5.1 Architecture

- **Feature-first** folder structure
- **Riverpod** for state management
- **Dio** for HTTP client
- **GoRouter** for navigation
- **Material Design 3** for UI

### 5.2 Naming conventions

| Element | Convention | Example |
|---------|------------|---------|
| Variables, functions | `camelCase` | `phoneNumber`, `fetchChamas` |
| Classes | `PascalCase` | `ChamaRepository`, `LoginScreen` |
| Constants | `UPPER_SNAKE_CASE` or `k` prefix | `kDefaultPageSize` |
| Files | `snake_case.dart` | `chama_list_screen.dart` |

### 5.3 API integration

- Parse the `{ success, message, data }` envelope
- Map JSON `snake_case` ↔ Dart `camelCase` (`@JsonSerializable(fieldRename: FieldRename.snake)`)
- Store JWT securely (`flutter_secure_storage`)
- Implement token refresh on 401

### 5.4 UI

- Reusable widgets in shared `widgets/` per feature or globally
- Form validation on client before API call (mirror server rules)
- Responsive layouts for varying screen sizes

---

## 6. Git and branching

Per `MASTER_PROJECT_SPEC.md`:

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code |
| `develop` | Integration branch |
| `feature/*` | New features |
| `release/*` | Release preparation |
| `hotfix/*` | Production fixes |

### Commit messages

- Use clear, imperative subject lines: `Add Chama invite endpoint`
- Reference module or sprint when helpful
- One logical change per commit when possible

---

## 7. Documentation requirements

When adding or changing behavior:

1. Update `Docs/API_SPEC.md` for new/changed endpoints
2. Update `Docs/PERMISSIONS.md` for RBAC changes
3. Add or update ADRs for architectural decisions
4. Add `@extend_schema` on new views
5. Add unit tests for services and API endpoints

---

## 8. Security checklist

- [ ] Passwords hashed (Django default PBKDF2)
- [ ] JWT access + refresh with rotation and blacklist on logout
- [ ] RBAC enforced at permission class and service layer
- [ ] Chama-scoped data filtered by membership
- [ ] No secrets in source control
- [ ] Audit logging for sensitive operations (when module exists)
- [ ] Input validation on all write endpoints

---

## 9. Code review checklist

- [ ] Business logic in services, not views
- [ ] UUID primary keys on new models
- [ ] Standard API envelope used
- [ ] Permissions applied correctly
- [ ] Tests added or updated
- [ ] OpenAPI annotations present
- [ ] No hardcoded business constants
- [ ] Migrations included
- [ ] Follows naming conventions

---

## 10. References

- `Docs/MASTER_PROJECT_SPEC.md` — product and technical specification
- `Docs/API_SPEC.md` — REST API contract
- `Docs/PERMISSIONS.md` — role-based access control
- `Docs/TESTING_STRATEGY.md` — testing approach
- `Docs/IMPLEMENTATION_PLAYBOOK.md` — sprint implementation guide
