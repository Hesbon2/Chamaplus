# ChamaPlus — Project Status & Architecture Inventory

**Version:** 1.2  
**Last updated:** July 12, 2026  
**Scope:** Backend (`Backend/`)  
**Aligned with:** `Docs/MASTER_PROJECT_SPEC.md`

---

## Executive summary

ChamaPlus backend is a **Django 5.0 + DRF** REST API backed by **MySQL (XAMPP)**. Foundation, authentication, roles, Chama/membership management, contribution management, and **financial core** (loan products, applications, committee voting, repayments) are **implemented and tested**. Credit scoring, reports, notifications, meetings, audit, and dashboard remain **not started**.

| Metric | Count |
|--------|------:|
| Django apps registered | 12 |
| Django apps with domain models | 6 |
| Database tables (domain) | 10 |
| API endpoints (business) | 46 |
| Unit/integration tests | 76 |
| Management commands | 1 |

---

## 1. Current folder structure

```
Chamaplus/
├── .cursor/                          # Cursor AI project rules
│   ├── project_rules.md
│   ├── coding_standards.md
│   └── workflow.md
├── Backend/                          # Django REST API
│   ├── manage.py
│   ├── requirements.txt
│   ├── pytest.ini
│   ├── .env.example
│   ├── .env                          # gitignored
│   ├── .gitignore
│   ├── static/.gitkeep
│   ├── media/.gitkeep
│   ├── logs/                         # Runtime log files
│   ├── chamaplus_backend/            # Django project package
│   │   ├── __init__.py
│   │   ├── urls.py                   # Root URL config
│   │   ├── wsgi.py
│   │   ├── asgi.py
│   │   ├── api/
│   │   │   ├── __init__.py
│   │   │   └── v1/
│   │   │       ├── __init__.py
│   │   │       └── urls.py           # API v1 route aggregation
│   │   └── settings/
│   │       ├── __init__.py
│   │       ├── base.py
│   │       ├── development.py
│   │       └── production.py
│   └── apps/
│       ├── conftest.py               # Shared pytest fixtures
│       ├── core/                     # Shared infrastructure
│       │   ├── models/base.py        # UUIDModel, TimeStampedModel
│       │   ├── responses/envelope.py # API envelope helpers
│       │   ├── exceptions/           # DomainError, exception handler
│       │   ├── utils/validators.py   # Kenyan phone validation
│       │   └── pagination.py         # StandardPagination
│       ├── accounts/                 # ✅ Implemented
│       │   ├── models.py
│       │   ├── serializers.py
│       │   ├── views.py
│       │   ├── urls.py
│       │   ├── services/auth_service.py
│       │   ├── admin.py
│       │   ├── migrations/
│       │   └── tests/
│       ├── roles/                    # ✅ Implemented
│       │   ├── models/role.py
│       │   ├── serializers.py
│       │   ├── views.py
│       │   ├── urls.py
│       │   ├── constants.py
│       │   ├── admin.py
│       │   ├── management/commands/seed_roles.py
│       │   ├── migrations/
│       │   └── (no dedicated tests yet)
│       ├── chamas/                   # ✅ Implemented
│       │   ├── models/chama.py
│       │   ├── serializers.py
│       │   ├── views.py
│       │   ├── urls.py
│       │   ├── services/chama_service.py
│       │   ├── constants.py
│       │   ├── admin.py
│       │   ├── migrations/
│       │   └── tests/
│       ├── memberships/              # ✅ Implemented
│       │   ├── models/membership.py
│       │   ├── serializers.py
│       │   ├── views.py
│       │   ├── urls.py
│       │   ├── services/membership_service.py
│       │   ├── permissions.py
│       │   ├── constants.py
│       │   ├── admin.py
│       │   ├── migrations/
│       │   └── tests/
│       ├── contributions/            # ✅ Implemented
│       │   ├── models/
│       │   │   ├── contribution_cycle.py
│       │   │   └── contribution.py
│       │   ├── serializers.py
│       │   ├── views.py
│       │   ├── urls.py
│       │   ├── contribution_urls.py
│       │   ├── services/
│       │   │   ├── contribution_cycle_service.py
│       │   │   └── contribution_service.py
│       │   ├── permissions.py
│       │   ├── constants.py
│       │   ├── admin.py
│       │   ├── migrations/
│       │   └── tests/
│       ├── loans/                    # ✅ Implemented
│       │   ├── models/
│       │   │   ├── loan_product.py
│       │   │   ├── loan_application.py
│       │   │   ├── committee_vote.py
│       │   │   └── loan_repayment.py
│       │   ├── serializers.py
│       │   ├── views.py
│       │   ├── product_urls.py
│       │   ├── application_urls.py
│       │   ├── services/
│       │   │   ├── loan_product_service.py
│       │   │   ├── loan_application_service.py
│       │   │   ├── committee_vote_service.py
│       │   │   ├── loan_repayment_service.py
│       │   │   └── eligibility_service.py
│       │   ├── permissions.py
│       │   ├── constants.py
│       │   ├── admin.py
│       │   ├── migrations/
│       │   └── tests/
│       ├── governance/               # ⬜ Placeholder app (meetings/attendance future)
│       ├── credit_scoring/           # ⬜ Placeholder app
│       ├── reports/                  # ⬜ Placeholder app
│       ├── notifications/            # ⬜ Placeholder app
│       └── audit/                    # ⬜ Placeholder app
├── Docs/                             # Project documentation
│   ├── MASTER_PROJECT_SPEC.md
│   ├── API_SPEC.md
│   ├── CODING_STANDARDS.md
│   ├── PERMISSIONS.md
│   ├── IMPLEMENTATION_PLAYBOOK.md
│   ├── TESTING_STRATEGY.md
│   ├── PROJECT_STATUS.md             # This file
│   └── adr/                          # Architecture decision records
└── README.md
```

