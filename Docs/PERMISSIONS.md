# ChamaPlus Permissions Reference

**Version:** 1.0  
**Status:** Active  
**Aligned with:** `MASTER_PROJECT_SPEC.md`, `API_SPEC.md`

---

## 1. Overview

ChamaPlus uses **role-based access control (RBAC)** with two scopes:

| Scope | Description |
|-------|-------------|
| **Platform** | System-wide access (`Administrator`) |
| **Chama** | Per-group access via `Membership` (all other roles) |

Permissions are enforced at:

1. **DRF permission classes** — HTTP layer
2. **Service layer** — business rule checks (defence in depth)
3. **Queryset filtering** — data scoped to user's Chamas

Authentication is required for all endpoints except register, login, and refresh.

---

## 2. Roles

### 2.1 Role catalog

| Slug | Name | Scope | Description |
|------|------|-------|-------------|
| `chairperson` | Chairperson | Chama | Leads the group; full Chama governance |
| `treasurer` | Treasurer | Chama | Manages contributions and financial records |
| `secretary` | Secretary | Chama | Meetings, records, member invitations |
| `committee_member` | Committee Member | Chama | Loan voting and committee decisions |
| `member` | Member | Chama | Regular participant |
| `administrator` | Administrator | Platform | System-wide administration |

**Rule:** `administrator` is a **platform role** (`is_platform_role=True`). It must never be assigned to a Chama membership.

### 2.2 Role assignment

- Roles are assigned via the `memberships` table (`user` + `chama` + `role`)
- A user may hold **one role per Chama** (one membership record per user per Chama)
- Role changes: Chairperson only (`PATCH /api/v1/memberships/{id}/role/`)

---

## 3. Membership statuses

| Status | Meaning | Can access Chama API? |
|--------|---------|----------------------|
| `pending` | Invited, not yet joined | No |
| `active` | Full member | Yes |
| `suspended` | Temporarily blocked | No |
| `left` | Departed the Chama | No |

Only **active** memberships grant API access to Chama-scoped resources.

---

## 4. Permission classes (implemented)

Defined in `apps.memberships.permissions`:

| Class | Check |
|-------|-------|
| `IsChamaMember` | User has `active` membership in the Chama |
| `IsChamaChairperson` | User has `active` membership with role `chairperson` |
| `IsChamaOfficial` | User has `active` membership with role `chairperson` or `secretary` |
| `IsMembershipChairperson` | User is Chairperson of the Chama linked to the membership being modified |

---

## 5. Endpoint permission matrix

### 5.1 Authentication & users

| Endpoint | Auth | Role / permission |
|----------|------|-------------------|
| `POST /api/v1/auth/register/` | None | Public |
| `POST /api/v1/auth/login/` | None | Public |
| `POST /api/v1/auth/refresh/` | None | Public |
| `POST /api/v1/auth/logout/` | JWT | Any authenticated user |
| `POST /api/v1/auth/change-password/` | JWT | Any authenticated user |
| `GET /api/v1/users/me/` | JWT | Any authenticated user |
| `PATCH /api/v1/users/me/` | JWT | Any authenticated user |

### 5.2 Roles

| Endpoint | Auth | Role / permission |
|----------|------|-------------------|
| `GET /api/v1/roles/` | JWT | Any authenticated user |

### 5.3 Chamas (implemented)

| Endpoint | Auth | Role / permission |
|----------|------|-------------------|
| `POST /api/v1/chamas/` | JWT | Any authenticated user |
| `GET /api/v1/chamas/` | JWT | Any authenticated user (own Chamas only) |
| `GET /api/v1/chamas/{id}/` | JWT | `IsChamaMember` |
| `PATCH /api/v1/chamas/{id}/` | JWT | `IsChamaChairperson` |
| `DELETE /api/v1/chamas/{id}/` | JWT | `IsChamaChairperson` |
| `POST /api/v1/chamas/{id}/invite/` | JWT | `IsChamaOfficial` |
| `POST /api/v1/chamas/join/` | JWT | Any authenticated user |
| `GET /api/v1/chamas/{id}/members/` | JWT | `IsChamaMember` |

### 5.4 Memberships (implemented)

