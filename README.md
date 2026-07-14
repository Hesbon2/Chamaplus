# ChamaPlus

Digital platform for Kenyan savings groups (Chamas) — contributions, loans, meetings, governance, and reporting.

## Repository structure

| Directory | Purpose |
|-----------|---------|
| `Backend/` | Django REST API (complete) |
| `mobile/` | Flutter mobile client |
| `Docs/` | Project specs, API docs, coding standards |

## Mobile app (`mobile/`)

Flutter client with authentication, dashboard, design system, form framework, and Chama management.

### Tech stack

- **Flutter** + **Material 3** + **Riverpod** + **GoRouter** + **Dio**
- **fl_chart**, **Google Fonts**, **flutter_secure_storage**, **flutter_dotenv**, **connectivity_plus**

### Architecture

```
lib/
├── core/                  # API, routing, theme, storage
├── shared/
│   ├── components/        # Design system (AppCard, StatCard, …)
│   └── forms/             # Form framework (AppForm, fields, validators)
└── features/
    ├── auth/
    ├── dashboard/
    └── chamas/
```

### Design system

```dart
import 'package:chamaplus_mobile/shared/components/components.dart';
```

Includes `AppCard`, `StatCard`, `SectionHeader`, `AvatarBadge`, `InfoTile`, `StatusChip`, `EmptyState`, `ShimmerLoader`, `ActionButton`, `ConfirmationDialog`.

### Form framework

Reusable Material 3 form primitives under `lib/shared/forms/`:

```dart
import 'package:chamaplus_mobile/shared/forms/forms.dart';
```

| Component | Purpose |
|-----------|---------|
| `AppForm` / `FormSection` | Form shell + labeled field groups |
| `AppTextField` | Single-line text |
| `AppPhoneField` | Kenyan phone + validation |
| `AppCurrencyField` | Currency code dropdown |
| `AppAmountField` | Monetary amount |
| `AppDropdown` | Generic select |
| `AppSearchField` | Search with clear |
| `AppDatePicker` / `AppTimePicker` | Material pickers |
| `AppMultilineField` | Notes / descriptions |
| `AppSubmitButton` | Validate + submit with loading |
| `AppValidators` | Shared validators (required, phone, amount, email, compose, …) |

Supported across fields: validation, read-only, disabled, loading (submit), prefix/suffix icons, error text, keyboard types, auto-validation.

### Chama management

| Route | Screen |
|-------|--------|
| `/chamas` | My Chamas |
| `/chamas/:id` | Chama details |
| `/chamas/:id/members` | Members |
| `/chamas/:id/members/:membershipId` | Member details |
| `/chamas/:id/join-requests` | Approve / reject invites |

### Getting started

```bash
cd mobile
cp .env.example .env
flutter pub get
flutter run
```

| Target | `API_BASE_URL` |
|--------|----------------|
| iOS Simulator / desktop | `http://127.0.0.1:8000/api/v1` |
| Android Emulator | `http://10.0.2.2:8000/api/v1` |
| Physical device | LAN IP, e.g. `http://192.168.x.x:8000/api/v1` |

### Verify build

```bash
cd mobile
flutter analyze
flutter test
```

## Backend

See `Docs/API_SPEC.md` and `Docs/PROJECT_STATUS.md`.

## License

Proprietary — ChamaPlus project.