---

## 2. Installed Django apps

### 2.1 Django built-in

| App | Purpose |
|-----|---------|
| `django.contrib.admin` | Admin interface |
| `django.contrib.auth` | Auth framework |
| `django.contrib.contenttypes` | Content type system |
| `django.contrib.sessions` | Session middleware |
| `django.contrib.messages` | Messaging framework |
| `django.contrib.staticfiles` | Static file serving |

### 2.2 Third-party

| App | Package | Purpose |
|-----|---------|---------|
| `rest_framework` | djangorestframework | REST API framework |
| `rest_framework_simplejwt` | djangorestframework-simplejwt | JWT authentication |
| `rest_framework_simplejwt.token_blacklist` | djangorestframework-simplejwt | Refresh token blacklist |
| `drf_spectacular` | drf-spectacular | OpenAPI / Swagger |
| `corsheaders` | django-cors-headers | CORS support |

### 2.3 Local apps

| App | Label | Status | Domain models |
|-----|-------|--------|:-------------:|
| `apps.core` | `core` | Infrastructure only | Abstract bases |
| `apps.accounts` | `accounts` | **Complete** | `User` |
| `apps.roles` | `roles` | **Complete** | `Role` |
| `apps.chamas` | `chamas` | **Complete** | `Chama` |
| `apps.memberships` | `memberships` | **Complete** | `Membership` |
| `apps.contributions` | `contributions` | **Complete** | `ContributionCycle`, `Contribution` |
| `apps.loans` | `loans` | **Complete** | `LoanProduct`, `LoanApplication`, `CommitteeVote`, `LoanRepayment` |
| `apps.governance` | `governance` | Registered, empty | — |
| `apps.credit_scoring` | `credit_scoring` | Registered, empty | — |
| `apps.reports` | `reports` | Registered, empty | — |
| `apps.notifications` | `notifications` | Registered, empty | — |
| `apps.audit` | `audit` | Registered, empty | — |

---

## 3. Database models implemented

### 3.1 Domain tables (10 of 16 spec tables)

| Table | Model | App | PK | Key fields |
|-------|-------|-----|----|------------|
| `users` | `User` | accounts | UUID | `phone_number`, `email`, `first_name`, `last_name` |
| `roles` | `Role` | roles | UUID | `name`, `slug`, `is_platform_role` |
| `chamas` | `Chama` | chamas | UUID | `name`, `invite_code`, `currency`, `is_active`, `created_by` |
| `memberships` | `Membership` | memberships | UUID | `user`, `chama`, `role`, `status`, `joined_at` |
| `contribution_cycles` | `ContributionCycle` | contributions | UUID | `chama`, `frequency`, `contribution_amount`, `dates`, `status` |
| `contributions` | `Contribution` | contributions | UUID | `cycle`, `member`, `amount`, `payment_method`, `recorded_by` |
| `loan_products` | `LoanProduct` | loans | UUID | `chama`, `amounts`, `interest_rate`, `maximum_duration` |
| `loan_applications` | `LoanApplication` | loans | UUID | `applicant`, `loan_product`, `status`, `outstanding_balance` |
| `committee_votes` | `CommitteeVote` | loans | UUID | `loan_application`, `committee_member`, `decision` |
| `repayments` | `LoanRepayment` | loans | UUID | `loan_application`, `amount`, `payment_method`, `recorded_by` |

### 3.2 Abstract base models (`apps.core`)

| Model | Fields | Usage |
|-------|--------|-------|
| `UUIDModel` | `id` (UUID PK) | Base for all domain models |
| `TimeStampedModel` | `id`, `created_at`, `updated_at` | Base for entities with audit timestamps |

### 3.3 Migrations applied

