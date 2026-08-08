# ChamaPlus Mobile

Flutter client for Kenyan savings groups (Chamas).

## Architecture

Feature-first modules under `lib/features/`:

- `data/` — Dio API clients, DTOs, repository implementations
- `domain/` — immutable entities + repository contracts
- `presentation/` — Riverpod controllers/providers, screens, widgets

Shared frameworks:

- Design system — `lib/shared/components/` (including `SummaryMetricTile`, `ChamaHubTile`)
- Forms — `lib/shared/forms/` (`AppAmountField`, `AppPasswordField`, …; decimal formatters must interpolate — never `$var` inside raw `r'...'`)
- API state — `lib/shared/api_state/`
- Charts — `lib/shared/charts/`
- Reports — `lib/shared/reports/` + feature screens in `lib/features/reports/`

API base URL defaults to `http://127.0.0.1:8000/api/v1` (see `.env` / `EnvConfig`).

## Application shell

Path: `lib/shared/navigation/`

Persistent bottom navigation is implemented with GoRouter
`StatefulShellRoute.indexedStack` so each tab keeps its own navigator stack.

### Bottom navigation

| Tab | Route | Screen |
|-----|-------|--------|
| Home | `/home` | Dashboard |
| Chamas | `/chamas` | My chamas (+ nested chama features) |
| Loans | `/loans` | Loans hub (pick chama) |
| Alerts | `/alerts` | Alerts tab (notifications-ready) |
| More | `/more` | Overflow: governance, contributions, profile, reports, settings |

Full-screen destinations that cover the shell (root navigator):

- `/contributions`, `/meetings`, `/reports` (hubs — pick a chama)
- `/settings` (+ appearance, security, notifications, help, about; diagnostics in debug only)
- `/profile`, `/profile/edit`

### Shell building blocks

| File | Role |
|------|------|
| `app_shell.dart` | Wraps `StatefulNavigationShell` |
| `app_shell_scaffold.dart` | Scaffold + FAB + bottom nav |
| `app_bottom_navigation.dart` | Material 3 `NavigationBar` |
| `navigation_provider.dart` | Badge counts + shell context |
| `role_navigation_service.dart` | Role-aware quick actions |
| `quick_actions_sheet.dart` | FAB modal sheet |
| `navigation_badge.dart` | Reusable badge overlay |

### Home FAB

Shown only on the Home tab. Opens `QuickActionsSheet` with actions from
`RoleNavigationService` based on the active chama role (chairperson, treasurer,
secretary, committee member, member).

### Reusable widgets

- `NavigationBadge`
- `QuickActionTile`
- `BottomNavItem`

Import via:

```dart
import 'package:chamaplus_mobile/shared/navigation/navigation.dart';
```

## Chamas & membership RBAC

Path: `lib/features/chamas/`

### Role helpers (`AppMemberRole`)

| Capability | Roles |
|------------|-------|
| Invite members | Chairperson, Secretary |
| Manage roles / status / join-request approve·reject | Chairperson only |
| View members / chama details | Any active member |

Uses `currentMemberRoleProvider` (from dashboard `userRole`). Backend remains authoritative.

### Membership management

- **Member details (chairperson):** Change role (`PATCH /memberships/{id}/role/` with `{ "role": "<slug>" }`), suspend / reactivate / mark left / approve pending (`PATCH /memberships/{id}/status/`).
- **Invite:** Chairperson & secretary only (FAB + chama details). Assignable roles: chairperson, treasurer, secretary, committee_member, member.
- **Join requests:** Approve/Reject buttons only for chairperson; other roles see a read-only pending list if they open the route.
- **Pending invitations (invitee):** `/pending-invitations` lists the authenticated user's pending phone invitations (`GET /memberships/pending/`). Accept (`POST /memberships/{id}/accept/`) activates membership and exits onboarding; decline (`POST /memberships/{id}/decline/`) maps to status `left`. Welcome onboarding links here.

### API mapping

| Client | Backend |
|--------|---------|
| `POST /chamas/{id}/invite/` | Invite by phone |
| `GET /chamas/{id}/members/` | List members (`?status=pending` for join requests) |
| `GET /memberships/pending/` | List my pending invitations |
| `POST /memberships/{id}/accept/` | Accept invitation (invitee) |
| `POST /memberships/{id}/decline/` | Decline invitation (invitee → `left`) |
| `PATCH /memberships/{id}/role/` | Update role (chairperson) |
| `PATCH /memberships/{id}/status/` | Update status (chairperson) |

