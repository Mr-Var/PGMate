# PG Manager

Offline-first Android app for a single PG owner to manage 30–100 tenants: rooms and beds, tenants, rent invoices, cash/UPI payments, expenses, complaints, notices, food menu, reports and encrypted backups.

Everything runs locally. No Firebase, no cloud database, no paid services, no internet needed for day-to-day use.

## Stack

| Concern | Choice |
|---|---|
| UI | Flutter (Material 3), IBM Plex Sans (bundled, OFL) |
| Database | SQLite via Drift (`drift_flutter`) |
| State | Riverpod 3 |
| Navigation | go_router (stateful shell, 5 tabs) |
| Auth | 4-digit PIN (PBKDF2-HMAC-SHA256, salted, in `flutter_secure_storage`) + optional biometrics (`local_auth`) |

## Data integrity rules (enforced in SQLite, not just in UI)

- All money is stored as **integer paise**.
- One active allocation per bed, and per tenant (partial unique indexes).
- No duplicate invoice for the same tenant + month (cancelled invoices excluded).
- A UPI reference (UTR) can be recorded only once.
- Payments, payment allocations, invoices, expenses and allocation history **cannot be deleted** (triggers). Payments are immutable; corrections are reversal entries.
- A confirmed payment cannot be moved back to pending/rejected. Unverified UPI payments are never counted as collected.
- Foreign keys enabled; every money column has a non-negative CHECK.

## Project layout

```
lib/
  app/            router, shell (bottom nav), app widget
  core/
    database/     app_database.dart, tables/, daos/, enums
    services/     auth (PIN + biometrics), providers
    theme/        colours, theme, spacing
    utils/        money (paise), dates
  features/       authentication, dashboard, rooms, tenants, payments, settings …
  shared/widgets/ cards, state views, PIN pad, validators
```

## Development

```bash
flutter pub get
dart run build_runner build   # regenerate Drift code after schema changes
flutter analyze
flutter test
flutter build apk --release
```

## Status

**Phase 1 (done):** foundation, database schema + integrity rules, PIN/biometric lock, PG setup, live dashboard, rooms & beds management, settings.

**Next:** Phase 2 tenants (registration, documents, allocation, transfer, checkout) → Phase 3 invoices, payments, receipts, expenses → Phase 4 complaints, notices, menu → Phase 5 reports, CSV/PDF, encrypted backup/restore → Phase 6 hardening and release APK.