| App | Migration | Description |
|-----|-----------|-------------|
| accounts | `0001_initial` | Create `User` |
| accounts | `0002_user_phone_number` | Add `phone_number` field |
| roles | `0001_initial` | Create `Role` |
| chamas | `0001_initial` | Create `Chama` |
| memberships | `0001_initial` | Create `Membership` + unique constraint |
| contributions | `0001_initial` | Create `ContributionCycle` |
| contributions | `0002_contribution_and_more` | Create `Contribution` |
| contributions | `0003_...` | Idempotency key unique field |
| loans | `0001_initial` | Loan products, applications, votes, repayments |

### 3.4 Spec tables not yet implemented (6)

`user_roles`, `meetings`, `attendance`, `credit_scores`, `notifications`, `audit_logs`

**Note:** Role assignment is currently handled via `memberships.role` FK rather than a separate `user_roles` table.

---

## 4. Serializers implemented

### 4.1 `apps.accounts`

| Serializer | Type | Purpose |
|------------|------|---------|
| `KenyanPhoneField` | Custom field | Phone normalization |
| `RegisterSerializer` | Model | User registration |
| `UserSerializer` | Model | User profile output |
| `ProfileUpdateSerializer` | Model | Profile PATCH |
| `LoginSerializer` | Plain | Login input |
| `RefreshTokenSerializer` | Plain | Token refresh input |
| `LogoutSerializer` | Plain | Logout input |
| `ChangePasswordSerializer` | Plain | Password change input |

### 4.2 `apps.roles`

| Serializer | Type | Purpose |
|------------|------|---------|
| `RoleSerializer` | Model | Role catalog output |

### 4.3 `apps.chamas`

| Serializer | Type | Purpose |
|------------|------|---------|
| `ChamaSerializer` | Model | Chama detail/list output |
| `ChamaCreateSerializer` | Model | Chama creation input |
| `ChamaUpdateSerializer` | Model | Chama PATCH input |

### 4.4 `apps.memberships`

| Serializer | Type | Purpose |
|------------|------|---------|
| `RoleSummarySerializer` | Model | Nested role in membership |
| `UserSummarySerializer` | Model | Nested user in membership |
| `MembershipSerializer` | Model | Membership output |
| `InviteMemberSerializer` | Plain | Invite by phone |
| `JoinChamaSerializer` | Plain | Join by invite code |
| `MembershipRoleUpdateSerializer` | Plain | Role change input |
| `MembershipStatusUpdateSerializer` | Plain | Status change input |

### 4.5 `apps.contributions`

| Serializer | Type | Purpose |
|------------|------|---------|
| `ContributionCycleSerializer` | Model | Cycle detail/list output |
| `ContributionCycleCreateSerializer` | Model | Cycle creation input |
| `ContributionCycleUpdateSerializer` | Model | Cycle PATCH input |
| `ContributionSerializer` | Model | Contribution detail/list output |
| `ContributionCreateSerializer` | Plain | Record contribution input |

### 4.6 `apps.loans`

| Serializer | Type | Purpose |
|------------|------|---------|
| `LoanProductSerializer` | Model | Product detail/list output |
| `LoanProductCreateSerializer` | Model | Product creation input |
| `LoanProductUpdateSerializer` | Model | Product PATCH input |
| `LoanApplicationSerializer` | Model | Application detail/list output |
| `LoanApplicationCreateSerializer` | Plain | Submit application input |
| `LoanApplicationUpdateSerializer` | Plain | Draft update input |
| `LoanApplicationApproveSerializer` | Plain | Approve input |
| `LoanApplicationRejectSerializer` | Plain | Reject input |
| `CommitteeVoteSerializer` | Model | Vote output |
| `CommitteeVoteCreateSerializer` | Plain | Cast vote input |
| `LoanRepaymentSerializer` | Model | Repayment output |
| `LoanRepaymentCreateSerializer` | Plain | Record repayment input |

---

## 5. Services implemented

| Service | App | Methods |
|---------|-----|---------|
| `AuthService` | accounts | `register_user`, `login`, `refresh_token`, `logout`, `update_profile`, `change_password` |
| `ChamaService` | chamas | `create_chama`, `list_chamas_for_user`, `get_chama`, `update_chama`, `archive_chama` |
| `MembershipService` | memberships | `get_membership`, `get_user_membership`, `user_is_active_member`, `user_has_role`, `invite_member`, `join_chama`, `list_members`, `update_role`, `update_status` |
| `ContributionCycleService` | contributions | `create_cycle`, `list_cycles`, `get_cycle`, `update_cycle`, `close_cycle`, `delete_cycle`, `get_chama` |
| `ContributionService` | contributions | `record_contribution`, `list_contributions`, `get_contribution` |
| `LoanProductService` | loans | `create_product`, `list_products`, `get_product`, `update_product`, `delete_product` |
| `LoanApplicationService` | loans | `apply`, `submit`, `update_application`, `cancel`, `approve`, `reject`, `disburse`, `list_applications`, `get_application`, `evaluate_voting` |
| `LoanEligibilityService` | loans | `validate_eligibility` |
| `CommitteeVoteService` | loans | `cast_vote`, `list_votes` |
| `LoanRepaymentService` | loans | `record_repayment`, `list_repayments`, `get_repayment` |

