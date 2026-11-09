import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/rooms_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/state_views.dart';
import 'bed_status_style.dart';
import 'rooms_providers.dart';

class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  BedStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms & beds')),
      floatingActionButton: rooms.value?.isEmpty ?? true
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => context.push('/rooms/new'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add room'),
            ),
      body: rooms.when(
        loading: () => const LoadingList(itemHeight: 120),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(roomsProvider)),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.meeting_room_outlined,
              title: 'No rooms yet',
              message: 'Add rooms floor by floor. You can set the number of beds and rent for each room.',
              actionLabel: 'Add room',
              onAction: () => context.push('/rooms/new'),
            );
          }
          return _RoomList(
            rooms: list,
            filter: _filter,
            onFilter: (f) => setState(() => _filter = f == _filter ? null : f),
          );
        },
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  const _RoomList({required this.rooms, required this.filter, required this.onFilter});

  final List<RoomWithBeds> rooms;
  final BedStatus? filter;
  final ValueChanged<BedStatus> onFilter;

  @override
  Widget build(BuildContext context) {
    final counts = {for (final s in BedStatus.values) s: rooms.fold<int>(0, (a, r) => a + r.count(s))};
    final visible = filter == null ? rooms : rooms.where((r) => r.count(filter!) > 0).toList();
    final byFloor = <int, List<RoomWithBeds>>{};
    for (final r in visible) {
      byFloor.putIfAbsent(r.room.floor, () => []).add(r);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, 96),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final s in BedStatus.values) ...[
                FilterChip(
                  avatar: Icon(s.icon, size: 16, color: s.color),
                  label: Text('${s.label} ${counts[s]}'),
                  selected: filter == s,
                  showCheckmark: false,
                  onSelected: (_) => onFilter(s),
                ),
                const SizedBox(width: Gap.sm),
              ],
            ],
          ),
        ),
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Gap.xxl),
            child: Text(
              'No ${filter!.label.toLowerCase()} beds right now.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        for (final floor in byFloor.keys) ...[
          SectionHeader(title: Dates.floorLabel(floor), count: byFloor[floor]!.length),
          for (final r in byFloor[floor]!) ...[_RoomCard(room: r), const SizedBox(height: Gap.md)],
        ],
      ],
    );
  }
}

class _RoomCard extends ConsumerWidget {
  const _RoomCard({required this.room});
  final RoomWithBeds room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final r = room.room;
    final free = room.count(BedStatus.available);

    return AppCard(
      padding: const EdgeInsets.all(Gap.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room ${r.roomNumber}', style: t.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${room.capacity} ${room.capacity == 1 ? 'bed' : 'beds'} · ${Money.format(r.rentPaise)}/bed',
                      style: t.bodySmall?.copyWith(color: AppColors.textSecondary, fontFeatures: AppTheme.tabular),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: free == 0 ? 'Full' : '$free free',
                color: free == 0 ? AppColors.textSecondary : AppColors.success,
                background: free == 0 ? AppColors.neutralSoft : AppColors.successSoft,
              ),
              IconButton(
                tooltip: 'Edit room ${r.roomNumber}',
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () => context.push('/rooms/${r.id}/edit'),
              ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Wrap(
            spacing: Gap.sm,
            runSpacing: Gap.sm,
            children: [for (final b in room.beds) _BedChip(bed: b, roomNumber: r.roomNumber)],
          ),
        ],
      ),
    );
  }
}

class _BedChip extends ConsumerWidget {
  const _BedChip({required this.bed, required this.roomNumber});
  final BedView bed;
  final String roomNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = bed.effectiveStatus;
    return Semantics(
      button: true,
      label: 'Bed ${bed.bed.label}, ${s.label}${bed.tenantName == null ? '' : ', ${bed.tenantName}'}',
      excludeSemantics: true,
      child: Material(
        color: s.soft,
        borderRadius: BorderRadius.circular(Radii.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(Radii.md),
          onTap: () => _showBedSheet(context, ref),
          child: Container(
            constraints: const BoxConstraints(minWidth: 96, minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: s.color.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.icon, size: 18, color: s.color),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bed ${bed.bed.label}',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: s.color),
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Text(
                        bed.tenantName ?? s.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showBedSheet(BuildContext context, WidgetRef ref) async {
    final status = bed.effectiveStatus;
    final selected = await showModalBottomSheet<BedStatus>(
      context: context,
      builder: (ctx) {
        final t = Theme.of(ctx).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Room $roomNumber · Bed ${bed.bed.label}', style: t.titleLarge),
                const SizedBox(height: Gap.xs),
                Text(
                  status == BedStatus.occupied
                      ? 'Occupied by ${bed.tenantName}. Transfer or check out the tenant to free this bed.'
                      : 'Set the availability of this bed.',
                  style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: Gap.lg),
                if (status != BedStatus.occupied)
                  for (final s in [BedStatus.available, BedStatus.reserved, BedStatus.maintenance])
                    RadioListTile<BedStatus>(
                      value: s,
                      // ignore: deprecated_member_use
                      groupValue: status,
                      // ignore: deprecated_member_use
                      onChanged: (v) => Navigator.pop(ctx, v),
                      title: Text(s.label),
                      secondary: Icon(s.icon, color: s.color),
                      contentPadding: EdgeInsets.zero,
                    ),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || selected == status) return;
    try {
      await ref.read(databaseProvider).roomsDao.setBedStatus(bed.bed.id, selected);
      if (context.mounted) showAppSnack(context, 'Bed ${bed.bed.label} marked ${selected.label.toLowerCase()}');
    } on RoomRuleException catch (e) {
      if (context.mounted) showAppSnack(context, e.message, error: true);
    }
  }
}
