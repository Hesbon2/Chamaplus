# ChamaPlus Mobile — Production Hardening (RC1)

**Version:** 1.0.0-rc.1+2  
**Date:** August 1, 2026  
**Scope:** Flutter client only — no new business features.

This document records what the Production Hardening Sprint delivered for Release Candidate 1.

---

## Phase 1 — Offline caching

GET responses for chama-scoped and notification APIs are persisted in `OfflineCacheStore` (`SharedPreferences`, 12h TTL) via `OfflineCacheInterceptor`.

| Domain | Mechanism |
|--------|-----------|
| Dashboard | Aggregated in-memory TTL + underlying GET disk cache |
| Chamas / members | Disk GET cache |
| Contributions | Disk GET cache |
| Loans | Disk GET cache |
| Meetings | Disk GET cache |
| Notifications | Disk GET cache |
| Reports | Disk GET cache |
| Profile (`/users/me/`) | Disk GET cache (supports offline session UI) |

Writes (POST/PUT/PATCH/DELETE) invalidate related path prefixes. Logout clears the entire offline cache.

---

## Phase 2 — Network layer

| Component | File |
|-----------|------|
| Timeouts | `TimeoutInterceptor` + `BaseOptions` (connect/receive/send) |
| Connectivity | `ConnectivityInterceptor` + `ConnectivityService` |
| Offline / stale GET | `OfflineCacheInterceptor` |
| JWT attach + refresh | `AuthInterceptor` + `TokenRefreshService` |
| Retries (idempotent GET) | `RetryInterceptor` (backoff, max 2) |
| Debug logging | `DebugLoggingInterceptor` (redacts Authorization; debug only) |

---

## Phase 3 — Authentication

- Encrypted SharedPreferences (Android) + Keychain (`first_unlock_this_device`) on iOS
- JWT refresh with single-flight deduplication
- `restoreSession` retries via refresh; keeps tokens on transient network failures
- Auto-login path unchanged (splash → `restoreSession`)
- `performSecureLogout` clears tokens, dashboard cache, offline cache, onboarding gate, deep link, and key providers

---

## Phase 4 — Error handling

- Friendly `ErrorHandler` messages (no API_BASE_URL leaks in UI)
- `ApiStateBuilder` offline-aware titles + retry
- `OfflineBanner` in app shell
- Global `FlutterError` / `PlatformDispatcher` handlers + release `ErrorWidget`

---

## Phase 5 — Performance

- List screens already use builder/pagination (`PagedResult`, page size 20)
- Button / settings min height 48dp
- Text scale clamped 0.85–1.4
- In-memory dashboard TTL reduces duplicate aggregation work

---

## Phase 6 — Accessibility

- Semantics on `ActionButton` / `SettingsTile`
- Minimum 48dp touch targets on settings rows and primary buttons
- Large font support via text scaler clamp
- Brand contrast preserved (green primary on light/dark themes)
- Landscape allowed via existing `configChanges`

---

## Phase 7 — Security

- No tokens in SharedPreferences; secrets only in secure storage
- Logger redacts Bearer / password / token patterns (debug only)
- `SafeClipboard` blocks JWT-like clipboard copies
- Debug HTTP logging never prints Authorization values
- Signing keystore files gitignored; `key.properties.example` provided

---

## Phase 8 — Release prep

- Version `1.0.0-rc.1+2`
- Adaptive icon (`mipmap-anydpi-v26`) + branded splash
- App label **ChamaPlus**
- Release signing wired when `android/key.properties` exists

---

## Remaining recommendations (post-RC1)

1. Enable R8/ProGuard + obfuscation for Play Store builds  
2. Disable cleartext traffic when production API is HTTPS-only  
3. Add `package_info_plus` for runtime version in About  
4. Server-backed notification preference sync  
5. Optional Hive/Isar for larger offline datasets  
6. Screenshot / integration tests on CI with device farm  
7. Certificate pinning for production API host  
