# ChamaPlus API Specification

**Version:** 1.0.0  
**Base URL:** `https://api.chamaplus.example.com` (production) · `http://127.0.0.1:8000` (development)  
**Last updated:** July 2026  
**Status:** Living document — aligned with `MASTER_PROJECT_SPEC.md`

---

## Table of Contents

1. [Overview](#1-overview)
2. [API Versioning Strategy](#2-api-versioning-strategy)
3. [Standard Response Format](#3-standard-response-format)
4. [Authentication Flow](#4-authentication-flow)
5. [HTTP Status Codes](#5-http-status-codes)
6. [Validation Rules](#6-validation-rules)
7. [Error Handling](#7-error-handling)
8. [Pagination Standards](#8-pagination-standards)
9. [Filtering and Search Conventions](#9-filtering-and-search-conventions)
10. [Common Conventions](#10-common-conventions)
11. [Endpoint Reference](#11-endpoint-reference)
    - [Authentication & Users](#111-authentication--users--implemented)
    - [Roles](#112-roles--implemented)
    - [Chamas](#113-chamas--planned)
    - [Memberships](#114-memberships--planned)
    - [Contribution Cycles](#115-contribution-cycles--planned)
    - [Contributions](#116-contributions--planned)
    - [Loan Products](#117-loan-products--planned)
    - [Loan Applications](#118-loan-applications--planned)
    - [Loan Repayments](#119-loan-repayments--planned)
    - [Meetings](#1110-meetings--planned)
    - [Attendance](#1111-attendance--planned)
    - [Committee Voting](#1112-committee-voting--planned)
    - [Credit Scoring](#1113-credit-scoring--planned)
    - [Reports](#1114-reports--planned)
    - [Notifications](#1115-notifications--planned)
    - [Audit Logs](#1116-audit-logs--planned)
    - [Dashboard](#1117-dashboard--planned)
12. [OpenAPI / Swagger](#12-openapi--swagger)
13. [Flutter Client Guidelines](#13-flutter-client-guidelines)

---

## 1. Overview

ChamaPlus exposes a **RESTful JSON API** consumed by the Flutter mobile client. The API digitizes informal savings groups (Chamas) in Kenya and supports contribution management, loan administration, committee voting, financial reporting, and transparent credit scoring.

### Design principles

| Principle | Description |
|-----------|-------------|
| **REST** | Resources identified by nouns; HTTP verbs express actions |
| **Versioned** | All endpoints live under `/api/v1/` |
| **Envelope responses** | Every response uses `{ success, message, data }` |
| **JWT authentication** | Bearer tokens on protected routes |
| **Chama-scoped tenancy** | Most resources are nested under `/chamas/{chama_id}/` |
| **UUID identifiers** | All primary keys are UUID v4 strings |
| **snake_case** | All JSON field names use snake_case |
| **Africa/Nairobi** | All timestamps returned in ISO 8601 with timezone offset |

### Implementation status legend

| Label | Meaning |
|-------|---------|
| **Implemented** | Available in the current backend |
| **Planned** | Specified here; not yet built |

---

## 2. API Versioning Strategy

### URL-based versioning

All API routes are prefixed with the major version:

```
/api/v1/{resource}/
```

**Examples:**
```
POST /api/v1/auth/login/
GET  /api/v1/chamas/{chama_id}/contributions/
```

### Version rules

| Rule | Policy |
|------|--------|
| **Major version** | Breaking changes require a new prefix (`/api/v2/`) |
| **Minor changes** | Additive fields, new endpoints — same version |
| **Deprecation** | Old versions supported for minimum 6 months after successor launch |
| **Header (optional)** | Clients may send `Accept-Version: 1.0` for future use; URL is authoritative |
| **OpenAPI version** | Matches API version (`1.0.0`) |

### Breaking vs non-breaking changes

**Breaking (requires new major version):**
- Removing or renaming fields
- Changing field types
- Changing authentication scheme
- Changing URL structure

**Non-breaking (same version):**
- Adding optional request fields
- Adding response fields
- Adding new endpoints
- Adding new enum values

---

## 3. Standard Response Format

Every API response — success or failure — uses the same envelope defined in `MASTER_PROJECT_SPEC.md`.

### Success response

```json
{
  "success": true,
  "message": "Human-readable summary of the result.",
  "data": {}
}
```

| Field | Type | Description |
|-------|------|-------------|
| `success` | `boolean` | Always `true` on success |
| `message` | `string` | Short, user-facing description |
| `data` | `object \| array \| null` | Payload; `null` when no body is needed |

### Error response

```json
{
  "success": false,
  "message": "Human-readable error summary.",
  "data": {
    "field_name": ["Specific validation error."]
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `success` | `boolean` | Always `false` on error |
| `message` | `string` | Top-level error description |
| `data` | `object \| null` | Field-level errors; `null` for non-validation errors |

### Paginated list response

List endpoints wrap pagination metadata inside `data`:

```json
{
  "success": true,
  "message": "Contributions retrieved successfully.",
  "data": {
    "count": 48,
    "next": "http://127.0.0.1:8000/api/v1/chamas/{chama_id}/contributions/?page=3",
    "previous": "http://127.0.0.1:8000/api/v1/chamas/{chama_id}/contributions/?page=1",
    "results": []
  }
}
```

---

## 4. Authentication Flow

ChamaPlus uses **JWT (JSON Web Token)** authentication via `djangorestframework-simplejwt`.

### Token types

| Token | Lifetime (default) | Purpose |
|-------|-------------------|---------|
| **Access token** | 60 minutes | Sent on every authenticated request |
| **Refresh token** | 7 days | Used to obtain a new access token |

### Configuration

| Setting | Value |
|---------|-------|
| Header | `Authorization: Bearer <access_token>` |
| Refresh rotation | Enabled — new refresh token issued on each refresh |
| Blacklisting | Enabled — logout invalidates refresh token |
| User identifier in JWT | `user_id` (UUID) |

### Authentication flow diagram

```
┌──────────┐                              ┌──────────┐
│  Flutter │                              │  Django  │
│   App    │                              │   API    │
└────┬─────┘                              └────┬─────┘
     │                                         │
     │  1. POST /api/v1/auth/register/        │
     │────────────────────────────────────────>│
     │  { phone_number, password, ... }        │
     │<────────────────────────────────────────│
     │  { success, data: { id, phone_number }} │
     │                                         │
     │  2. POST /api/v1/auth/login/            │
     │────────────────────────────────────────>│
     │  { phone_number, password }             │
     │<────────────────────────────────────────│
     │  { success, data: { access, refresh }} │
     │                                         │
     │  3. GET /api/v1/users/me/               │
     │  Authorization: Bearer <access>         │
     │────────────────────────────────────────>│
     │<────────────────────────────────────────│
     │  { success, data: { profile } }        │
     │                                         │
     │  4. POST /api/v1/auth/refresh/          │
     │  { refresh: "<refresh_token>" }         │
     │────────────────────────────────────────>│
     │<────────────────────────────────────────│
     │  { success, data: { access, refresh }} │
     │                                         │
     │  5. POST /api/v1/auth/logout/           │
     │  Authorization: Bearer <access>        │
     │  { refresh: "<refresh_token>" }         │
     │────────────────────────────────────────>│
     │<────────────────────────────────────────│
     │  { success, message: "Logout successful." }
     │                                         │
```

### Token refresh strategy (Flutter)

1. Store `access` and `refresh` tokens securely (e.g. `flutter_secure_storage`).
2. Attach `access` token to all protected requests.
3. On `401 Unauthorized`, attempt one refresh using `refresh` token.
4. If refresh succeeds, retry the original request with the new `access` token.
5. If refresh fails, redirect user to login screen.

### Unauthenticated endpoints

These endpoints do **not** require a Bearer token:

- `POST /api/v1/auth/register/`
- `POST /api/v1/auth/login/`
- `POST /api/v1/auth/refresh/`

All other endpoints require authentication unless explicitly marked as public.

---

## 5. HTTP Status Codes

| Code | Meaning | When used |
|------|---------|-----------|
| `200` | OK | Successful GET, PATCH, PUT, DELETE, or action |
| `201` | Created | Resource successfully created (POST) |
| `204` | No Content | Reserved for future use; prefer `200` with envelope |
| `400` | Bad Request | Validation failure, domain rule violation |
| `401` | Unauthorized | Missing, invalid, or expired access token |
| `403` | Forbidden | Authenticated but insufficient role/permission |
| `404` | Not Found | Resource does not exist or not visible to user |
| `409` | Conflict | Duplicate resource or state conflict |
| `422` | Unprocessable Entity | Reserved; use `400` for validation errors |
| `429` | Too Many Requests | Rate limiting (future) |
| `500` | Internal Server Error | Unexpected server failure |

### Status code + envelope rule

The HTTP status code reflects the outcome. The envelope `success` field mirrors it:

```
HTTP 200  →  success: true
HTTP 201  →  success: true
HTTP 400  →  success: false
HTTP 401  →  success: false
HTTP 403  →  success: false
HTTP 404  →  success: false
```

---

## 6. Validation Rules

### General rules

| Rule | Standard |
|------|----------|
| **Required fields** | Must be present and non-empty |
| **UUID fields** | Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` |
| **Dates** | ISO 8601: `2026-07-12T14:30:00+0300` |
| **Currency** | Kenyan Shilling (KES); decimal with up to 2 places |
| **Strings** | Trimmed; no leading/trailing whitespace |
| **Enums** | Lowercase snake_case slugs |

### Kenyan phone numbers

Used for registration, login, and member identification.

| Input format | Example | Stored as |
|-------------|---------|-----------|
| Local | `0712345678` | `+254712345678` |
| Without leading zero | `712345678` | `+254712345678` |
| International | `+254712345678` | `+254712345678` |
| Without plus | `254712345678` | `+254712345678` |

**Pattern:** `^(?:\+?254|0)?([17]\d{8})$`

- Must start with `1` or `7` after country/leading zero
- Normalized to E.164: `+254XXXXXXXXX`
- Must be unique per user

### Password rules

| Rule | Requirement |
|------|-------------|
| Minimum length | 8 characters |
| Confirmation | `password_confirm` must match `password` on register |
| Change password | `current_password` must be correct; `new_password_confirm` must match |

### Email rules

| Rule | Requirement |
|------|-------------|
| Format | Valid email format |
| Uniqueness | Unique across users (case-insensitive) |
| Required | Optional on register; can be updated on profile |

### Monetary amounts

| Field | Rule |
|-------|------|
| `amount` | Positive decimal; max 12 digits, 2 decimal places |
| `currency` | Default `KES`; ISO 4217 code |

### Credit score (read-only computed field)

| Range | Risk level |
|-------|------------|
| 80–100 | Excellent |
| 60–79 | Good |
| 40–59 | Fair |
| 0–39 | High Risk |

Score is advisory only. Committee makes final loan decisions.

---

## 7. Error Handling

### Error categories

| Category | HTTP | `message` example | `data` |
|----------|------|-------------------|--------|
| **Validation** | 400 | `"Validation failed"` | Field-level error map |
| **Domain / business** | 400 | `"Invalid phone number or password."` | `null` or context object |
| **Authentication** | 401 | `"Authentication credentials were not provided."` | `null` |
| **Permission** | 403 | `"You do not have permission to perform this action."` | `null` |
| **Not found** | 404 | `"Not found."` | `null` |
| **Conflict** | 409 | `"A user with this phone number already exists."` | `null` |

### Validation error example

**Request:**
```http
POST /api/v1/auth/register/
Content-Type: application/json

{
  "phone_number": "0812345678",
  "password": "short",
  "password_confirm": "different"
}
```

**Response `400`:**
```json
{
  "success": false,
  "message": "Validation failed",
  "data": {
    "phone_number": ["Enter a valid Kenyan phone number (e.g. 0712345678 or +254712345678)."],
    "password": ["Ensure this field has at least 8 characters."],
    "password_confirm": ["Passwords do not match."]
  }
}
```

### Authentication error example

**Request:**
```http
GET /api/v1/users/me/
```

**Response `401`:**
```json
{
  "success": false,
  "message": "Authentication credentials were not provided.",
  "data": null
}
```

### Permission error example

**Response `403`:**
```json
{
  "success": false,
  "message": "You do not have permission to perform this action.",
  "data": null
}
```

### Flutter error handling guidance

```dart
// Pseudocode — map envelope to app errors
if (!response.success) {
  if (response.data != null && response.data is Map) {
    // Show field-level form errors
  } else {
    // Show response.message as snackbar/dialog
  }
}
```

---

## 8. Pagination Standards

All list endpoints returning multiple records use **page-number pagination**.

### Query parameters

| Parameter | Type | Default | Max | Description |
|-----------|------|---------|-----|-------------|
| `page` | integer | `1` | — | Page number (1-indexed) |
| `page_size` | integer | `20` | `100` | Records per page |

**Example:**
```
GET /api/v1/chamas/{chama_id}/contributions/?page=2&page_size=20
```

### Paginated response shape

```json
{
  "success": true,
  "message": "Contributions retrieved successfully.",
  "data": {
    "count": 48,
    "next": "http://127.0.0.1:8000/api/v1/chamas/abc/contributions/?page=3&page_size=20",
    "previous": "http://127.0.0.1:8000/api/v1/chamas/abc/contributions/?page=1&page_size=20",
    "results": [
      {
        "id": "uuid",
        "amount": "5000.00",
        "created_at": "2026-07-12T10:00:00+0300"
      }
    ]
  }
}
```

### Empty list

```json
{
  "success": true,
  "message": "Contributions retrieved successfully.",
  "data": {
    "count": 0,
    "next": null,
    "previous": null,
    "results": []
  }
}
```

---

## 9. Filtering and Search Conventions

### Standard query parameters

| Parameter | Applies to | Description |
|-----------|-----------|-------------|
| `search` | List endpoints | Full-text search across defined fields |
| `ordering` | List endpoints | Sort field; prefix `-` for descending |
| `status` | Stateful resources | Filter by status slug |
| `member_id` | Financial records | Filter by member UUID |
| `cycle_id` | Contributions | Filter by contribution cycle |
| `date_from` | Date-range resources | Inclusive start date (`YYYY-MM-DD`) |
| `date_to` | Date-range resources | Inclusive end date (`YYYY-MM-DD`) |
| `is_active` | Soft-deleted resources | `true` or `false` |

### Examples

```
GET /api/v1/chamas/?search=kileleshwa&ordering=-created_at
GET /api/v1/chamas/{id}/members/?search=jane&status=active
GET /api/v1/chamas/{id}/contributions/?member_id={uuid}&cycle_id={uuid}
GET /api/v1/chamas/{id}/loan-applications/?status=pending&ordering=-created_at
GET /api/v1/chamas/{id}/meetings/?date_from=2026-01-01&date_to=2026-12-31
GET /api/v1/notifications/?is_read=false&ordering=-created_at
```

### Searchable fields by module

| Module | `search` targets |
|--------|-----------------|
| Chamas | `name`, `description`, `location` |
| Memberships | Member `first_name`, `last_name`, `phone_number` |
| Contributions | Member name, reference number |
| Loan applications | Member name, purpose |
| Meetings | `title`, `agenda`, `location` |
| Notifications | `title`, `message` |

### Ordering

- Default ordering: `-created_at` (newest first) unless specified otherwise
- Multiple fields: `ordering=status,-created_at`
- Invalid ordering field → `400` validation error

---

## 10. Common Conventions

### Request headers

| Header | Required | Value |
|--------|----------|-------|
| `Content-Type` | Yes (body requests) | `application/json` |
| `Authorization` | Protected routes | `Bearer <access_token>` |
| `Accept` | Recommended | `application/json` |

### Resource naming

| Convention | Example |
|-----------|---------|
| Plural nouns | `/contributions/`, `/loan-applications/` |
| kebab-case paths | `/contribution-cycles/`, `/credit-scores/` |
| Nested under Chama | `/chamas/{chama_id}/contributions/` |
| UUID path params | `/chamas/3fa85f64-5717-4562-b3fc-2c963f66afa6/` |

### HTTP verb usage

| Verb | Usage |
|------|-------|
| `GET` | Retrieve one or list |
| `POST` | Create or action (approve, vote, logout) |
| `PATCH` | Partial update |
| `PUT` | Full replace (rare; prefer PATCH) |
| `DELETE` | Soft-delete or archive (financial records are immutable) |

### Role-based access

| Role | Scope |
|------|-------|
| Administrator | Platform-wide |
| Chairperson, Treasurer, Secretary, Committee Member, Member | Chama-scoped via membership |

Permission checks are enforced per endpoint. See each module for required roles.

---

## 11. Endpoint Reference

---

### 11.1 Authentication & Users — **Implemented**

#### POST `/api/v1/auth/register/`

Register a new user account.

| | |
|---|---|
| **Auth** | None |
| **Status** | Implemented |

**Request body:**

| Field | Type | Required | Rules |
|-------|------|----------|-------|
| `phone_number` | string | Yes | Valid Kenyan phone; unique |
| `password` | string | Yes | Min 8 characters |
| `password_confirm` | string | Yes | Must match `password` |
| `first_name` | string | No | Max 150 chars |
| `last_name` | string | No | Max 150 chars |
| `email` | string | No | Valid email; unique |

**Example request:**
```json
{
  "phone_number": "0712345678",
  "password": "SecurePass123",
  "password_confirm": "SecurePass123",
  "first_name": "Jane",
  "last_name": "Doe",
  "email": "jane@example.com"
}
```

**Example response `201`:**
```json
{
  "success": true,
  "message": "Registration successful.",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "phone_number": "+254712345678",
    "email": "jane@example.com",
    "first_name": "Jane",
    "last_name": "Doe",
    "is_staff": false,
    "date_joined": "2026-07-12T10:00:00+0300",
    "last_login": null
  }
}
```

---

#### POST `/api/v1/auth/login/`

Authenticate with phone number and password.

| | |
|---|---|
| **Auth** | None |
| **Status** | Implemented |

**Request body:**

| Field | Type | Required |
|-------|------|----------|
| `phone_number` | string | Yes |
| `password` | string | Yes |

**Example request:**
```json
{
  "phone_number": "0712345678",
  "password": "SecurePass123"
}
```

**Example response `200`:**
```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

#### POST `/api/v1/auth/refresh/`

Obtain a new access token (and rotated refresh token).

| | |
|---|---|
| **Auth** | None |
| **Status** | Implemented |

**Request body:**

| Field | Type | Required |
|-------|------|----------|
| `refresh` | string | Yes |

**Example response `200`:**
```json
{
  "success": true,
  "message": "Token refreshed successfully.",
  "data": {
    "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

#### POST `/api/v1/auth/logout/`

Blacklist the refresh token.

| | |
|---|---|
| **Auth** | Bearer token required |
| **Status** | Implemented |

**Request body:**

| Field | Type | Required |
|-------|------|----------|
| `refresh` | string | Yes |

**Example response `200`:**
```json
{
  "success": true,
  "message": "Logout successful.",
  "data": null
}
```

---

#### POST `/api/v1/auth/change-password/`

Change password for the authenticated user.

| | |
|---|---|
| **Auth** | Bearer token required |
| **Status** | Implemented |

**Request body:**

| Field | Type | Required |
|-------|------|----------|
| `current_password` | string | Yes |
| `new_password` | string | Yes (min 8) |
| `new_password_confirm` | string | Yes |

**Example response `200`:**
```json
{
  "success": true,
  "message": "Password changed successfully.",
  "data": null
}
```

---

#### GET `/api/v1/users/me/`

Retrieve the authenticated user's profile.

| | |
|---|---|
| **Auth** | Bearer token required |
| **Status** | Implemented |

**Example response `200`:**
```json
{
  "success": true,
  "message": "Profile retrieved successfully.",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "phone_number": "+254712345678",
    "email": "jane@example.com",
    "first_name": "Jane",
    "last_name": "Doe",
    "is_staff": false,
    "date_joined": "2026-07-12T10:00:00+0300",
    "last_login": "2026-07-12T12:00:00+0300"
  }
}
```

---

#### PATCH `/api/v1/users/me/`

Update the authenticated user's profile.

| | |
|---|---|
| **Auth** | Bearer token required |
| **Status** | Implemented |

**Request body (all fields optional):**

| Field | Type |
|-------|------|
| `email` | string |
| `first_name` | string |
| `last_name` | string |

**Example response `200`:**
```json
{
  "success": true,
  "message": "Profile updated successfully.",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "phone_number": "+254712345678",
    "email": "janet@example.com",
    "first_name": "Janet",
    "last_name": "Doe",
    "is_staff": false,
    "date_joined": "2026-07-12T10:00:00+0300",
    "last_login": "2026-07-12T12:00:00+0300"
  }
}
```

---

### 11.2 Roles — **Implemented**

#### GET `/api/v1/roles/`

List all available roles in the system catalog.

| | |
|---|---|
| **Auth** | Bearer token required |
| **Status** | Implemented |

**Example response `200`:**
```json
{
  "success": true,
  "message": "Roles retrieved successfully.",
  "data": [
    {
      "id": "uuid",
      "name": "Chairperson",
      "slug": "chairperson",
      "description": "Leads the Chama and oversees group operations.",
      "is_platform_role": false,
      "created_at": "2026-07-12T10:00:00+0300",
      "updated_at": "2026-07-12T10:00:00+0300"
    },
    {
      "id": "uuid",
      "name": "Administrator",
      "slug": "administrator",
      "description": "Platform administrator with system-wide access.",
      "is_platform_role": true,
      "created_at": "2026-07-12T10:00:00+0300",
      "updated_at": "2026-07-12T10:00:00+0300"
    }
  ]
}
```

**Role slugs:**

| Slug | Name | Platform role |
|------|------|---------------|
| `chairperson` | Chairperson | No |
| `treasurer` | Treasurer | No |
| `secretary` | Secretary | No |
| `committee_member` | Committee Member | No |
| `member` | Member | No |
| `administrator` | Administrator | Yes |

---

### 11.3 Chamas — **Planned**

Manage savings group entities.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/` | Yes | Any authenticated | List Chamas user belongs to |
| `POST` | `/api/v1/chamas/` | Yes | Any authenticated | Create a new Chama |
| `GET` | `/api/v1/chamas/{chama_id}/` | Yes | Member+ | Retrieve Chama details |
| `PATCH` | `/api/v1/chamas/{chama_id}/` | Yes | Chairperson | Update Chama details |
| `DELETE` | `/api/v1/chamas/{chama_id}/` | Yes | Chairperson | Archive Chama (soft delete) |

**Chama object:**

```json
{
  "id": "uuid",
  "name": "Kileleshwa Women Chama",
  "description": "Monthly savings group",
  "location": "Nairobi",
  "currency": "KES",
  "is_active": true,
  "created_by": "uuid",
  "created_at": "2026-07-12T10:00:00+0300",
  "updated_at": "2026-07-12T10:00:00+0300"
}
```

---

### 11.4 Memberships — **Planned**

Link users to Chamas with role assignments.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/members/` | Yes | Member+ | List members (paginated) |
| `POST` | `/api/v1/chamas/{chama_id}/members/` | Yes | Chairperson, Secretary | Add member |
| `GET` | `/api/v1/chamas/{chama_id}/members/{member_id}/` | Yes | Member+ | Member detail |
| `PATCH` | `/api/v1/chamas/{chama_id}/members/{member_id}/` | Yes | Chairperson | Update member role/status |
| `DELETE` | `/api/v1/chamas/{chama_id}/members/{member_id}/` | Yes | Chairperson | Remove member |

**Membership object:**

```json
{
  "id": "uuid",
  "user": {
    "id": "uuid",
    "phone_number": "+254712345678",
    "first_name": "Jane",
    "last_name": "Doe"
  },
  "role": {
    "slug": "treasurer",
    "name": "Treasurer"
  },
  "status": "active",
  "joined_at": "2026-01-15T10:00:00+0300",
  "created_at": "2026-01-15T10:00:00+0300"
}
```

**Membership statuses:** `active`, `suspended`, `left`

---

### 11.5 Contribution Cycles — **Planned**

Define savings periods within a Chama.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/contribution-cycles/` | Yes | Member+ | List cycles |
| `POST` | `/api/v1/chamas/{chama_id}/contribution-cycles/` | Yes | Treasurer, Chairperson | Create cycle |
| `GET` | `/api/v1/chamas/{chama_id}/contribution-cycles/{cycle_id}/` | Yes | Member+ | Cycle detail |
| `PATCH` | `/api/v1/chamas/{chama_id}/contribution-cycles/{cycle_id}/` | Yes | Treasurer | Update cycle |
| `POST` | `/api/v1/chamas/{chama_id}/contribution-cycles/{cycle_id}/close/` | Yes | Treasurer | Close cycle |

**Cycle object:**

```json
{
  "id": "uuid",
  "name": "July 2026 Cycle",
  "amount_expected": "5000.00",
  "start_date": "2026-07-01",
  "end_date": "2026-07-31",
  "status": "open",
  "created_at": "2026-07-01T08:00:00+0300"
}
```

**Cycle statuses:** `open`, `closed`

---

### 11.6 Contributions — **Planned**

Record member savings payments.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/contributions/` | Yes | Member+ | List contributions |
| `POST` | `/api/v1/chamas/{chama_id}/contributions/` | Yes | Treasurer | Record contribution |
| `GET` | `/api/v1/chamas/{chama_id}/contributions/{id}/` | Yes | Member+ | Contribution detail |

**Contribution object:**

```json
{
  "id": "uuid",
  "member_id": "uuid",
  "cycle_id": "uuid",
  "amount": "5000.00",
  "currency": "KES",
  "payment_method": "cash",
  "reference": "CASH-001",
  "recorded_by": "uuid",
  "recorded_at": "2026-07-05T14:00:00+0300",
  "created_at": "2026-07-05T14:00:00+0300"
}
```

**Note:** Contributions are immutable. Corrections use reversal entries (future).

**Payment methods:** `cash`, `mpesa` (future), `bank`

---

### 11.7 Loan Products — **Planned**

Define loan templates offered by a Chama.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/loan-products/` | Yes | Member+ | List products |
| `POST` | `/api/v1/chamas/{chama_id}/loan-products/` | Yes | Chairperson, Treasurer | Create product |
| `GET` | `/api/v1/chamas/{chama_id}/loan-products/{id}/` | Yes | Member+ | Product detail |
| `PATCH` | `/api/v1/chamas/{chama_id}/loan-products/{id}/` | Yes | Chairperson | Update product |

**Loan product object:**

```json
{
  "id": "uuid",
  "name": "Standard Member Loan",
  "min_amount": "5000.00",
  "max_amount": "50000.00",
  "interest_rate": "10.00",
  "term_months": 6,
  "is_active": true,
  "created_at": "2026-07-01T08:00:00+0300"
}
```

---

### 11.8 Loan Applications — **Planned**

Members apply for loans; committee reviews.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/loan-applications/` | Yes | Member+ | List applications |
| `POST` | `/api/v1/chamas/{chama_id}/loan-applications/` | Yes | Member | Submit application |
| `GET` | `/api/v1/chamas/{chama_id}/loan-applications/{id}/` | Yes | Member+ | Application detail |
| `PATCH` | `/api/v1/chamas/{chama_id}/loan-applications/{id}/` | Yes | Applicant (pending only) | Update application |
| `POST` | `/api/v1/chamas/{chama_id}/loan-applications/{id}/approve/` | Yes | Committee | Approve application |
| `POST` | `/api/v1/chamas/{chama_id}/loan-applications/{id}/reject/` | Yes | Committee | Reject application |

**Loan application object:**

```json
{
  "id": "uuid",
  "member_id": "uuid",
  "loan_product_id": "uuid",
  "amount_requested": "20000.00",
  "purpose": "School fees",
  "status": "pending",
  "credit_score": 72,
  "credit_risk_level": "good",
  "approved_amount": null,
  "approved_by": null,
  "created_at": "2026-07-10T09:00:00+0300"
}
```

**Application statuses:** `pending`, `under_review`, `approved`, `rejected`, `disbursed`, `repaid`, `defaulted`

---

### 11.9 Loan Repayments — **Planned**

Record loan repayment transactions.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/loan-applications/{loan_id}/repayments/` | Yes | Member+ | List repayments |
| `POST` | `/api/v1/chamas/{chama_id}/loan-applications/{loan_id}/repayments/` | Yes | Treasurer | Record repayment |
| `GET` | `/api/v1/chamas/{chama_id}/loan-applications/{loan_id}/repayments/{id}/` | Yes | Member+ | Repayment detail |

**Repayment object:**

```json
{
  "id": "uuid",
  "loan_application_id": "uuid",
  "amount": "3500.00",
  "currency": "KES",
  "payment_method": "cash",
  "reference": "REP-001",
  "recorded_by": "uuid",
  "recorded_at": "2026-07-15T11:00:00+0300",
  "created_at": "2026-07-15T11:00:00+0300"
}
```

---

### 11.10 Meetings — **Planned**

Schedule and manage Chama meetings.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/meetings/` | Yes | Member+ | List meetings |
| `POST` | `/api/v1/chamas/{chama_id}/meetings/` | Yes | Secretary, Chairperson | Schedule meeting |
| `GET` | `/api/v1/chamas/{chama_id}/meetings/{id}/` | Yes | Member+ | Meeting detail |
| `PATCH` | `/api/v1/chamas/{chama_id}/meetings/{id}/` | Yes | Secretary | Update meeting |
| `POST` | `/api/v1/chamas/{chama_id}/meetings/{id}/close/` | Yes | Secretary | Close meeting |

**Meeting object:**

```json
{
  "id": "uuid",
  "title": "July Monthly Meeting",
  "agenda": "Review contributions and loan applications",
  "location": "Community Hall",
  "scheduled_at": "2026-07-20T14:00:00+0300",
  "status": "scheduled",
  "created_at": "2026-07-12T10:00:00+0300"
}
```

**Meeting statuses:** `scheduled`, `in_progress`, `completed`, `cancelled`

---

### 11.11 Attendance — **Planned**

Track member presence at meetings.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/meetings/{meeting_id}/attendance/` | Yes | Member+ | List attendance |
| `POST` | `/api/v1/chamas/{chama_id}/meetings/{meeting_id}/attendance/` | Yes | Secretary | Record attendance |
| `PATCH` | `/api/v1/chamas/{chama_id}/meetings/{meeting_id}/attendance/{id}/` | Yes | Secretary | Update attendance |

**Attendance object:**

```json
{
  "id": "uuid",
  "meeting_id": "uuid",
  "member_id": "uuid",
  "status": "present",
  "recorded_at": "2026-07-20T14:30:00+0300"
}
```

**Attendance statuses:** `present`, `absent`, `excused`

---

### 11.12 Committee Voting — **Planned**

Committee votes on loan applications.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/loan-applications/{loan_id}/votes/` | Yes | Committee | List votes |
| `POST` | `/api/v1/chamas/{chama_id}/loan-applications/{loan_id}/votes/` | Yes | Committee | Cast vote |

**Vote object:**

```json
{
  "id": "uuid",
  "loan_application_id": "uuid",
  "voter_id": "uuid",
  "decision": "approve",
  "comment": "Good repayment history",
  "created_at": "2026-07-11T16:00:00+0300"
}
```

**Vote decisions:** `approve`, `reject`, `abstain`

**Rule:** Credit score is advisory. Committee vote is final.

---

### 11.13 Credit Scoring — **Planned**

Transparent, computed credit scores for loan decision support.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/members/{member_id}/credit-scores/` | Yes | Member+ | Score history |
| `GET` | `/api/v1/chamas/{chama_id}/members/{member_id}/credit-scores/current/` | Yes | Member+ | Latest score |
| `POST` | `/api/v1/chamas/{chama_id}/members/{member_id}/credit-scores/recalculate/` | Yes | Treasurer, Chairperson | Trigger recalculation |

**Credit score object:**

```json
{
  "id": "uuid",
  "member_id": "uuid",
  "score": 72,
  "risk_level": "good",
  "breakdown": {
    "contribution_consistency": 28,
    "repayment_history": 25,
    "attendance": 12,
    "membership_duration": 7
  },
  "weights": {
    "contribution_consistency": 0.35,
    "repayment_history": 0.35,
    "attendance": 0.15,
    "membership_duration": 0.15
  },
  "calculated_at": "2026-07-12T10:00:00+0300"
}
```

**Scoring weights (from spec):**

| Factor | Weight |
|--------|--------|
| Contribution consistency | 35% |
| Repayment history | 35% |
| Attendance | 15% |
| Membership duration | 15% |

---

### 11.14 Reports — **Planned**

Generate financial and operational reports.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/reports/contributions/` | Yes | Treasurer+ | Contribution summary |
| `GET` | `/api/v1/chamas/{chama_id}/reports/loans/` | Yes | Treasurer+ | Loan portfolio summary |
| `GET` | `/api/v1/chamas/{chama_id}/reports/financial/` | Yes | Treasurer+ | Full financial report |
| `GET` | `/api/v1/chamas/{chama_id}/reports/{type}/export/` | Yes | Treasurer+ | Export as PDF |

**Query parameters:** `date_from`, `date_to`, `cycle_id`, `format` (`json`, `pdf`)

---

### 11.15 Notifications — **Planned**

In-app alerts for members and officials.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/notifications/` | Yes | Any authenticated | List user notifications |
| `GET` | `/api/v1/notifications/{id}/` | Yes | Owner | Notification detail |
| `PATCH` | `/api/v1/notifications/{id}/` | Yes | Owner | Mark as read |
| `POST` | `/api/v1/notifications/mark-all-read/` | Yes | Any authenticated | Mark all as read |

**Notification object:**

```json
{
  "id": "uuid",
  "title": "Loan vote required",
  "message": "A new loan application from Jane Doe requires your vote.",
  "type": "loan_vote",
  "is_read": false,
  "metadata": {
    "chama_id": "uuid",
    "loan_application_id": "uuid"
  },
  "created_at": "2026-07-12T10:00:00+0300"
}
```

---

### 11.16 Audit Logs — **Planned**

Read-only system audit trail (Administrator and Chairperson).

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/audit-logs/` | Yes | Administrator | Platform-wide logs |
| `GET` | `/api/v1/chamas/{chama_id}/audit-logs/` | Yes | Chairperson | Chama-scoped logs |

**Audit log object:**

```json
{
  "id": "uuid",
  "actor_id": "uuid",
  "action": "contribution.created",
  "entity_type": "contribution",
  "entity_id": "uuid",
  "changes": {
    "amount": "5000.00"
  },
  "ip_address": "192.168.1.1",
  "created_at": "2026-07-12T10:00:00+0300"
}
```

---

### 11.17 Dashboard — **Planned**

Aggregated summary for mobile home screen.

| Method | Endpoint | Auth | Roles | Description |
|--------|----------|------|-------|-------------|
| `GET` | `/api/v1/chamas/{chama_id}/dashboard/` | Yes | Member+ | Chama dashboard summary |

**Dashboard object:**

```json
{
  "chama": { "id": "uuid", "name": "Kileleshwa Women Chama" },
  "summary": {
    "total_members": 24,
    "active_cycle": { "id": "uuid", "name": "July 2026" },
    "contributions_this_cycle": "120000.00",
    "outstanding_loans": "85000.00",
    "pending_loan_applications": 3,
    "next_meeting": { "id": "uuid", "scheduled_at": "2026-07-20T14:00:00+0300" }
  },
  "my_summary": {
    "contributions_paid": "5000.00",
    "contributions_expected": "5000.00",
    "active_loans": 1,
    "credit_score": 72
  }
}
```

---

## 12. OpenAPI / Swagger

Interactive API documentation is auto-generated from Django views.

| Resource | URL |
|----------|-----|
| OpenAPI schema | `GET /api/schema/` |
| Swagger UI | `GET /api/docs/` |
| ReDoc | `GET /api/redoc/` |

- Schema version: `1.0.0`
- Path prefix: `/api/v1`
- All implemented endpoints are annotated with `@extend_schema`

**Rule for both teams:** The OpenAPI schema is the machine-readable companion to this document. When they diverge, update this spec first, then align the code.

---

## 13. Flutter Client Guidelines

### Dio configuration

```dart
// Pseudocode
final dio = Dio(BaseOptions(
  baseUrl: 'http://127.0.0.1:8000/api/v1',
  headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
));

// Attach access token via interceptor
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  },
));
```

### Response parsing

```dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
}
```

### Naming convention mapping

| API (snake_case) | Flutter (camelCase) |
|-----------------|----------------------|
| `phone_number` | `phoneNumber` |
| `first_name` | `firstName` |
| `credit_score` | `creditScore` |
| `is_platform_role` | `isPlatformRole` |
| `created_at` | `createdAt` |

Use `@JsonSerializable(fieldRename: FieldRename.snake)` or equivalent.

### Chama context

After login, the app stores the user's Chama memberships. Most API calls require a selected `chamaId` inserted into the URL path:

```
/chamas/{chamaId}/contributions/
```

---

## Appendix A — Endpoint Summary Table

| Module | Endpoints | Status |
|--------|-----------|--------|
| Authentication | 5 | Implemented |
| Users | 2 | Implemented |
| Roles | 1 | Implemented |
| Chamas | 5 | Planned |
| Memberships | 5 | Planned |
| Contribution Cycles | 5 | Planned |
| Contributions | 3 | Planned |
| Loan Products | 4 | Planned |
| Loan Applications | 6 | Planned |
| Loan Repayments | 3 | Planned |
| Meetings | 5 | Planned |
| Attendance | 3 | Planned |
| Committee Voting | 2 | Planned |
| Credit Scoring | 3 | Planned |
| Reports | 4 | Planned |
| Notifications | 4 | Planned |
| Audit Logs | 2 | Planned |
| Dashboard | 1 | Planned |

**Total:** 8 implemented · 52 planned · 60 overall

---

## Appendix B — Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | July 2026 | Initial API specification |

---

*This document is the contract between the Flutter and Django teams. All new endpoints must be added here before implementation begins.*