### Core infrastructure (not services, but shared logic)

| Module | Purpose |
|--------|---------|
| `apps.core.responses.envelope` | `success_response`, `error_response`, `EnvelopeAPIView` |
| `apps.core.exceptions.handlers` | `custom_exception_handler` |
| `apps.core.exceptions.base` | `DomainError` |
| `apps.core.utils.validators` | `normalize_kenyan_phone_number` |
| `apps.core.pagination` | `StandardPagination` |

**Repositories:** None implemented yet (planned for credit scoring and reports per ADR 003).

---

## 6. API views implemented

| View | App | Methods | Base class |
|------|-----|---------|------------|
| `RegisterView` | accounts | POST | `EnvelopeAPIView` |
| `LoginView` | accounts | POST | `EnvelopeAPIView` |
| `RefreshTokenView` | accounts | POST | `EnvelopeAPIView` |
| `LogoutView` | accounts | POST | `EnvelopeAPIView` |
| `ChangePasswordView` | accounts | POST | `EnvelopeAPIView` |
| `MeView` | accounts | GET, PATCH | `EnvelopeAPIView` |
| `RoleListView` | roles | GET | `EnvelopeAPIView` |
| `ChamaListCreateView` | chamas | GET, POST | `EnvelopeAPIView` |
| `ChamaDetailView` | chamas | GET, PATCH, DELETE | `EnvelopeAPIView` |
| `InviteMemberView` | memberships | POST | `EnvelopeAPIView` |
| `JoinChamaView` | memberships | POST | `EnvelopeAPIView` |
| `MemberListView` | memberships | GET | `EnvelopeAPIView` |
| `MembershipRoleUpdateView` | memberships | PATCH | `EnvelopeAPIView` |
| `MembershipStatusUpdateView` | memberships | PATCH | `EnvelopeAPIView` |
| `ContributionCycleListCreateView` | contributions | GET, POST | `EnvelopeAPIView` |
| `ContributionCycleDetailView` | contributions | GET, PATCH, DELETE | `EnvelopeAPIView` |
| `ContributionCycleCloseView` | contributions | POST | `EnvelopeAPIView` |
| `ContributionListCreateView` | contributions | GET, POST | `EnvelopeAPIView` |
| `ContributionDetailView` | contributions | GET | `EnvelopeAPIView` |
| `LoanProductListCreateView` | loans | GET, POST | `EnvelopeAPIView` |
| `LoanProductDetailView` | loans | GET, PATCH, DELETE | `EnvelopeAPIView` |
| `LoanApplicationListCreateView` | loans | GET, POST | `EnvelopeAPIView` |
| `LoanApplicationDetailView` | loans | GET, PATCH | `EnvelopeAPIView` |
| `LoanApplicationSubmitView` | loans | POST | `EnvelopeAPIView` |
| `LoanApplicationCancelView` | loans | POST | `EnvelopeAPIView` |
| `LoanApplicationApproveView` | loans | POST | `EnvelopeAPIView` |
| `LoanApplicationRejectView` | loans | POST | `EnvelopeAPIView` |
| `LoanApplicationDisburseView` | loans | POST | `EnvelopeAPIView` |
| `CommitteeVoteListCreateView` | loans | GET, POST | `EnvelopeAPIView` |
| `LoanRepaymentListCreateView` | loans | GET, POST | `EnvelopeAPIView` |
| `LoanRepaymentDetailView` | loans | GET | `EnvelopeAPIView` |

All views use class-based API views with `@extend_schema` OpenAPI annotations.

---

## 7. URL endpoints available

### 7.1 Infrastructure

| Method | Path | Description |
|--------|------|-------------|
| — | `/admin/` | Django admin |
| GET | `/api/schema/` | OpenAPI schema (JSON) |
| GET | `/api/docs/` | Swagger UI |
| GET | `/api/redoc/` | ReDoc UI |

### 7.2 API v1 — Authentication (`/api/v1/auth/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| POST | `/api/v1/auth/register/` | Public | `RegisterView` |
| POST | `/api/v1/auth/login/` | Public | `LoginView` |
| POST | `/api/v1/auth/refresh/` | Public | `RefreshTokenView` |
| POST | `/api/v1/auth/logout/` | JWT | `LogoutView` |
| POST | `/api/v1/auth/change-password/` | JWT | `ChangePasswordView` |

