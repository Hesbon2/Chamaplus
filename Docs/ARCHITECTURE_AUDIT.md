# Architecture & Quality Audit — Flutter Mobile

**Date:** 1 August 2026  
**Scope:** `Mobile/` (ChamaPlus Flutter client)  
**Mode:** Audit + remediation only (no new product features)

---

## Executive Summary

The Flutter app already follows a solid feature-first architecture (Repository → Riverpod controllers → GoRouter → shared Design System / Forms / API State / Charts / Reports). This audit closed the highest-risk gaps: **deep-link loss during auth bootstrap**, **dual design-system widgets**, **auth screens outside the form framework**, **KPI widget duplication**, and **hub UI copy-paste**.

Quality gates after remediation:

- `flutter analyze` — no errors (pre-existing infos remain elsewhere)
- `flutter test` — all tests passing

Settings remains a deliberate placeholder; production hardening / Settings UI are out of scope.

---

## Issues Found

| Priority | Area | Issue |
|----------|------|--------|
| P0 | Navigation | Deep links discarded when redirecting to splash/login |
| P1 | Design system | Duplicate `core/widgets` stack vs `shared/components` + `shared/forms` |
| P1 | Forms | No `AppPasswordField`; login/forgot used legacy core widgets |
| P1 | Forms | My Chamas / Members used raw `TextField` instead of `AppSearchField` |
| P1 | API state | Meeting minutes / action items hid load errors behind empty UI |
| P1 | Performance | Dashboard watched full `authControllerProvider` |
| P1 | Design system | `StatCard` / `SummaryMetricTile` / `DashboardStatCard` triplicated KPI UI |
| P1 | Design system | Four hub screens duplicated chama picker tiles |
| P2 | Accessibility | Missing semantics on primary actions / KPI tiles |
| P2 | API state | Some loan/apply screens still use `AsyncValue.when` (deferred) |
| P2 | Presentation | A few screens call repositories directly (deferred — not Dio leakage) |

---

## Issues Fixed

### Navigation (P0)
- Added `pendingDeepLinkProvider` + `isEphemeralAuthLocation`
- Router captures intended URI before splash/login/onboarding redirects and restores after auth

### Design system
- Deleted unused/legacy core widgets: empty/error/loading, confirmation dialog, primary/secondary buttons, core `AppTextField`
- `core/widgets` now exports only `AppSnackbar`
- `StatCard` → thin alias over `SummaryMetricTile`
- Removed `DashboardStatCard`; dashboard uses `SummaryMetricTile` directly
- Added shared `ChamaHubTile`; Loans / Contributions / Meetings / Reports hubs consume it
- Auth scaffold uses `AppCard`

### Forms
- Added `AppPasswordField` (visibility toggle, autofill, validation)
- Login / Forgot password / Register migrated to shared form framework
- `AppTextField` gained `autofillHints`
- My Chamas + Members use `AppSearchField`

### API state / UX
- Meeting action items: `ShimmerLoader` + error `EmptyState` + retry
- Meeting minutes: same pattern for failed loads
- Empty action-items copy uses `EmptyState`

### Performance
- Dashboard provider selects `userId` / `displayName` / `isAuthenticated` only

### Accessibility
- `ActionButton` / `SummaryMetricTile` / `ChamaHubTile` / auth brand header semantics
- Password visibility tooltips; back button tooltip

---

## Performance Improvements

1. Narrowed dashboard auth watches → fewer accidental dashboard reloads  
2. Shared hub tile → less widget duplication / smaller rebuild surface  
3. KPI consolidation → single implementation path  

---

## Refactors

| Before | After |
|--------|--------|
| Dual DS (`core/widgets` + `shared/*`) | Single DS; snackbar-only core utils |
| Hand-rolled password fields | `AppPasswordField` |
| Duplicated hub cards | `ChamaHubTile` |
| Three KPI widgets | `SummaryMetricTile` (+ `StatCard` alias) |
| Lost deep links | Pending destination restore |

---

## Code Cleanup

Removed:

- `lib/core/widgets/{empty_state,error_state,loading_indicator,confirmation_dialog,primary_button,secondary_button,app_text_field}.dart`
- `lib/features/dashboard/presentation/widgets/dashboard_stat_card.dart`
- Unused import in notification provider tests

---

## Remaining Low-Priority Recommendations

1. **Settings module** — replace placeholder when product-ready  
2. Migrate `apply_loan` / `loan_calculator` / `member_details` / `record_contribution` async branches fully onto `ApiStateBuilder`  
3. Prefer controllers over direct repository calls on invite/create/join/export forms  
4. Extract `MemberListTile` / `ChamaListTile` for list screens  
5. Convert loan details InfoTile timeline → `TimelineCard`  
6. Use named GoRouter navigation where useful  
7. Golden suite for core DS widgets beyond `SummaryMetricTile`  
8. Production hardening (crash reporting, env flavors, certificate pinning) — separate track  

---

## Files Changed (primary)

- `lib/core/routing/app_router.dart`, `pending_deep_link.dart`
- `lib/core/widgets/widgets.dart` (+ deleted legacy widgets)
- `lib/shared/forms/app_password_field.dart`, `app_text_field.dart`, `forms.dart`
- `lib/shared/components/{stat_card,summary_metric_tile,chama_hub_tile,action_button,components}.dart`
- Auth screens + `auth_scaffold.dart`
- Hub screens (loans/contributions/meetings/reports)
- `my_chamas_screen.dart`, `members_screen.dart`
- `dashboard_provider.dart`, `dashboard_content.dart`
- Meeting minutes + action items screens
- Tests: forms, pending deep link, notifications cleanup
- `README.md`, `Docs/PROJECT_STATUS.md`, this document

---

## Deliverable Checklist

| Gate | Status |
|------|--------|
| No duplicated DS widgets in features | Improved (hubs/KPIs/auth) |
| No Dio from UI | Verified clean |
| Form framework for auth + amounts | Fixed |
| Deep-link restore | Fixed |
| Accessibility improvements | Applied on shared primitives |
| Docs | This file + README / PROJECT_STATUS updates |
