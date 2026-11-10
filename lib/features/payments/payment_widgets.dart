import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/billing_dao.dart';
import '../../core/database/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/state_views.dart';

(Color, Color) invoiceColors(InvoiceStatus s) => switch (s) {
  InvoiceStatus.paid => (AppColors.success, AppColors.successSoft),
  InvoiceStatus.partiallyPaid => (AppColors.info, AppColors.infoSoft),
  InvoiceStatus.overdue => (AppColors.danger, AppColors.dangerSoft),
  InvoiceStatus.unpaid => (AppColors.warning, AppColors.warningSoft),
  InvoiceStatus.cancelled => (AppColors.textSecondary, AppColors.neutralSoft),
};

StatusPill invoicePill(InvoiceStatus s) {
  final (c, b) = invoiceColors(s);
  return StatusPill(label: s.label, color: c, background: b);
}

IconData methodIcon(PaymentMethod m) => switch (m) {
  PaymentMethod.cash => Icons.payments_outlined,
  PaymentMethod.upi => Icons.qr_code_2_rounded,
  PaymentMethod.bank => Icons.account_balance_outlined,
  PaymentMethod.deposit => Icons.savings_outlined,
};

class InvoiceTile extends StatelessWidget {
  const InvoiceTile({super.key, required this.view, this.showTenant = true});
  final InvoiceView view;
  final bool showTenant;

  @override
  Widget build(BuildContext context) {
    final i = view.invoice;
    final cancelled = i.status == InvoiceStatus.cancelled;
    return _LedgerRow(
      onTap: () => context.push('/invoices/${i.id}'),
      title: showTenant ? view.tenantName : '${Dates.monthYear(i.periodStart)} rent',
      strike: cancelled,
      subtitle: [
        if (showTenant) Dates.monthYear(i.periodStart),
        if (showTenant && view.roomLabel != null) view.roomLabel!,
        'Due ${Dates.dayMonth(i.dueDate)}',
        if (i.isProrated) 'Part month',
      ].join(' · '),
      amount: cancelled || i.status == InvoiceStatus.paid
          ? Money.format(i.totalPaise)
          : Money.format(view.balancePaise),
      tag: invoicePill(i.status),
    );
  }
}

/// Flexible row for money lists: grows with large text instead of clipping.
class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.leading,
    this.tag,
    this.strike = false,
    this.amountColor,
  });

  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final String amount;
  final Widget? leading;
  final Widget? tag;
  final bool strike;
  final Color? amountColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: Gap.lg)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: strike ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  if (tag != null) ...[const SizedBox(height: 6), tag!],
                ],
              ),
            ),
            const SizedBox(width: Gap.md),
            Text(amount, style: AppTheme.figure(15, color: amountColor)),
          ],
        ),
      ),
    );
  }
}

class PaymentTile extends StatelessWidget {
  const PaymentTile({super.key, required this.view, this.showTenant = true});
  final PaymentView view;
  final bool showTenant;

  @override
  Widget build(BuildContext context) {
    final p = view.payment;
    final reversal = p.kind == PaymentKind.reversal;
    final pending = p.status == PaymentStatus.pendingVerification;
    final rejected = p.status == PaymentStatus.rejected;
    final color = reversal ? AppColors.danger : (rejected ? AppColors.textMuted : AppColors.success);
    return _LedgerRow(
      onTap: () => context.push('/payments/${p.id}'),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withValues(alpha: 0.10),
        child: Icon(reversal ? Icons.undo_rounded : methodIcon(p.method), size: 18, color: color),
      ),
      title: showTenant ? view.tenantName : p.receiptNumber,
      strike: rejected || view.isReversed,
      subtitle: [
        if (showTenant) p.receiptNumber,
        reversal ? 'Cancelled payment' : p.method.label,
        Dates.dayMonth(p.paymentDate),
      ].join(' · '),
      amount: '${p.amountPaise < 0 ? '−' : ''}${Money.format(p.amountPaise.abs())}',
      amountColor: rejected ? AppColors.textMuted : null,
      tag: pending
          ? const StatusPill(
              label: 'Check bank app',
              color: AppColors.warning,
              background: AppColors.warningSoft,
              icon: Icons.hourglass_top_rounded,
            )
          : rejected
          ? const StatusPill(label: 'Not received', color: AppColors.textSecondary, background: AppColors.neutralSoft)
          : view.isReversed
          ? const StatusPill(label: 'Cancelled', color: AppColors.danger, background: AppColors.dangerSoft)
          : null,
    );
  }
}

/// A list of tiles inside one card, separated by dividers.
class TileGroup extends StatelessWidget {
  const TileGroup({super.key, required this.children, this.indent = 16});
  final List<Widget> children;
  final double indent;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, c) in children.indexed) ...[if (i > 0) Divider(indent: indent), c],
        ],
      ),
    );
  }
}
