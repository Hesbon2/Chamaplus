# ChamaPlus Testing Strategy

**Version:** 1.0  
**Status:** Active  
**Aligned with:** `MASTER_PROJECT_SPEC.md`

---

## 1. Purpose

This document defines how ChamaPlus is tested across backend, frontend, and API layers. The goal is reliable, maintainable test coverage that supports the spec's non-functional requirements: fast, secure, reliable, maintainable, and scalable.

---

## 2. Testing pyramid

```
                    ┌─────────────┐
                    │    E2E /    │  Few — critical user journeys
                    │  Manual API │
                    ├─────────────┤
                    │ Integration │  API endpoint tests, DB tests
                    │    tests    │
                    ├─────────────┤
                    │    Unit     │  Services, validators, serializers
                    │    tests    │  Most tests live here
                    └─────────────┘
```

| Layer | Tool | Scope |
|-------|------|-------|
| **Unit** | pytest, Flutter Test | Services, validators, models, widgets |
| **Integration** | pytest-django, APIClient | HTTP endpoints with database |
| **API manual** | Postman, Swagger UI | Exploratory and contract verification |
| **E2E** | Future — integration_test (Flutter) | Full user flows against running backend |

---

## 3. Backend testing (pytest)

### 3.1 Configuration

| File | Purpose |
|------|---------|
| `Backend/pytest.ini` | Django settings module, test paths |
| `Backend/apps/conftest.py` | Shared fixtures (users, auth clients, roles, chamas) |
| `Backend/apps/<module>/tests/` | Per-module test suites |

### 3.2 Running tests

```powershell
cd Backend

# All tests
.\.venv\Scripts\pytest -v

# Single module
.\.venv\Scripts\pytest apps/accounts/tests/ -v
.\.venv\Scripts\pytest apps/chamas/tests/ apps/memberships/tests/ -v

# Single test class or method
.\.venv\Scripts\pytest apps/accounts/tests/test_auth.py::TestLogin::test_login_success -v

# With coverage (when pytest-cov is added)
.\.venv\Scripts\pytest --cov=apps --cov-report=term-missing
```

### 3.3 What to test

| Component | Test focus |
|-----------|------------|
| **Validators** | Kenyan phone normalization, edge cases, invalid input |
| **Services** | Business rules, state transitions, `DomainError` cases |
| **Serializers** | Field validation, password match, uniqueness |
| **Views / API** | Status codes, envelope shape, permissions, happy path + errors |
| **Permissions** | Allowed and denied access per role |

### 3.4 What not to test

- Django framework internals
- Third-party library behaviour (JWT library itself)
- Trivial getters with no logic
- Migrations (unless data migration with complex logic)

### 3.5 Test structure conventions

```python
@pytest.mark.django_db
class TestChamaCreate:
    def test_create_chama_success(self, auth_client, roles):
        response = auth_client.post(CHAMAS_URL, payload, format="json")
        assert response.status_code == 201
        assert response.data["success"] is True
        assert response.data["data"]["name"] == payload["name"]
```

**Naming:** `test_<action>_<expected_outcome>`

### 3.6 Fixtures

Shared fixtures live in `apps/conftest.py`:

| Fixture | Provides |
|---------|----------|
| `roles` | Seeded role catalog |
| `chairperson_user` | User with phone `+254712345678` |
| `member_user` | Second test user |
| `auth_client` | APIClient with chairperson JWT |
| `member_client` | APIClient with member JWT |
| `chama` | Created test Chama |

Module-specific fixtures extend these in `apps/<module>/tests/conftest.py`.

### 3.7 Database handling

- pytest-django uses `@pytest.mark.django_db` for tests needing the database
- Each test runs in a transaction rolled back after completion (default)
- Use `django_db_reset_sequences` only when testing auto-increment behaviour (not applicable for UUID PKs)

### 3.8 Assertion standards

Always assert:

