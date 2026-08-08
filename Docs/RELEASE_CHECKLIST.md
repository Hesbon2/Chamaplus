# ChamaPlus Mobile — Release Checklist (RC1)

Use this checklist before tagging **v1.0.0-rc.1**.

## Build identity

- [ ] `pubspec.yaml` version is `1.0.0-rc.1+2` (or next RC bump)
- [ ] `AppConstants.appVersion` matches pubspec
- [ ] Android `applicationId` is `com.chamaplus.chamaplus_mobile`
- [ ] Launcher label shows **ChamaPlus**
- [ ] Adaptive icon + splash render on a physical device

## Environment

- [ ] Production `.env` uses **HTTPS** `API_BASE_URL`
- [ ] `.env` is not committed (gitignored)
- [ ] Timeouts tuned for production networks (`API_CONNECT_TIMEOUT_MS` / `API_RECEIVE_TIMEOUT_MS`)

## Signing

- [ ] Upload keystore created and backed up offline
- [ ] `android/key.properties` created from `key.properties.example` (not committed)
- [ ] `flutter build appbundle --release` signs with the upload key
- [ ] Play App Signing enrollment completed (if publishing)

## Quality gates

```bash
cd Mobile
flutter analyze
flutter test
```

- [ ] `flutter analyze` has no errors (infos/lints triage acceptable)
- [ ] `flutter test` — all tests pass
- [ ] Manual smoke: login, dashboard, chama list, contributions, loans, meetings, notifications, reports, settings, logout
- [ ] Airplane mode: previously loaded lists still show; offline banner visible; mutations blocked with friendly error

## Security spot-checks

- [ ] No tokens in logcat on a debug build (Authorization redacted)
- [ ] Logout clears secure storage and offline cache (re-open app → login)
- [ ] Diagnostics route absent from release builds
- [ ] Clipboard copy of invite/support email works; JWT-like strings blocked

## Artifacts

```bash
flutter build apk --release
flutter build appbundle --release
```

- [ ] APK installs and launches
- [ ] AAB uploaded to Play internal testing track (optional for RC1)

## Sign-off

| Role | Name | Date |
|------|------|------|
| Engineering | | |
| QA | | |
| Product | | |
