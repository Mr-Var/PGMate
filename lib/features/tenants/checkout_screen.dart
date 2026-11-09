import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/billing_dao.dart';
import '../../core/database/enums.dart';
import '../../core/database/rules.dart';
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
import 'tenant_actions.dart';
import 'tenants_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.tenantId});
  final int tenantId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DateTime? _date;
  final _deductions = TextEditingController();
  final _deductionNote = TextEditingController();
  final _notes = TextEditingController();
  PaymentMethod _refundMethod = PaymentMethod.cash;
  Future<CheckoutPreview>? _preview;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(databaseProvider).tenantsDao.tenantDetail(widget.tenantId).then((d) {
      if (!mounted || d == null) return;
      final t = d.tenant;
      setState(() => _date = t.expectedCheckoutDate ?? Dates.today());
      _recalc();
    });
  }

  @override
  void dispose() {
    _deductions.dispose();
    _deductionNote.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _recalc() {
    if (_date == null) return;
    setState(() {
      _error = null;
      _preview = ref
          .read(databaseProvider)
          .billingDao
          .previewCheckout(widget.tenantId, _date!, deductionsPaise: Money.parseRupees(_deductions.text) ?? 0)
          .catchError((Object e) {
        if (mounted) setState(() => _error = e is RuleException ? e.message : '$e');
        throw e;
      });
    });
  }

  Future<void> _confirm(String name) async {
    final auth = ref.read(authServiceProvider);
    final pinOk = await confirmOwnerPin(
      context,
      title: 'Confirm checkout',
      message: 'Checkout settles money and frees the bed. Enter your PIN.',
      length: AuthService.pinLength,
      verify: (pin) async => switch (await auth.verifyPin(pin)) { PinOk() => true, PinWrong() => false, PinLockedOut() => null },
    );
    if (!pinOk || !mounted) return;
    CheckoutResult? result;
    final ok = await runGuarded(context, () async {
      result = await ref.read(databaseProvider).billingDao.checkout(
            widget.tenantId,
            _date!,
            deductionsPaise: Money.parseRupees(_deductions.text) ?? 0,
            deductionNote: _deductionNote.text.trim().isEmpty ? null : 'Deduction: ${_deductionNote.text.trim()}',
            refundMethod: _refundMethod,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
    });
    if (!ok || !mounted || result == null) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 40),
        title: Text('$name checked out'),
        content: Text(
          [
            if (result!.refundPaise > 0) 'Refund ${Money.format(result!.refundPaise)} to the tenant.',
            if (result!.toCollectPaise > 0) 'Collect ${Money.format(result!.toCollectPaise)} still due.',
            if (result!.refundPaise == 0 && result!.toCollectPaise == 0) 'Fully settled. Nothing to pay or refund.',
            'The bed is now available. Payment history is kept.',
          ].join('\n\n'),
        ),
        actions: [
          if (result!.toCollectPaise > 0)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.pushReplacement('/payments/collect?tenant=${widget.tenantId}');
              },
              child: const Text('Collect now'),
            ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(tenantDetailProvider(widget.tenantId)).value;
    final t = Theme.of(context).textTheme;
    final name = detail?.tenant.fullName ?? 'Tenant';
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: _date == null || detail == null
          ? const LoadingList()
          : ListView(
              padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
              children: [
                Text(name, style: t.headlineSmall),
                Text(detail.current?.label ?? 'No bed', style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: Gap.xl),
                DateField(
                  label: 'Checkout date',
                  value: _date!,
                  first: detail.tenant.joiningDate,
                  onChanged: (d) {
                    _date = d;
                    _recalc();
                  },
                ),
                const SizedBox(height: Gap.lg),
                MoneyField(
                  controller: _deductions,
                  label: 'Deductions (damages, cleaning…)',
                  allowZero: true,
                  required: false,
                  onChanged: (_) => _recalc(),
                ),
                const SizedBox(height: Gap.lg),
                TextField(
                  controller: _deductionNote,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Deduction reason (optional)', hintText: 'e.g. Broken chair'),
                ),
                const SectionHeader(title: 'Settlement'),
                FutureBuilder<CheckoutPreview>(
                  future: _preview,
                  builder: (context, snap) {
                    if (_error != null) {
                      return AppCard(child: Text(_error!, style: const TextStyle(color: AppColors.danger)));
                    }
                    final p = snap.data;
                    if (p == null) return const SkeletonBox(height: 260, radius: Radii.lg);
                    final rows = <(String, int, String?)>[
                      ('Unpaid invoices', p.outstandingPaise, null),
                      (
                        'Final month rent',
                        p.finalMonthRentPaise - p.finalMonthInvoiced,
                        '${p.daysInFinalMonth} days of ${Dates.monthYear(p.checkoutDate)} = ${Money.format(p.finalMonthRentPaise)}'
                            '${p.finalMonthInvoiced > 0 ? ', invoiced ${Money.format(p.finalMonthInvoiced)}' : ''}'
                      ),
                      if (p.deductionsPaise > 0) ('Deductions', p.deductionsPaise, null),
                      ('Advance credit', -p.creditPaise, null),
                      ('Security deposit', -p.depositPaise, null),
                    ];
                    return Column(children: [
                      AppCard(
                        child: Column(children: [
                          for (final (i, r) in rows.indexed) ...[
                            if (i > 0) const Divider(height: Gap.xl),
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(r.$1, style: t.bodyMedium),
                                  if (r.$3 != null) Text(r.$3!, style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
                                ]),
                              ),
                              Text(
                                '${r.$2 < 0 ? '−' : r.$2 > 0 ? '+' : ''}${Money.format(r.$2.abs())}',
                                style: t.titleSmall?.copyWith(
                                  fontFeatures: AppTheme.tabular,
                                  color: r.$2 < 0 ? AppColors.success : AppColors.textPrimary,
                                ),
                              ),
                            ]),
                          ],
                        ]),
                      ),
                      const SizedBox(height: Gap.md),
                      SettlementBanner(amountPaise: p.settlementPaise),
                      if (p.settlementPaise > 0) ...[
                        const SizedBox(height: Gap.lg),
                        SegmentedButton<PaymentMethod>(
                          segments: const [
                            ButtonSegment(value: PaymentMethod.cash, label: Text('Refund in cash')),
                            ButtonSegment(value: PaymentMethod.upi, label: Text('Refund by UPI')),
                          ],
                          selected: {_refundMethod},
                          onSelectionChanged: (s) => setState(() => _refundMethod = s.first),
                        ),
                      ],
                    ]);
                  },
                ),
                const SizedBox(height: Gap.lg),
                TextField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Checkout notes (optional)'),
                ),
                const SizedBox(height: Gap.xl),
                AsyncButton(label: 'Confirm checkout', icon: Icons.logout_rounded, danger: true, onPressed: () => _confirm(name)),
              ],
            ),
    );
  }
}