1. **HTTP status code**
2. **Envelope `success` field**
3. **Envelope `message`** (when relevant)
4. **Envelope `data` shape and values**
5. **Database state** (when side effects matter)

```python
assert response.status_code == 400
assert response.data["success"] is False
assert "phone_number" in response.data["data"]
```

---

## 4. Frontend testing (Flutter)

### 4.1 Tools

| Tool | Purpose |
|------|---------|
| `flutter test` | Unit and widget tests |
| `mockito` / `mocktail` | Mock repositories and API clients |
| `integration_test` | Future E2E tests |

### 4.2 What to test

| Layer | Focus |
|-------|-------|
| **Models** | JSON serialization/deserialization (snake_case ↔ camelCase) |
| **Repositories** | Envelope parsing, error mapping |
| **Providers** | State transitions (Riverpod) |
| **Widgets** | Rendering, form validation, user interaction |
| **Screens** | Navigation, loading/error states |

### 4.3 Running tests

```bash
flutter test
flutter test test/features/auth/login_screen_test.dart
```

### 4.4 Conventions

- Mirror backend validation rules in client-side form validators
- Mock Dio responses using the standard envelope shape
- Test both `success: true` and `success: false` paths

---

## 5. API testing (manual)

### 5.1 Swagger UI

Interactive testing at `http://127.0.0.1:8000/api/docs/`:

1. Authenticate via login endpoint
2. Copy access token
3. Authorize with `Bearer <token>`
4. Execute endpoints and verify responses

### 5.2 Postman

Recommended collections:

| Collection | Contents |
|------------|----------|
| **Auth** | Register, login, refresh, logout, profile |
| **Chamas** | CRUD, invite, join, members |
| **Per sprint** | New module endpoints as implemented |

Store environment variables:

- `base_url`: `http://127.0.0.1:8000/api/v1`
- `access_token`: from login response `data.access`
- `refresh_token`: from login response `data.refresh`

### 5.3 Contract verification

After each sprint, verify:

- Response matches `{ success, message, data }` envelope
- Field names are `snake_case`
- UUIDs are valid v4 format
- Timestamps include timezone offset (`+0300` for Africa/Nairobi)
- Error responses return correct HTTP status codes

---

## 6. Test data conventions

| Entity | Test value |
|--------|------------|
| Phone (chairperson) | `0712345678` → `+254712345678` |
| Phone (member) | `0798765432` → `+254798765432` |
| Password | `SecurePass123` |
| Chama name | `Kileleshwa Women Chama` |
| Currency | `KES` |

Use `seed_roles` management command before tests requiring the role catalog.

---

## 7. Coverage targets

| Area | Target | Priority |
|------|--------|----------|
| Services | ≥ 90% | High |
| Views / API endpoints | ≥ 80% | High |
| Serializers | ≥ 80% | Medium |
| Permissions | 100% of rules | High |
| Flutter repositories | ≥ 80% | Medium |
| Flutter widgets (critical paths) | ≥ 70% | Medium |

Coverage is a guide, not a goal. Prioritise tests that protect business rules and security.

---

## 8. CI recommendations (future)

When CI is configured:

```yaml
# Example pipeline steps
- pip install -r requirements.txt
- python manage.py check
- pytest --tb=short
- flutter test
```

Block merge on:

- `manage.py check` failures
- Test failures
- Lint errors (when configured)

---

## 9. Current test inventory

| Module | Test file | Tests |
|--------|-----------|-------|
| Accounts | `apps/accounts/tests/test_auth.py` | 16 |
| Chamas | `apps/chamas/tests/test_chamas.py` | 8 |
| Memberships | `apps/memberships/tests/test_memberships.py` | 8 |
| **Total** | | **32** |

---

## 10. References

- `Docs/CODING_STANDARDS.md` — code conventions
- `Docs/IMPLEMENTATION_PLAYBOOK.md` — when to write tests in a sprint
- `Docs/API_SPEC.md` — expected request/response shapes
- `Backend/pytest.ini` — pytest configuration
