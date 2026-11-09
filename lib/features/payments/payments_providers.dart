import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/billing_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/utils/dates.dart';

class BillingMonth extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime(DateTime.now().year, DateTime.now().month);
  void set(DateTime m) => state = DateTime(m.year, m.month);
  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final billingMonthProvider = NotifierProvider<BillingMonth, DateTime>(BillingMonth.new);

final monthInvoicesProvider = StreamProvider<List<InvoiceView>>((ref) {
  final m = ref.watch(billingMonthProvider);
  return ref.watch(databaseProvider).billingDao.watchInvoices(year: m.year, month: m.month);
});

final monthPaymentsProvider = StreamProvider<List<PaymentView>>((ref) {
  final m = ref.watch(billingMonthProvider);
  return ref.watch(databaseProvider).billingDao.watchPayments(range: DateRange.month(m.year, m.month));
});

final pendingUpiProvider = StreamProvider<List<PaymentView>>(
  (ref) => ref.watch(databaseProvider).billingDao.watchPayments(status: PaymentStatus.pendingVerification),
);

final unbilledCountProvider = StreamProvider<int>((ref) {
  final m = ref.watch(billingMonthProvider);
  return ref.watch(databaseProvider).billingDao.watchUnbilledCount(m.year, m.month);
});

final paymentProvider = StreamProvider.family<PaymentView?, int>(
  (ref, id) => ref.watch(databaseProvider).billingDao.watchPayment(id),
);

final invoiceProvider = StreamProvider.family<(InvoiceView, List<(Payment, int)>)?, int>(
  (ref, id) => ref.watch(databaseProvider).billingDao.watchInvoice(id),
);
