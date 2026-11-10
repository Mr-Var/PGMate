import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/ops_dao.dart';
import '../../core/database/daos/rooms_dao.dart';
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
import '../../shared/widgets/validators.dart';
import '../payments/payment_widgets.dart';
import '../rooms/rooms_providers.dart';
import '../tenants/tenants_providers.dart';
import 'complaint_widgets.dart';

class _StatusFilter extends Notifier<ComplaintStatus?> {
  @override
  ComplaintStatus? build() => null;
  void set(ComplaintStatus? s) => state = s;
}

final _statusFilterProvider = NotifierProvider<_StatusFilter, ComplaintStatus?>(_StatusFilter.new);

final _complaintsProvider = StreamProvider<List<ComplaintView>>((ref) {
  return ref.watch(databaseProvider).opsDao.watchComplaints(status: ref.watch(_statusFilterProvider));
});

final _allComplaintsProvider = StreamProvider<List<ComplaintView>>(
  (ref) => ref.watch(databaseProvider).opsDao.watchComplaints(),
);

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_statusFilterProvider);
    final list = ref.watch(_complaintsProvider);
    final all = ref.watch(_allComplaintsProvider).value ?? const [];
    int count(ComplaintStatus s) => all.where((c) => c.complaint.status == s).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.push('/more/complaints/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New complaint'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Gap.lg),
              children: [
                ChoiceChip(
                  label: Text('All ${all.length}'),
                  selected: filter == null,
                  showCheckmark: false,
                  onSelected: (_) => ref.read(_statusFilterProvider.notifier).set(null),
                ),
                for (final s in ComplaintStatus.values) ...[
                  const SizedBox(width: Gap.sm),
                  ChoiceChip(
                    label: Text('${s.label} ${count(s)}'),
                    selected: filter == s,
                    showCheckmark: false,
                    onSelected: (_) => ref.read(_statusFilterProvider.notifier).set(s),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: list.when(
              skipLoadingOnReload: true,
              loading: () => const LoadingList(),
              error: (e, _) => ErrorState(error: e),
              data: (l) => l.isEmpty
                  ? EmptyState(
                      icon: Icons.handyman_outlined,
                      title: filter == null ? 'No complaints' : 'Nothing ${filter.label.toLowerCase()}',
                      message: 'Log maintenance issues from tenants to track them until they are fixed.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, 96),
                      children: [
                        TileGroup(indent: 68, children: [for (final c in l) ComplaintTile(view: c)]),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ComplaintFormScreen extends ConsumerStatefulWidget {
  const ComplaintFormScreen({super.key, this.tenantId, this.complaintId});
  final int? tenantId;

  /// When set, the form edits this complaint instead of creating one.
  final int? complaintId;

  @override
  ConsumerState<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends ConsumerState<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _desc = TextEditingController();
  late int? _tenantId = widget.tenantId;
  int? _roomId;
  String? _category;
  ComplaintPriority _priority = ComplaintPriority.medium;
  final List<(Uint8List, String)> _images = [];
  List<String> _existingImages = const [];
  bool get _isEdit => widget.complaintId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      ref.read(databaseProvider).opsDao.watchComplaints().first.then((all) {
        final v = all.where((c) => c.complaint.id == widget.complaintId).firstOrNull;
        if (v == null || !mounted) return;
        setState(() {
          _desc.text = v.complaint.description;
          _tenantId = v.complaint.tenantId;
          _roomId = v.complaint.roomId;
          _category = v.complaint.category;
          _priority = v.complaint.priority;
          _existingImages = v.images;
        });
      });
    }
  }

  @override
  void dispose() {
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final files = ref.read(fileStoreProvider);
    final paths = <String>[
      for (final img in _images) await files.save(img.$1, folder: 'complaints', extension: img.$2),
    ];
    if (!mounted) return;
    final ops = ref.read(databaseProvider).opsDao;
    final ok = await runGuarded(
      context,
      () => _isEdit
          ? ops.updateComplaintDetails(
              widget.complaintId!,
              tenantId: _tenantId,
              roomId: _roomId,
              category: _category!,
              description: _desc.text,
              priority: _priority,
              newImages: paths,
            )
          : ops.addComplaint(
              tenantId: _tenantId,
              roomId: _roomId,
              category: _category!,
              description: _desc.text,
              priority: _priority,
              images: paths,
            ),
      success: _isEdit ? 'Complaint updated' : 'Complaint logged',
    );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final tenants = ref.watch(currentTenantsProvider).value ?? const <TenantListItem>[];
    final rooms = ref.watch(roomsProvider).value ?? const <RoomWithBeds>[];
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit complaint' : 'New complaint')),
      body: Form(
        key: _formKey,
        child: FormScroll(
          padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
          children: [
            FormSection(
              title: 'What is wrong?',
              children: [
                Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final c in complaintCategories)
                      ChoiceChip(
                        avatar: Icon(complaintIcon(c), size: 18),
                        label: Text(c),
                        selected: _category == c,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _category = c),
                      ),
                  ],
                ),
                FormField<String>(
                  validator: (_) => _category == null ? 'Choose a category' : null,
                  builder: (s) => s.hasError
                      ? Text(s.errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12))
                      : const SizedBox.shrink(),
                ),
                TextFormField(
                  controller: _desc,
                  minLines: 3,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g. Bathroom tap leaking since morning',
                  ),
                  validator: (v) => Validators.required(v, 'Description', min: 5, max: 2000),
                ),
                SegmentedButton<ComplaintPriority>(
                  segments: [for (final p in ComplaintPriority.values) ButtonSegment(value: p, label: Text(p.label))],
                  selected: {_priority},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _priority = s.first),
                ),
              ],
            ),
            FormSection(
              title: 'Who and where',
              children: [
                DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: tenants.any((x) => x.tenant.id == _tenantId) ? _tenantId : null,
                  decoration: const InputDecoration(labelText: 'Tenant (optional)'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Not tenant-specific')),
                    for (final t in tenants)
                      DropdownMenuItem<int?>(
                        value: t.tenant.id,
                        child: Text('${t.tenant.fullName}${t.roomLabel == null ? '' : ' · ${t.roomLabel}'}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _tenantId = v),
                ),
                DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: _roomId,
                  decoration: const InputDecoration(labelText: 'Room (optional)'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Common area / not specific')),
                    for (final r in rooms)
                      DropdownMenuItem<int?>(
                        value: r.room.id,
                        child: Text('Room ${r.room.roomNumber} · ${Dates.floorLabel(r.room.floor)}'),
                      ),
                  ],
                  onChanged: (v) => setState(() => _roomId = v),
                ),
              ],
            ),
            FormSection(
              title: 'Photos',
              subtitle: 'Optional. Stored privately on this phone.',
              children: [
                Wrap(
                  spacing: Gap.sm,
                  runSpacing: Gap.sm,
                  children: [
                    for (final path in _existingImages)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(Radii.md),
                        child: StoredImage(path: path, width: 88, height: 88),
                      ),
                    for (final (i, img) in _images.indexed)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Radii.md),
                            child: Image.memory(img.$1, width: 88, height: 88, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: IconButton.filled(
                              tooltip: 'Remove photo',
                              iconSize: 16,
                              style: IconButton.styleFrom(
                                minimumSize: const Size(28, 28),
                                backgroundColor: Colors.black54,
                              ),
                              onPressed: () => setState(() => _images.removeAt(i)),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ),
                        ],
                      ),
                    if (_existingImages.length + _images.length < 6)
                      InkWell(
                        borderRadius: BorderRadius.circular(Radii.md),
                        onTap: () async {
                          final img = await pickImage(context, title: 'Complaint photo');
                          if (img != null) setState(() => _images.add(img));
                        },
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Radii.md),
                            border: Border.all(color: AppColors.border),
                            color: AppColors.surface,
                          ),
                          child: const Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            AsyncButton(label: _isEdit ? 'Save changes' : 'Log complaint', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class ComplaintDetailScreen extends ConsumerWidget {
  const ComplaintDetailScreen({super.key, required this.complaintId});
  final int complaintId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(_allComplaintsProvider);
    final closed =
        all.value?.where((c) => c.complaint.id == complaintId).firstOrNull?.complaint.status == ComplaintStatus.closed;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint'),
        actions: [
          if (all.hasValue && !closed)
            IconButton(
              tooltip: 'Edit complaint',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/more/complaints/$complaintId/edit'),
            ),
        ],
      ),
      body: all.when(
        loading: () => const LoadingList(),
        error: (e, _) => ErrorState(error: e),
        data: (l) {
          final v = l.where((c) => c.complaint.id == complaintId).firstOrNull;
          if (v == null) {
            return const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Not found',
              message: 'This complaint does not exist.',
            );
          }
          return _ComplaintBody(view: v);
        },
      ),
    );
  }
}

