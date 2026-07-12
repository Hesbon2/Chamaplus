# ChamaPlus — Cursor Coding Standards (Quick Reference)

**Full document:** `Docs/CODING_STANDARDS.md`

---

## Backend (Django / DRF)

| Rule | Standard |
|------|----------|
| Naming | `snake_case` variables, `PascalCase` classes, `UPPER_CASE` constants |
| Primary keys | UUID v4 on all models |
| Views | Class-based only (`EnvelopeAPIView`); thin — no business logic |
| Logic | `services/<name>_service.py` |
| Validation | Serializers for input; `DomainError` for business rules |
| Responses | `success_response()` / `error_response()` envelope |
| Auth | JWT Bearer token; phone number login |
| Permissions | DRF permission classes per endpoint |
| OpenAPI | `@extend_schema(tags=[...], summary="...")` |
| Tests | pytest in `apps/<module>/tests/` |
| Settings | `django-environ`; split base/dev/production |

## Frontend (Flutter)

| Rule | Standard |
|------|----------|
| Naming | `camelCase` variables, `PascalCase` classes |
| Architecture | Feature-first |
| State | Riverpod |
| HTTP | Dio with envelope parsing |
| Navigation | GoRouter |
| UI | Material Design 3, reusable widgets |
| JSON | `fieldRename: FieldRename.snake` |

## File layout per Django app

```
apps/<module>/
├── models/
├── serializers.py
├── views.py
├── urls.py
├── services/
├── permissions.py
├── constants.py
├── admin.py
├── migrations/
└── tests/
```

## Git branches

`main` · `develop` · `feature/*` · `release/*` · `hotfix/*`

## Do not

- Put business logic in views or serializers
- Hardcode credit score weights, role names, or currency
- Return raw DRF responses without envelope
- Create integer PKs
- Skip tests for new endpoints
- Implement out-of-scope modules
