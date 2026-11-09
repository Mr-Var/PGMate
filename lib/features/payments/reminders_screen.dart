import 'package:drift/drift.dart' show StringExpressionOperators;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/daos/tenants_dao.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import '../tenants/tenants_providers.dart';

const defaultReminderTemplate =
    'Hi {name}, a friendly reminder from {pg}: your rent of {amount} is due. '
    '{upi}Please ignore this if you have already paid. Thank you!';

final _templateProvider = StreamProvider<String>(
  (ref) => ref
      .watch(databaseProvider)
      .settingsDao
      .watchSetting('reminder_template')
      .map((v) => (v == null || v.trim().isEmpty) ? defaultReminderTemplate : v),
);

/// Last reminder date per tenant id, stored as `reminded_{id}`.
final _remindedProvider = StreamProvider<Map<int, DateTime>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.appSettings)..where((s) => s.key.like('reminded_%'))).watch().map((rows) {
    final out = <int, DateTime>{};
    for (final r in rows) {
      final id = int.tryParse(r.key.substring('reminded_'.length));
      final d = DateTime.tryParse(r.value);
      if (id != null && d != null) out[id] = d;
    }
    return out;
  });
});

String fillReminder(
  String template, {
  required String name,
  required int amountPaise,
  required String pg,
  String? upi,
}) {
  return template
      .replaceAll('{name}', name.split(' ').first)
      .replaceAll('{amount}', Money.format(amountPaise))
      .replaceAll('{pg}', pg)
      .replaceAll('{upi}', upi == null ? '' : 'Pay by UPI to $upi. ')
      .replaceAll(RegExp(r' {2,}'), ' ')
      .trim();
}

