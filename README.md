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

## Release build and signing

Debug-signed builds install fine for testing. For the Play Store (or to keep
updates installable), sign with your own key. Keep the key and passwords safe:
losing them means you can never update the app.

1. Create a key (once):
   `keytool -genkey -v -keystore ~/pg-manager-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Create `android/key.properties` (never commit it):
   ```
   storePassword=...
   keyPassword=...
   keyAlias=upload
   storeFile=/full/path/to/pg-manager-upload.jks
   ```
3. Load it in `android/app/build.gradle.kts` as described in Flutter's
   "Build and release an Android app" guide, then run `flutter build apk --release`
   (or `flutter build appbundle` for the Play Store).

## Status

All features in the specification are implemented: dashboard, tenants with
full lifecycle and checkout settlement, rooms and beds, invoices (monthly and
manual), cash/UPI payments with owner verification and reversals, PDF rent and
deposit receipts, expenses, complaints, food menu, notices, 12 reports with
PDF/CSV export, encrypted backup/restore, PIN + biometric lock and local rent
reminders. 54 automated tests cover billing, integrity rules, every screen and
the backup round trip. Device-level features (notifications, biometrics,
camera, UPI/WhatsApp intents, file saving) still need checking on a phone.
