import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/state_views.dart';

typedef PaymentRow = ({Payment payment, String tenantName});

final paymentsListProvider = StreamProvider<List<PaymentRow>>((ref) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.payments).join([innerJoin(db.tenants, db.tenants.id.equalsExp(db.payments.tenantId))])
    ..orderBy([OrderingTerm.desc(db.payments.paymentDate), OrderingTerm.desc(db.payments.id)])
    ..limit(200);
  return q.watch().map(
        (rows) => [
          for (final r in rows) (payment: r.readTable(db.payments), tenantName: r.readTable(db.tenants).fullName),
        ],
      );
});

/// Payment ledger backed by the database. Collection, UPI verification and
/// receipts are delivered in Phase 3.
class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsListProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: payments.when(
        loading: () => const LoadingList(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(paymentsListProvider)),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No payments recorded',
              message: 'Rent invoices, cash and UPI collection, and PDF receipts are coming after tenant management.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: Gap.sm),
            itemBuilder: (context, i) {
              final p = list[i].payment;
              final t = Theme.of(context).textTheme;
              final pending = p.status == PaymentStatus.pendingVerification;
              return AppCard(
                padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
                child: Row(
                  children: [
                    Icon(p.method == PaymentMethod.upi ? Icons.qr_code_2_rounded : Icons.payments_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(list[i].tenantName, style: t.titleSmall),
                          Text('${p.receiptNumber} · ${p.method.label} · ${Dates.short(p.paymentDate)}',
                              style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Money.format(p.amountPaise),
                            style: t.titleSmall?.copyWith(fontFeatures: AppTheme.tabular)),
                        if (pending)
                          const StatusPill(
                            label: 'Unverified',
                            color: AppColors.warning,
                            background: AppColors.warningSoft,
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