### 7.3 API v1 — Users (`/api/v1/users/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `/api/v1/users/me/` | JWT | `MeView` |
| PATCH | `/api/v1/users/me/` | JWT | `MeView` |

### 7.4 API v1 — Roles (`/api/v1/roles/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `/api/v1/roles/` | JWT | `RoleListView` |

### 7.5 API v1 — Chamas (`/api/v1/chamas/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `/api/v1/chamas/` | JWT | `ChamaListCreateView` |
| POST | `/api/v1/chamas/` | JWT | `ChamaListCreateView` |
| POST | `/api/v1/chamas/join/` | JWT | `JoinChamaView` |
| GET | `/api/v1/chamas/{id}/` | JWT + Member | `ChamaDetailView` |
| PATCH | `/api/v1/chamas/{id}/` | JWT + Chairperson | `ChamaDetailView` |
| DELETE | `/api/v1/chamas/{id}/` | JWT + Chairperson | `ChamaDetailView` |
| POST | `/api/v1/chamas/{id}/invite/` | JWT + Official | `InviteMemberView` |
| GET | `/api/v1/chamas/{id}/members/` | JWT + Member | `MemberListView` |

### 7.6 API v1 — Memberships (`/api/v1/memberships/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| PATCH | `/api/v1/memberships/{id}/role/` | JWT + Chairperson | `MembershipRoleUpdateView` |
| PATCH | `/api/v1/memberships/{id}/status/` | JWT + Chairperson | `MembershipStatusUpdateView` |

### 7.7 API v1 — Contribution Cycles (`/api/v1/chamas/{chama_id}/contribution-cycles/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `/api/v1/chamas/{chama_id}/contribution-cycles/` | JWT + Member | `ContributionCycleListCreateView` |
| POST | `/api/v1/chamas/{chama_id}/contribution-cycles/` | JWT + Treasurer/Chairperson | `ContributionCycleListCreateView` |
| GET | `/api/v1/chamas/{chama_id}/contribution-cycles/{id}/` | JWT + Member | `ContributionCycleDetailView` |
| PATCH | `/api/v1/chamas/{chama_id}/contribution-cycles/{id}/` | JWT + Treasurer | `ContributionCycleDetailView` |
| DELETE | `/api/v1/chamas/{chama_id}/contribution-cycles/{id}/` | JWT + Treasurer | `ContributionCycleDetailView` |
| POST | `/api/v1/chamas/{chama_id}/contribution-cycles/{id}/close/` | JWT + Treasurer | `ContributionCycleCloseView` |

### 7.8 API v1 — Contributions (`/api/v1/chamas/{chama_id}/contributions/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `/api/v1/chamas/{chama_id}/contributions/` | JWT + Member | `ContributionListCreateView` |
| POST | `/api/v1/chamas/{chama_id}/contributions/` | JWT + Treasurer | `ContributionListCreateView` |
| GET | `/api/v1/chamas/{chama_id}/contributions/{id}/` | JWT + Member | `ContributionDetailView` |

### 7.9 API v1 — Loan Products (`/api/v1/chamas/{chama_id}/loan-products/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `/api/v1/chamas/{chama_id}/loan-products/` | JWT + Member | `LoanProductListCreateView` |
| POST | `/api/v1/chamas/{chama_id}/loan-products/` | JWT + Chairperson/Treasurer | `LoanProductListCreateView` |
| GET | `/api/v1/chamas/{chama_id}/loan-products/{id}/` | JWT + Member | `LoanProductDetailView` |
| PATCH | `/api/v1/chamas/{chama_id}/loan-products/{id}/` | JWT + Chairperson | `LoanProductDetailView` |
| DELETE | `/api/v1/chamas/{chama_id}/loan-products/{id}/` | JWT + Chairperson | `LoanProductDetailView` |

### 7.10 API v1 — Loan Applications (`/api/v1/chamas/{chama_id}/loan-applications/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `/api/v1/chamas/{chama_id}/loan-applications/` | JWT + Member | `LoanApplicationListCreateView` |
| POST | `/api/v1/chamas/{chama_id}/loan-applications/` | JWT + Member | `LoanApplicationListCreateView` |
| GET | `/api/v1/chamas/{chama_id}/loan-applications/{id}/` | JWT + Member | `LoanApplicationDetailView` |
| PATCH | `/api/v1/chamas/{chama_id}/loan-applications/{id}/` | JWT + Applicant | `LoanApplicationDetailView` |
| POST | `/api/v1/chamas/{chama_id}/loan-applications/{id}/submit/` | JWT + Applicant | `LoanApplicationSubmitView` |
| POST | `/api/v1/chamas/{chama_id}/loan-applications/{id}/cancel/` | JWT + Applicant | `LoanApplicationCancelView` |
| POST | `/api/v1/chamas/{chama_id}/loan-applications/{id}/approve/` | JWT + Committee | `LoanApplicationApproveView` |
| POST | `/api/v1/chamas/{chama_id}/loan-applications/{id}/reject/` | JWT + Committee | `LoanApplicationRejectView` |
| POST | `/api/v1/chamas/{chama_id}/loan-applications/{id}/disburse/` | JWT + Treasurer | `LoanApplicationDisburseView` |

