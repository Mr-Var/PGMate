import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/validators.dart';

class PgProfileData {
  const PgProfileData({
    required this.name,
    required this.address,
    required this.ownerName,
    required this.ownerPhone,
    required this.upiId,
    required this.rentDueDay,
  });

  final String name;
  final String address;
  final String ownerName;
  final String ownerPhone;
  final String? upiId;
  final int rentDueDay;
}

/// PG details form used by onboarding and settings.
class PgProfileForm extends StatefulWidget {
  const PgProfileForm({super.key, this.initial, required this.submitLabel, required this.onSubmit});

  final PgProfile? initial;
  final String submitLabel;
  final Future<void> Function(PgProfileData data) onSubmit;

  @override
  State<PgProfileForm> createState() => _PgProfileFormState();
}

class _PgProfileFormState extends State<PgProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _address = TextEditingController(text: widget.initial?.address);
  late final _owner = TextEditingController(text: widget.initial?.ownerName);
  late final _phone = TextEditingController(text: widget.initial?.ownerPhone);
  late final _upi = TextEditingController(text: widget.initial?.upiId);
  late int _dueDay = widget.initial?.defaultRentDueDay ?? 5;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _address, _owner, _phone, _upi]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(PgProfileData(
        name: _name.text.trim(),
        address: _address.text.trim(),
        ownerName: _owner.text.trim(),
        ownerPhone: _phone.text.trim(),
        upiId: _upi.text.trim().isEmpty ? null : _upi.text.trim(),
        rentDueDay: _dueDay,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'PG name', prefixIcon: Icon(Icons.apartment_rounded)),
            validator: (v) => Validators.required(v, 'PG name', min: 2, max: 120),
          ),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _address,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(Icons.location_on_outlined),
              helperText: 'Printed on receipts',
            ),
            validator: (v) => Validators.required(v, 'Address', min: 5, max: 500),
          ),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _owner,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(labelText: 'Owner name', prefixIcon: Icon(Icons.person_outline_rounded)),
            validator: (v) => Validators.required(v, 'Owner name', min: 2, max: 120),
          ),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            decoration: const InputDecoration(
              labelText: 'Owner phone',
              prefixIcon: Icon(Icons.phone_outlined),
              prefixText: '+91 ',
            ),
            validator: Validators.indianPhone,
          ),
          const SizedBox(height: Gap.lg),
          TextFormField(
            controller: _upi,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'UPI ID (optional)',
              hintText: 'name@bank',
              prefixIcon: Icon(Icons.qr_code_2_rounded),
              helperText: 'Shown to tenants when collecting UPI payments',
            ),
            validator: Validators.optionalUpi,
          ),
          const SizedBox(height: Gap.lg),
          DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: _dueDay,
            decoration: const InputDecoration(
              labelText: 'Default rent due day',
              prefixIcon: Icon(Icons.event_outlined),
              helperText: 'Day of the month rent is due. Can be changed per tenant.',
            ),
            items: [
              for (var d = 1; d <= 28; d++) DropdownMenuItem(value: d, child: Text('${_ordinal(d)} of every month')),
            ],
            onChanged: (v) => setState(() => _dueDay = v ?? _dueDay),
          ),
          const SizedBox(height: Gap.xl),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    return switch (n % 10) { 1 => '${n}st', 2 => '${n}nd', 3 => '${n}rd', _ => '${n}th' };
  }
}
