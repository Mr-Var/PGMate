import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';

class _Week extends Notifier<DateTime> {
  @override
  DateTime build() {
    final t = Dates.today();
    return t.subtract(Duration(days: t.weekday - 1)); // Monday
  }

  void shift(int weeks) => state = state.add(Duration(days: 7 * weeks));
}

final _weekProvider = NotifierProvider<_Week, DateTime>(_Week.new);

final _menusProvider = StreamProvider<List<Menu>>((ref) {
  final start = ref.watch(_weekProvider);
  return ref.watch(databaseProvider).opsDao.watchMenus(start, start.add(const Duration(days: 7)));
});

class FoodMenuScreen extends ConsumerWidget {
  const FoodMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final start = ref.watch(_weekProvider);
    final menus = ref.watch(_menusProvider);
    final t = Theme.of(context).textTheme;
    final today = Dates.today();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food menu'),
        actions: [
          IconButton(
            tooltip: 'Share this week',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _share(context, ref, start, menus.value ?? const []),
          ),
          PopupMenuButton<String>(
            onSelected: (_) async {
              final n = await ref.read(databaseProvider).opsDao.copyPreviousWeek(start);
              if (context.mounted) {
                showAppSnack(context, n == 0 ? 'Last week has no menu to copy' : 'Copied $n days from last week');
              }
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'copy', child: Text('Copy last week'))],
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous week',
                onPressed: () => ref.read(_weekProvider.notifier).shift(-1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Text(
                  '${Dates.dayMonth(start)} – ${Dates.dayMonth(start.add(const Duration(days: 6)))}',
                  textAlign: TextAlign.center,
                  style: t.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Next week',
                onPressed: () => ref.read(_weekProvider.notifier).shift(1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          Expanded(
            child: menus.when(
              skipLoadingOnReload: true,
              loading: () => const LoadingList(count: 7, itemHeight: 96),
              error: (e, _) => ErrorState(error: e),
              data: (list) {
                final byDay = {for (final m in list) Dates.today(m.menuDate): m};
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
                  itemCount: 7,
                  separatorBuilder: (_, _) => const SizedBox(height: Gap.sm),
                  itemBuilder: (_, i) {
                    final day = start.add(Duration(days: i));
                    final m = byDay[day];
                    final isToday = day == today;
                    return AppCard(
                      onTap: () => _edit(context, ref, day, m),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 52,
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('EEE').format(day),
                                  style: t.labelMedium?.copyWith(
                                    color: isToday ? AppColors.primary : AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  '${day.day}',
                                  style: t.titleLarge?.copyWith(
                                    color: isToday ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: Gap.md),
                          Expanded(
                            child: m == null || (m.breakfast.isEmpty && m.lunch.isEmpty && m.dinner.isEmpty)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: Gap.sm),
                                    child: Text(
                                      'Tap to set the menu',
                                      style: t.bodyMedium?.copyWith(color: AppColors.textMuted),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _Meal(
                                        icon: Icons.free_breakfast_outlined,
                                        label: 'Breakfast',
                                        value: m.breakfast,
                                      ),
                                      _Meal(icon: Icons.lunch_dining_outlined, label: 'Lunch', value: m.lunch),
                                      _Meal(icon: Icons.dinner_dining_outlined, label: 'Dinner', value: m.dinner),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, DateTime day, Menu? m) async {
    final b = TextEditingController(text: m?.breakfast);
    final l = TextEditingController(text: m?.lunch);
    final d = TextEditingController(text: m?.dinner);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl + MediaQuery.viewInsetsOf(ctx).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(DateFormat('EEEE, d MMMM').format(day), style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: Gap.lg),
              TextField(
                controller: b,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Breakfast',
                  prefixIcon: Icon(Icons.free_breakfast_outlined),
                ),
              ),
              const SizedBox(height: Gap.md),
              TextField(
                controller: l,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Lunch', prefixIcon: Icon(Icons.lunch_dining_outlined)),
              ),
              const SizedBox(height: Gap.md),
              TextField(
                controller: d,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Dinner', prefixIcon: Icon(Icons.dinner_dining_outlined)),
              ),
              const SizedBox(height: Gap.xl),
              AsyncButton(
                label: 'Save menu',
                onPressed: () async {
                  await ref
                      .read(databaseProvider)
                      .opsDao
                      .saveMenu(day, breakfast: b.text, lunch: l.text, dinner: d.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref, DateTime start, List<Menu> menus) async {
    if (menus.isEmpty) {
      showAppSnack(context, 'Set the menu for this week first', error: true);
      return;
    }
    final pg = ref.read(pgProfileProvider).value;
    final b = StringBuffer(
      '*${pg?.name ?? 'PG'} · Menu ${Dates.dayMonth(start)} – ${Dates.dayMonth(start.add(const Duration(days: 6)))}*\n',
    );
    for (final m in menus) {
      b.writeln('\n*${DateFormat('EEE d MMM').format(m.menuDate)}*');
      if (m.breakfast.isNotEmpty) b.writeln('Breakfast: ${m.breakfast}');
      if (m.lunch.isNotEmpty) b.writeln('Lunch: ${m.lunch}');
      if (m.dinner.isNotEmpty) b.writeln('Dinner: ${m.dinner}');
    }
    await ref.read(exportServiceProvider).shareText(b.toString());
  }
}

class _Meal extends StatelessWidget {
  const _Meal({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