### 7.11 API v1 — Committee Voting (`/api/v1/chamas/{chama_id}/loan-applications/{loan_id}/votes/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `.../votes/` | JWT + Committee | `CommitteeVoteListCreateView` |
| POST | `.../votes/` | JWT + Committee | `CommitteeVoteListCreateView` |

### 7.12 API v1 — Loan Repayments (`/api/v1/chamas/{chama_id}/loan-applications/{loan_id}/repayments/`)

| Method | Path | Auth | View |
|--------|------|------|------|
| GET | `.../repayments/` | JWT + Member | `LoanRepaymentListCreateView` |
| POST | `.../repayments/` | JWT + Treasurer | `LoanRepaymentListCreateView` |
| GET | `.../repayments/{id}/` | JWT + Member | `LoanRepaymentDetailView` |

**Total business endpoints:** 46

---

## 8. Authentication features completed

| Feature | Status | Details |
|---------|--------|---------|
| Custom User model | ✅ | UUID PK, phone-based auth |
| Phone + password login | ✅ | `USERNAME_FIELD = phone_number` |
| Kenyan phone validation | ✅ | E.164 normalization (`+254...`) |
| User registration | ✅ | With password confirmation |
| JWT access tokens | ✅ | 60-minute default lifetime |
| JWT refresh tokens | ✅ | 7-day default lifetime |
| Token rotation | ✅ | New refresh on each refresh |
| Token blacklisting | ✅ | Logout invalidates refresh token |
| Profile view/update | ✅ | GET/PATCH `/users/me/` |
| Password change | ✅ | Requires current password |
| Default auth on all endpoints | ✅ | `IsAuthenticated` unless `AllowAny` |

---

## 9. Permissions implemented

| Permission class | File | Check |
|------------------|------|-------|
| `IsChamaMember` | `memberships/permissions.py` | Active membership in Chama |
| `IsChamaChairperson` | `memberships/permissions.py` | Active Chairperson role |
| `IsChamaOfficial` | `memberships/permissions.py` | Chairperson or Secretary |
| `IsMembershipChairperson` | `memberships/permissions.py` | Chairperson of membership's Chama |
| `IsChamaTreasurer` | `contributions/permissions.py` | Active Treasurer role |
| `IsChamaTreasurerOrChairperson` | `contributions/permissions.py` | Treasurer or Chairperson (cycle create) |
| `IsChamaCommitteeMember` | `loans/permissions.py` | Committee member or Chairperson |
| `IsChamaTreasurer` | `loans/permissions.py` | Treasurer (disburse, repayments) |
| `IsChamaChairpersonOrTreasurer` | `loans/permissions.py` | Chairperson or Treasurer (product create) |

### Not yet implemented

- `IsChamaSecretary`
- Platform `Administrator` permission class
- Object-level DRF permissions (all current checks are request-level)
- Permission classes for meetings, governance modules

Full matrix documented in `Docs/PERMISSIONS.md`.

---

## 10. Tests available

**Total: 76 tests** (all passing as of last run)

### 10.1 `apps/accounts/tests/test_auth.py` — 16 tests

| Class | Tests |
|-------|------:|
| `TestKenyanPhoneValidation` | 4 |
| `TestRegister` | 3 |
| `TestLogin` | 2 |
| `TestRefreshToken` | 1 |
| `TestLogout` | 1 |
| `TestProfile` | 3 |
| `TestChangePassword` | 2 |

### 10.2 `apps/chamas/tests/test_chamas.py` — 8 tests

| Class | Tests |
|-------|------:|
| `TestChamaCreate` | 2 |
| `TestChamaList` | 2 |
| `TestChamaDetail` | 4 |

### 10.3 `apps/memberships/tests/test_memberships.py` — 8 tests

| Class | Tests |
|-------|------:|
| `TestInviteMember` | 2 |
| `TestJoinChama` | 3 |
| `TestMemberList` | 1 |
| `TestMembershipUpdates` | 2 |

### 10.4 `apps/contributions/tests/` — 26 tests

| File | Tests |
|------|------:|
| `test_contribution_cycles.py` | 14 |
| `test_contributions.py` | 12 |

### 10.5 `apps/loans/tests/` — 18 tests

| File | Tests |
|------|------:|
| `test_loan_products.py` | 5 |
| `test_loan_applications.py` | 13 |