class _ComplaintBody extends ConsumerWidget {
  const _ComplaintBody({required this.view});
  final ComplaintView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = view.complaint;
    final t = Theme.of(context).textTheme;
    final (color, bg) = complaintStatusColors(c.status);
    final next = switch (c.status) {
      ComplaintStatus.open => ComplaintStatus.inProgress,
      ComplaintStatus.inProgress => ComplaintStatus.resolved,
      ComplaintStatus.resolved => ComplaintStatus.closed,
      ComplaintStatus.closed => null,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
      children: [
        Row(
          children: [
            Icon(complaintIcon(c.category), color: priorityColor(c.priority)),
            const SizedBox(width: Gap.sm),
            Expanded(child: Text(c.category, style: t.titleLarge)),
            StatusPill(label: c.status.label, color: color, background: bg),
          ],
        ),
        const SizedBox(height: Gap.md),
        _Progress(status: c.status),
        const SizedBox(height: Gap.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(c.description, style: t.bodyLarge),
              const SizedBox(height: Gap.md),
              Text(
                [
                  '${c.priority.label} priority',
                  if (view.tenantName != null) view.tenantName!,
                  if (view.roomNumber != null) 'Room ${view.roomNumber}',
                  'Logged ${Dates.short(c.createdAt)}',
                  if (c.resolvedAt != null) 'Resolved ${Dates.short(c.resolvedAt!)}',
                ].join(' · '),
                style: t.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        if (view.images.isNotEmpty) ...[
          const SectionHeader(title: 'Photos'),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: view.images.length,
              separatorBuilder: (_, _) => const SizedBox(width: Gap.sm),
              itemBuilder: (_, i) => InkWell(
                onTap: () => context.push(
                  Uri(
                    path: '/document',
                    queryParameters: {'path': view.images[i], 'title': 'Photo ${i + 1}'},
                  ).toString(),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.md),
                  child: StoredImage(path: view.images[i], width: 104, height: 104),
                ),
              ),
            ),
          ),
        ],
        if (c.resolutionNotes != null || view.expense != null) ...[
          const SectionHeader(title: 'Resolution'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.resolutionNotes != null) Text(c.resolutionNotes!, style: t.bodyMedium),
                if (view.expense != null) ...[
                  if (c.resolutionNotes != null) const SizedBox(height: Gap.sm),
                  Text(
                    'Repair cost ${Money.format(view.expense!.amountPaise)} · recorded as an expense',
                    style: t.bodySmall?.copyWith(color: AppColors.textSecondary, fontFeatures: AppTheme.tabular),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: Gap.xl),
        if (next != null)
          AsyncButton(
            label: switch (next) {
              ComplaintStatus.inProgress => 'Start work',
              ComplaintStatus.resolved => 'Mark resolved',
              _ => 'Close complaint',
            },
            icon: Icons.arrow_forward_rounded,
            onPressed: () => next == ComplaintStatus.resolved
                ? _resolve(context, ref)
                : runGuarded(
                    context,
                    () => ref.read(databaseProvider).opsDao.updateComplaintStatus(c.id, next),
                    success: 'Marked ${next.label.toLowerCase()}',
                  ),
          ),
      ],
    );
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref) async {
    final notes = TextEditingController();
    final cost = TextEditingController();
    final key = GlobalKey<FormState>();
    var method = PaymentMethod.cash;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl + MediaQuery.viewInsetsOf(ctx).bottom),
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Mark resolved', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: Gap.lg),
                  TextFormField(
                    controller: notes,
                    minLines: 2,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'What was done?'),
                    validator: (v) => Validators.required(v, 'Resolution', min: 3),
                  ),
                  const SizedBox(height: Gap.lg),
                  MoneyField(
                    controller: cost,
                    label: 'Repair cost (optional)',
                    allowZero: true,
                    required: false,
                    helper: 'Saved as a Repairs expense linked to this complaint.',
                  ),
                  const SizedBox(height: Gap.md),
                  SegmentedButton<PaymentMethod>(
                    segments: const [
                      ButtonSegment(value: PaymentMethod.cash, label: Text('Cash')),
                      ButtonSegment(value: PaymentMethod.upi, label: Text('UPI')),
                      ButtonSegment(value: PaymentMethod.bank, label: Text('Bank')),
                    ],
                    selected: {method},
                    onSelectionChanged: (s) => setState(() => method = s.first),
                  ),
                  const SizedBox(height: Gap.xl),
                  AsyncButton(
                    label: 'Save',
                    onPressed: () async {
                      if (!key.currentState!.validate()) return;
                      final ok = await runGuarded(
                        ctx,
                        () => ref
                            .read(databaseProvider)
                            .opsDao
                            .updateComplaintStatus(
                              view.complaint.id,
                              ComplaintStatus.resolved,
                              resolutionNotes: notes.text,
                              repairCostPaise: MoneyField.read(cost),
                              repairMethod: method,
                            ),
                        success: 'Complaint resolved',
                      );
                      if (ok && ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.status});
  final ComplaintStatus status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status ${status.label}, step ${status.index + 1} of 4',
      child: Row(
        children: [
          for (final s in ComplaintStatus.values) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: s.index <= status.index ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: s.index <= status.index ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (s != ComplaintStatus.closed) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}
