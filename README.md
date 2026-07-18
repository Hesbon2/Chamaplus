# ChamaPlus

Digital platform for Kenyan savings groups (Chamas) — contributions, loans, meetings, governance, and reporting.

## Repository structure

| Directory | Purpose |
|-----------|---------|
| `Backend/` | Django REST API (complete) |
| `mobile/` | Flutter mobile client |
| `Docs/` | Project specs, API docs, coding standards |

## Mobile app (`mobile/`)

Flutter client with authentication, dashboard, design system, form framework, API state framework, Chama management, and contributions.

### Tech stack

- **Flutter** + **Material 3** + **Riverpod** + **GoRouter** + **Dio**
- **fl_chart**, **Google Fonts**, **flutter_secure_storage**, **flutter_dotenv**, **connectivity_plus**

### Architecture

```
lib/
├── core/                  # API, routing, theme, storage
├── shared/
│   ├── components/        # Design system (AppCard, StatCard, …)
│   ├── forms/             # Form framework (AppForm, fields, validators)
│   └── api_state.dart     # ApiState, ApiStateBuilder, controllers
└── features/
    ├── auth/
    ├── dashboard/
    ├── chamas/
    └── contributions/
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

### API state framework

```dart
import 'package:chamaplus_mobile/shared/api_state.dart';
```

| Piece | Purpose |
|-------|---------|
| `ApiState<T>` | Loading / refreshing / success / empty / error |
| `ApiStateBuilder` | Shimmer, empty, error+retry, pull-to-refresh |
| `RefreshController` | Single-resource Riverpod notifier |
| `PaginationController` | Paginated lists + infinite scroll |

### Chama management

| Route | Screen |
|-------|--------|
| `/chamas` | My Chamas |
| `/create-chama` | Create Chama |
| `/join-chama` | Join with invite code |
| `/chamas/:id` | Chama details (invite code copy/share) |
| `/chamas/:id/invite` | Invite members |
| `/chamas/:id/members` | Members |
| `/chamas/:id/members/:membershipId` | Member details |
| `/chamas/:id/join-requests` | Approve / reject invites |

### User onboarding

| Route | Screen |
|-------|--------|
| `/register` | Register (auto-login after success) |
| `/welcome` | Welcome — create or join |
| `/pending-approval` | Waiting for chairperson approval |
| `/profile` | Profile |
| `/profile/edit` | Edit profile |

Shared `EmptyActionCard` guides empty modules toward the next action.

### Contributions

| Route | Screen |
|-------|--------|
| `/contributions` | Hub — pick a chama |
| `/chamas/:id/contributions` | Contribution dashboard |
| `/chamas/:id/contribution-cycles` | Cycles list (search + status filter) |
| `/chamas/:id/contribution-cycles/create` | Create cycle |
| `/chamas/:id/contribution-cycles/:cycleId` | Cycle details / close |
| `/chamas/:id/contributions/history` | History (search, filter, pagination) |
| `/chamas/:id/contributions/record` | Record contribution |
| `/chamas/:id/contributions/:contributionId` | Contribution details |
| `/chamas/:id/contributions/members/:memberId` | Member contribution summary |

Uses design system, form framework, and API state (`RefreshController` / `PaginationController` / `ApiStateBuilder`). Backend APIs: contribution cycles, contributions, reports.

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
| Physical device (LAN) | e.g. `http://192.168.x.x:8000/api/v1` |
| Render (remote) | `https://chamaplus-8fzh.onrender.com/api/v1` |

### Typical onboarding flow

1. Register or Sign in
2. Welcome → Create Chama **or** Join with invite code
3. Share invite code from Chama details (copy / share)
4. Invite members by phone (pending until approved under Join requests)
5. Profile / Edit profile from the dashboard

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