### 10.6 Shared fixtures (`apps/conftest.py`)

`roles`, `chairperson_user`, `member_user`, `treasurer_user`, `committee_user`, `auth_client`, `member_client`, `treasurer_client`, `committee_client`, `chama`

### 10.7 Test gaps

| Area | Gap |
|------|-----|
| Roles | No dedicated tests for `RoleListView` or `seed_roles` |
| Permissions | No isolated permission class unit tests |
| Core | No tests for exception handler or phone validator (validator tested via accounts) |
| Integration | No end-to-end multi-step flow tests |
| Coverage tooling | `pytest-cov` not yet in requirements |

---

## 11. Management commands

| Command | App | Purpose |
|---------|-----|---------|
| `seed_roles` | roles | Seed 6 default roles (Chairperson, Treasurer, Secretary, Committee Member, Member, Administrator) |

```powershell
.\.venv\Scripts\python manage.py seed_roles
```

---

## 12. Outstanding TODOs

### 12.1 Spec modules not started

| Priority | Module | Spec tables |
|----------|--------|-------------|
| P1 | Meetings, attendance | `meetings`, `attendance` |
| P2 | Credit scoring | `credit_scores` |
| P2 | Reports | (aggregation, no new table) |
| P2 | Notifications | `notifications` |
| P2 | Dashboard | (aggregation, no new table) |
| P3 | Audit logs | `audit_logs` |

### 12.2 Cross-cutting TODOs

| Item | Description |
|------|-------------|
| Audit logging | Wire `AuditService` into all write operations |
| `user_roles` table | Spec lists separate table; currently merged into `memberships.role` — document or align |
| API_SPEC.md status | Update Chamas/Memberships/Contributions sections from "Planned" to "Implemented" |
| Roles tests | Add tests for `GET /api/v1/roles/` and `seed_roles` |
| CI pipeline | No GitHub Actions / automated test runner configured |
| Production deployment | No Docker, Gunicorn, or hosting config |
| Flutter client | Not started |
| `pytest-cov` | Add coverage reporting to requirements |
| Rate limiting | Not implemented (future) |

### 12.3 Credit scoring prerequisites (before Sprint 7)

- Define sub-formulas for consistency, repayment, attendance, duration
- Implement meetings + attendance modules first (15% weight)
- Configurable weights via environment variables
- `CreditScoreRepository` for cross-table aggregations

---

## 13. Feature status

### ✅ Completed

| Feature | Sprint |
|---------|--------|
| Backend foundation (Django, DRF, MySQL, settings split) | 1a |
| Virtual environment, requirements, .env, .gitignore | 1a |
| JWT, Swagger, CORS, logging, static/media | 1a |
| Core infrastructure (envelope, exceptions, base models, pagination) | 1a |
| Custom User model (UUID, phone auth) | 1b |
| Authentication API (register, login, refresh, logout, profile, change password) | 1b |
| Kenyan phone validation | 1b |
| Role catalog model + seed command | 2 |
| Role list API | 2 |
| Chama CRUD (create, list, detail, update, archive) | 3 |
| Membership invite, join, list | 3 |
| Membership role/status updates | 3 |
| Chama-scoped RBAC permission classes | 3 |
| Contribution cycles (CRUD + close) | 4 |
| Contributions (record, list, detail) | 4 |
| Contribution permissions (Treasurer, Member) | 4 |
| Loan products CRUD | 4 |
| Loan applications (apply, approve, reject, cancel, disburse) | 4 |
| Committee voting with auto status update | 4 |
| Loan repayments (immutable, balance tracking) | 4 |
| Unit tests (76) | 1b–5 |
| Project documentation (spec, API, standards, ADRs, permissions) | — |

### 🔄 In Progress

| Feature | Notes |
|---------|-------|
| None | No active sprint in progress at time of inventory |

### ⬜ Not Started

| Feature | Spec reference |
|---------|----------------|
| Meetings | Modules list (before credit scoring) |
| Attendance | Modules list (before credit scoring) |
| Credit scoring | Dev order #8 |
| Financial reports (PDF) | Dev order #9 |
| Notifications | Dev order #10 |
| Dashboard | Dev order #11 |
| Audit logs | Modules list (cross-cutting) |
| Flutter mobile app | Technology stack |
| M-Pesa integration | Future scope |
| SMS notifications | Future scope |
| Biometric login | Future scope |
| Offline sync | Future scope |
| Multi-Chama membership UI | Future scope |
| Web dashboard | Future scope |
| Analytics | Future scope |
| AI loan prediction | Future scope |

---

## 14. Known technical debt

