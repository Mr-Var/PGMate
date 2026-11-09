import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/database/daos/reports_dao.dart';
import '../../core/database/daos/tenants_dao.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/state_views.dart';
import '../dashboard/period_picker.dart';
import '../payments/payment_widgets.dart';

IconData reportIcon(ReportType t) => switch (t) {
      ReportType.financialSummary => Icons.insights_rounded,
      ReportType.collection => Icons.account_balance_wallet_outlined,
      ReportType.cashCollection => Icons.payments_outlined,
      ReportType.upiCollection => Icons.qr_code_2_rounded,
      ReportType.pendingRent => Icons.pending_actions_outlined,
      ReportType.overdueRent => Icons.warning_amber_rounded,
      ReportType.expenses => Icons.shopping_bag_outlined,
      ReportType.occupancy => Icons.bed_outlined,
      ReportType.tenantLedger => Icons.menu_book_outlined,
      ReportType.admissions => Icons.login_rounded,
      ReportType.checkouts => Icons.logout_rounded,
      ReportType.deposits => Icons.savings_outlined,
    };

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const groups = [
      ('Money', [ReportType.financialSummary, ReportType.collection, ReportType.cashCollection, ReportType.upiCollection, ReportType.expenses]),
      ('Dues', [ReportType.pendingRent, ReportType.overdueRent, ReportType.tenantLedger, ReportType.deposits]),
      ('Tenants and beds', [ReportType.occupancy, ReportType.admissions, ReportType.checkouts]),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          for (final g in groups) ...[
            SectionHeader(title: g.$1),
            TileGroup(indent: 72, children: [
              for (final r in g.$2)
                ListTile(
                  minTileHeight: 64,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(Radii.md)),
                    child: Icon(reportIcon(r), color: AppColors.primary),
                  ),
                  title: Text(r.title),
                  subtitle: Text(r.subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/more/reports/${r.name}'),
                ),
            ]),
          ],
        ],
      ),
    );
  }
}

class ReportViewScreen extends ConsumerStatefulWidget {
  const ReportViewScreen({super.key, required this.type, this.tenantId});
  final ReportType type;
  final int? tenantId;

  @override
  ConsumerState<ReportViewScreen> createState() => _ReportViewScreenState();
}

class _ReportViewScreenState extends ConsumerState<ReportViewScreen> {
  DateRange _range = DateRange.currentMonth();
  late int? _tenantId = widget.tenantId;
  String _search = '';
  late Future<ReportTable> _future = _load();

  Future<ReportTable> _load() => ref.read(databaseProvider).reportsDao.build(widget.type, _range, tenantId: _tenantId);

  void _reload() => setState(() => _future = _load());

  Future<void> _pickTenant() async {
    final all = await ref.read(databaseProvider).tenantsDao.watchTenants(filter: TenantFilter.all, sort: TenantSort.name).first;
    if (!mounted) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.7,
          child: ListView(children: [
            for (final t in all)
              ListTile(
                title: Text(t.tenant.fullName),
                subtitle: Text('${t.tenant.status.name == 'checkedOut' ? 'Checked out' : t.roomLabel ?? ''} · ${t.tenant.phone}'),
                onTap: () => Navigator.pop(ctx, t.tenant.id),
              ),
          ]),
        ),
      ),
    );
    if (picked != null) {
      _tenantId = picked;
      _reload();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.type == ReportType.tenantLedger && _tenantId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickTenant());
    }
  }

  @override
  Widget build(BuildContext context) {
    final pgName = ref.watch(pgProfileProvider).value?.name ?? 'PG';
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.title),
        actions: [
          FutureBuilder<ReportTable>(
            future: _future,
            builder: (context, snap) => PopupMenuButton<String>(
              tooltip: 'Export',
              icon: const Icon(Icons.ios_share_rounded),
              enabled: snap.hasData,
              onSelected: (v) async {
                final t = snap.data!;
                final name = '${widget.type.name}-${Dates.short(_range.start).replaceAll(' ', '')}';
                if (v == 'pdf') {
                  await Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(t.title)),
                      body: PdfPreview(
                        build: (_) => ref.read(exportServiceProvider).reportPdf(t, pgName: pgName),
                        pdfFileName: '$name.pdf',
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                      ),
                    ),
                  ));
                } else {
                  await ref.read(exportServiceProvider).shareCsv(t, '$name.csv');
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf_outlined), title: Text('PDF'))),
                PopupMenuItem(value: 'csv', child: ListTile(leading: Icon(Icons.table_chart_outlined), title: Text('CSV (Excel)'))),
              ],
            ),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.sm),
          child: Row(children: [
            if (widget.type.usesRange)
              ActionChip(
                avatar: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                label: Text(_range.label),
                onPressed: () async {
                  final r = await showPeriodPicker(context, _range);
                  if (r != null) {
                    _range = r;
                    _reload();
                  }
                },
              ),
            if (widget.type == ReportType.tenantLedger)
              ActionChip(
                avatar: const Icon(Icons.person_search_outlined, size: 18, color: AppColors.primary),
                label: const Text('Choose tenant'),
                onPressed: _pickTenant,
              ),
            const SizedBox(width: Gap.sm),
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Filter rows',
                    prefixIcon: Icon(Icons.search_rounded, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
            ),
          ]),
        ),
        Expanded(
          child: FutureBuilder<ReportTable>(
            future: _future,
            builder: (context, snap) {
              if (snap.hasError) return ErrorState(error: snap.error!, onRetry: _reload);
              if (!snap.hasData) return const LoadingList();
              final t = snap.data!;
              final rows = _search.isEmpty ? t.rows : t.rows.where((r) => r.any((c) => c.toLowerCase().contains(_search))).toList();
              return ListView(
                padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
                children: [
                  Text(t.subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: Gap.md),
                  if (t.summary.isNotEmpty)
                    Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: [
                      for (final s in t.summary)
                        Container(
                          constraints: const BoxConstraints(minWidth: 140),
                          padding: const EdgeInsets.all(Gap.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(Radii.md),
                          ),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.$1, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 2),
                            Text(s.$2, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFeatures: AppTheme.tabular)),
                          ]),
                        ),
                    ]),
                  const SizedBox(height: Gap.lg),
                  if (t.columns.isEmpty || rows.isEmpty)
                    AppCard(
                      child: Text(
                        t.columns.isEmpty ? 'Choose a tenant to see their ledger.' : 'No records for this selection.',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    Card(
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: const WidgetStatePropertyAll(AppColors.surfaceMuted),
                          headingTextStyle: Theme.of(context).textTheme.labelLarge,
                          dataTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontFeatures: AppTheme.tabular),
                          columnSpacing: 20,
                          horizontalMargin: 14,
                          dataRowMinHeight: 40,
                          columns: [
                            for (final c in t.columns) DataColumn(label: Text(c.label), numeric: c.align == ColumnAlign.right),
                          ],
                          rows: [for (final r in rows) DataRow(cells: [for (final c in r) DataCell(Text(c))])],
                        ),
                      ),
                    ),
                  if (t.footer != null) ...[
                    const SizedBox(height: Gap.md),
                    for (final f in t.footer!) Text(f, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  ],
                ],
              );
            },
          ),
        ),
      ]),
    );
  }
}