## Loans module

Path: `lib/features/loans/`

### Routes

| Route | Screen |
|-------|--------|
| `/loans` | Loans hub (pick chama) |
| `/chamas/:chamaId/loans` | Loan dashboard |
| `/chamas/:chamaId/loans/products` | Loan products (role-aware empty + create FAB) |
| `/chamas/:chamaId/loans/products/create` | Create loan product (chairperson / treasurer) |
| `/chamas/:chamaId/loans/products/:productId` | Product details (edit/delete for chairperson) |
| `/chamas/:chamaId/loans/products/:productId/edit` | Edit loan product (chairperson) |
| `/chamas/:chamaId/loans/calculator` | Loan calculator |
| `/chamas/:chamaId/loans/apply` | Apply for loan |
| `/chamas/:chamaId/loans/history` | Loan history |
| `/chamas/:chamaId/loans/applications/:id` | Application details |
| `/chamas/:chamaId/loans/applications/:id/vote` | Committee voting |
| `/chamas/:chamaId/loans/applications/:id/repayments` | Repayment history |
| `/chamas/:chamaId/loans/applications/:id/active` | Active loan |

### API mapping

All paths are relative to `/api/v1` and chama-scoped:

| Client helper | Backend |
|---------------|---------|
| `GET /chamas/{id}/loan-products/` | List products |
| `POST /chamas/{id}/loan-products/` | Create product (chairperson / treasurer) |
| `GET /chamas/{id}/loan-products/{pid}/` | Product detail |
| `PATCH /chamas/{id}/loan-products/{pid}/` | Update product (chairperson) |
| `DELETE /chamas/{id}/loan-products/{pid}/` | Delete product (chairperson) |
| `GET/POST /chamas/{id}/loan-applications/` | List / apply |
| `POST .../loan-applications/{aid}/submit\|cancel\|approve\|reject\|disburse/` | Lifecycle |
| `GET/POST .../loan-applications/{aid}/votes/` | Committee votes |
| `GET/POST .../loan-applications/{aid}/repayments/` | Repayments |
| `GET /chamas/{id}/members/{mid}/credit-scores/current/` | Credit score (optional) |

Envelope responses `{ success, message, data }` are unwrapped in `LoanApi`.

### Loan product management (mobile)

- **Chairperson:** create, edit, delete products; members can still apply when a product is active.
- **Treasurer:** create products; no edit/delete UI (backend rejects PATCH/DELETE).
- **Other members:** view products and apply; empty state does not prompt them to create.
- Role checks use `AppMemberRole` / `currentMemberRoleProvider` (`canCreateLoanProduct`, `canManageLoanProducts`); the API remains authoritative.
- Form fields match the backend serializers: name, description, interest rate, min/max amount, maximum duration, grace period days, processing fee, `is_active`.

### Shared progress widget

`ProgressStatCard` (`lib/shared/components/progress_stat_card.dart`) is generic and reused for loan outstanding progress, repayment progress, calculator principal share, and voting progress.

## Meetings / Governance module

Path: `lib/features/meetings/`

### Routes

| Route | Screen |
|-------|--------|
| `/meetings` | Meetings hub (pick chama) |
| `/chamas/:chamaId/meetings` | Governance dashboard |
| `/chamas/:chamaId/meetings/list` | All meetings |
| `/chamas/:chamaId/meetings/upcoming` | Upcoming meetings |
| `/chamas/:chamaId/meetings/schedule` | Schedule meeting |
| `/chamas/:chamaId/meetings/:meetingId` | Meeting details |
| `/chamas/:chamaId/meetings/:meetingId/attendance` | Attendance |
| `/chamas/:chamaId/meetings/:meetingId/minutes` | Minutes (save / approve) |
| `/chamas/:chamaId/meetings/:meetingId/action-items` | Action items (from minutes JSON) |

### API mapping

All paths are relative to `/api/v1` and chama-scoped. Meetings are not paginated.