| # | Area | Issue | Impact | Suggested fix |
|---|------|-------|--------|---------------|
| 1 | Django version | Pinned to 5.0.x for XAMPP MariaDB 10.4 | Cannot upgrade Django until DB upgraded | Upgrade to MariaDB 10.5+ or MySQL 8.0 |
| 2 | App registration | 8 placeholder apps in `INSTALLED_APPS` with no models | Noise in app registry; potential confusion | Remove from `INSTALLED_APPS` until implemented, or keep for planned structure |
| 3 | `user_roles` table | Spec has separate table; implementation uses `memberships.role` | Schema divergence from spec | Update spec or add `user_roles` if multi-role per member needed |
| 4 | API_SPEC.md | Chamas/Memberships still marked "Planned" | Documentation drift | Update status labels |
| 5 | Roles tests | No test coverage for roles module | Gap in test pyramid | Add `apps/roles/tests/` |
| 6 | Permission depth | Request-level only; no DRF object permissions | Adequate for now; may need `has_object_permission` later | Add when complex object access needed |
| 7 | SECRET_KEY | `.env.example` has placeholder value | Security risk if used in production | Generate strong key for production |
| 8 | Pip artifacts | `pip-unpack-*`, `pip-metadata-*` dirs in Backend/ | Repo clutter | Add to `.gitignore` and clean up |
| 9 | Case sensitivity | `Backend/` vs `backend/` path on Windows | Inconsistent paths in tooling | Standardize on `Backend/` |
| 10 | Test settings | No dedicated `test.py` settings module | Tests run on `development` settings | Add `settings/test.py` with faster config |
| 11 | Financial immutability | Contributions immutable (no PATCH/DELETE API; admin read-only) | Reversal entries not yet implemented | Add reversal-entry model in future sprint |
| 12 | Idempotency | `idempotency_key` on contributions; service + DB unique | MariaDB conditional constraints unsupported | Uses nullable unique column + service check |

---

## 15. Recommendations for next milestone

### Milestone: Sprint 6 — Governance & Credit Scoring

**Goal:** Meetings, attendance, and transparent credit scoring.

### Recommended sequence

1. **Update docs** — Mark Financial Core as Implemented in `API_SPEC.md`
2. **Implement `Meeting` and `Attendance` models** in governance app
3. **Implement `CreditScore` model** and `CreditScoringService`
4. **Wire recalculation triggers** on contribution/repayment/meeting events
5. **Expose API** — meetings, attendance, credit scores
6. **Write tests** — governance workflow + scoring formulas

### Success criteria

- Secretary can schedule meetings and record attendance
- Credit scores computed with configurable weights
- Scores attached as advisory on loan applications
- ≥ 15 new unit tests passing

---

## Appendix A — Dependencies (`requirements.txt`)

| Package | Version constraint |
|---------|-------------------|
| Django | `>=5.0,<5.1` |
| djangorestframework | `>=3.15,<4.0` |
| django-environ | `>=0.11,<1.0` |
| djangorestframework-simplejwt | `>=5.3,<6.0` |
| drf-spectacular | `>=0.27,<1.0` |
| mysqlclient | `>=2.2,<3.0` |
| django-cors-headers | `>=4.3,<5.0` |
| pytest | `>=8.0,<9.0` |
| pytest-django | `>=4.8,<5.0` |

---

## Appendix B — Configuration summary

| Setting | Value |
|---------|-------|
| Project name | `chamaplus_backend` |
| Settings module (dev) | `chamaplus_backend.settings.development` |
| Database | MySQL via XAMPP (`chamaplus_db`) |
| Auth model | `accounts.User` |
| Timezone | `Africa/Nairobi` |
| API prefix | `/api/v1/` |
| JWT access lifetime | 60 minutes |
| JWT refresh lifetime | 7 days |
| Default page size | 20 (max 100) |

---

## Appendix C — Documentation index

| Document | Path |
|----------|------|
| Master specification | `Docs/MASTER_PROJECT_SPEC.md` |
| API specification | `Docs/API_SPEC.md` |
| Coding standards | `Docs/CODING_STANDARDS.md` |
| Permissions reference | `Docs/PERMISSIONS.md` |
| Implementation playbook | `Docs/IMPLEMENTATION_PLAYBOOK.md` |
| Testing strategy | `Docs/TESTING_STRATEGY.md` |
| Project status (this file) | `Docs/PROJECT_STATUS.md` |
| ADR 001 — Django | `Docs/adr/001-use-django.md` |
| ADR 002 — JWT | `Docs/adr/002-use-jwt.md` |
| ADR 003 — Service layer | `Docs/adr/003-service-layer.md` |
| ADR 004 — MySQL | `Docs/adr/004-use-mysql.md` |
| ADR 005 — Credit scoring | `Docs/adr/005-credit-scoring.md` |
| Cursor project rules | `.cursor/project_rules.md` |

---

*This document is a point-in-time inventory. Update after each sprint completion.*
