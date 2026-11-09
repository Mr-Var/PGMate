import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/daos/billing_dao.dart';
import '../../core/database/daos/ops_dao.dart';
import '../../core/database/daos/tenants_dao.dart';
import '../../core/services/providers.dart';

class TenantQuery {
  const TenantQuery({this.filter = TenantFilter.current, this.search = '', this.sort = TenantSort.joiningNewest});
  final TenantFilter filter;
  final String search;
  final TenantSort sort;

  TenantQuery copyWith({TenantFilter? filter, String? search, TenantSort? sort}) =>
      TenantQuery(filter: filter ?? this.filter, search: search ?? this.search, sort: sort ?? this.sort);
}

class TenantQueryNotifier extends Notifier<TenantQuery> {
  @override
  TenantQuery build() => const TenantQuery();
  void update(TenantQuery q) => state = q;
}

final tenantQueryProvider = NotifierProvider<TenantQueryNotifier, TenantQuery>(TenantQueryNotifier.new);

final tenantListProvider = StreamProvider<List<TenantListItem>>((ref) {
  final q = ref.watch(tenantQueryProvider);
  return ref.watch(databaseProvider).tenantsDao.watchTenants(filter: q.filter, search: q.search, sort: q.sort);
});

/// Current tenants for pickers (collect rent, complaints).
final currentTenantsProvider = StreamProvider<List<TenantListItem>>(
  (ref) => ref.watch(databaseProvider).tenantsDao.watchTenants(sort: TenantSort.name),
);

final tenantDetailProvider = StreamProvider.family<TenantDetail?, int>(
  (ref, id) => ref.watch(databaseProvider).tenantsDao.watchTenant(id),
);

final tenantInvoicesProvider = StreamProvider.family<List<InvoiceView>, int>(
  (ref, id) => ref.watch(databaseProvider).billingDao.watchInvoices(tenantId: id),
);

final tenantPaymentsProvider = StreamProvider.family<List<PaymentView>, int>(
  (ref, id) => ref.watch(databaseProvider).billingDao.watchPayments(tenantId: id),
);

final tenantComplaintsProvider = StreamProvider.family<List<ComplaintView>, int>(
  (ref, id) => ref.watch(databaseProvider).opsDao.watchComplaints(tenantId: id),
);

final freeBedsProvider = FutureProvider.autoDispose<List<FreeBed>>(
  (ref) => ref.watch(databaseProvider).tenantsDao.freeBeds(),
);
