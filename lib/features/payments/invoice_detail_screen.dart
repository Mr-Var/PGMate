import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/billing_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import 'payment_widgets.dart';
import 'payments_providers.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  final int invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(invoiceProvider(invoiceId));
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: data.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingList(),
        error: (e, _) => ErrorState(error: e),
        data: (d) => d == null
            ? const EmptyState(icon: Icons.search_off_rounded, title: 'Invoice not found', message: 'This record does not exist.')
            : _Body(view: d.$1, payments: d.$2),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.view, required this.payments});
  final InvoiceView view;
  final List<(Payment, int)> payments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i = view.invoice;
    final t = Theme.of(context).textTheme;
    final open = i.status != InvoiceStatus.cancelled;
    final lines = <(String, int)>[
      ('Rent${i.isProrated ? ' (prorated)' : ''}', i.rentPaise),
      if (i.additionalChargesPaise > 0) ('Additional charges', i.additionalChargesPaise),
      if (i.discountPaise > 0) ('Discount', -i.discountPaise),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
      children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${Dates.monthYear(i.periodStart)} rent', style: t.headlineSmall),
              const SizedBox(height: 2),
              InkWell(
                onTap: () => context.push('/tenants/${i.tenantId}'),
                child: Text('${view.tenantName}${view.roomLabel == null ? '' : ' · ${view.roomLabel}'}',
                    style: t.bodyMedium?.copyWith(color: AppColors.primary)),
              ),
            ]),
          ),
          invoicePill(i.status),
        ]),
        const SizedBox(height: Gap.lg),
        AppCard(
          child: Column(children: [
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.sm),
                child: Row(children: [
                  Expanded(child: Text(l.$1, style: t.bodyMedium)),
                  Text('${l.$2 < 0 ? '−' : ''}${Money.format(l.$2.abs())}',
                      style: t.bodyMedium?.copyWith(fontFeatures: AppTheme.tabular, color: l.$2 < 0 ? AppColors.success : null)),
                ]),
              ),
            const Divider(height: Gap.xl),
            _row(t, 'Total', Money.format(i.totalPaise), strong: true),
            const SizedBox(height: Gap.sm),
            _row(t, 'Paid', Money.format(i.paidPaise)),
            const SizedBox(height: Gap.sm),
            _row(t, 'Balance', Money.format(view.balancePaise), strong: true, color: view.balancePaise > 0 ? AppColors.danger : AppColors.success),
          ]),
        ),
        const SizedBox(height: Gap.md),
        Text(
          '${i.invoiceNumber} · Due ${Dates.short(i.dueDate)}'
          '${i.cancelReason == null ? '' : ' · Cancelled: ${i.cancelReason}'}'
          '${i.notes == null ? '' : '\n${i.notes}'}',
          style: t.bodySmall?.copyWith(color: AppColors.textMuted),
        ),
        const SectionHeader(title: 'Payments applied'),
        if (payments.isEmpty)
          AppCard(child: Text('Nothing paid yet.', style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)))
        else
          TileGroup(children: [
            for (final (p, applied) in payments)
              ListTile(
                onTap: () => context.push('/payments/${p.id}'),
                leading: Icon(p.kind == PaymentKind.reversal ? Icons.undo_rounded : methodIcon(p.method), color: AppColors.primary),
                title: Text(p.receiptNumber),
                subtitle: Text('${p.method.label} · ${Dates.short(p.paymentDate)}'),
                trailing: Text('${applied < 0 ? '−' : ''}${Money.format(applied.abs())}',
                    style: const TextStyle(fontFeatures: AppTheme.tabular, fontWeight: FontWeight.w600)),
              ),
          ]),
        const SizedBox(height: Gap.xl),
        if (open && view.balancePaise > 0) ...[
          AsyncButton(
            label: 'Collect ${Money.format(view.balancePaise)}',
            icon: Icons.add_card_rounded,
            onPressed: () async => context.push('/payments/collect?tenant=${i.tenantId}&invoice=${i.id}'),
          ),
          const SizedBox(height: Gap.md),
        ],
        if (open) ...[
          AsyncButton(label: 'Add charge or discount', icon: Icons.tune_rounded, outlined: true, onPressed: () => _adjust(context, ref, i)),
          const SizedBox(height: Gap.md),
        ],
        if (open && i.paidPaise == 0)
          AsyncButton(
            label: 'Cancel invoice',
            icon: Icons.block_rounded,
            outlined: true,
            danger: true,
            onPressed: () async {
              final reason = await askReason(context, title: 'Cancel this invoice?', hint: 'Reason', confirmLabel: 'Cancel invoice');
              if (reason == null || !context.mounted) return;
              await runGuarded(context, () async {
                await ref.read(databaseProvider).billingDao.cancelInvoice(i.id, reason);
                await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
              }, success: 'Invoice cancelled');
            },
          ),
      ],
    );
  }

  Widget _row(TextTheme t, String a, String b, {bool strong = false, Color? color}) => Row(children: [
        Expanded(child: Text(a, style: strong ? t.titleSmall : t.bodyMedium)),
        Text(b, style: (strong ? t.titleSmall : t.bodyMedium)?.copyWith(fontFeatures: AppTheme.tabular, color: color)),
      ]);

  Future<void> _adjust(BuildContext context, WidgetRef ref, RentInvoice i) async {
    final extra = TextEditingController(text: i.additionalChargesPaise == 0 ? '' : Money.toInput(i.additionalChargesPaise));
    final discount = TextEditingController(text: i.discountPaise == 0 ? '' : Money.toInput(i.discountPaise));
    final note = TextEditingController();
    final key = GlobalKey<FormState>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Form(
            key: key,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Charges and discount', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: Gap.xs),
              Text('Rent stays ${Money.format(i.rentPaise)}. Electricity, food or other extras go in charges.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: Gap.lg),
              MoneyField(controller: extra, label: 'Additional charges', allowZero: true, required: false),
              const SizedBox(height: Gap.lg),
              MoneyField(controller: discount, label: 'Discount', allowZero: true, required: false),
              const SizedBox(height: Gap.lg),
              TextField(controller: note, decoration: const InputDecoration(labelText: 'What is this for? (optional)')),
              const SizedBox(height: Gap.xl),
              AsyncButton(
                label: 'Save',
                onPressed: () async {
                  if (!key.currentState!.validate()) return;
                  final ok = await runGuarded(
                    ctx,
                    () => ref.read(databaseProvider).billingDao.adjustInvoice(
                          i.id,
                          additionalChargesPaise: MoneyField.read(extra),
                          discountPaise: MoneyField.read(discount),
                          notes: note.text.trim().isEmpty ? null : [i.notes, note.text.trim()].whereType<String>().join('\n'),
                        ),
                    success: 'Invoice updated',
                  );
                  if (ok && ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
