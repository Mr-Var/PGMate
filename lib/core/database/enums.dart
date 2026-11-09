/// Enums persisted as text (by name) via Drift's `textEnum`.
/// Never rename existing values without a migration.
library;

enum BedStatus { available, occupied, reserved, maintenance }

enum TenantStatus { newTenant, active, noticeGiven, checkedOut, archived }

enum Gender { male, female, other }

enum InvoiceStatus { unpaid, partiallyPaid, paid, overdue, cancelled }

enum PaymentMethod { cash, upi }

/// A payment is created as [pendingVerification] (UPI) or [confirmed] (cash).
/// Only the owner can move a UPI payment to [confirmed].
enum PaymentStatus { pendingVerification, confirmed, rejected }

/// Successful payments are never edited. Mistakes are fixed by adding a
/// [reversal] (negative amount) and, if needed, a fresh [payment].
enum PaymentKind { payment, reversal }

enum ExpenseCategory {
  electricity,
  water,
  food,
  staffSalaries,
  internet,
  maintenance,
  cleaning,
  repairs,
  miscellaneous,
}

enum ComplaintStatus { open, inProgress, resolved, closed }

enum ComplaintPriority { low, medium, high, urgent }

extension BedStatusX on BedStatus {
  String get label => switch (this) {
        BedStatus.available => 'Available',
        BedStatus.occupied => 'Occupied',
        BedStatus.reserved => 'Reserved',
        BedStatus.maintenance => 'Maintenance',
      };
}

extension TenantStatusX on TenantStatus {
  String get label => switch (this) {
        TenantStatus.newTenant => 'New',
        TenantStatus.active => 'Active',
        TenantStatus.noticeGiven => 'Notice given',
        TenantStatus.checkedOut => 'Checked out',
        TenantStatus.archived => 'Archived',
      };
}

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.upi => 'UPI',
      };
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.electricity => 'Electricity',
        ExpenseCategory.water => 'Water',
        ExpenseCategory.food => 'Food',
        ExpenseCategory.staffSalaries => 'Staff salaries',
        ExpenseCategory.internet => 'Internet',
        ExpenseCategory.maintenance => 'Maintenance',
        ExpenseCategory.cleaning => 'Cleaning',
        ExpenseCategory.repairs => 'Repairs',
        ExpenseCategory.miscellaneous => 'Miscellaneous',
      };
}
