# ADR 003: Use a Service Layer for Business Logic

**Status:** Accepted  
**Date:** 2026-07  
**Deciders:** ChamaPlus engineering team

---

## Context

ChamaPlus has significant business logic: Chama lifecycle, membership invitations, contribution tracking, loan workflows, committee voting, and credit scoring. The master specification requires:

- Service Layer between API and data access
- Repository Layer where appropriate
- Business logic kept inside services
- No hardcoded business rules
- Class-based views

Without a clear layering discipline, logic tends to accumulate in views or serializers, making the system hard to test, reuse, and maintain.

---

## Decision

We adopt a **service layer** as the mandatory location for all business logic.

### Layer responsibilities

```
HTTP Request
    → View (thin: auth, permissions, envelope)
        → Serializer (input validation, output shape)
            → Service (business rules, orchestration, transactions)
                → Repository (complex queries only — optional)
                    → ORM Model (schema, simple CRUD)
```

| Layer | Responsibility | Example |
|-------|----------------|---------|
| **View** | HTTP, permissions, call service, return envelope | `ChamaListCreateView` |
| **Serializer** | Field validation, type coercion | `ChamaCreateSerializer` |
| **Service** | Business rules, transactions, state changes | `ChamaService.create_chama()` |
| **Repository** | Complex aggregations, cross-table reads | `CreditScoreRepository` (planned) |
| **Model** | Schema, constraints, simple properties | `Chama`, `Membership` |

### Service conventions

- One service per domain app: `auth_service.py`, `chama_service.py`, `membership_service.py`
- Static methods or small classes; no HTTP awareness
- Use `transaction.atomic()` for multi-step writes
- Raise `DomainError(message, status_code=...)` for business violations
- Return model instances or dicts — never `Response` objects

### Repository conventions

- Use **only where appropriate** (per spec)
- Apply to: credit scoring aggregations, financial reports, dashboard summaries
- Do **not** wrap simple CRUD that the ORM handles directly
- Place in `repositories/` under the relevant app

---

## Consequences

### Positive

- Business rules are testable without HTTP (pytest on services directly)
- Views remain thin and consistent across modules
- Logic is reusable (services callable from management commands, signals, future tasks)
- Clear separation makes code review straightforward
- Aligns with master spec coding rules

### Negative

- Additional files and indirection compared to a minimal DRF app
- Developers must resist putting logic in views or serializers
- Repository pattern adds complexity if over-applied

### Neutral

- Not a full Domain-Driven Design implementation; pragmatic layering for a small team
- Celery/async tasks (future) will call the same services

---

## Examples (implemented)

```python
# Service — business logic
class ChamaService:
    @staticmethod
    def create_chama(user, validated_data):
        with transaction.atomic():
            chama = Chama.objects.create(created_by=user, **validated_data)
            Membership.objects.create(user=user, chama=chama, role=chairperson_role, ...)
            return chama

# View — thin HTTP layer
class ChamaListCreateView(EnvelopeAPIView):
    def post(self, request):
        serializer = ChamaCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        chama = ChamaService.create_chama(request.user, serializer.validated_data)
        return success_response(data=ChamaSerializer(chama).data, ...)
```

---

## References

- `Docs/MASTER_PROJECT_SPEC.md` — Development Architecture, Coding Rules
- `Docs/CODING_STANDARDS.md` — Section 4.6 Services
- `Backend/apps/chamas/services/` — reference implementation
- `Backend/apps/memberships/services/` — reference implementation
- ADR 005 — Credit scoring service and repository
