import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/billing_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/owner_pin.dart';
import '../../shared/widgets/state_views.dart';
import 'payment_widgets.dart';
import 'payments_providers.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingUpiProvider).value?.length ?? 0;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payments'),
          actions: [
            IconButton(
              tooltip: 'New invoice',
              icon: const Icon(Icons.post_add_rounded),
              onPressed: () => context.push('/invoices/new'),
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Invoices'),
              const Tab(text: 'Received'),
              Tab(
                child: Badge(
                  isLabelVisible: pending > 0,
                  offset: const Offset(14, -6),
                  backgroundColor: AppColors.warning,
                  label: Text('$pending'),
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => context.push('/payments/collect'),
          icon: const Icon(Icons.add_card_rounded),
          label: const Text('Collect rent'),
        ),
        body: const TabBarView(children: [_InvoicesTab(), _ReceivedTab(), _VerifyTab()]),
      ),
    );
  }
}

class _MonthBar extends ConsumerWidget {
  const _MonthBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(billingMonthProvider);
    final n = ref.read(billingMonthProvider.notifier);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.sm, Gap.sm, Gap.sm, 0),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: () => n.shift(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Expanded(
            child: Text(
              Dates.monthYear(m),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(tooltip: 'Next month', onPressed: () => n.shift(1), icon: const Icon(Icons.chevron_right_rounded)),
        ],
      ),
    );
  }
}

class _InvoicesTab extends ConsumerWidget {
  const _InvoicesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(monthInvoicesProvider);
    final unbilled = ref.watch(unbilledCountProvider).value ?? 0;
    final month = ref.watch(billingMonthProvider);
    return Column(
      children: [
        const _MonthBar(),
        Expanded(
          child: invoices.when(
            skipLoadingOnReload: true,
            loading: () => const LoadingList(),
            error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(monthInvoicesProvider)),
            data: (list) {
              final active = list.where((v) => v.invoice.status != InvoiceStatus.cancelled).toList();
              final billed = active.fold<int>(0, (a, v) => a + v.invoice.totalPaise);
              final paid = active.fold<int>(0, (a, v) => a + v.invoice.paidPaise);
              return ListView(
                padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, 96),
                children: [
                  if (unbilled > 0) _GenerateCard(month: month, count: unbilled),
                  if (unbilled > 0) const SizedBox(height: Gap.md),
                  if (list.isEmpty && unbilled == 0)
                    const Padding(
                      padding: EdgeInsets.only(top: Gap.xxl),
                      child: EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'No invoices this month',
                        message: 'Invoices appear here once tenants with beds are billed for the month.',
                      ),
                    )
                  else if (list.isNotEmpty) ...[
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            icon: Icons.receipt_long_outlined,
                            label: 'Billed',
                            value: Money.format(billed),
                            caption: '${active.length} invoices',
                          ),
                        ),
                        const SizedBox(width: Gap.md),
                        Expanded(
                          child: MetricTile(
                            icon: Icons.pending_actions_outlined,
                            label: 'Still due',
                            value: Money.format(billed - paid),
                            tone: AppColors.warning,
                            caption: '${active.where((v) => v.balancePaise > 0).length} of ${active.length} unpaid',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Gap.md),
                    TileGroup(children: [for (final v in list) InvoiceTile(view: v)]),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GenerateCard extends ConsumerWidget {
  const _GenerateCard({required this.month, required this.count});
  final DateTime month;
  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(Radii.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, color: AppColors.primary),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Text(
                  '$count ${count == 1 ? 'tenant is' : 'tenants are'} not billed for ${Dates.monthYear(month)}',
                  style: t.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'Creates one invoice per tenant using their current rent. New joiners are prorated. Advance credit is applied.',
            style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: Gap.md),
          AsyncButton(
            label: 'Generate invoices',
            icon: Icons.receipt_long_rounded,
            onPressed: () async {
              GenerateResult? r;
              final ok = await runGuarded(context, () async {
                r = await ref.read(databaseProvider).billingDao.generateMonthlyInvoices(month.year, month.month);
                await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
              });
              if (ok && context.mounted) showAppSnack(context, '${r!.created} invoices created');
            },
          ),
        ],
      ),
    );
  }
}

class _ReceivedTab extends ConsumerWidget {
  const _ReceivedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(monthPaymentsProvider);
    return Column(
      children: [
        const _MonthBar(),
        Expanded(
          child: payments.when(
            skipLoadingOnReload: true,
            loading: () => const LoadingList(),
            error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(monthPaymentsProvider)),
            data: (list) {
              if (list.isEmpty) {
                return const EmptyState(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'No payments this month',
                  message: 'Cash and UPI payments you record appear here with their receipts.',
                );
              }
              int sum(PaymentMethod m) => list
                  .where((v) => v.payment.method == m && v.payment.status == PaymentStatus.confirmed)
                  .fold<int>(0, (a, v) => a + v.payment.amountPaise);
              return ListView(
                padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, 96),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MetricTile(
                          icon: Icons.payments_outlined,
                          label: 'Cash',
                          value: Money.format(sum(PaymentMethod.cash)),
                          tone: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: MetricTile(
                          icon: Icons.qr_code_2_rounded,
                          label: 'UPI (verified)',
                          value: Money.format(sum(PaymentMethod.upi)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.md),
                  TileGroup(indent: 68, children: [for (final v in list) PaymentTile(view: v)]),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VerifyTab extends ConsumerWidget {
  const _VerifyTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingUpiProvider);
    final t = Theme.of(context).textTheme;
    return pending.when(
      loading: () => const LoadingList(),
      error: (e, _) => ErrorState(error: e),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyState(
            icon: Icons.verified_outlined,
            title: 'Nothing to verify',
            message: 'UPI payments you record without checking your bank app wait here until you confirm them.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, 96),
          itemCount: list.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: Gap.md),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Text(
                'Open your UPI or bank app, find each UTR, then confirm. Only confirmed payments count as collected.',
                style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
              );
            }
            final v = list[i - 1];
            final p = v.payment;
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(v.tenantName, style: t.titleSmall)),
                      Text(Money.format(p.amountPaise), style: t.titleMedium?.copyWith(fontFeatures: AppTheme.tabular)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    'UTR ${p.upiReference ?? '—'} · ${Dates.short(p.paymentDate)}',
                    style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: Gap.md),
                  Row(
                    children: [
                      Expanded(
                        child: AsyncButton(
                          label: 'Not received',
                          outlined: true,
                          danger: true,
                          onPressed: () async {
                            final reason = await askReason(
                              context,
                              title: 'Reject this UPI payment?',
                              hint: 'What happened?',
                              confirmLabel: 'Reject',
                            );
                            if (reason == null || !context.mounted) return;
                            if (!await requireOwnerPin(
                                  context,
                                  ref,
                                  message: 'Rejecting marks this UPI payment as not received.',
                                ) ||
                                !context.mounted) {
                              return;
                            }
                            await runGuarded(
                              context,
                              () => ref.read(databaseProvider).billingDao.rejectUpiPayment(p.id, reason),
                              success: 'Marked as not received',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: Gap.md),
                      Expanded(
                        child: AsyncButton(
                          label: 'Received',
                          icon: Icons.check_rounded,
                          onPressed: () => runGuarded(context, () async {
                            await ref.read(databaseProvider).billingDao.verifyUpiPayment(p.id);
                            await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
                          }, success: '${Money.format(p.amountPaise)} confirmed'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
