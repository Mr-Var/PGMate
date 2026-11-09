import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/dashboard_dao.dart';
import 'daos/rooms_dao.dart';
import 'daos/settings_dao.dart';
import 'enums.dart';
import 'tables/finance_tables.dart';
import 'tables/operations_tables.dart';
import 'tables/property_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    PgProfiles,
    Rooms,
    Beds,
    Tenants,
    Allocations,
    RentInvoices,
    Payments,
    PaymentAllocations,
    Expenses,
    Complaints,
    Notices,
    Menus,
    AuditLogs,
    AppSettings,
  ],
  daos: [DashboardDao, RoomsDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static const fileName = 'pg_manager';

  static QueryExecutor _openConnection() => driftDatabase(name: fileName);

  /// Bump this and add a step in [migration] whenever the schema changes.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIntegrityRules();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations go here, e.g.
          // if (from < 2) { await m.addColumn(tenants, tenants.newColumn); }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Rules Drift cannot express declaratively: partial unique indexes and
  /// triggers that protect financial history.
  Future<void> _createIntegrityRules() async {
    const statements = [
      // One active allocation per bed, and one per tenant.
      'CREATE UNIQUE INDEX ux_alloc_active_bed ON allocations(bed_id) WHERE is_active = 1',
      'CREATE UNIQUE INDEX ux_alloc_active_tenant ON allocations(tenant_id) WHERE is_active = 1',
      // No duplicate invoice for the same tenant and billing month.
      "CREATE UNIQUE INDEX ux_invoice_period ON rent_invoices(tenant_id, period_year, period_month) "
          "WHERE status <> 'cancelled'",
      // A UPI reference (UTR) can only be recorded once.
      'CREATE UNIQUE INDEX ux_payment_upi_ref ON payments(upi_reference) '
          "WHERE upi_reference IS NOT NULL AND kind = 'payment'",
      // Financial records are never hard-deleted.
      "CREATE TRIGGER trg_no_delete_payments BEFORE DELETE ON payments "
          "BEGIN SELECT RAISE(ABORT, 'Payments cannot be deleted; record a reversal'); END",
      "CREATE TRIGGER trg_no_delete_payment_allocations BEFORE DELETE ON payment_allocations "
          "BEGIN SELECT RAISE(ABORT, 'Payment allocations cannot be deleted'); END",
      "CREATE TRIGGER trg_no_delete_invoices BEFORE DELETE ON rent_invoices "
          "BEGIN SELECT RAISE(ABORT, 'Invoices cannot be deleted; cancel instead'); END",
      "CREATE TRIGGER trg_no_delete_expenses BEFORE DELETE ON expenses "
          "BEGIN SELECT RAISE(ABORT, 'Expenses cannot be deleted; void instead'); END",
      // Recorded payments are immutable apart from the verification status.
      'CREATE TRIGGER trg_payments_immutable BEFORE UPDATE OF amount_paise, tenant_id, method, '
          'upi_reference, payment_date, transaction_id, receipt_number, kind ON payments '
          "BEGIN SELECT RAISE(ABORT, 'Payments are immutable; record a reversal'); END",
      // A confirmed payment can never go back to pending or rejected.
      "CREATE TRIGGER trg_payment_status BEFORE UPDATE OF status ON payments "
          "WHEN OLD.status = 'confirmed' AND NEW.status <> 'confirmed' "
          "BEGIN SELECT RAISE(ABORT, 'Confirmed payments cannot change status'); END",
      // Allocation history is never deleted.
      "CREATE TRIGGER trg_no_delete_allocations BEFORE DELETE ON allocations "
          "BEGIN SELECT RAISE(ABORT, 'Allocation history cannot be deleted'); END",
    ];
    for (final sql in statements) {
      await customStatement(sql);
    }
  }
}
