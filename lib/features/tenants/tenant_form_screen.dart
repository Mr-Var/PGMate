import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/billing_math.dart';
import '../../core/database/daos/tenants_dao.dart';
import '../../core/database/enums.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/state_views.dart';
import '../../shared/widgets/validators.dart';
import 'tenants_providers.dart';

const idProofTypes = ['Aadhaar', 'PAN card', 'Driving licence', 'Passport', 'Voter ID', 'College / office ID', 'Other'];

class TenantFormScreen extends ConsumerWidget {
  const TenantFormScreen({super.key, this.tenantId});
  final int? tenantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tenantId == null) return const _TenantForm();
    final detail = ref.watch(tenantDetailProvider(tenantId!));
    return detail.when(
      loading: () => const Scaffold(body: LoadingList()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(error: e),
      ),
      data: (d) => d == null
          ? Scaffold(
              appBar: AppBar(),
              body: const EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Tenant not found',
                message: 'This record no longer exists.',
              ),
            )
          : _TenantForm(existing: d.tenant),
    );
  }
}

class _TenantForm extends ConsumerStatefulWidget {
  const _TenantForm({this.existing});
  final Tenant? existing;

  @override
  ConsumerState<_TenantForm> createState() => _TenantFormState();
}

class _TenantFormState extends ConsumerState<_TenantForm> {
  final _formKey = GlobalKey<FormState>();
  Tenant? get _e => widget.existing;
  bool get _isEdit => _e != null;

  late final _name = TextEditingController(text: _e?.fullName);
  late final _phone = TextEditingController(text: _e?.phone);
  late final _email = TextEditingController(text: _e?.email);
  late final _occupation = TextEditingController(text: _e?.occupation);
  late final _emName = TextEditingController(text: _e?.emergencyContactName);
  late final _emPhone = TextEditingController(text: _e?.emergencyContactPhone);
  late final _idNumber = TextEditingController(text: _e?.idProofNumber);
  late final _rent = TextEditingController(text: _e == null ? '' : Money.toInput(_e!.monthlyRentPaise));
  late final _deposit = TextEditingController(text: _e == null ? '' : Money.toInput(_e!.securityDepositPaise));
  late final _advance = TextEditingController();
  late final _utr = TextEditingController();
  late final _notes = TextEditingController(text: _e?.notes);

  late Gender _gender = _e?.gender ?? Gender.male;
  late String? _idType = _e?.idProofType;
  late DateTime _joining = _e?.joiningDate ?? Dates.today();
  late int _dueDay = _e?.rentDueDay ?? 5;
  int? _bedId;
  PaymentMethod _advanceMethod = PaymentMethod.cash;
  bool _firstInvoice = true;

  // New files picked in this session (saved on submit).
  (Uint8List, String)? _newPhoto;
  (Uint8List, String)? _newIdDoc;
  bool _dueDayTouched = false;