| Endpoint | Auth | Role / permission |
|----------|------|-------------------|
| `PATCH /api/v1/memberships/{id}/role/` | JWT | `IsMembershipChairperson` |
| `PATCH /api/v1/memberships/{id}/status/` | JWT | `IsMembershipChairperson` |

---

## 6. Planned module permissions

The following matrix defines intended access for modules not yet implemented. Implement matching permission classes when building each sprint.

### 6.1 Contributions

| Action | Chairperson | Treasurer | Secretary | Committee | Member |
|--------|:-----------:|:---------:|:---------:|:---------:|:------:|
| View contributions | ✓ | ✓ | ✓ | ✓ | ✓ |
| Record contribution | — | ✓ | — | — | — |
| Manage cycles | ✓ | ✓ | — | — | — |

### 6.2 Loans

| Action | Chairperson | Treasurer | Secretary | Committee | Member |
|--------|:-----------:|:---------:|:---------:|:---------:|:------:|
| View loan products | ✓ | ✓ | ✓ | ✓ | ✓ |
| Manage loan products | ✓ | — | — | — | — |
| Submit application | — | — | — | — | ✓ |
| View applications | ✓ | ✓ | ✓ | ✓ | Own only |
| Approve / reject | — | — | — | ✓ | — |
| Record repayment | — | ✓ | — | — | — |

### 6.3 Governance (meetings, attendance, voting)

| Action | Chairperson | Treasurer | Secretary | Committee | Member |
|--------|:-----------:|:---------:|:---------:|:---------:|:------:|
| Manage meetings | ✓ | — | ✓ | — | — |
| Record attendance | — | — | ✓ | — | — |
| Cast committee vote | — | — | — | ✓ | — |

### 6.4 Credit scoring

| Action | Chairperson | Treasurer | Secretary | Committee | Member |
|--------|:-----------:|:---------:|:---------:|:---------:|:------:|
| View own score | ✓ | ✓ | ✓ | ✓ | ✓ |
| View member scores | ✓ | ✓ | ✓ | ✓ | — |
| Trigger recalculation | ✓ | ✓ | — | — | — |

**Important:** Credit scores are **advisory only**. Committee members retain final loan authority per spec.

### 6.5 Reports

| Action | Chairperson | Treasurer | Secretary | Committee | Member |
|--------|:-----------:|:---------:|:---------:|:---------:|:------:|
| View reports | ✓ | ✓ | ✓ | — | — |
| Export PDF | ✓ | ✓ | — | — | — |

### 6.6 Notifications

| Action | Any authenticated user |
|--------|------------------------|
| View own notifications | ✓ |
| Mark as read | ✓ (owner only) |

### 6.7 Audit logs

| Action | Administrator | Chairperson |
|--------|:-------------:|:-----------:|
| Platform audit logs | ✓ | — |
| Chama audit logs | — | ✓ |

---

## 7. Data isolation rules

1. **Chama tenancy:** Financial and governance data is always scoped to `chama_id`
2. **List endpoints:** Return only Chamas where the user has `active` membership
3. **Object access:** Verify membership before returning any Chama-scoped resource
4. **Cross-Chama access:** Denied unless user is `Administrator` (future platform endpoints)
5. **Inactive Chamas:** Archived Chamas (`is_active=False`) are hidden from non-admin queries

---

## 8. Implementation guidelines

### Adding a new permission class

```python
class IsChamaTreasurer(BasePermission):
    message = "Only the Treasurer can perform this action."

    def has_permission(self, request, view):
        chama = get_chama_from_kwargs(view)
        if chama is None:
            return False
        return MembershipService.user_has_role(
            request.user, chama, [TREASURER]
        )
```

### Permission class selection in views

```python
def get_permissions(self):
    if self.request.method == "GET":
        return [IsAuthenticated(), IsChamaMember()]
    if self.request.method == "POST":
        return [IsAuthenticated(), IsChamaTreasurer()]
    return super().get_permissions()
```

### Service-layer defence

Even when permissions pass, services must validate:

- Target entity belongs to the Chama
- Actor's membership is `active`
- Business state allows the operation (e.g. cannot vote on closed applications)

---

## 9. References

- `Backend/apps/memberships/permissions.py` — implemented permission classes
- `Backend/apps/roles/constants.py` — role slugs
- `Docs/API_SPEC.md` — endpoint documentation
- `Docs/CODING_STANDARDS.md` — implementation conventions
