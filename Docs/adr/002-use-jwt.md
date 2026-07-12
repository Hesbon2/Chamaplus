# ADR 002: Use JWT for API Authentication

**Status:** Accepted  
**Date:** 2026-07  
**Deciders:** ChamaPlus engineering team

---

## Context

ChamaPlus is a mobile-first application. The Flutter client communicates with the backend over REST. Authentication must:

- Work statelessly across API requests (no server-side sessions for mobile)
- Support token refresh without re-login
- Allow secure logout (invalidate refresh tokens)
- Identify users by UUID for all protected endpoints
- Align with the master spec: "Authentication: JWT"

Candidates considered:

| Option | Pros | Cons |
|--------|------|------|
| **JWT (Simple JWT)** | Stateless, mobile-friendly, spec-mandated | Token revocation requires blacklist |
| **Session cookies** | Simple for web | Poor fit for mobile; CSRF complexity |
| **OAuth2 / social login** | External providers | Out of scope for v1; Chamas use phone numbers |
| **API keys** | Simple | No user identity; no refresh flow |

---

## Decision

We will use **JSON Web Tokens** via `djangorestframework-simplejwt` for API authentication.

Configuration:

| Setting | Value |
|---------|-------|
| Access token lifetime | 60 minutes (configurable via env) |
| Refresh token lifetime | 7 days (configurable via env) |
| Refresh rotation | Enabled |
| Blacklist after rotation | Enabled (`token_blacklist` app) |
| Auth header | `Authorization: Bearer <access_token>` |
| User identifier in token | `user_id` (UUID) |
| Login credential | Phone number + password |

Endpoints:

- `POST /api/v1/auth/register/`
- `POST /api/v1/auth/login/`
- `POST /api/v1/auth/refresh/`
- `POST /api/v1/auth/logout/` (blacklists refresh token)

---

## Consequences

### Positive

- Stateless API suits mobile client and future scaling
- Flutter can store tokens in secure storage and attach to every request
- Token refresh provides good UX without frequent re-login
- Logout invalidates refresh tokens server-side via blacklist
- Simple JWT integrates natively with DRF permission classes

### Negative

- Access tokens cannot be revoked before expiry (mitigated by short lifetime)
- Blacklist table grows over time; requires periodic cleanup in production
- Client must implement refresh-on-401 logic correctly

### Neutral

- Biometric login (future scope) will wrap the same JWT flow
- M-Pesa and SMS integrations do not affect authentication mechanism

---

## Flutter client responsibilities

1. Store `access` and `refresh` in `flutter_secure_storage`
2. Attach `Bearer` token to all protected requests
3. On 401: attempt one refresh; retry original request
4. On refresh failure: redirect to login
5. On logout: call logout endpoint and clear local tokens

---

## References

- `Docs/MASTER_PROJECT_SPEC.md` — Authentication: JWT
- `Docs/API_SPEC.md` — Authentication Flow
- `Backend/chamaplus_backend/settings/base.py` — `SIMPLE_JWT` configuration
- ADR 001 — Django + DRF as host framework
