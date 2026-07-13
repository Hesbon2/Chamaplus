# ChamaPlus

Digital platform for Kenyan savings groups (Chamas) — contributions, loans, meetings, governance, and reporting.

## Repository structure

| Directory | Purpose |
|-----------|---------|
| `Backend/` | Django REST API (complete) |
| `mobile/` | Flutter mobile client |
| `Docs/` | Project specs, API docs, coding standards |

## Mobile app (`mobile/`)

Flutter client for ChamaPlus with a complete **authentication module** and foundation for domain features.

### Tech stack

- **Flutter** with **Material 3**
- **Riverpod** — dependency injection and state management
- **GoRouter** — declarative navigation with route guards
- **Dio** — HTTP client with JWT refresh interceptor
- **Google Fonts** — Inter typography
- **flutter_secure_storage** — secure JWT token persistence
- **flutter_dotenv** — environment configuration
- **connectivity_plus** — network status monitoring

### Architecture

The mobile app follows a **feature-first** layout with a shared **core** layer:

```
lib/
├── main.dart
├── app.dart
├── core/                  # Cross-cutting infrastructure
│   ├── api/               # Dio, auth interceptor, token refresh
│   ├── config/            # .env loading
│   ├── routing/           # GoRouter + auth redirects
│   ├── storage/           # Secure token storage
│   └── ...
├── shared/
└── features/
    └── auth/              # Login, logout, session restore
        ├── data/          # API client, DTOs, repository impl
        ├── domain/        # User entity, repository interface
        └── presentation/  # Screens, controllers, providers
```

**Auth data flow:**

```
Screen → Controller (Riverpod) → AuthRepository → AuthApi → Dio → Django API
                                      ↓
                            SecureStorageService (tokens only)
```

### Authentication

| Feature | Implementation |
|---------|----------------|
| Login | `POST /auth/login/` → store JWT pair → fetch `/users/me/` |
| Logout | `POST /auth/logout/` → blacklist refresh token → clear storage |
| Session restore | Splash reads tokens → validates via `/users/me/` |
| Token refresh | Dio interceptor on `401` → `POST /auth/refresh/` → retry request |
| Session expiry | Refresh failure → clear tokens → redirect to login |
| Route guards | GoRouter redirect based on `AuthController` state |
| Forgot password | UI only (backend endpoint not yet available) |

**Security rules:**

- Access and refresh tokens stored **only** in `flutter_secure_storage`
- Passwords are **never** persisted
- Logout always clears local storage, even if the API call fails

**Auth screens:**

| Route | Screen |
|-------|--------|
| `/splash` | Session restoration |
| `/login` | Phone + password sign-in |
| `/forgot-password` | Placeholder reset UI |
| `/home` | Authenticated placeholder (requires login) |

### Getting started

**Prerequisites:** Flutter SDK 3.19+, Dart 3.3+, Django backend running

```bash
cd mobile
cp .env.example .env
flutter pub get
flutter run
```

**API base URL** (in `.env`):

| Target | `API_BASE_URL` |
|--------|----------------|
| iOS Simulator / desktop | `http://127.0.0.1:8000/api/v1` |
| Android Emulator | `http://10.0.2.2:8000/api/v1` |
| Physical device | LAN IP, e.g. `http://192.168.x.x:8000/api/v1` |

**Test login:** Register a user via `POST /api/v1/auth/register/` or Django admin, then sign in with phone number and password on the login screen.

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
