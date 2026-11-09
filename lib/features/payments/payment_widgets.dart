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
    final t = Theme.of(context).textTheme;
    final i = view.invoice;
    final cancelled = i.status == InvoiceStatus.cancelled;
    return ListTile(
      minTileHeight: 68,
      onTap: () => context.push('/invoices/${i.id}'),
      title: Text(
        showTenant ? view.tenantName : '${Dates.monthYear(i.periodStart)} rent',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(decoration: cancelled ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(
        [
          if (showTenant) Dates.monthYear(i.periodStart),
          if (showTenant && view.roomLabel != null) view.roomLabel!,
          'Due ${Dates.dayMonth(i.dueDate)}',
          if (i.isProrated) 'Prorated',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.bodySmall?.copyWith(color: AppColors.textMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            cancelled || i.status == InvoiceStatus.paid ? Money.format(i.totalPaise) : Money.format(view.balancePaise),
            style: t.titleSmall?.copyWith(fontFeatures: AppTheme.tabular),
          ),
          const SizedBox(height: 4),
          invoicePill(i.status),
        ],
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
    final t = Theme.of(context).textTheme;
    final p = view.payment;
    final reversal = p.kind == PaymentKind.reversal;
    final pending = p.status == PaymentStatus.pendingVerification;
    final rejected = p.status == PaymentStatus.rejected;
    final color = reversal ? AppColors.danger : (rejected ? AppColors.textMuted : AppColors.success);
    return ListTile(
      minTileHeight: 68,
      onTap: () => context.push('/payments/${p.id}'),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withValues(alpha: 0.10),
        child: Icon(reversal ? Icons.undo_rounded : methodIcon(p.method), size: 20, color: color),
      ),
      title: Text(
        showTenant ? view.tenantName : p.receiptNumber,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(decoration: rejected || view.isReversed ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(
        [
          if (showTenant) p.receiptNumber,
          reversal ? 'Reversal' : p.method.label,
          Dates.dayMonth(p.paymentDate),
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: t.bodySmall?.copyWith(color: AppColors.textMuted),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${p.amountPaise < 0 ? '−' : ''}${Money.format(p.amountPaise.abs())}',
            style: t.titleSmall?.copyWith(fontFeatures: AppTheme.tabular, color: rejected ? AppColors.textMuted : null),
          ),
          if (pending)
            const StatusPill(
              label: 'Verify',
              color: AppColors.warning,
              background: AppColors.warningSoft,
              icon: Icons.hourglass_top_rounded,
            )
          else if (rejected)
            const StatusPill(label: 'Rejected', color: AppColors.textSecondary, background: AppColors.neutralSoft)
          else if (view.isReversed)
            const StatusPill(label: 'Reversed', color: AppColors.danger, background: AppColors.dangerSoft),
        ],
      ),
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
