import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/billing_math.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../tenants/tenants_providers.dart';

/// Creates one invoice by hand, e.g. for a month that was missed or a
/// tenant who joined after the monthly invoices were generated.
class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({super.key, this.tenantId});
  final int? tenantId;

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rent = TextEditingController();
  final _extra = TextEditingController();
  final _discount = TextEditingController();
  final _notes = TextEditingController();
  late int? _tenantId = widget.tenantId;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _due;
  bool _prorate = false;

  @override
  void initState() {
    super.initState();
    if (widget.tenantId != null) {
      ref.read(databaseProvider).tenantsDao.tenantDetail(widget.tenantId!).then((d) {
        if (d != null && mounted && _rent.text.isEmpty) {
          setState(() => _rent.text = Money.toInput(d.tenant.monthlyRentPaise));
        }
      });
    }
  }

  @override
  void dispose() {
    for (final c in [_rent, _extra, _discount, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tenants = ref.watch(currentTenantsProvider).value ?? const [];
    final tenant = tenants.where((x) => x.tenant.id == _tenantId).firstOrNull?.tenant;
    final joinedThisMonth =
        tenant != null && tenant.joiningDate.year == _month.year && tenant.joiningDate.month == _month.month;
    final due =
        _due ??
        (tenant == null ? null : BillingMath.dueDate(_month.year, _month.month, tenant.rentDueDay, tenant.joiningDate));
    final rentPaise = Money.parseRupees(_rent.text) ?? 0;
    final total = rentPaise + (Money.parseRupees(_extra.text) ?? 0) - (Money.parseRupees(_discount.text) ?? 0);

    void fillRent(Tenant? t) {
      if (t == null) return;
      final joined = t.joiningDate.year == _month.year && t.joiningDate.month == _month.month;
      final r = _prorate && joined
          ? BillingMath.joiningMonthRent(t.monthlyRentPaise, t.joiningDate)
          : t.monthlyRentPaise;
      _rent.text = Money.toInput(r);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('New invoice')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
          children: [
            FormSection(
              title: 'Tenant and month',
              children: [
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: tenants.any((x) => x.tenant.id == _tenantId) ? _tenantId : null,
                  decoration: const InputDecoration(labelText: 'Tenant'),
                  items: [
                    for (final x in tenants)
                      DropdownMenuItem(
                        value: x.tenant.id,
                        child: Text('${x.tenant.fullName}${x.roomLabel == null ? '' : ' · ${x.roomLabel}'}'),
                      ),
                  ],
                  onChanged: (v) => setState(() {
                    _tenantId = v;
                    _due = null;
                    fillRent(tenants.where((x) => x.tenant.id == v).firstOrNull?.tenant);
                  }),
                  validator: (v) => v == null ? 'Choose a tenant' : null,
                ),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Billing month',
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous month',
                        onPressed: () => setState(() {
                          _month = DateTime(_month.year, _month.month - 1);
                          _due = null;
                        }),
                        icon: const Icon(Icons.chevron_left_rounded),
                      ),
                      Expanded(
                        child: Text(Dates.monthYear(_month), textAlign: TextAlign.center, style: t.titleMedium),
                      ),
                      IconButton(
                        tooltip: 'Next month',
                        onPressed: () => setState(() {
                          _month = DateTime(_month.year, _month.month + 1);
                          _due = null;
                        }),
                        icon: const Icon(Icons.chevron_right_rounded),
                      ),
                    ],
                  ),
                ),
                if (joinedThisMonth)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _prorate,
                    title: const Text('Prorate from joining date'),
                    subtitle: Text('Joined ${Dates.short(tenant.joiningDate)}'),
                    onChanged: (v) => setState(() {
                      _prorate = v;
                      fillRent(tenant);
                    }),
                  ),
              ],
            ),
            FormSection(
              title: 'Amounts',
              children: [
                MoneyField(
                  controller: _rent,
                  label: 'Rent',
                  onChanged: (_) => setState(() {}),
                  helper: tenant == null ? null : 'Current rent ${Money.format(tenant.monthlyRentPaise)}/month',
                ),
                MoneyField(
                  controller: _extra,
                  label: 'Additional charges',
                  allowZero: true,
                  required: false,
                  onChanged: (_) => setState(() {}),
                  helper: 'Electricity, food, laundry…',
                ),
                MoneyField(
                  controller: _discount,
                  label: 'Discount',
                  allowZero: true,
                  required: false,
                  onChanged: (_) => setState(() {}),
                ),
                if (due != null) DateField(label: 'Due date', value: due, onChanged: (d) => setState(() => _due = d)),
                TextField(
                  controller: _notes,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
              ],
            ),
            AppCard(
              child: Row(
                children: [
                  Expanded(child: Text('Invoice total', style: t.titleSmall)),
                  Text(
                    Money.format(total < 0 ? 0 : total),
                    style: t.titleLarge?.copyWith(
                      fontFeatures: AppTheme.tabular,
                      color: total < 0 ? AppColors.danger : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.xl),
            AsyncButton(
              label: 'Create invoice',
              icon: Icons.receipt_long_rounded,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                int? id;
                final ok = await runGuarded(context, () async {
                  id = await ref
                      .read(databaseProvider)
                      .billingDao
                      .createInvoice(
                        tenantId: _tenantId!,
                        year: _month.year,
                        month: _month.month,
                        rentPaise: MoneyField.read(_rent),
                        additionalChargesPaise: MoneyField.read(_extra),
                        discountPaise: MoneyField.read(_discount),
                        dueDate: due,
                        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
                        prorated: _prorate && joinedThisMonth,
                      );
                  await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
                }, success: 'Invoice created');
                if (ok && context.mounted) context.pushReplacement('/invoices/$id');
              },
            ),
          ],
        ),
      ),
    );
  }
}
