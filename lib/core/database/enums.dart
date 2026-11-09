/// Enums persisted as text (by name) via Drift's `textEnum`.
/// Never rename existing values without a migration.
library;

enum BedStatus { available, occupied, reserved, maintenance }

enum TenantStatus { newTenant, active, noticeGiven, checkedOut, archived }

enum Gender { male, female, other }

enum InvoiceStatus { unpaid, partiallyPaid, paid, overdue, cancelled }

/// [deposit] is an internal settlement from the security deposit at checkout
/// and is never counted as cash collected. [bank] is used for expenses.
enum PaymentMethod { cash, upi, bank, deposit }

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
    PaymentMethod.bank => 'Bank transfer',
    PaymentMethod.deposit => 'Deposit adjustment',
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

extension InvoiceStatusX on InvoiceStatus {
  String get label => switch (this) {
    InvoiceStatus.unpaid => 'Unpaid',
    InvoiceStatus.partiallyPaid => 'Partially paid',
    InvoiceStatus.paid => 'Paid',
    InvoiceStatus.overdue => 'Overdue',
    InvoiceStatus.cancelled => 'Cancelled',
  };
}

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
    PaymentStatus.pendingVerification => 'Awaiting verification',
    PaymentStatus.confirmed => 'Confirmed',
    PaymentStatus.rejected => 'Rejected',
  };
}

extension ComplaintStatusX on ComplaintStatus {
  String get label => switch (this) {
    ComplaintStatus.open => 'Open',
    ComplaintStatus.inProgress => 'In progress',
    ComplaintStatus.resolved => 'Resolved',
    ComplaintStatus.closed => 'Closed',
  };
}

extension ComplaintPriorityX on ComplaintPriority {
  String get label => switch (this) {
    ComplaintPriority.low => 'Low',
    ComplaintPriority.medium => 'Medium',
    ComplaintPriority.high => 'High',
    ComplaintPriority.urgent => 'Urgent',
  };
}

extension GenderX on Gender {
  String get label => switch (this) {
    Gender.male => 'Male',
    Gender.female => 'Female',
    Gender.other => 'Other',
  };
}