/// Sends WhatsApp rent reminders to many tenants: pick once, then one tap
/// per tenant opens their chat with the message ready to send.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  Set<int>? _selected; // initialised to everyone with dues
  bool _showAll = false;
  List<TenantListItem>? _queue; // set while sending
  int _next = 0;

  Future<void> _sendNext(String template) async {
    final q = _queue!;
    final it = q[_next];
    final pg = ref.read(pgProfileProvider).value;
    final msg = fillReminder(
      template,
      name: it.tenant.fullName,
      amountPaise: it.duesPaise,
      pg: pg?.name ?? 'your PG',
      upi: pg?.upiId,
    );
    await ref.read(exportServiceProvider).whatsapp(msg, phone: it.tenant.phone);
    await ref
        .read(databaseProvider)
        .settingsDao
        .setSetting('reminded_${it.tenant.id}', Dates.today().toIso8601String());
    if (!mounted) return;
    setState(() {
      _next++;
      if (_next >= q.length) {
        showAppSnack(context, 'Reminders opened for ${q.length} ${q.length == 1 ? 'tenant' : 'tenants'}');
        _queue = null;
        _next = 0;
      }
    });
  }

  Future<void> _editTemplate(String current) async {
    final c = TextEditingController(text: current);
    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Reminder message', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: Gap.xs),
              Text(
                '{name} first name · {amount} amount due · {pg} PG name · {upi} your UPI ID',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: Gap.lg),
              TextField(controller: c, minLines: 4, maxLines: 8, textCapitalization: TextCapitalization.sentences),
              const SizedBox(height: Gap.md),
              TextButton(onPressed: () => c.text = defaultReminderTemplate, child: const Text('Reset to default')),
              const SizedBox(height: Gap.sm),
              FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Save message')),
            ],
          ),
        ),
      ),
    );
    if (saved != null && saved.isNotEmpty) {
      await ref.read(databaseProvider).settingsDao.setSetting('reminder_template', saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(currentTenantsProvider);
    final template = ref.watch(_templateProvider).value ?? defaultReminderTemplate;
    final reminded = ref.watch(_remindedProvider).value ?? const <int, DateTime>{};
    final pg = ref.watch(pgProfileProvider).value;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Rent reminders')),
      body: list.when(
        loading: () => const LoadingList(),
        error: (e, _) => ErrorState(error: e),
        data: (all) {
          final withDues = all.where((i) => i.duesPaise > 0).toList()
            ..sort((a, b) => b.duesPaise.compareTo(a.duesPaise));
          _selected ??= {for (final i in withDues) i.tenant.id};
          final shown = _showAll ? all : withDues;
          if (all.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No tenants yet',
              message: 'Reminders are sent to current tenants who have rent due.',
            );
          }
          final selected = shown.where((i) => _selected!.contains(i.tenant.id)).toList();
          final sample = selected.isNotEmpty ? selected.first : (shown.isNotEmpty ? shown.first : all.first);
          final preview = fillReminder(
            template,
            name: sample.tenant.fullName,
            amountPaise: sample.duesPaise,
            pg: pg?.name ?? 'your PG',
            upi: pg?.upiId,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xl),
                  children: [
                    AppCard(
                      onTap: _queue == null ? () => _editTemplate(template) : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Eyebrow('Message preview')),
                              if (_queue == null) Text('Edit', style: t.labelLarge?.copyWith(color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: Gap.sm),
                          Text(preview, style: t.bodyMedium),
                        ],
                      ),
                    ),
                    SectionHeader(
                      title: _showAll ? 'All tenants' : 'Rent due',
                      count: shown.length,
                      trailing: TextButton(
                        onPressed: _queue == null ? () => setState(() => _showAll = !_showAll) : null,
                        child: Text(_showAll ? 'Only with dues' : 'Show all'),
                      ),
                    ),
                    if (shown.isEmpty)
                      Text('Everyone is paid up.', style: t.bodyMedium?.copyWith(color: AppColors.textMuted))
                    else
                      Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            CheckboxListTile(
                              value: selected.length == shown.length ? true : (selected.isEmpty ? false : null),
                              tristate: true,
                              onChanged: _queue != null
                                  ? null
                                  : (_) => setState(() {
                                      if (selected.length == shown.length) {
                                        _selected!.removeAll(shown.map((i) => i.tenant.id));
                                      } else {
                                        _selected!.addAll(shown.map((i) => i.tenant.id));
                                      }
                                    }),
                              title: Text('Select all', style: t.labelLarge),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            for (final it in shown) ...[
                              const Divider(indent: 56),
                              _TenantRow(
                                item: it,
                                selected: _selected!.contains(it.tenant.id),
                                remindedOn: reminded[it.tenant.id],
                                isNext:
                                    _queue != null &&
                                    _next < _queue!.length &&
                                    _queue![_next].tenant.id == it.tenant.id,
                                done: _queue != null && _queue!.take(_next).any((q) => q.tenant.id == it.tenant.id),
                                onChanged: _queue != null
                                    ? null
                                    : (v) => setState(
                                        () => v ? _selected!.add(it.tenant.id) : _selected!.remove(it.tenant.id),
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: Gap.md),
                    Text(
                      'WhatsApp opens each tenant\'s chat with the message ready. Tap Send in WhatsApp, then come back for the next one.',
                      style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.lg, Gap.md),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: _queue == null
                      ? FilledButton.icon(
                          onPressed: selected.isEmpty
                              ? null
                              : () => setState(() {
                                  _queue = selected;
                                  _next = 0;
                                }),
                          icon: const Icon(Icons.send_rounded),
                          label: Text(
                            selected.isEmpty
                                ? 'Select tenants to remind'
                                : 'Remind ${selected.length} ${selected.length == 1 ? 'tenant' : 'tenants'}',
                          ),
                        )
                      : Row(
                          children: [
                            TextButton(
                              onPressed: () => setState(() {
                                _queue = null;
                                _next = 0;
                              }),
                              child: const Text('Stop'),
                            ),
                            const SizedBox(width: Gap.sm),
                            Expanded(
                              child: AsyncButton(
                                icon: Icons.chat_outlined,
                                label:
                                    'Send to ${_queue![_next].tenant.fullName.split(' ').first} (${_next + 1} of ${_queue!.length})',
                                onPressed: () => _sendNext(template),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TenantRow extends StatelessWidget {
  const _TenantRow({
    required this.item,
    required this.selected,
    required this.remindedOn,
    required this.isNext,
    required this.done,
    required this.onChanged,
  });

  final TenantListItem item;
  final bool selected;
  final DateTime? remindedOn;
  final bool isNext;
  final bool done;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tenant = item.tenant;
    return Container(
      color: isNext ? AppColors.accentSoft : null,
      child: CheckboxListTile(
        key: ValueKey(tenant.id),
        value: selected,
        onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: Gap.sm),
        activeColor: AppColors.primary,
        side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
        checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: Row(
          children: [
            Expanded(child: Text(tenant.fullName, maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (done) const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success),
          ],
        ),
        subtitle: Text(
          [
            item.roomLabel ?? 'No bed',
            if (remindedOn != null) 'reminded ${Dates.relativeDays(remindedOn!).toLowerCase()}',
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        secondary: Text(
          item.duesPaise > 0 ? Money.format(item.duesPaise) : 'Paid',
          style: AppTheme.figure(
            14,
            color: item.overdue ? AppColors.danger : (item.duesPaise > 0 ? AppColors.textPrimary : AppColors.success),
          ),
        ),
      ),
    );
  }
}
