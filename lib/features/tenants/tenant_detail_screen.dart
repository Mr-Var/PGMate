import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/tenants_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import '../complaints/complaint_widgets.dart';
import '../payments/payment_widgets.dart';
import 'tenant_actions.dart';
import 'tenants_providers.dart';
import 'tenants_screen.dart';

enum _Tab { billing, stay, documents, complaints }

class TenantDetailScreen extends ConsumerStatefulWidget {
  const TenantDetailScreen({super.key, required this.tenantId});
  final int tenantId;

  @override
  ConsumerState<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends ConsumerState<TenantDetailScreen> {
  _Tab _tab = _Tab.billing;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(tenantDetailProvider(widget.tenantId));
    return detail.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(body: LoadingList()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(error: e),
      ),
      data: (d) {
        if (d == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Tenant not found',
              message: 'This record no longer exists.',
            ),
          );
        }
        final t = d.tenant;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tenant'),
            actions: [
              IconButton(
                tooltip: 'Edit details',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push('/tenants/${t.id}/edit'),
              ),
              PopupMenuButton<String>(
                tooltip: 'More actions',
                onSelected: (v) => _menu(v, d),
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'ledger', child: Text('Ledger report')),
                  if (t.securityDepositPaise > 0) const PopupMenuItem(value: 'deposit', child: Text('Deposit receipt')),
                  if (d.isCurrent && d.current != null)
                    const PopupMenuItem(value: 'transfer', child: Text('Transfer bed')),
                  if (t.status == TenantStatus.noticeGiven)
                    const PopupMenuItem(value: 'withdraw', child: Text('Withdraw notice')),
                  if (t.status == TenantStatus.checkedOut)
                    const PopupMenuItem(value: 'archive', child: Text('Archive')),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
            children: [
              _Header(detail: d),
              const SizedBox(height: Gap.lg),
              _Money(detail: d),
              const SizedBox(height: Gap.lg),
              _Actions(detail: d),
              const SizedBox(height: Gap.xl),
              SegmentedButton<_Tab>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: _Tab.billing, label: Text('Billing')),
                  ButtonSegment(value: _Tab.stay, label: Text('Stay')),
                  ButtonSegment(value: _Tab.documents, label: Text('Docs')),
                  ButtonSegment(value: _Tab.complaints, label: Text('Issues')),
                ],
                selected: {_tab},
                onSelectionChanged: (s) => setState(() => _tab = s.first),
              ),
              const SizedBox(height: Gap.lg),
              switch (_tab) {
                _Tab.billing => _Billing(tenantId: t.id),
                _Tab.stay => _Stay(detail: d),
                _Tab.documents => _Documents(tenant: t),
                _Tab.complaints => _Complaints(tenantId: t.id),
              },
            ],
          ),
        );
      },
    );
  }

  Future<void> _menu(String v, TenantDetail d) async {
    final dao = ref.read(databaseProvider).tenantsDao;
    switch (v) {
      case 'deposit':
        context.push('/tenants/${d.tenant.id}/deposit-receipt');
      case 'ledger':
        context.push('/more/reports/tenantLedger?tenant=${d.tenant.id}');
      case 'transfer':
        await showTransferSheet(context, ref, d);
      case 'withdraw':
        if (await confirmAction(
          context,
          title: 'Withdraw notice?',
          message: '${d.tenant.fullName} will be marked active again.',
        )) {
          if (mounted) await runGuarded(context, () => dao.withdrawNotice(d.tenant.id), success: 'Notice withdrawn');
        }
      case 'archive':
        if (await confirmAction(
          context,
          title: 'Archive tenant?',
          message: 'Archived tenants are hidden from lists. Their history is kept.',
        )) {
          if (mounted) await runGuarded(context, () => dao.archive(d.tenant.id), success: 'Tenant archived');
        }
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.detail});
  final TenantDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = detail.tenant;
    final text = Theme.of(context).textTheme;
    final (color, bg) = statusColors(t.status);
    return Row(
      children: [
        PersonAvatar(name: t.fullName, photoPath: t.photoPath, radius: 34),
        const SizedBox(width: Gap.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.fullName, style: text.headlineSmall),
              const SizedBox(height: 2),
              Text(
                detail.current?.label ?? 'No bed assigned',
                style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: Gap.sm),
              Wrap(
                spacing: Gap.sm,
                runSpacing: Gap.xs,
                children: [
                  StatusPill(label: t.status.label, color: color, background: bg),
                  if (t.status == TenantStatus.noticeGiven && t.expectedCheckoutDate != null)
                    StatusPill(
                      label: 'Leaves ${Dates.dayMonth(t.expectedCheckoutDate!)}',
                      color: AppColors.info,
                      background: AppColors.infoSoft,
                    ),
                ],
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Call ${t.phone}',
          onPressed: () => launchUrl(Uri(scheme: 'tel', path: '+91${t.phone}')),
          icon: const Icon(Icons.call_outlined),
        ),
      ],
    );
  }
}

