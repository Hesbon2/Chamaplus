# ChamaPlus — Cursor Workflow

**Full document:** `Docs/IMPLEMENTATION_PLAYBOOK.md`

---

## Before starting any task

1. Read `Docs/MASTER_PROJECT_SPEC.md`
2. Read relevant section of `Docs/API_SPEC.md`
3. Confirm the task is within the current sprint scope
4. Check `Docs/PERMISSIONS.md` for RBAC requirements

---

## Backend implementation steps

```
1. Models + constants
2. makemigrations + migrate
3. Serializers (validation)
4. Services (business logic)
5. Permissions
6. Views (class-based, thin)
7. URLs → api/v1 router
8. admin.py
9. @extend_schema annotations
10. Unit tests (pytest)
11. manage.py check
12. Update Docs/API_SPEC.md
```

---

## Commands

```powershell
cd Backend

# Environment
.\.venv\Scripts\pip install -r requirements.txt
Copy-Item .env.example .env

# Database
.\.venv\Scripts\python manage.py makemigrations <app>
.\.venv\Scripts\python manage.py migrate
.\.venv\Scripts\python manage.py seed_roles

# Verify
.\.venv\Scripts\python manage.py check
.\.venv\Scripts\pytest apps/<module>/tests/ -v
.\.venv\Scripts\python manage.py runserver

# API docs
# http://127.0.0.1:8000/api/docs/
```

---

## Sprint status

| Sprint | Module | Status |
|--------|--------|--------|
| 1 | Foundation + Auth | ✅ Done |
| 2 | Roles | ✅ Done |
| 3 | Chamas & Memberships | ✅ Done |
| 4 | Contributions | Next |
| 5 | Loans | Planned |
| 6 | Governance | Planned |
| 7 | Credit Scoring | Planned |
| 8 | Reports | Planned |
| 9 | Notifications | Planned |
| 10 | Dashboard | Planned |

---

## Definition of done

- [ ] Matches API_SPEC.md contract
- [ ] Permissions per PERMISSIONS.md
- [ ] Business logic in services only
- [ ] Tests pass
- [ ] OpenAPI docs correct
- [ ] API_SPEC.md updated
- [ ] No out-of-scope code

---

## When stuck

1. Re-read the master spec for the module
2. Check existing implemented modules (accounts, chamas) for patterns
3. Check ADRs in `Docs/adr/` for architectural decisions
4. Ask for clarification before inventing new patterns
