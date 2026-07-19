# ChamaPlus Mobile

Flutter client for Kenyan savings groups (Chamas).

## Architecture

Feature-first modules under `lib/features/`:

- `data/` — Dio API clients, DTOs, repository implementations
- `domain/` — immutable entities + repository contracts
- `presentation/` — Riverpod controllers/providers, screens, widgets

Shared frameworks:

- Design system — `lib/shared/components/`
- Forms — `lib/shared/forms/`
- API state — `lib/shared/api_state/` (`RefreshController`, `PaginationController`, `ApiStateBuilder`)

API base URL defaults to `http://127.0.0.1:8000/api/v1` (see `.env` / `EnvConfig`).

## Loans module

Path: `lib/features/loans/`

### Routes

| Route | Screen |
|-------|--------|
| `/loans` | Loans hub (pick chama) |
| `/chamas/:chamaId/loans` | Loan dashboard |
| `/chamas/:chamaId/loans/products` | Loan products |
| `/chamas/:chamaId/loans/products/:productId` | Product details |
| `/chamas/:chamaId/loans/calculator` | Loan calculator |
| `/chamas/:chamaId/loans/apply` | Apply for loan |
| `/chamas/:chamaId/loans/history` | Loan history |
| `/chamas/:chamaId/loans/applications/:id` | Application details |
| `/chamas/:chamaId/loans/applications/:id/vote` | Committee voting |
| `/chamas/:chamaId/loans/applications/:id/repayments` | Repayment history |
| `/chamas/:chamaId/loans/applications/:id/active` | Active loan |

### API mapping

All paths are relative to `/api/v1` and chama-scoped:

| Client helper | Backend |
|---------------|---------|
| `GET /chamas/{id}/loan-products/` | List products |
| `GET /chamas/{id}/loan-products/{pid}/` | Product detail |
| `GET/POST /chamas/{id}/loan-applications/` | List / apply |
| `POST .../loan-applications/{aid}/submit\|cancel\|approve\|reject\|disburse/` | Lifecycle |
| `GET/POST .../loan-applications/{aid}/votes/` | Committee votes |
| `GET/POST .../loan-applications/{aid}/repayments/` | Repayments |
| `GET /chamas/{id}/members/{mid}/credit-scores/current/` | Credit score (optional) |

Envelope responses `{ success, message, data }` are unwrapped in `LoanApi`.

### Shared progress widget

`ProgressStatCard` (`lib/shared/components/progress_stat_card.dart`) is generic and reused for loan outstanding progress, repayment progress, calculator principal share, and voting progress.

## Run

```bash
flutter pub get
flutter run
flutter test
dart analyze
```
