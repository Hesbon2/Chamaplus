# ChamaPlus

Digital platform for Kenyan savings groups (Chamas) — contributions, loans, meetings, governance, and reporting.

## Repository structure

| Directory | Purpose |
|-----------|---------|
| `Backend/` | Django REST API |
| `Mobile/` | Flutter mobile client |
| `Docs/` | Specs, API docs, local setup, coding standards |

## Run & test locally

**Start here:** [`Docs/LOCAL_SETUP.md`](Docs/LOCAL_SETUP.md)

Covers Backend + Mobile, Android emulator, tests, and **automatic development / production environment switching**.

### Quick start

```bash
# Backend
cd Backend
python -m venv .venv
.\.venv\Scripts\activate          # Windows
pip install -r requirements.txt
copy .env.example .env            # set APP_ENV=development, local MySQL
python manage.py migrate
python manage.py runserver 0.0.0.0:8000

# Mobile (new terminal) — debug uses .env.development automatically
cd Mobile
flutter pub get
flutter run
```

| Who | Default env |
|-----|-------------|
| `manage.py` | development |
| `wsgi` / `asgi` | production |
| `flutter run` (debug) | `.env.development` (Android emu: `127.0.0.1` → `10.0.2.2`) |
| `flutter run --release` | `.env.production` |

Force mobile: `flutter run --dart-define=APP_ENV=production`

### Verify

```bash
# Backend
cd Backend && python -m pytest -q

# Mobile
cd Mobile && flutter analyze && flutter test
```

## Docs

| Doc | Topic |
|-----|--------|
| [`Docs/LOCAL_SETUP.md`](Docs/LOCAL_SETUP.md) | Local run, emulator, env switching |
| [`Docs/API_SPEC.md`](Docs/API_SPEC.md) | API contracts |
| [`Docs/PROJECT_STATUS.md`](Docs/PROJECT_STATUS.md) | Architecture inventory |
| [`Docs/DEPLOYMENT_GUIDE.md`](Docs/DEPLOYMENT_GUIDE.md) | Release builds |
| [`Mobile/README.md`](Mobile/README.md) | Mobile modules & RBAC |

## License

Proprietary — ChamaPlus project.