  @override
  void initState() {
    super.initState();
    if (!_isEdit) {
      ref.read(databaseProvider).settingsDao.getProfile().then((p) {
        if (p != null && mounted && !_dueDayTouched) setState(() => _dueDay = p.defaultRentDueDay);
      });
    }
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _email,
      _occupation,
      _emName,
      _emPhone,
      _idNumber,
      _rent,
      _deposit,
      _advance,
      _utr,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      showAppSnack(context, 'Some details need attention. Check the highlighted fields.', error: true);
      return;
    }
    final files = ref.read(fileStoreProvider);
    final photo = _newPhoto == null
        ? _e?.photoPath
        : await files.save(_newPhoto!.$1, folder: 'tenants', extension: _newPhoto!.$2);
    final idDoc = _newIdDoc == null
        ? _e?.idProofPath
        : await files.save(_newIdDoc!.$1, folder: 'id_proofs', extension: _newIdDoc!.$2);
    final input = TenantInput(
      fullName: _name.text,
      phone: _phone.text,
      gender: _gender,
      joiningDate: _joining,
      monthlyRentPaise: MoneyField.read(_rent),
      rentDueDay: _dueDay,
      email: _email.text,
      photoPath: photo,
      idProofType: _idType,
      idProofNumber: _idNumber.text,
      idProofPath: idDoc,
      emergencyContactName: _emName.text,
      emergencyContactPhone: _emPhone.text,
      occupation: _occupation.text,
      securityDepositPaise: MoneyField.read(_deposit),
      advancePaise: _isEdit ? (_e!.advancePaise) : MoneyField.read(_advance),
      notes: _notes.text,
    );
    final dao = ref.read(databaseProvider).tenantsDao;
    if (!mounted) return;
    final ok = await runGuarded(context, () async {
      if (_isEdit) {
        await dao.updateTenant(_e!.id, input);
      } else {
        final id = await dao.createTenant(
          input,
          bedId: _bedId,
          advanceMethod: _advanceMethod,
          advanceUpiReference: _advanceMethod == PaymentMethod.upi ? _utr.text : null,
          generateFirstInvoice: _firstInvoice,
        );
        await refreshReminders(ref.read(databaseProvider), ref.read(reminderServiceProvider));
        if (mounted) context.pushReplacement('/tenants/$id');
      }
    }, success: _isEdit ? 'Details saved' : '${input.fullName.trim()} registered');
    if (ok && _isEdit && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final rentPaise = Money.parseRupees(_rent.text) ?? 0;
    final prorated = BillingMath.joiningMonthRent(rentPaise, _joining);

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit tenant' : 'New tenant')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.sm, Gap.lg, Gap.xxl),
            children: [
              Center(
                child: _PhotoPicker(
                  existing: _e?.photoPath,
                  picked: _newPhoto?.$1,
                  name: _name.text,
                  onPick: () async {
                    final img = await pickImage(context, title: 'Tenant photo');
                    if (img != null) setState(() => _newPhoto = img);
                  },
                ),
              ),
              const SizedBox(height: Gap.xl),
              FormSection(
                title: 'Personal details',
                icon: Icons.person_outline_rounded,
                children: [
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => Validators.required(v, 'Full name', min: 2, max: 120),
                  ),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    decoration: const InputDecoration(labelText: 'Mobile number', prefixText: '+91 '),
                    validator: Validators.indianPhone,
                  ),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Email (optional)'),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return null;
                      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s) ? null : 'Enter a valid email address';
                    },
                  ),
                  SegmentedButton<Gender>(
                    segments: [for (final g in Gender.values) ButtonSegment(value: g, label: Text(g.label))],
                    selected: {_gender},
                    onSelectionChanged: (s) => setState(() => _gender = s.first),
                    showSelectedIcon: false,
                  ),
                  TextFormField(
                    controller: _occupation,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Occupation / company (optional)'),
                  ),
                ],
              ),
              FormSection(
                title: 'Emergency contact',
                icon: Icons.emergency_outlined,
                children: [
                  TextFormField(
                    controller: _emName,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Name and relation', hintText: 'e.g. Suresh (father)'),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Add an emergency contact' : null,
                  ),
                  TextFormField(
                    controller: _emPhone,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    decoration: const InputDecoration(labelText: 'Emergency phone', prefixText: '+91 '),
                    validator: Validators.indianPhone,
                  ),
                ],
              ),
              FormSection(
                title: 'ID proof',
                icon: Icons.badge_outlined,
                subtitle: 'Stored privately on this phone only.',
                children: [
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _idType,
                    decoration: const InputDecoration(labelText: 'ID type'),
                    items: [for (final t in idProofTypes) DropdownMenuItem(value: t, child: Text(t))],
                    onChanged: (v) => setState(() => _idType = v),
                    validator: (v) => v == null ? 'Choose the ID type' : null,
                  ),
                  TextFormField(
                    controller: _idNumber,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'ID number (optional)'),
                  ),
                  _DocTile(
                    label: 'ID document',
                    hasExisting: _e?.idProofPath != null,
                    picked: _newIdDoc,
                    onPick: () async {
                      final d = await pickDocument(context, title: 'ID proof');
                      if (d != null) setState(() => _newIdDoc = d);
                    },
                  ),
                ],
              ),
              FormSection(
                title: 'Stay and rent',
                icon: Icons.bed_outlined,
                children: [
                  if (!_isEdit) ...[
                    DateField(label: 'Joining date', value: _joining, onChanged: (d) => setState(() => _joining = d)),
                    _BedPicker(
                      value: _bedId,
                      onChanged: (bedId, rent) => setState(() {
                        _bedId = bedId;
                        if (rent != null && _rent.text.trim().isEmpty) _rent.text = Money.toInput(rent);
                      }),
                    ),
                  ],
                  MoneyField(
                    controller: _rent,
                    label: 'Monthly rent',
                    onChanged: (_) => setState(() {}),
                    helper: _isEdit ? 'Changes apply from the next invoice. Past invoices keep their amount.' : null,
                  ),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _dueDay,
                    decoration: const InputDecoration(labelText: 'Rent due day'),
                    items: [
                      for (var d = 1; d <= 28; d++) DropdownMenuItem(value: d, child: Text('Day $d of every month')),
                    ],
                    onChanged: (v) => setState(() {
                      _dueDay = v ?? _dueDay;
                      _dueDayTouched = true;
                    }),
                  ),
                  MoneyField(
                    controller: _deposit,
                    label: 'Security deposit',
                    allowZero: true,
                    required: false,
                    helper: 'Held, not counted as income. Settled at checkout.',
                  ),
                  if (!_isEdit) ...[
                    MoneyField(
                      controller: _advance,
                      label: 'Advance rent received now',
                      allowZero: true,
                      required: false,
                      onChanged: (_) => setState(() {}),
                      helper: 'Recorded as a payment and used against the first invoices.',
                    ),
                    if ((Money.parseRupees(_advance.text) ?? 0) > 0) ...[
                      SegmentedButton<PaymentMethod>(
                        segments: const [
                          ButtonSegment(
                            value: PaymentMethod.cash,
                            label: Text('Cash'),
                            icon: Icon(Icons.payments_outlined),
                          ),
                          ButtonSegment(
                            value: PaymentMethod.upi,
                            label: Text('UPI'),
                            icon: Icon(Icons.qr_code_2_rounded),
                          ),
                        ],
                        selected: {_advanceMethod},
                        onSelectionChanged: (s) => setState(() => _advanceMethod = s.first),
                      ),
                      if (_advanceMethod == PaymentMethod.upi)
                        TextFormField(
                          controller: _utr,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'UPI reference (UTR)',
                            helperText: 'Check it in your UPI or bank app before saving.',
                          ),
                          validator: (v) => (v ?? '').trim().length < 6 ? 'Enter the UTR from your UPI app' : null,
                        ),
                    ],
                    if (_bedId != null)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _firstInvoice,
                        onChanged: (v) => setState(() => _firstInvoice = v),
                        title: const Text('Create this month\'s invoice'),
                        subtitle: Text(
                          rentPaise == 0
                              ? 'Enter the rent to see the amount'
                              : _joining.day > 1
                              ? '${Money.format(prorated)} for ${BillingMath.daysInMonth(_joining.year, _joining.month) - _joining.day + 1} days (prorated)'
                              : Money.format(prorated),
                          style: const TextStyle(fontFeatures: AppTheme.tabular),
                        ),
                      ),
                  ],
                ],
              ),
              FormSection(
                title: 'Notes',
                icon: Icons.notes_rounded,
                children: [
                  TextFormField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Food preference, vehicle number…',
                    ),
                  ),
                ],
              ),
              AsyncButton(label: _isEdit ? 'Save changes' : 'Register tenant', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({required this.existing, required this.picked, required this.name, required this.onPick});

  final String? existing;
  final Uint8List? picked;
  final String name;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tenant photo',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPick,
        child: Stack(
          children: [
            if (picked != null)
              CircleAvatar(radius: 48, backgroundImage: MemoryImage(picked!))
            else if (existing != null)
              PersonAvatar(name: name, photoPath: existing, radius: 48)
            else
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.surfaceMuted,
                child: const Icon(Icons.person_outline_rounded, size: 44, color: AppColors.textMuted),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 3),
                ),
                child: const Icon(Icons.photo_camera_outlined, size: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.label, required this.hasExisting, required this.picked, required this.onPick});

  final String label;
  final bool hasExisting;
  final (Uint8List, String)? picked;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final has = picked != null || hasExisting;
    final isPdf = picked != null ? picked!.$2 == 'pdf' : false;
    return OutlinedButton.icon(
      onPressed: onPick,
      icon: Icon(has ? Icons.check_circle_rounded : Icons.upload_file_rounded, color: has ? AppColors.success : null),
      label: Text(
        picked != null
            ? '${isPdf ? 'PDF' : 'Photo'} selected · tap to change'
            : hasExisting
            ? '$label saved · tap to replace'
            : 'Upload $label (photo or PDF)',
      ),
    );
  }
}

