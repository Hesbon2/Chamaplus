# ChamaPlus Implementation Playbook

**Version:** 1.0  
**Status:** Active  
**Aligned with:** `MASTER_PROJECT_SPEC.md`

---

## 1. Purpose

This playbook guides engineers through implementing ChamaPlus features sprint by sprint. It translates the master specification into a repeatable delivery process for both Django and Flutter teams.

---

## 2. Development order

Per `MASTER_PROJECT_SPEC.md`:

| Sprint | Module | Status |
|--------|--------|--------|
| 1a | Backend foundation | ✅ Complete |
| 1b | Authentication & users | ✅ Complete |
| 2 | Roles | ✅ Complete |
| 3 | Chamas & memberships | ✅ Complete |
| 4 | Contribution cycles & contributions | Planned |
| 5 | Loan products, applications, repayments | Planned |
| 6 | Meetings, attendance, committee voting | Planned |
| 7 | Credit scoring | Planned |
| 8 | Reports | Planned |
| 9 | Notifications | Planned |
| 10 | Dashboard | Planned |
| — | Audit logs (cross-cutting) | Planned — wire early |

**Note:** Meetings and attendance should be built before credit scoring (attendance = 15% of score).

---

## 3. Sprint workflow

### Phase 1 — Design (before coding)

1. Read `MASTER_PROJECT_SPEC.md` and `API_SPEC.md`
2. Confirm endpoints, models, and permissions for the sprint
3. Update `API_SPEC.md` if the contract changes
4. Update `PERMISSIONS.md` for new RBAC rules
5. Get review approval before implementation

### Phase 2 — Backend implementation

Follow this order for each module:

```
1. Models + constants
2. Migrations
3. Serializers (validation only)
4. Services (business logic)
5. Permissions
6. Views (class-based, thin)
7. URLs (register under /api/v1/)
8. Admin registration
9. OpenAPI annotations (@extend_schema)
10. Unit tests
```

### Phase 3 — Verification

```powershell
cd Backend
.\.venv\Scripts\python manage.py check
.\.venv\Scripts\python manage.py migrate
.\.venv\Scripts\pytest apps/<module>/tests/ -v
.\.venv\Scripts\python manage.py runserver
# Verify at http://127.0.0.1:8000/api/docs/
```

### Phase 4 — Flutter implementation (parallel or after backend)

```
1. Data models (freezed/json_serializable)
2. API service (Dio + envelope parsing)
3. Repository
4. Riverpod providers
5. UI screens and widgets
6. Widget tests / integration tests
```

### Phase 5 — Documentation and merge

1. Mark endpoints as **Implemented** in `API_SPEC.md`
2. Update this playbook sprint status
3. Create PR to `develop` via `feature/*` branch
4. Request code review using `CODING_STANDARDS.md` checklist

---

## 4. Backend module template

### 4.1 Create the app (if new)

```powershell
cd Backend
.\.venv\Scripts\python manage.py startapp <module> apps/<module>
```

Register in `chamaplus_backend/settings/base.py` → `LOCAL_APPS`.

### 4.2 Model example

```python
from apps.core.models import TimeStampedModel

class MyEntity(TimeStampedModel):
    chama = models.ForeignKey("chamas.Chama", on_delete=models.CASCADE)
    name = models.CharField(max_length=200)

    class Meta:
        db_table = "my_entities"
        ordering = ["-created_at"]
```

### 4.3 Service example

```python
class MyEntityService:
    @staticmethod
    def create(chama, user, validated_data):
        with transaction.atomic():
            # business logic here
            return MyEntity.objects.create(chama=chama, **validated_data)
```

### 4.4 View example

```python
class MyEntityCreateView(EnvelopeAPIView):
    permission_classes = [IsAuthenticated, IsChamaTreasurer]

    @extend_schema(tags=["MyModule"], summary="Create entity")
    def post(self, request, pk):
        serializer = MyEntityCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        chama = ChamaService.get_chama(pk)
        entity = MyEntityService.create(chama, request.user, serializer.validated_data)
        return success_response(
            data=MyEntitySerializer(entity).data,
            message="Entity created successfully.",
            status_code=status.HTTP_201_CREATED,
        )
```