| Client helper | Backend |
|---------------|---------|
| `GET/POST /chamas/{id}/meetings/` | List / schedule |
| `GET/PATCH/DELETE /chamas/{id}/meetings/{mid}/` | Detail / update / cancel |
| `POST .../meetings/{mid}/start/` | Start meeting |
| `POST .../meetings/{mid}/close/` | Close meeting |
| `GET/POST .../meetings/{mid}/attendance/` | Roster / record |
| `PATCH .../meetings/{mid}/attendance/{aid}/` | Update attendance |
| `GET/POST/PATCH .../meetings/{mid}/minutes/` | Minutes CRUD |
| `POST .../meetings/{mid}/minutes/approve/` | Approve minutes |

Statuses: `scheduled \| ongoing \| completed \| cancelled`. Attendance: `present \| late \| absent \| excused`. Action items live in minutes JSON (`action_items`), not a separate CRUD API.

Envelope responses `{ success, message, data }` are unwrapped in `MeetingApi`.

### Shared widgets

- `TimelineCard` (`lib/shared/components/timeline_card.dart`) — generic lifecycle / progress timeline reused on governance dashboard, meeting details, minutes, and action items.
- `ProgressStatCard` — meeting completion progress on the governance dashboard.

## Notifications module

Path: `lib/features/notifications/`

### Routes (Alerts shell tab)

| Route | Screen |
|-------|--------|
| `/alerts` | Notifications dashboard |
| `/alerts/list` | Full inbox (optional `?unread=1`) |
| `/alerts/:notificationId` | Notification details + deep link |

### API mapping

Relative to `/api/v1`:

| Client helper | Backend |
|---------------|---------|
| `GET /notifications/` | Paginated list (`is_read`, `page`, `page_size`, `ordering`) |
| `GET /notifications/{id}/` | Detail |
| `PATCH /notifications/{id}/` | Mark one read (`{ "is_read": true }`) |
| `POST /notifications/mark-all-read/` | Mark all read → `{ updated_count }` |

### Shared widget

`NotificationCard` (`lib/shared/components/notification_card.dart`) is generic for notifications, announcements, and future inbox channels. Reused on the dashboard, list, and details screens.

### Navigation badge

`notificationUnreadCountProvider` feeds `navigationBadgesProvider.alerts` so the Alerts tab badge updates when items are marked read.

### Deep links

`NotificationDeepLink` routes by `notification_type` + `metadata` into Loans, Contributions, Meetings, Chama details, or Home.

## Reports & Analytics module

Path: `lib/features/reports/`

### Routes

| Route | Screen |
|-------|--------|
| `/reports` | Reports hub (pick chama) |
| `/chamas/:id/reports` | Reports home (KPIs + chart suite) |
| `/chamas/:id/reports/monthly` | Monthly report |
| `/chamas/:id/reports/financial` | Financial report |
| `/chamas/:id/reports/member-statement` | Member statement (`?memberId=` optional) |
| `/chamas/:id/reports/export` | Export center (PDF / CSV / share / download) |

### API mapping

Relative to `/api/v1` and chama-scoped:

| Client | Backend |
|--------|---------|
| `GET .../reports/monthly/?year&month` | Monthly aggregates |
| `GET .../reports/contributions/` | Contribution totals |
| `GET .../reports/loans/` | Loan portfolio KPIs |
| `GET .../reports/repayments/` | Repayment totals |
| `GET .../reports/financial/` | Combined financial overview |
| `GET .../reports/members/{id}/financial/` | Member statement snapshot |

Exports are generated on-device via shared `ReportExportService` (not the server export endpoint).

### Shared pieces

- `SummaryMetricTile` — generic KPI tile (title, value, trend, percentage, icon, footer)
- Charts from `lib/shared/charts/` (no duplicated fl_chart code)
- `ReportCard`, `ExportButton`, `runReportExportFlow` from `lib/shared/reports/`

### Charts on Reports home

Monthly contributions, loan outstanding, repayments, loan portfolio mix, meeting attendance, and optional personal credit score.

## Shared analytics infrastructure

Used by the Reports module and Dashboard.

### Charts — `lib/shared/charts/`