class _BedPicker extends ConsumerWidget {
  const _BedPicker({required this.value, required this.onChanged});

  final int? value;
  final void Function(int? bedId, int? roomRentPaise) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beds = ref.watch(freeBedsProvider);
    return beds.when(
      loading: () => const SkeletonBox(height: 56, radius: Radii.md),
      error: (e, _) => Text('Could not load beds: $e'),
      data: (list) {
        if (list.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(Gap.md),
            decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(Radii.md)),
            child: const Text(
              'No free beds. You can still register the tenant and assign a bed later from their profile.',
              style: TextStyle(color: AppColors.warning),
            ),
          );
        }
        return DropdownButtonFormField<int?>(
          isExpanded: true,
          initialValue: value,
          decoration: const InputDecoration(labelText: 'Bed', helperText: 'Leave empty to assign later'),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Assign later')),
            for (final b in list)
              DropdownMenuItem<int?>(
                value: b.bed.id,
                child: Text(
                  '${b.label} · ${Dates.floorLabel(b.room.floor)} · ${Money.format(b.room.rentPaise)}'
                  '${b.bed.status == BedStatus.reserved ? ' · reserved' : ''}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (id) {
            final b = list.where((x) => x.bed.id == id).firstOrNull;
            onChanged(id, b?.room.rentPaise);
          },
        );
      },
    );
  }
}