### 4.5 URL registration

Add to `chamaplus_backend/api/v1/urls.py` or the app's `urls.py` included from there. Chama-scoped resources use nested paths:

```
/api/v1/chamas/{chama_id}/contributions/
```

---

## 5. Cross-cutting concerns

### 5.1 Standard response envelope

Always use `success_response()` / `error_response()` from `apps.core.responses`.

### 5.2 Domain errors

Raise `DomainError(message, status_code=400)` from services. The exception handler wraps it in the envelope.

### 5.3 Pagination

Use `StandardPagination` from `apps.core.pagination` for list endpoints. Return:

```json
{
  "success": true,
  "message": "...",
  "data": {
    "count": 0,
    "next": null,
    "previous": null,
    "results": []
  }
}
```

### 5.4 Kenyan phone numbers

Use `normalize_kenyan_phone_number()` from `apps.core.utils.validators` for any phone input.

### 5.5 Role seeding

Run after fresh database setup:

```powershell
.\.venv\Scripts\python manage.py seed_roles
```

### 5.6 Audit logging

When implementing write operations on financial or governance entities, call `AuditService.log()` (to be built in audit app). Log: actor, action, entity, changes, timestamp.

---

## 6. Sprint-specific guidance

### Sprint 4 — Contributions

- Models: `ContributionCycle`, `Contribution`
- Immutable contribution records (no hard delete; reversals in future)
- Treasurer records contributions; all members can view
- Idempotency key field on contributions (M-Pesa readiness)
- Cycles: `open` → `closed` state machine

### Sprint 5 — Loans

- Models: `LoanProduct`, `LoanApplication`, `Repayment`
- Application states: `pending` → `under_review` → `approved` / `rejected` → `disbursed` → `repaid` / `defaulted`
- Committee votes linked to applications
- Credit score attached as recommendation (read-only on application)

### Sprint 6 — Governance

- Models: `Meeting`, `Attendance`, `CommitteeVote`
- Attendance recorded by Secretary at meeting time
- Votes: `approve`, `reject`, `abstain`
- Meeting states: `scheduled` → `in_progress` → `completed`

### Sprint 7 — Credit scoring

- Model: `CreditScore` (historical snapshots)
- Service: `CreditScoringService` with configurable weights from settings
- Repository: `CreditScoreRepository` for cross-table aggregations
- Weights: consistency 35%, repayment 35%, attendance 15%, duration 15%
- Recalculate on: contribution recorded, repayment recorded, meeting closed

### Sprint 8 — Reports

- No new tables; aggregate via repository
- PDF export via reports generator
- Treasurer and Chairperson access only

### Sprint 9 — Notifications

- Model: `Notification`
- Event-driven: services publish events after key actions
- `NotificationService` creates in-app alerts
- User sees only own notifications

### Sprint 10 — Dashboard

- No new tables; aggregation endpoint
- `GET /api/v1/chamas/{id}/dashboard/`
- Combines: member count, active cycle, contributions, loans, next meeting, user summary

---

## 7. Environment setup

```powershell
# Prerequisites: Python 3.12+, XAMPP MySQL running

cd Backend
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
Copy-Item .env.example .env
.\.venv\Scripts\python manage.py migrate
.\.venv\Scripts\python manage.py seed_roles
.\.venv\Scripts\python manage.py runserver
```

---

## 8. Definition of done

A sprint module is **done** when:

- [ ] Models and migrations applied
- [ ] Services contain all business logic
- [ ] API endpoints match `API_SPEC.md`
- [ ] Permissions match `PERMISSIONS.md`
- [ ] OpenAPI docs render correctly in Swagger
- [ ] Unit tests pass (`pytest`)
- [ ] `manage.py check` reports no issues
- [ ] `API_SPEC.md` updated with **Implemented** status
- [ ] No scope creep into future modules

---

## 9. References

- `Docs/MASTER_PROJECT_SPEC.md`
- `Docs/API_SPEC.md`
- `Docs/CODING_STANDARDS.md`
- `Docs/PERMISSIONS.md`
- `Docs/TESTING_STRATEGY.md`
- `Docs/adr/` — architecture decision records
