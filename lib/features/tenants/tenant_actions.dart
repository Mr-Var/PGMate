import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/daos/tenants_dao.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import 'tenants_providers.dart';

Future<void> showAssignBedSheet(BuildContext context, WidgetRef ref, TenantDetail d) =>
    _bedSheet(context, ref, d, transfer: false);

Future<void> showTransferSheet(BuildContext context, WidgetRef ref, TenantDetail d) =>
    _bedSheet(context, ref, d, transfer: true);

Future<void> _bedSheet(BuildContext context, WidgetRef ref, TenantDetail d, {required bool transfer}) {
  ref.invalidate(freeBedsProvider);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _BedSheet(detail: d, transfer: transfer),
  );
}

class _BedSheet extends ConsumerStatefulWidget {
  const _BedSheet({required this.detail, required this.transfer});
  final TenantDetail detail;
  final bool transfer;

  @override
  ConsumerState<_BedSheet> createState() => _BedSheetState();
}

class _BedSheetState extends ConsumerState<_BedSheet> {
  FreeBed? _bed;
  DateTime _date = Dates.today();
  late final _rent = TextEditingController(text: Money.toInput(widget.detail.tenant.monthlyRentPaise));
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _rent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final beds = ref.watch(freeBedsProvider);
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.transfer ? 'Transfer to another bed' : 'Assign a bed', style: t.titleLarge),
              const SizedBox(height: Gap.xs),
              Text(
                widget.transfer
                    ? 'Currently in ${widget.detail.current?.label}. The old bed is freed and kept in history.'
                    : 'Choose a free bed for ${widget.detail.tenant.fullName}.',
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: Gap.lg),
              beds.when(
                loading: () => const SkeletonBox(height: 56, radius: Radii.md),
                error: (e, _) => Text('$e'),
                data: (list) => list.isEmpty
                    ? const Text(
                        'No free beds right now. Free or add a bed in Rooms first.',
                        style: TextStyle(color: AppColors.warning),
                      )
                    : DropdownButtonFormField<FreeBed>(
                        isExpanded: true,
                        initialValue: _bed,
                        decoration: const InputDecoration(labelText: 'Bed'),
                        items: [
                          for (final b in list)
                            DropdownMenuItem(
                              value: b,
                              child: Text(
                                '${b.label} · ${Dates.floorLabel(b.room.floor)} · ${Money.format(b.room.rentPaise)}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (b) => setState(() {
                          _bed = b;
                          if (widget.transfer && b != null) _rent.text = Money.toInput(b.room.rentPaise);
                        }),
                        validator: (v) => v == null ? 'Choose a bed' : null,
                      ),
              ),
              const SizedBox(height: Gap.lg),
              DateField(
                label: widget.transfer ? 'Move date' : 'Start date',
                value: _date,
                onChanged: (d) => setState(() => _date = d),
              ),
              if (widget.transfer) ...[
                const SizedBox(height: Gap.lg),
                MoneyField(
                  controller: _rent,
                  label: 'Monthly rent after transfer',
                  helper: 'Applies from the next invoice.',
                ),
              ],
              const SizedBox(height: Gap.xl),
              AsyncButton(
                label: widget.transfer ? 'Transfer' : 'Assign bed',
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final dao = ref.read(databaseProvider).tenantsDao;
                  final ok = await runGuarded(
                    context,
                    () => widget.transfer
                        ? dao.transfer(
                            widget.detail.tenant.id,
                            _bed!.bed.id,
                            _date,
                            newRentPaise: MoneyField.read(_rent),
                          )
                        : dao.assignBed(widget.detail.tenant.id, _bed!.bed.id, _date),
                    success: widget.transfer ? 'Moved to ${_bed!.label}' : 'Assigned ${_bed!.label}',
                  );
                  if (ok && context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showNoticeSheet(BuildContext context, WidgetRef ref, TenantDetail d) {
  var notice = Dates.today();
  var leave = Dates.today().add(const Duration(days: 30));
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Record notice', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: Gap.xs),
              Text(
                '${d.tenant.fullName} plans to leave. You can withdraw the notice later.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: Gap.lg),
              DateField(
                label: 'Notice given on',
                value: notice,
                onChanged: (v) => setState(() {
                  notice = v;
                  // Keep the checkout on or after the notice date.
                  if (leave.isBefore(v)) leave = v.add(const Duration(days: 30));
                }),
              ),
              const SizedBox(height: Gap.lg),
              DateField(
                label: 'Expected checkout',
                value: leave,
                first: notice,
                helper: '${leave.difference(notice).inDays} days notice',
                onChanged: (v) => setState(() => leave = v),
              ),
              const SizedBox(height: Gap.xl),
              AsyncButton(
                label: 'Save notice',
                onPressed: () async {
                  final ok = await runGuarded(
                    ctx,
                    () => ref.read(databaseProvider).tenantsDao.giveNotice(d.tenant.id, notice, leave),
                    success: 'Notice recorded',
                  );
                  if (ok && ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Highlights a positive (refund) or negative (to collect) settlement.
class SettlementBanner extends StatelessWidget {
  const SettlementBanner({super.key, required this.amountPaise});
  final int amountPaise;

  @override
  Widget build(BuildContext context) {
    final refund = amountPaise >= 0;
    final color = refund ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.all(Gap.lg),
      decoration: BoxDecoration(
        color: refund ? AppColors.successSoft : AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Row(
        children: [
          Icon(refund ? Icons.south_west_rounded : Icons.north_east_rounded, color: color),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Text(
              refund ? 'Refund to tenant' : 'Collect from tenant',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
            ),
          ),
          Text(
            Money.format(amountPaise.abs()),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color, fontFeatures: AppTheme.tabular),
          ),
        ],
      ),
    );
  }
}
