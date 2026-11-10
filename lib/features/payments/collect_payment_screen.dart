import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/database/daos/billing_dao.dart';
import '../../core/database/daos/tenants_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/export_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import '../tenants/tenants_providers.dart';

class CollectPaymentScreen extends ConsumerStatefulWidget {
  const CollectPaymentScreen({super.key, this.tenantId, this.invoiceId});
  final int? tenantId;
  final int? invoiceId;

  @override
  ConsumerState<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends ConsumerState<CollectPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _utr = TextEditingController();
  final _notes = TextEditingController();
  late int? _tenantId = widget.tenantId;
  late int? _invoiceId = widget.invoiceId;
  PaymentMethod _method = PaymentMethod.cash;
  DateTime _date = Dates.today();
  bool _verified = false;
  bool _amountTouched = false;

  @override
  void dispose() {
    _amount.dispose();
    _utr.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _suggestAmount(List<InvoiceView> open) {
    if (_amountTouched) return;
    final inv = open.where((v) => v.invoice.id == _invoiceId).firstOrNull;
    final suggested = inv?.balancePaise ?? open.fold<int>(0, (a, v) => a + v.balancePaise);
    final text = suggested > 0 ? Money.toInput(suggested) : '';
    if (_amount.text != text) setState(() => _amount.text = text);
  }

  Future<void> _pickTenant() async {
    final picked = await showModalBottomSheet<TenantListItem>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _TenantPickerSheet(),
    );
    if (picked != null) {
      setState(() {
        _tenantId = picked.tenant.id;
        _invoiceId = null;
        _amountTouched = false;
      });
    }
  }

