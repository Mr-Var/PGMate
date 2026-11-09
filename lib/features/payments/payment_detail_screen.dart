import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/database/daos/billing_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/state_views.dart';
import 'payment_widgets.dart';
import 'payments_providers.dart';

class PaymentDetailScreen extends ConsumerWidget {
  const PaymentDetailScreen({super.key, required this.paymentId});
  final int paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pv = ref.watch(paymentProvider(paymentId));
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: pv.when(
        skipLoadingOnReload: true,
        loading: () => const LoadingList(),
        error: (e, _) => ErrorState(error: e),
        data: (v) => v == null
            ? const EmptyState(icon: Icons.search_off_rounded, title: 'Payment not found', message: 'This record does not exist.')
            : _Body(view: v),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.view});
  final PaymentView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = view.payment;
    final t = Theme.of(context).textTheme;
    final pending = p.status == PaymentStatus.pendingVerification;
    final reversal = p.kind == PaymentKind.reversal;
    final canReverse = !reversal && p.status == PaymentStatus.confirmed && !view.isReversed && p.method != PaymentMethod.deposit;
    final (statusLabel, statusColor, statusBg) = switch (p.status) {
      _ when view.isReversed => ('Reversed', AppColors.danger, AppColors.dangerSoft),
      PaymentStatus.confirmed => (reversal ? 'Reversal' : 'Confirmed', reversal ? AppColors.danger : AppColors.success,
          reversal ? AppColors.dangerSoft : AppColors.successSoft),
      PaymentStatus.pendingVerification => ('Awaiting verification', AppColors.warning, AppColors.warningSoft),
      PaymentStatus.rejected => ('Rejected', AppColors.textSecondary, AppColors.neutralSoft),
    };
    final rows = <(String, String)>[
      ('Tenant', view.tenantName),
      ('Receipt', p.receiptNumber),
      ('Date', Dates.short(p.paymentDate)),
      ('Method', p.method.label),
      if (p.upiReference != null) ('UTR', p.upiReference!),
      if (p.verifiedAt != null) ('Verified', Dates.short(p.verifiedAt!)),
      ('Transaction ID', p.transactionId),
      if (p.notes != null) ('Notes', p.notes!),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
      children: [
        Container(
          padding: const EdgeInsets.all(Gap.xl),
          decoration: BoxDecoration(
            color: reversal ? AppColors.danger : AppColors.primary,
            borderRadius: BorderRadius.circular(Radii.xl),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(reversal ? Icons.undo_rounded : methodIcon(p.method), color: Colors.white70),
              const SizedBox(width: Gap.sm),
              Text(reversal ? 'Amount reversed' : 'Amount received', style: t.labelLarge?.copyWith(color: Colors.white70)),
            ]),
            const SizedBox(height: Gap.sm),
            Text(Money.format(p.amountPaise.abs()),
                style: t.displaySmall?.copyWith(color: Colors.white, fontFeatures: AppTheme.tabular)),
            const SizedBox(height: Gap.md),
            StatusPill(label: statusLabel, color: statusColor, background: statusBg),
          ]),
        ),
        const SizedBox(height: Gap.lg),
        AppCard(
          child: Column(children: [
            for (final (i, r) in rows.indexed) ...[
              if (i > 0) const Divider(height: Gap.xl),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 116, child: Text(r.$1, style: t.bodyMedium?.copyWith(color: AppColors.textMuted))),
                Expanded(child: SelectableText(r.$2, style: t.bodyMedium)),
              ]),
            ],
          ]),
        ),
        const SizedBox(height: Gap.xl),
        if (pending) ...[
          AsyncButton(
            label: 'Money received · confirm',
            icon: Icons.verified_rounded,
            onPressed: () => runGuarded(context, () async {
              await ref.read(databaseProvider).billingDao.verifyUpiPayment(p.id);
              await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
            }, success: 'Payment confirmed'),
          ),
          const SizedBox(height: Gap.md),
          AsyncButton(
            label: 'Not received · reject',
            outlined: true,
            danger: true,
            onPressed: () async {
              final reason = await askReason(context, title: 'Reject this UPI payment?', hint: 'What happened?', confirmLabel: 'Reject');
              if (reason == null || !context.mounted) return;
              await runGuarded(context, () => ref.read(databaseProvider).billingDao.rejectUpiPayment(p.id, reason), success: 'Rejected');
            },
          ),
          const SizedBox(height: Gap.md),
        ],
        if (p.status != PaymentStatus.rejected) ...[
          AsyncButton(
            label: 'View receipt',
            icon: Icons.receipt_long_rounded,
            outlined: pending,
            onPressed: () async => context.push('/payments/${p.id}/receipt'),
          ),
          const SizedBox(height: Gap.md),
          AsyncButton(
            label: 'Share on WhatsApp',
            icon: Icons.chat_outlined,
            outlined: true,
            onPressed: () async {
              final r = await ref.read(databaseProvider).billingDao.receiptData(p.id);
              final pdf = await ref.read(exportServiceProvider).receiptPdf(r);
              final f = await ref.read(exportServiceProvider).writeTemp('${p.receiptNumber}.pdf', pdf);
              await ref.read(exportServiceProvider).shareFile(
                    f,
                    mime: 'application/pdf',
                    text: '${r.profile.name}: received ${Money.format(p.amountPaise.abs())} from ${r.tenant.fullName} '
                        'on ${Dates.short(p.paymentDate)}. Receipt ${p.receiptNumber}. Balance due ${Money.format(r.outstandingPaise)}.',
                  );
            },
          ),
        ],
        if (canReverse) ...[
          const SizedBox(height: Gap.xl),
          const Divider(),
          const SizedBox(height: Gap.md),
          Text('Entered something wrong? Payments are never edited. Reverse this one and record it again.',
              style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: Gap.md),
          AsyncButton(
            label: 'Reverse payment',
            icon: Icons.undo_rounded,
            outlined: true,
            danger: true,
            onPressed: () => _reverse(context, ref, p.id),
          ),
        ],
      ],
    );
  }

  Future<void> _reverse(BuildContext context, WidgetRef ref, int id) async {
    final reason = await askReason(context, title: 'Reverse this payment?', hint: 'Reason for reversal', confirmLabel: 'Continue');
    if (reason == null || !context.mounted) return;
    final auth = ref.read(authServiceProvider);
    final ok = await confirmOwnerPin(
      context,
      message: 'Reversing a payment changes the tenant\'s balance.',
      length: AuthService.pinLength,
      verify: (pin) async => switch (await auth.verifyPin(pin)) { PinOk() => true, PinWrong() => false, PinLockedOut() => null },
    );
    if (!ok || !context.mounted) return;
    await runGuarded(context, () async {
      final revId = await ref.read(databaseProvider).billingDao.reversePayment(id, reason);
      await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
      if (context.mounted) context.pushReplacement('/payments/$revId');
    }, success: 'Payment reversed');
  }
}

class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({super.key, required this.paymentId});
  final int paymentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: PdfPreview(
        build: (_) async {
          final r = await ref.read(databaseProvider).billingDao.receiptData(paymentId);
          return ref.read(exportServiceProvider).receiptPdf(r);
        },
        pdfFileName: 'receipt-$paymentId.pdf',
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        loadingWidget: const CircularProgressIndicator(),
      ),
    );
  }
}