| Widget | Role |
|--------|------|
| `ChartCard` | Title, legend, loading, empty, responsive body |
| `ChartHeader` / `ChartLegend` | Titles and series keys |
| `ChartLoading` / `ChartEmptyState` | Async placeholders |
| `AppLineChart` | Multi/single series lines |
| `AppBarChart` | Category bars |
| `AppPieChart` | Donut / pie with touch badges |
| `AppAreaChart` | Filled trend area |

Import:

```dart
import 'package:chamaplus_mobile/shared/charts/charts.dart';
```

Dashboard monthly trends already use this kit (no duplicate fl_chart code in the feature).

### Reports / export — `lib/shared/reports/`

| Piece | Role |
|-------|------|
| `ReportCard` | Report library / export list tile |
| `ExportButton` | CTA |
| `ExportDialog` | PDF/CSV + share vs download |
| `ExportProgressDialog` | Progress 0–1 |
| `ExportSuccessDialog` | Success path |
| `ReportExportService` | Generate PDF/CSV + progress + errors |
| `FileShareService` | Temp write, documents save, share sheet |
| `runReportExportFlow` | Standard dialog → progress → success UX |

Report screens build a `ReportExportRequest` and call `runReportExportFlow` / `ReportExportService` — do not fork export logic.

## Auth & session

Path: `lib/features/auth/` (+ onboarding gate under `lib/features/onboarding/`)

### Session cleanup

`performSecureLogout` / `performSecureLogoutWithReader` (`lib/shared/auth/session_cleanup.dart`) is the canonical teardown for logout and JWT session expiry:

- Clears dashboard in-memory cache and **offline GET cache**
- Server logout (or local expire when tokens already cleared)
- Resets onboarding gate to `unknown`, clears pending deep link
- Invalidates profile, dashboard, chamas, pending invitations, notifications

Welcome and settings use this helper (not bare `AuthController.logout()` alone).

### Onboarding gate

`resolveOnboardingGate` maps empty chamas → `needsOnboarding`, active membership → `ready`. **Network / API failures → `unresolved`** (splash retry), never Welcome. Authenticated + `unknown|unresolved` stay on splash until resolved.

### Forgot / reset password

| Route | Screen |
|-------|--------|
| `/forgot-password` | Two-step: request code → OTP + new password |

Wired to `POST /api/v1/auth/forgot-password/` and `POST /api/v1/auth/reset-password/`. Shared form widgets (`AppTextField`, `AppSubmitButton`). In DEBUG, backend may return `debug_reset_code` (SMS/email delivery still stubbed server-side).

## Settings & Profile module

Path: `lib/features/settings/` (+ profile screens under `lib/features/profile/`)

### Routes

| Route | Screen |
|-------|--------|
| `/settings` | Settings home |
| `/settings/appearance` | Theme: System / Light / Dark (persisted) |
| `/settings/security` | Change password |
| `/settings/notifications` | Local notification preference toggles |
| `/settings/help` | Help & support |
| `/settings/about` | Version & about |
| `/settings/diagnostics` | **Debug only** (`kDebugMode`) — never in release |
| `/profile` | Profile overview |
| `/profile/edit` | Edit profile |

### Shared widgets

- `SettingsTile`, `ProfileHeader`, `ThemeSelector` in `lib/shared/components/`

### Persistence

- Theme + notification prefs: `PreferencesStorage` (`shared_preferences`)
- Tokens: `SecureStorageService` (cleared on logout)

### Logout

Uses `performSecureLogout` (see Auth & session above).

## Production readiness (RC1)

See:

- [`Docs/PRODUCTION_HARDENING.md`](../Docs/PRODUCTION_HARDENING.md)
- [`Docs/RELEASE_CHECKLIST.md`](../Docs/RELEASE_CHECKLIST.md)
- [`Docs/DEPLOYMENT_GUIDE.md`](../Docs/DEPLOYMENT_GUIDE.md)

Network stack: timeouts, connectivity gate, offline GET cache, JWT refresh, retries, debug-only redacted logging.

## Run

```bash
flutter pub get
flutter run
flutter test
flutter analyze
```

Release artifacts:

```bash
flutter build apk --release
flutter build appbundle --release
```

Architecture audit notes: see repo root [`Docs/ARCHITECTURE_AUDIT.md`](../Docs/ARCHITECTURE_AUDIT.md).
