import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/validators.dart';

const noticeCategories = ['General', 'Rent', 'Maintenance', 'Water / power cut', 'Rules', 'Event', 'Food'];

final noticesProvider = StreamProvider<List<Notice>>((ref) => ref.watch(databaseProvider).opsDao.watchNotices());

IconData noticeIcon(String c) => switch (c) {
      'Rent' => Icons.currency_rupee_rounded,
      'Maintenance' => Icons.build_outlined,
      'Water / power cut' => Icons.power_off_outlined,
      'Rules' => Icons.gavel_rounded,
      'Event' => Icons.celebration_outlined,
      'Food' => Icons.restaurant_outlined,
      _ => Icons.campaign_outlined,
    };

String noticeMessage(Notice n, String? pgName) =>
    '*${pgName == null ? '' : '$pgName · '}${n.title}*\n${Dates.short(n.publishDate)}\n\n${n.body}';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(noticesProvider);
    final t = Theme.of(context).textTheme;
    final today = Dates.today();
    return Scaffold(
      appBar: AppBar(title: const Text('Notices')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/more/notices/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New notice'),
      ),
      body: list.when(
        loading: () => const LoadingList(),
        error: (e, _) => ErrorState(error: e),
        data: (l) => l.isEmpty
            ? EmptyState(
                icon: Icons.campaign_outlined,
                title: 'No notices yet',
                message: 'Write announcements like rent reminders or water cuts, then share them on WhatsApp.',
                actionLabel: 'New notice',
                onAction: () => context.push('/more/notices/new'),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, 96),
                itemCount: l.length,
                separatorBuilder: (_, _) => const SizedBox(height: Gap.sm),
                itemBuilder: (_, i) {
                  final n = l[i];
                  final scheduled = n.publishDate.isAfter(today);
                  return AppCard(
                    onTap: () => context.push('/more/notices/${n.id}'),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(noticeIcon(n.category), size: 18, color: AppColors.primary),
                        const SizedBox(width: Gap.sm),
                        Expanded(child: Text(n.category, style: t.labelMedium?.copyWith(color: AppColors.textSecondary))),
                        if (scheduled)
                          StatusPill(label: 'From ${Dates.dayMonth(n.publishDate)}', color: AppColors.info, background: AppColors.infoSoft)
                        else
                          Text(Dates.dayMonth(n.publishDate), style: t.labelMedium?.copyWith(color: AppColors.textMuted)),
                      ]),
                      const SizedBox(height: Gap.sm),
                      Text(n.title, style: t.titleSmall),
                      const SizedBox(height: 2),
                      Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                    ]),
                  );
                },
              ),
      ),
    );
  }
}

class NoticeFormScreen extends ConsumerStatefulWidget {
  const NoticeFormScreen({super.key, this.noticeId});
  final int? noticeId;

  @override
  ConsumerState<NoticeFormScreen> createState() => _NoticeFormScreenState();
}

class _NoticeFormScreenState extends ConsumerState<NoticeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  String _category = noticeCategories.first;
  DateTime _date = Dates.today();
  bool _loaded = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<int?> _save() async {
    if (!_formKey.currentState!.validate()) return null;
    return ref.read(databaseProvider).opsDao.saveNotice(
          id: widget.noticeId,
          title: _title.text,
          body: _body.text,
          category: _category,
          publishDate: _date,
        );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.noticeId != null && !_loaded) {
      final n = ref.watch(noticesProvider).value?.where((x) => x.id == widget.noticeId).firstOrNull;
      if (n != null) {
        _title.text = n.title;
        _body.text = n.body;
        _category = n.category;
        _date = n.publishDate;
        _loaded = true;
      }
    }
    final isEdit = widget.noticeId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Notice' : 'New notice'),
        actions: [
          if (isEdit)
            IconButton(
              tooltip: 'Delete notice',
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              onPressed: () async {
                if (!await confirmAction(context, title: 'Delete notice?', message: 'This removes it from the notice history.', destructive: true, confirmLabel: 'Delete')) {
                  return;
                }
                await ref.read(databaseProvider).opsDao.deleteNotice(widget.noticeId!);
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
          children: [
            Wrap(spacing: Gap.sm, runSpacing: Gap.sm, children: [
              for (final c in noticeCategories)
                ChoiceChip(
                  avatar: Icon(noticeIcon(c), size: 18),
                  label: Text(c),
                  selected: _category == c,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _category = c),
                ),
            ]),
            const SizedBox(height: Gap.xl),
            TextFormField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Water supply off on Sunday'),
              validator: (v) => Validators.required(v, 'Title', max: 160),
            ),
            const SizedBox(height: Gap.lg),
            TextFormField(
              controller: _body,
              minLines: 5,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Message', alignLabelWithHint: true),
              validator: (v) => Validators.required(v, 'Message', max: 4000),
            ),
            const SizedBox(height: Gap.lg),
            DateField(label: 'Publish date', value: _date, onChanged: (d) => setState(() => _date = d)),
            const SizedBox(height: Gap.xl),
            AsyncButton(
              label: 'Save and share on WhatsApp',
              icon: Icons.chat_outlined,
              onPressed: () async {
                final id = await _save();
                if (id == null) return;
                final pg = ref.read(pgProfileProvider).value;
                final n = Notice(id: id, title: _title.text.trim(), body: _body.text.trim(), category: _category, publishDate: _date, createdAt: DateTime.now());
                await ref.read(exportServiceProvider).whatsapp(noticeMessage(n, pg?.name));
                if (context.mounted) context.pop();
              },
            ),
            const SizedBox(height: Gap.md),
            AsyncButton(
              label: 'Save',
              outlined: true,
              onPressed: () async {
                final id = await _save();
                if (id != null && context.mounted) {
                  showAppSnack(context, 'Notice saved');
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
