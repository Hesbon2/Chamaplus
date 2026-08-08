# ChamaPlus Mobile — Deployment Guide

## Prerequisites

- Flutter stable (SDK compatible with `pubspec.yaml`: `>=3.3.0 <4.0.0`)
- Android SDK 34 / build-tools matching the Flutter toolchain
- Backend API reachable over the network configured in `.env`

## Configure environment

Environment files ship with the app:

| File | When used |
|------|-----------|
| `.env.development` | Debug / profile (`flutter run`) |
| `.env.production` | Release builds |

Force or override:

```bash
flutter run --dart-define=APP_ENV=production
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

Android emulator: development loopback URLs are rewritten to `10.0.2.2` automatically. See [`LOCAL_SETUP.md`](./LOCAL_SETUP.md).

For a one-off local override without editing committed files, prefer `--dart-define=API_BASE_URL=...`.

## Signing (Android)

1. Generate an upload keystore (once):

```bash
keytool -genkey -v -keystore chamaplus-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias chamaplus
```

2. Copy `android/key.properties.example` → `android/key.properties` and fill secrets.
3. Keep `*.jks` / `key.properties` out of git (already gitignored).

Without `key.properties`, release builds fall back to the debug keystore (local smoke only — not for Play).

## Build Release Candidate artifacts

```bash
cd Mobile
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

Outputs:

- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

## Versioning

| Field | Location | RC1 value |
|-------|----------|-----------|
| Version name | `pubspec.yaml` / Play | `1.0.0-rc.1` |
| Build number | `+N` in pubspec | `2` |
| In-app string | `AppConstants.appVersion` | `1.0.0-rc.1+2` |

Bump `+N` for every store upload. Bump semver for user-facing releases.

## Backend coordination

1. Deploy Django with production settings (`chamaplus_backend.settings.production`).
2. Confirm CORS / allowed hosts include the mobile API base URL host.
3. Confirm JWT refresh + change-password endpoints match `ApiConstants`.
4. Run backend test suite before promoting the API that RC1 points at.

## Install / distribute

- **Internal QA:** sideload the release APK or use Play internal testing with the AAB.
- **Play Console:** create release → upload AAB → smoke on internal track → promote.

## Rollback

- Play: halt production rollout / promote previous AAB.
- API: keep prior backend release compatible with RC1 contracts (`Docs/API_SPEC.md`).

## Related docs

- [PRODUCTION_HARDENING.md](./PRODUCTION_HARDENING.md)
- [RELEASE_CHECKLIST.md](./RELEASE_CHECKLIST.md)
- [Mobile/README.md](../Mobile/README.md)
