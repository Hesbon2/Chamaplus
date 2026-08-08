# ChamaPlus — Local run & test

Brief guide to run and test **Backend** + **Mobile** on your machine (including Android emulator). Environment switching is automatic for day-to-day work.

---

## Prerequisites

| Tool | Notes |
|------|--------|
| Python 3.12+ | Backend |
| MySQL | XAMPP or equivalent on `127.0.0.1:3306` |
| Flutter stable | SDK matching `Mobile/pubspec.yaml` |
| Android Studio | Emulator / SDK (optional but typical) |

---

## Environment switching (automatic)

### Backend

| Entry point | Default settings |
|-------------|------------------|
| `python manage.py …` | `chamaplus_backend.settings.development` |
| `wsgi.py` / `asgi.py` (Gunicorn, Render) | `chamaplus_backend.settings.production` |

Override via `Backend/.env`:

```env
APP_ENV=development
DJANGO_SETTINGS_MODULE=chamaplus_backend.settings.development
```

Switch to production settings locally:

```env
APP_ENV=production
DJANGO_SETTINGS_MODULE=chamaplus_backend.settings.production
DEBUG=False
```

Process env `DJANGO_SETTINGS_MODULE` always wins if already set.

### Mobile

| Build | Env file | Typical API |
|-------|----------|-------------|
| `flutter run` (debug) | `.env.development` | local Django |
| `flutter run --release` / release APK | `.env.production` | hosted API |

Force either side:

```bash
flutter run --dart-define=APP_ENV=production
flutter run --dart-define=APP_ENV=development
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

**Android emulator:** leave `API_BASE_URL=http://127.0.0.1:8000/api/v1` in development — the app rewrites it to `http://10.0.2.2:8000/api/v1` at runtime.

**Physical device:** pass your PC LAN IP with `--dart-define=API_BASE_URL=...` (or edit `.env.development`).

Confirm in the app: **More → Settings → Diagnostics** (debug only) shows environment + API base URL.

---

## Backend — run locally

```bash
cd Backend
python -m venv .venv

# Windows
.\.venv\Scripts\activate
# macOS / Linux
# source .venv/bin/activate

pip install -r requirements.txt
copy .env.example .env   # Windows; use cp on Unix
```

1. Start MySQL and create DB `chamaplus_db` (or match `DB_NAME` in `.env`).
2. Keep `APP_ENV=development` in `.env`.
3. Migrate and run:

```bash
python manage.py migrate
python manage.py seed_roles   # if available
python manage.py runserver 0.0.0.0:8000
```

API: `http://127.0.0.1:8000/api/v1/`  
Docs (DEBUG): `http://127.0.0.1:8000/api/docs/`

Bind `0.0.0.0` so the emulator / LAN devices can reach the host.

### Backend — test

```bash
cd Backend
.\.venv\Scripts\activate
# If SSL/MySQL quirks appear locally:
# set DB_SSL_MODE=DISABLED   (Windows PowerShell: $env:DB_SSL_MODE="DISABLED")
python -m pytest -q
```

Targeted:

```bash
python -m pytest apps/accounts/tests/test_auth.py -q
```

---

## Mobile — run locally (emulator)

```bash
cd Mobile
flutter pub get
flutter devices
flutter run
```

Typical Android emulator flow:

1. Start an AVD from Android Studio (or `emulator -avd <name>`).
2. Ensure backend is on `0.0.0.0:8000`.
3. `flutter run` → debug → **development** env → auto `10.0.2.2` for loopback URLs.
4. Register / login against your local API.

iOS Simulator / Windows desktop use `127.0.0.1` as-is (no rewrite).

Smoke against production API without a release build:

```bash
flutter run --dart-define=APP_ENV=production
```

### Mobile — test & analyze

```bash
cd Mobile
flutter analyze
flutter test
```

---

## Suggested daily workflow

1. Start MySQL + `python manage.py runserver 0.0.0.0:8000`
2. Start Android emulator
3. `cd Mobile && flutter run`
4. Use Diagnostics to confirm **development** + rewritten API URL
5. Run `pytest` / `flutter test` before pushing

---

## Related

- Mobile details: [`Mobile/README.md`](../Mobile/README.md)
- Deploy / release: [`DEPLOYMENT_GUIDE.md`](./DEPLOYMENT_GUIDE.md)
- API contracts: [`API_SPEC.md`](./API_SPEC.md)
- Status: [`PROJECT_STATUS.md`](./PROJECT_STATUS.md)