  Future<void> _save(String tenantName) async {
    if (_tenantId == null) {
      showAppSnack(context, 'Choose a tenant first', error: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final amount = MoneyField.read(_amount);
    final dao = ref.read(databaseProvider).billingDao;

    final similar = await dao.findSimilarPayment(_tenantId!, amount, _date);
    if (similar != null && mounted) {
      final go = await confirmAction(
        context,
        title: 'Possible duplicate',
        message:
            '${similar.receiptNumber} already records ${Money.format(amount)} from $tenantName on ${Dates.short(_date)}. '
            'Record another payment anyway?',
        confirmLabel: 'Record again',
      );
      if (!go) return;
    }
    if (!mounted) return;
    final invoices = ref.read(tenantInvoicesProvider(_tenantId!)).value ?? const <InvoiceView>[];
    final target = invoices.where((v) => v.invoice.id == _invoiceId).firstOrNull;
    final openMonths =
        (invoices.where((v) => v.balancePaise > 0).toList()
              ..sort((a, b) => a.invoice.periodStart.compareTo(b.invoice.periodStart)))
            .map((v) => Dates.monthYear(v.invoice.periodStart))
            .toList();
    final sure = await confirmMoney(
      context,
      title: 'Save this payment?',
      amountPaise: amount,
      details: [
        ('From', tenantName),
        ('Paid by', _method == PaymentMethod.cash ? 'Cash' : 'UPI · ${_utr.text.trim()}'),
        (
          'For',
          target != null
              ? '${Dates.monthYear(target.invoice.periodStart)} rent'
              : (openMonths.isEmpty ? 'Advance (no rent due now)' : openMonths.take(3).join(', ')),
        ),
        ('Date', Dates.short(_date)),
      ],
    );
    if (!sure || !mounted) return;
    int? id;
    final ok = await runGuarded(context, () async {
      id = await dao.recordPayment(
        PaymentInput(
          tenantId: _tenantId!,
          amountPaise: amount,
          method: _method,
          date: _date,
          invoiceId: _invoiceId,
          upiReference: _method == PaymentMethod.upi ? _utr.text : null,
          upiVerified: _verified,
          notes: _notes.text,
        ),
      );
      await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
    });
    if (!ok || !mounted) return;
    final counted = !(_method == PaymentMethod.upi && !_verified);
    showAppSnack(
      context,
      counted
          ? '${Money.format(amount)} received from $tenantName'
          : 'Saved. Verify it in the Payments tab once the money arrives.',
    );
    final db = ref.read(databaseProvider);
    final autoSend = (await db.settingsDao.getSetting('auto_receipt')) != 'false';
    if (!mounted) return;
    context.pushReplacement('/payments/$id');
    if (counted && autoSend) {
      // Opens the tenant's WhatsApp chat with the receipt attached. The
      // payment is already saved, so a sharing problem must not surface as
      // a failure here; the receipt can be sent again from the payment.
      try {
        final r = await db.billingDao.receiptData(id!);
        await ref.read(exportServiceProvider).sendReceiptToTenant(r);
      } catch (e) {
        debugPrint('Auto receipt not sent: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final detail = _tenantId == null ? null : ref.watch(tenantDetailProvider(_tenantId!)).value;
    final invoices = _tenantId == null
        ? const <InvoiceView>[]
        : (ref.watch(tenantInvoicesProvider(_tenantId!)).value ?? const <InvoiceView>[]);
    final open = invoices.where((v) => v.balancePaise > 0).toList()
      ..sort((a, b) => a.invoice.periodStart.compareTo(b.invoice.periodStart));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _tenantId != null) _suggestAmount(open);
    });
    final profile = ref.watch(pgProfileProvider).value;
    final amountPaise = Money.parseRupees(_amount.text) ?? 0;
    final totalDue = open.fold<int>(0, (a, v) => a + v.balancePaise);

    return Scaffold(
      appBar: AppBar(title: const Text('Collect rent')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: FormScroll(
            padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
            children: [
              AppCard(
                onTap: widget.tenantId == null ? _pickTenant : null,
                child: Row(
                  children: [
                    if (detail != null)
                      PersonAvatar(name: detail.tenant.fullName, photoPath: detail.tenant.photoPath)
                    else
                      const CircleAvatar(radius: 22, child: Icon(Icons.person_search_outlined)),
                    const SizedBox(width: Gap.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail?.tenant.fullName ?? 'Choose tenant', style: t.titleMedium),
                          Text(
                            detail == null
                                ? 'Tap to search by name or phone'
                                : '${detail.current?.label ?? 'No bed'} · ${totalDue > 0 ? '${Money.format(totalDue)} due' : 'No dues'}',
                            style: t.bodySmall?.copyWith(color: totalDue > 0 ? AppColors.danger : AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (widget.tenantId == null) const Icon(Icons.expand_more_rounded),
                  ],
                ),
              ),
              if (detail != null) ...[
                if (open.isNotEmpty) ...[
                  const SectionHeader(title: 'Apply to'),
                  Wrap(
                    spacing: Gap.sm,
                    runSpacing: Gap.sm,
                    children: [
                      ChoiceChip(
                        label: Text('Oldest dues first · ${Money.format(totalDue)}'),
                        selected: _invoiceId == null,
                        showCheckmark: false,
                        onSelected: (_) => setState(() {
                          _invoiceId = null;
                          _amountTouched = false;
                        }),
                      ),
                      for (final v in open)
                        ChoiceChip(
                          label: Text('${Dates.monthYear(v.invoice.periodStart)} · ${Money.format(v.balancePaise)}'),
                          selected: _invoiceId == v.invoice.id,
                          showCheckmark: false,
                          onSelected: (_) => setState(() {
                            _invoiceId = v.invoice.id;
                            _amountTouched = false;
                          }),
                        ),
                    ],
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.only(top: Gap.lg),
                    child: Text(
                      'No open rent bills. This payment will be kept as extra paid (advance) for the next rent bill.',
                      style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                const SectionHeader(title: 'Payment'),
                MoneyField(
                  controller: _amount,
                  label: 'Amount received',
                  onChanged: (_) => setState(() => _amountTouched = true),
                  helper: amountPaise > totalDue && totalDue > 0
                      ? '${Money.format(amountPaise - totalDue)} extra will be kept as advance for next month.'
                      : null,
                ),
                const SizedBox(height: Gap.lg),
                SegmentedButton<PaymentMethod>(
                  segments: const [
                    ButtonSegment(value: PaymentMethod.cash, label: Text('Cash'), icon: Icon(Icons.payments_outlined)),
                    ButtonSegment(value: PaymentMethod.upi, label: Text('UPI'), icon: Icon(Icons.qr_code_2_rounded)),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) => setState(() => _method = s.first),
                ),
                const SizedBox(height: Gap.lg),
                DateField(
                  label: 'Payment date',
                  value: _date,
                  first: detail.tenant.joiningDate,
                  last: Dates.today(),
                  onChanged: (d) => setState(() => _date = d),
                ),
                if (_method == PaymentMethod.upi) ...[
                  if (profile?.upiId != null && amountPaise > 0) ...[
                    const SizedBox(height: Gap.lg),
                    _UpiQrCard(
                      upiId: profile!.upiId!,
                      payee: profile.name,
                      amountPaise: amountPaise,
                      note: 'Rent ${detail.tenant.fullName.split(' ').first}',
                    ),
                  ] else if (profile?.upiId == null) ...[
                    const SizedBox(height: Gap.md),
                    Text(
                      'Add your UPI ID in Settings → PG profile to show a QR code here.',
                      style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: _utr,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'UPI transaction number',
                      hintText: '12-digit number from the UPI app',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().length < 6 ? 'Enter the transaction number shown in the UPI app' : null,
                  ),
                  const SizedBox(height: Gap.sm),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _verified,
                    onChanged: (v) => setState(() => _verified = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('I checked my UPI / bank app and the money has arrived'),
                    subtitle: Text(
                      _verified
                          ? 'Counted as collected now.'
                          : 'Saved as awaiting verification. Not counted until you confirm it.',
                      style: TextStyle(color: _verified ? AppColors.success : AppColors.warning),
                    ),
                  ),
                ],
                const SizedBox(height: Gap.lg),
                TextField(
                  controller: _notes,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: Gap.xl),
                AsyncButton(
                  label: amountPaise > 0 ? 'Record ${Money.format(amountPaise)}' : 'Record payment',
                  icon: Icons.check_rounded,
                  onPressed: () => _save(detail.tenant.fullName),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UpiQrCard extends StatelessWidget {
  const _UpiQrCard({required this.upiId, required this.payee, required this.amountPaise, required this.note});
  final String upiId;
  final String payee;
  final int amountPaise;
  final String note;

  @override
  Widget build(BuildContext context) {
    final uri = ExportService.upiUri(upiId: upiId, payeeName: payee, amountPaise: amountPaise, note: note);
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(Radii.sm)),
            child: QrImageView(data: uri.toString(), size: 112, padding: EdgeInsets.zero),
          ),
          const SizedBox(width: Gap.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tenant scans to pay', style: t.titleSmall),
                const SizedBox(height: 2),
                Text(
                  '${Money.format(amountPaise)} to $upiId',
                  style: t.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: Gap.sm),
                TextButton.icon(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 40)),
                  onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Open UPI app'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TenantPickerSheet extends ConsumerStatefulWidget {
  const _TenantPickerSheet();

  @override
  ConsumerState<_TenantPickerSheet> createState() => _TenantPickerSheetState();
}

class _TenantPickerSheetState extends ConsumerState<_TenantPickerSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(currentTenantsProvider);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.md),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _q = v.toLowerCase()),
                decoration: const InputDecoration(hintText: 'Search tenant', prefixIcon: Icon(Icons.search_rounded)),
              ),
            ),
            Expanded(
              child: list.when(
                loading: () => const LoadingList(),
                error: (e, _) => ErrorState(error: e),
                data: (items) {
                  final f =
                      items
                          .where(
                            (i) =>
                                _q.isEmpty ||
                                i.tenant.fullName.toLowerCase().contains(_q) ||
                                i.tenant.phone.contains(_q),
                          )
                          .toList()
                        ..sort((a, b) => b.duesPaise.compareTo(a.duesPaise));
                  if (f.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off_rounded,
                      title: 'No tenants found',
                      message: 'Only current tenants are listed.',
                    );
                  }
                  return ListView.builder(
                    itemCount: f.length,
                    itemBuilder: (_, i) {
                      final it = f[i];
                      return ListTile(
                        minTileHeight: 64,
                        leading: PersonAvatar(name: it.tenant.fullName, photoPath: it.tenant.photoPath),
                        title: Text(it.tenant.fullName),
                        subtitle: Text(it.roomLabel ?? 'No bed'),
                        trailing: it.duesPaise > 0
                            ? Text(
                                Money.format(it.duesPaise),
                                style: TextStyle(
                                  fontFeatures: AppTheme.tabular,
                                  fontWeight: FontWeight.w600,
                                  color: it.overdue ? AppColors.danger : AppColors.textPrimary,
                                ),
                              )
                            : const Text('Paid up', style: TextStyle(color: AppColors.success)),
                        onTap: () => Navigator.pop(context, it),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
