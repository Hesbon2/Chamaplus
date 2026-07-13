# ChamaPlus

Digital platform for Kenyan savings groups (Chamas) — contributions, loans, meetings, governance, and reporting.

## Repository structure

| Directory | Purpose |
|-----------|---------|
| `Backend/` | Django REST API (complete) |
| `mobile/` | Flutter mobile client |
| `Docs/` | Project specs, API docs, coding standards |

## Mobile app (`mobile/`)

Flutter foundation for the ChamaPlus mobile client. Feature modules (auth, chamas, loans, etc.) are scaffolded but not yet implemented.

### Tech stack

- **Flutter** with **Material 3**
- **Riverpod** — dependency injection and state management
- **GoRouter** — declarative navigation
- **Dio** — HTTP client for the Django API
- **Google Fonts** — Inter typography
- **flutter_secure_storage** — token persistence
- **flutter_dotenv** — environment configuration
- **connectivity_plus** — network status monitoring

### Architecture

The mobile app follows a **feature-first** layout with a shared **core** layer:

```
lib/
├── main.dart              # Entry point, loads .env, starts ProviderScope
├── app.dart               # MaterialApp.router root widget
├── core/                  # Cross-cutting infrastructure
│   ├── api/               # Dio client, interceptors, API envelope
│   ├── config/            # Environment (.env) loading
│   ├── constants/         # App and API constants
│   ├── errors/            # AppException types, ErrorHandler
│   ├── routing/           # GoRouter configuration
│   ├── services/          # ConnectivityService
│   ├── storage/           # SecureStorageService (tokens)
│   ├── theme/             # Colors, spacing, typography, Material 3 themes
│   ├── utils/             # Logger and helpers
│   └── widgets/           # Reusable UI components
├── shared/                # Cross-feature models and components
│   ├── models/
│   └── components/
└── features/              # One folder per domain feature
    ├── auth/
    ├── dashboard/         # HomeScreen placeholder only
    ├── chamas/
    ├── contributions/
    ├── loans/
    ├── meetings/
    ├── reports/
    ├── notifications/
    ├── profile/
    └── settings/
```

**Data flow (planned for features):**

```
UI (feature/presentation)
  → Riverpod providers (feature/application)
    → Repositories (feature/data)
      → ApiClient (core/api) → Django API
```

**Core services wired at startup:**

| Service | Role |
|---------|------|
| `EnvConfig` | Loads `API_BASE_URL` and timeouts from `.env` |
| `ApiClient` | Global Dio instance with auth interceptor |
| `ErrorHandler` | Maps Dio/network errors to `AppException` |
| `SecureStorageService` | Persists access/refresh tokens |
| `ConnectivityService` | Streams online/offline status |
| `themeModeProvider` | Light / dark / system theme switching |

### Getting started

**Prerequisites:** Flutter SDK 3.19+, Dart 3.3+

```bash
cd mobile
cp .env.example .env   # adjust API_BASE_URL if needed
flutter pub get
flutter run
```

**API base URL notes:**

| Target | `API_BASE_URL` |
|--------|----------------|
| iOS Simulator / desktop | `http://127.0.0.1:8000/api/v1` |
| Android Emulator | `http://10.0.2.2:8000/api/v1` |
| Physical device | Your machine's LAN IP, e.g. `http://192.168.x.x:8000/api/v1` |

Start the Django backend from `Backend/` before testing API calls.

### Reusable widgets

Located in `lib/core/widgets/`:

- `PrimaryButton`, `SecondaryButton`
- `AppTextField`
- `LoadingIndicator`, `EmptyState`, `ErrorState`
- `ConfirmationDialog`, `AppSnackbar`

### Verify build

```bash
cd mobile
flutter analyze
flutter test
```

## Backend

See `Docs/API_SPEC.md` for endpoint documentation and `Docs/PROJECT_STATUS.md` for implementation status.

## License

Proprietary — ChamaPlus project.
