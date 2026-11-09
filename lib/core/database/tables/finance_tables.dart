// Drift CHECK constraints reference their own column getter by design.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../enums.dart';
import 'property_tables.dart';

/// Monthly rent invoice. Amounts are frozen at generation time so later rent
/// changes never rewrite history. Duplicate (tenant, period) invoices are
/// blocked by a partial unique index that ignores cancelled invoices.
@DataClassName('RentInvoice')
@TableIndex(name: 'idx_invoices_tenant', columns: {#tenantId})
@TableIndex(name: 'idx_invoices_period', columns: {#periodStart})
@TableIndex(name: 'idx_invoices_due', columns: {#dueDate})
class RentInvoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get invoiceNumber => text().unique()();
  IntColumn get tenantId => integer().references(Tenants, #id, onDelete: KeyAction.restrict)();
  IntColumn get allocationId => integer().nullable().references(Allocations, #id, onDelete: KeyAction.restrict)();
  IntColumn get periodYear => integer()();
  IntColumn get periodMonth => integer().check(periodMonth.isBetweenValues(1, 12))();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  IntColumn get rentPaise => integer().check(rentPaise.isBiggerOrEqualValue(0))();
  IntColumn get additionalChargesPaise =>
      integer().withDefault(const Constant(0)).check(additionalChargesPaise.isBiggerOrEqualValue(0))();
  IntColumn get discountPaise =>
      integer().withDefault(const Constant(0)).check(discountPaise.isBiggerOrEqualValue(0))();
  IntColumn get totalPaise => integer().check(totalPaise.isBiggerOrEqualValue(0))();
  IntColumn get paidPaise => integer().withDefault(const Constant(0)).check(paidPaise.isBiggerOrEqualValue(0))();
  TextColumn get status => textEnum<InvoiceStatus>().withDefault(Constant(InvoiceStatus.unpaid.name))();
  DateTimeColumn get dueDate => dateTime()();
  BoolColumn get isProrated => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Immutable payment ledger. Reversals are separate rows with a negative
/// amount pointing at the payment they reverse.
@DataClassName('Payment')
@TableIndex(name: 'idx_payments_tenant', columns: {#tenantId})
@TableIndex(name: 'idx_payments_date', columns: {#paymentDate})
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get transactionId => text().unique()();
  TextColumn get receiptNumber => text().unique()();
  IntColumn get tenantId => integer().references(Tenants, #id, onDelete: KeyAction.restrict)();
  IntColumn get amountPaise => integer().check(amountPaise.equals(0).not())();
  TextColumn get method => textEnum<PaymentMethod>()();

  /// UPI UTR / reference number. Unique when present (partial index).
  TextColumn get upiReference => text().nullable()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get status => textEnum<PaymentStatus>()();
  TextColumn get kind => textEnum<PaymentKind>().withDefault(Constant(PaymentKind.payment.name))();
  IntColumn get reversesPaymentId => integer().nullable().references(Payments, #id, onDelete: KeyAction.restrict)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('PaymentAllocation')
@TableIndex(name: 'idx_payalloc_payment', columns: {#paymentId})
@TableIndex(name: 'idx_payalloc_invoice', columns: {#invoiceId})
class PaymentAllocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get paymentId => integer().references(Payments, #id, onDelete: KeyAction.restrict)();
  IntColumn get invoiceId => integer().references(RentInvoices, #id, onDelete: KeyAction.restrict)();

  /// Positive for payments, negative for reversals.
  IntColumn get amountPaise => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Expenses are voided, never deleted.
@DataClassName('Expense')
@TableIndex(name: 'idx_expenses_date', columns: {#expenseDate})
@TableIndex(name: 'idx_expenses_category', columns: {#category})
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get category => textEnum<ExpenseCategory>()();
  IntColumn get amountPaise => integer().check(amountPaise.isBiggerThanValue(0))();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>()();
  TextColumn get vendor => text().nullable()();
  TextColumn get billPath => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isVoided => boolean().withDefault(const Constant(false))();
  TextColumn get voidReason => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
