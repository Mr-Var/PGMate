import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/daos/rooms_dao.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/validators.dart';
import 'rooms_providers.dart';

class RoomFormScreen extends ConsumerWidget {
  const RoomFormScreen({super.key, this.roomId});

  final int? roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (roomId == null) return const _RoomForm();
    final rooms = ref.watch(roomsProvider);
    return rooms.when(
      loading: () => const Scaffold(body: LoadingList()),
      error: (e, _) => Scaffold(appBar: AppBar(), body: ErrorState(error: e)),
      data: (list) {
        final match = list.where((r) => r.room.id == roomId).firstOrNull;
        if (match == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'Room not found',
              message: 'It may have been removed.',
            ),
          );
        }
        return _RoomForm(existing: match);
      },
    );
  }
}

class _RoomForm extends ConsumerStatefulWidget {
  const _RoomForm({this.existing});
  final RoomWithBeds? existing;

  @override
  ConsumerState<_RoomForm> createState() => _RoomFormState();
}

class _RoomFormState extends ConsumerState<_RoomForm> {
  final _formKey = GlobalKey<FormState>();
  late final _number = TextEditingController(text: widget.existing?.room.roomNumber);
  late final _rent = TextEditingController(
    text: widget.existing == null ? '' : Money.toInput(widget.existing!.room.rentPaise),
  );
  late final _notes = TextEditingController(text: widget.existing?.room.notes);
  late int _floor = widget.existing?.room.floor ?? 0;
  late int _beds = widget.existing?.capacity ?? 2;
  bool _saving = false;
  String? _numberError;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _number.dispose();
    _rent.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _numberError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final dao = ref.read(databaseProvider).roomsDao;
    final rent = Money.parseRupees(_rent.text)!;
    try {
      if (_isEdit) {
        await dao.updateRoom(
          roomId: widget.existing!.room.id,
          roomNumber: _number.text,
          floor: _floor,
          rentPaise: rent,
          bedCount: _beds,
          notes: _notes.text,
        );
      } else {
        await dao.addRoom(roomNumber: _number.text, floor: _floor, rentPaise: rent, bedCount: _beds, notes: _notes.text);
      }
      if (!mounted) return;
      showAppSnack(context, _isEdit ? 'Room ${_number.text.trim()} updated' : 'Room ${_number.text.trim()} added');
      context.pop();
    } on RoomRuleException catch (e) {
      if (!mounted) return;
      if (e.message.contains('already exists')) {
        setState(() => _numberError = e.message);
      } else {
        showAppSnack(context, e.message, error: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final room = widget.existing!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove room ${room.room.roomNumber}?'),
        content: const Text(
          'Rooms that never had tenants are deleted. Rooms with history are archived so past records stay intact.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger, minimumSize: const Size(64, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final auth = ref.read(authServiceProvider);
    final pinOk = await confirmOwnerPin(
      context,
      message: 'Removing a room is a sensitive action.',
      length: AuthService.pinLength,
      verify: (pin) async => switch (await auth.verifyPin(pin)) {
        PinOk() => true,
        PinWrong() => false,
        PinLockedOut() => null,
      },
    );
    if (!pinOk || !mounted) return;

    try {
      await ref.read(databaseProvider).roomsDao.deleteRoom(room.room.id);
      if (!mounted) return;
      showAppSnack(context, 'Room ${room.room.roomNumber} removed');
      context.pop();
    } on RoomRuleException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final occupied = widget.existing?.beds.where((b) => b.tenantId != null).length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit room' : 'Add room'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Remove room',
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(Gap.lg),
            children: [
              DropdownButtonFormField<int>(
            isExpanded: true,
                initialValue: _floor,
                decoration: const InputDecoration(labelText: 'Floor', prefixIcon: Icon(Icons.layers_outlined)),
                items: [
                  for (var f = -1; f <= 15; f++) DropdownMenuItem(value: f, child: Text(Dates.floorLabel(f))),
                ],
                onChanged: (v) => setState(() => _floor = v ?? _floor),
              ),
              const SizedBox(height: Gap.lg),
              TextFormField(
                controller: _number,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                decoration: InputDecoration(
                  labelText: 'Room number',
                  hintText: _floor <= 0 ? 'e.g. 001' : 'e.g. ${_floor}01',
                  prefixIcon: const Icon(Icons.meeting_room_outlined),
                  errorText: _numberError,
                ),
                onChanged: (_) {
                  if (_numberError != null) setState(() => _numberError = null);
                },
                validator: (v) => Validators.required(v, 'Room number', max: 20),
              ),
              const SizedBox(height: Gap.lg),
              TextFormField(
                controller: _rent,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Rent per bed (monthly)',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                  helperText: 'Default rent for tenants in this room. Can be changed per tenant.',
                ),
                validator: (v) => Validators.amount(v, field: 'Rent'),
              ),
              const SizedBox(height: Gap.xl),
              Text('Beds', style: t.titleSmall),
              const SizedBox(height: Gap.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: Gap.xs),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Fewer beds',
                      onPressed: _beds > 1 ? () => setState(() => _beds--) : null,
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    Expanded(
                      child: Text(
                        '$_beds ${_beds == 1 ? 'bed' : 'beds'}',
                        textAlign: TextAlign.center,
                        style: t.titleMedium?.copyWith(fontFeatures: AppTheme.tabular),
                      ),
                    ),
                    IconButton(
                      tooltip: 'More beds',
                      onPressed: _beds < 20 ? () => setState(() => _beds++) : null,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              if (_isEdit && occupied > 0) ...[
                const SizedBox(height: Gap.sm),
                Text(
                  '$occupied ${occupied == 1 ? 'bed is' : 'beds are'} occupied and cannot be removed.',
                  style: t.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: Gap.xl),
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'AC, attached bathroom, balcony…',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: Gap.xxl),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isEdit ? 'Save changes' : 'Add room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
