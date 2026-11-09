import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/database/rules.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import 'state_views.dart';
import 'validators.dart';

/// A titled group of form fields.
class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, required this.children, this.subtitle, this.icon});

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: Gap.sm)],
            Expanded(child: Semantics(header: true, child: Text(title, style: t.titleMedium))),
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: t.bodySmall?.copyWith(color: AppColors.textMuted)),
          ],
          const SizedBox(height: Gap.md),
          for (final (i, c) in children.indexed) ...[if (i > 0) const SizedBox(height: Gap.lg), c],
        ],
      ),
    );
  }
}

class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
    this.allowZero = false,
    this.required = true,
    this.onChanged,
    this.maxPaise,
  });

  final TextEditingController controller;
  final String label;
  final String? helper;
  final bool allowZero;
  final bool required;
  final ValueChanged<String>? onChanged;
  final int? maxPaise;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
      style: const TextStyle(fontFeatures: AppTheme.tabular),
      decoration: InputDecoration(labelText: label, prefixText: '₹ ', helperText: helper, helperMaxLines: 2),
      onChanged: onChanged,
      validator: (v) {
        if (!required && (v == null || v.trim().isEmpty)) return null;
        final e = Validators.amount(v, allowZero: allowZero, field: label);
        if (e != null) return e;
        if (maxPaise != null && Money.parseRupees(v!)! > maxPaise!) return 'Cannot be more than ${Money.format(maxPaise!)}';
        return null;
      },
    );
  }

  static int read(TextEditingController c) => Money.parseRupees(c.text) ?? 0;
}

/// Read-only field that opens a date picker.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.first,
    this.last,
    this.helper,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? first;
  final DateTime? last;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Radii.md),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: first ?? DateTime(2020),
          lastDate: last ?? DateTime(DateTime.now().year + 2),
        );
        if (picked != null) onChanged(Dates.today(picked));
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          prefixIcon: const Icon(Icons.event_outlined),
          suffixIcon: const Icon(Icons.expand_more_rounded),
        ),
        child: Text(Dates.short(value)),
      ),
    );
  }
}

/// Primary action with built-in busy state and rule-error handling.
class AsyncButton extends StatefulWidget {
  const AsyncButton({super.key, required this.label, required this.onPressed, this.icon, this.danger = false, this.outlined = false});

  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final bool danger;
  final bool outlined;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy || widget.onPressed == null) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } on RuleException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } catch (e) {
      if (mounted) showAppSnack(context, 'Could not complete: $e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _busy
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.icon != null) ...[Icon(widget.icon, size: 20), const SizedBox(width: Gap.sm)],
            Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
          ]);
    final onPressed = widget.onPressed == null || _busy ? null : _run;
    if (widget.outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: widget.danger ? OutlinedButton.styleFrom(foregroundColor: AppColors.danger) : null,
        child: child,
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: widget.danger ? FilledButton.styleFrom(backgroundColor: AppColors.danger) : null,
      child: child,
    );
  }
}

/// Runs [action] and shows rule errors as a snackbar. Returns true on success.
Future<bool> runGuarded(BuildContext context, Future<void> Function() action, {String? success}) async {
  try {
    await action();
    if (success != null && context.mounted) showAppSnack(context, success);
    return true;
  } on RuleException catch (e) {
    if (context.mounted) showAppSnack(context, e.message, error: true);
  } catch (e) {
    if (context.mounted) showAppSnack(context, 'Could not complete: $e', error: true);
  }
  return false;
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 44),
            backgroundColor: destructive ? AppColors.danger : null,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// Asks for a short reason (for reversals, cancellations, voids).
Future<String?> askReason(BuildContext context, {required String title, String hint = 'Reason', String confirmLabel = 'Confirm'}) {
  final c = TextEditingController();
  final key = GlobalKey<FormState>();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Form(
        key: key,
        child: TextFormField(
          controller: c,
          autofocus: true,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: hint),
          validator: (v) => Validators.required(v, hint, min: 3, max: 200),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
          onPressed: () {
            if (key.currentState!.validate()) Navigator.pop(ctx, c.text.trim());
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Picks a photo from camera or gallery, downscaled for storage.
Future<(Uint8List, String)?> pickImage(BuildContext context, {String title = 'Add photo'}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.sm),
          child: Align(alignment: Alignment.centerLeft, child: Text(title, style: Theme.of(ctx).textTheme.titleLarge)),
        ),
        ListTile(
          leading: const Icon(Icons.photo_camera_outlined),
          title: const Text('Take a photo'),
          onTap: () => Navigator.pop(ctx, ImageSource.camera),
        ),
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('Choose from gallery'),
          onTap: () => Navigator.pop(ctx, ImageSource.gallery),
        ),
        const SizedBox(height: Gap.sm),
      ]),
    ),
  );
  if (source == null) return null;
  final x = await ImagePicker().pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 82);
  if (x == null) return null;
  final ext = x.name.contains('.') ? x.name.split('.').last : 'jpg';
  return (await x.readAsBytes(), ext);
}

/// Picks an image or PDF document (ID proofs, bills).
Future<(Uint8List, String)?> pickDocument(BuildContext context, {String title = 'Add document'}) async {
  final choice = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.sm),
          child: Align(alignment: Alignment.centerLeft, child: Text(title, style: Theme.of(ctx).textTheme.titleLarge)),
        ),
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Take a photo'), onTap: () => Navigator.pop(ctx, 'camera')),
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Choose image'), onTap: () => Navigator.pop(ctx, 'gallery')),
        ListTile(leading: const Icon(Icons.picture_as_pdf_outlined), title: const Text('Choose PDF'), onTap: () => Navigator.pop(ctx, 'pdf')),
        const SizedBox(height: Gap.sm),
      ]),
    ),
  );
  if (choice == null) return null;
  if (choice == 'pdf') {
    final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (files.isEmpty) return null;
    return (await files.first.readAsBytes(), 'pdf');
  }
  final x = await ImagePicker().pickImage(
    source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
    maxWidth: 2000,
    maxHeight: 2000,
    imageQuality: 85,
  );
  if (x == null) return null;
  return (await x.readAsBytes(), x.name.contains('.') ? x.name.split('.').last : 'jpg');
}

/// Shows an image stored in private app storage, by relative path.
class StoredImage extends ConsumerWidget {
  const StoredImage({super.key, required this.path, this.fit = BoxFit.cover, this.width, this.height});

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<File>(
      future: ref.read(fileStoreProvider).resolve(path),
      builder: (context, snap) {
        final f = snap.data;
        if (f == null) return SizedBox(width: width, height: height);
        return Image.file(
          f,
          fit: fit,
          width: width,
          height: height,
          cacheWidth: width == null ? null : (width! * MediaQuery.devicePixelRatioOf(context)).round(),
          errorBuilder: (_, _, _) => SizedBox(
            width: width,
            height: height,
            child: const Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted)),
          ),
        );
      },
    );
  }
}

/// Circle avatar with the tenant's photo or initials.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.name, this.photoPath, this.radius = 22, this.color = AppColors.primary});

  final String name;
  final String? photoPath;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.10),
      child: photoPath == null
          ? Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: radius * 0.66))
          : ClipOval(child: StoredImage(path: photoPath!, width: radius * 2, height: radius * 2)),
    );
  }
}