class _Money extends StatelessWidget {
  const _Money({required this.detail});
  final TenantDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = detail.tenant;
    final credit = detail.creditPaise > 0 ? detail.creditPaise : 0;
    return Row(
      children: [
        Expanded(
          child: MetricTile(
            icon: Icons.pending_actions_outlined,
            label: 'Dues',
            value: Money.format(detail.outstandingPaise),
            caption: credit > 0 ? '${Money.format(credit)} advance' : 'Unpaid invoices',
            tone: detail.outstandingPaise > 0 ? AppColors.danger : AppColors.success,
            valueColor: detail.outstandingPaise > 0 ? AppColors.danger : null,
          ),
        ),
        const SizedBox(width: Gap.md),
        Expanded(
          child: MetricTile(
            icon: Icons.savings_outlined,
            label: 'Rent · Deposit',
            value: Money.format(t.monthlyRentPaise),
            caption: '${Money.format(t.securityDepositPaise)} deposit',
          ),
        ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.detail});
  final TenantDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = detail.tenant;
    final actions = <(IconData, String, VoidCallback)>[
      if (detail.isCurrent || detail.outstandingPaise > 0)
        (Icons.account_balance_wallet_outlined, 'Collect', () => context.push('/payments/collect?tenant=${t.id}')),
      if (detail.isCurrent && detail.current == null)
        (Icons.bed_outlined, 'Assign bed', () => showAssignBedSheet(context, ref, detail)),
      if (t.status == TenantStatus.active || t.status == TenantStatus.newTenant)
        (Icons.event_busy_outlined, 'Notice', () => showNoticeSheet(context, ref, detail)),
      if (detail.isCurrent) (Icons.logout_rounded, 'Check out', () => context.push('/tenants/${t.id}/checkout')),
      (Icons.chat_outlined, 'WhatsApp', () => _whatsApp(ref)),
    ];
    return Row(
      children: [
        for (final (i, a) in actions.indexed) ...[
          if (i > 0) const SizedBox(width: Gap.sm),
          Expanded(
            child: Material(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.md),
                side: const BorderSide(color: AppColors.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.md),
                onTap: a.$3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Gap.md),
                  child: Column(
                    children: [
                      Icon(a.$1, color: AppColors.primary),
                      const SizedBox(height: 4),
                      Text(
                        a.$2,
                        style: Theme.of(context).textTheme.labelMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _whatsApp(WidgetRef ref) async {
    final t = detail.tenant;
    final pg = ref.read(pgProfileProvider).value;
    final msg = detail.outstandingPaise > 0
        ? 'Hi ${t.fullName.split(' ').first}, a gentle reminder that ${Money.format(detail.outstandingPaise)} rent is pending'
              '${pg == null ? '' : ' at ${pg.name}'}.${pg?.upiId == null ? '' : ' UPI: ${pg!.upiId}'} Thank you!'
        : 'Hi ${t.fullName.split(' ').first},';
    await ref.read(exportServiceProvider).whatsapp(msg, phone: t.phone);
  }
}

class _Billing extends ConsumerWidget {
  const _Billing({required this.tenantId});
  final int tenantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(tenantInvoicesProvider(tenantId));
    final payments = ref.watch(tenantPaymentsProvider(tenantId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Invoices',
          trailing: TextButton.icon(
            onPressed: () => context.push('/invoices/new?tenant=$tenantId'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New'),
          ),
        ),
        invoices.when(
          loading: () => const SkeletonBox(height: 120, radius: Radii.lg),
          error: (e, _) => Text('$e'),
          data: (l) => l.isEmpty
              ? const _Inline(text: 'No invoices yet. Monthly invoices are created from the Payments tab.')
              : TileGroup(children: [for (final v in l.take(12)) InvoiceTile(view: v, showTenant: false)]),
        ),
        const SectionHeader(title: 'Payments'),
        payments.when(
          loading: () => const SkeletonBox(height: 120, radius: Radii.lg),
          error: (e, _) => Text('$e'),
          data: (l) => l.isEmpty
              ? const _Inline(text: 'No payments recorded.')
              : TileGroup(indent: 68, children: [for (final v in l.take(20)) PaymentTile(view: v, showTenant: false)]),
        ),
      ],
    );
  }
}

class _Stay extends StatelessWidget {
  const _Stay({required this.detail});
  final TenantDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = detail.tenant;
    final rows = <(String, String)>[
      ('Phone', '+91 ${t.phone}'),
      if (t.email != null) ('Email', t.email!),
      ('Gender', t.gender.label),
      if (t.occupation != null) ('Occupation', t.occupation!),
      ('Joined', Dates.short(t.joiningDate)),
      ('Rent due', 'Day ${t.rentDueDay} of each month'),
      if (t.emergencyContactName != null) ('Emergency', '${t.emergencyContactName} · ${t.emergencyContactPhone ?? ''}'),
      if (t.noticeDate != null) ('Notice given', Dates.short(t.noticeDate!)),
      if (t.checkoutDate != null) ('Checked out', Dates.short(t.checkoutDate!)),
      if (t.checkoutDate != null) ('Deposit adjusted', Money.format(t.depositAdjustedPaise)),
      if (t.checkoutDate != null) ('Deposit refunded', Money.format(t.depositRefundedPaise)),
      if (t.notes != null) ('Notes', t.notes!),
    ];
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            children: [
              for (final (i, r) in rows.indexed) ...[
                if (i > 0) const Divider(height: Gap.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(r.$1, style: text.bodyMedium?.copyWith(color: AppColors.textMuted)),
                    ),
                    Expanded(child: Text(r.$2, style: text.bodyMedium)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SectionHeader(title: 'Bed history'),
        if (detail.history.isEmpty)
          const _Inline(text: 'No bed assigned yet.')
        else
          TileGroup(
            children: [
              for (final a in detail.history)
                ListTile(
                  leading: Icon(
                    a.allocation.isActive ? Icons.bed_rounded : Icons.history_rounded,
                    color: a.allocation.isActive ? AppColors.primary : AppColors.textMuted,
                  ),
                  title: Text(a.label),
                  subtitle: Text(
                    '${Dates.short(a.allocation.startDate)} – ${a.allocation.endDate == null ? 'now' : Dates.short(a.allocation.endDate!)}'
                    '${a.allocation.endReason == null ? '' : ' · ${a.allocation.endReason}'}',
                  ),
                  trailing: Text(
                    Money.format(a.allocation.rentPaise),
                    style: const TextStyle(fontFeatures: AppTheme.tabular),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _Documents extends StatelessWidget {
  const _Documents({required this.tenant});
  final Tenant tenant;

  @override
  Widget build(BuildContext context) {
    final docs = <(String, String, IconData)>[
      if (tenant.photoPath != null) ('Photo', tenant.photoPath!, Icons.portrait_outlined),
      if (tenant.idProofPath != null)
        (
          '${tenant.idProofType ?? 'ID proof'}${tenant.idProofNumber == null ? '' : ' · ${tenant.idProofNumber}'}',
          tenant.idProofPath!,
          Icons.badge_outlined,
        ),
    ];
    final depositTile = tenant.securityDepositPaise <= 0
        ? null
        : ListTile(
            leading: const Icon(Icons.savings_outlined, color: AppColors.primary),
            title: const Text('Deposit receipt'),
            subtitle: Text('${Money.format(tenant.securityDepositPaise)} · PDF'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/tenants/${tenant.id}/deposit-receipt'),
          );
    if (docs.isEmpty && depositTile == null) {
      return _Inline(
        text: 'No documents uploaded. Add a photo or ID proof from Edit details.',
        onTap: () => context.push('/tenants/${tenant.id}/edit'),
      );
    }
    return TileGroup(
      children: [
        for (final d in docs)
          ListTile(
            leading: Icon(d.$3, color: AppColors.primary),
            title: Text(d.$1),
            subtitle: const Text('Stored privately on this phone'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () =>
                context.push(Uri(path: '/document', queryParameters: {'path': d.$2, 'title': d.$1}).toString()),
          ),
        ?depositTile,
      ],
    );
  }
}

class _Complaints extends ConsumerWidget {
  const _Complaints({required this.tenantId});
  final int tenantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(tenantComplaintsProvider(tenantId));
    return list.when(
      loading: () => const SkeletonBox(height: 120, radius: Radii.lg),
      error: (e, _) => Text('$e'),
      data: (l) => l.isEmpty
          ? _Inline(
              text: 'No complaints from this tenant.',
              onTap: () => context.push('/more/complaints/new?tenant=$tenantId'),
            )
          : TileGroup(children: [for (final c in l) ComplaintTile(view: c, showTenant: false)]),
    );
  }
}

class _Inline extends StatelessWidget {
  const _Inline({required this.text, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
    );
  }
}
