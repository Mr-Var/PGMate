import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/rules.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/dates.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/form_kit.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/state_views.dart';

final _lastBackupProvider = StreamProvider<String?>(
  (ref) => ref.watch(databaseProvider).settingsDao.watchSetting('last_backup_at'),
);

class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(_lastBackupProvider).value;
    final lastAt = last == null ? null : DateTime.tryParse(last);
    final stale = lastAt == null || DateTime.now().difference(lastAt).inDays >= 7;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          Container(
            padding: const EdgeInsets.all(Gap.lg),
            decoration: BoxDecoration(
              color: stale ? AppColors.warningSoft : AppColors.successSoft,
              borderRadius: BorderRadius.circular(Radii.lg),
            ),
            child: Row(
              children: [
                Icon(
                  stale ? Icons.warning_amber_rounded : Icons.verified_user_outlined,
                  color: stale ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    lastAt == null
                        ? 'No backup yet. All data lives only on this phone. If it is lost or reset, the data is gone.'
                        : 'Last backup ${Dates.relativeDays(lastAt).toLowerCase()} (${Dates.short(lastAt)}).'
                              '${stale ? ' Back up at least once a week.' : ''}',
                    style: t.bodyMedium?.copyWith(
                      color: stale ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Create backup'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Includes every tenant, payment, rent bill, expense and all photos and documents. '
                  'The file is encrypted with a password you choose.',
                  style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: Gap.lg),
                AsyncButton(
                  label: 'Back up now',
                  icon: Icons.cloud_download_outlined,
                  onPressed: () => _create(context, ref),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Restore'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Replaces all data on this phone with a backup file. The backup is checked first; '
                  'nothing changes unless it is valid and you confirm with your PIN.',
                  style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: Gap.lg),
                AsyncButton(
                  label: 'Restore from file',
                  icon: Icons.restore_rounded,
                  outlined: true,
                  onPressed: () => _restore(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),
          Text(
            'Keep backups somewhere other than this phone: Google Drive, email to yourself, or a computer.',
            style: t.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Future<(String, bool)?> _askPassword(BuildContext context, {required bool confirm}) {
    final a = TextEditingController();
    final b = TextEditingController();
    final key = GlobalKey<FormState>();
    var hide = true;
    var remember = true;
    return showDialog<(String, bool)>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(confirm ? 'Set backup password' : 'Backup password'),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (confirm)
                  const Padding(
                    padding: EdgeInsets.only(bottom: Gap.md),
                    child: Text(
                      'You need this password to restore. It cannot be recovered if forgotten.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                TextFormField(
                  controller: a,
                  obscureText: hide,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      tooltip: hide ? 'Show password' : 'Hide password',
                      icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => hide = !hide),
                    ),
                  ),
                  validator: (v) => confirm
                      ? BackupService.validatePassword(v ?? '')
                      : ((v ?? '').isEmpty ? 'Enter the password' : null),
                ),
                if (confirm) ...[
                  const SizedBox(height: Gap.md),
                  TextFormField(
                    controller: b,
                    obscureText: hide,
                    decoration: const InputDecoration(labelText: 'Repeat password'),
                    validator: (v) => v != a.text ? 'Passwords do not match' : null,
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: remember,
                    onChanged: (v) => setState(() => remember = v ?? true),
                    title: const Text('Remember on this phone for one-tap backups'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
              onPressed: () {
                if (key.currentState!.validate()) Navigator.pop(ctx, (a.text, remember));
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) => quickBackup(context, ref, askPassword: _askPassword);

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final files = await FilePicker.pickFiles(type: FileType.any);
    if (files.isEmpty || !context.mounted) return;
    final bytes = await files.first.readAsBytes();
    if (!context.mounted) return;
    final saved = await ref.read(secureStoreProvider).read(backupPasswordKey);
    if (!context.mounted) return;
    String? password = saved;
    if (password != null) {
      try {
        await ref
            .read(backupServiceProvider)
            .validate(bytes, password, currentSchemaVersion: ref.read(databaseProvider).schemaVersion);
      } on RuleException {
        password = null; // a different password was used for this file
      }
    }
    if (!context.mounted) return;
    password ??= (await _askPassword(context, confirm: false))?.$1;
    if (password == null || !context.mounted) return;

    final db = ref.read(databaseProvider);
    final backups = ref.read(backupServiceProvider);
    late final ValidatedBackup valid;
    try {
      valid = await backups.validate(bytes, password, currentSchemaVersion: db.schemaVersion);
    } on RuleException catch (e) {
      if (context.mounted) showAppSnack(context, e.message, error: true);
      return;
    }
    if (!context.mounted) return;
    final m = valid.manifest;
    final go = await confirmAction(
      context,
      title: 'Replace all current data?',
      message:
          'Backup of “${m.pgName}” from ${Dates.short(m.createdAt)}: ${m.tenants} tenants, ${m.payments} payments, '
          '${m.files} files.\n\nEverything on this phone will be replaced. A safety copy of the current data is kept in the app folder.',
      confirmLabel: 'Replace data',
      destructive: true,
    );
    if (!go || !context.mounted) return;
    final auth = ref.read(authServiceProvider);
    final pinOk = await confirmOwnerPin(
      context,
      title: 'Confirm restore',
      message: 'Enter your PIN to replace the data.',
      length: AuthService.pinLength,
      verify: (pin) async => switch (await auth.verifyPin(pin)) {
        PinOk() => true,
        PinWrong() => false,
        PinLockedOut() => null,
      },
    );
    if (!pinOk || !context.mounted) return;

    await db.close();
    await backups.apply(valid);
    ref.invalidate(databaseProvider);
    final fresh = ref.read(databaseProvider);
    await fresh.settingsDao.log('backup', null, 'restore', m.createdAt.toIso8601String());
    if (context.mounted) showAppSnack(context, 'Restored ${m.tenants} tenants from ${Dates.short(m.createdAt)}');
  }
}

const backupPasswordKey = 'backup_password';

typedef PasswordAsker = Future<(String, bool)?> Function(BuildContext context, {required bool confirm});

/// One-tap backup: uses the remembered password (or asks once), builds the
/// encrypted backup and lets the owner save or share it.
Future<void> quickBackup(BuildContext context, WidgetRef ref, {PasswordAsker? askPassword}) async {
  final store = ref.read(secureStoreProvider);
  var password = await store.read(backupPasswordKey);
  if (!context.mounted) return;
  if (password == null) {
    final asked = await (askPassword ?? const BackupScreen()._askPassword)(context, confirm: true);
    if (asked == null || !context.mounted) return;
    password = asked.$1;
    if (asked.$2) await store.write(backupPasswordKey, password);
  }
  if (!context.mounted) return;
  final db = ref.read(databaseProvider);
  final (bytes, manifest) = await ref.read(backupServiceProvider).create(db, password);
  final name = BackupService.fileName(manifest.createdAt);
  if (!context.mounted) return;
  final where = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.sm),
            child: Text(
              'Backup ready · ${manifest.tenants} tenants. Where should it go?',
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_to_drive_rounded),
            title: const Text('Google Drive, email or WhatsApp'),
            subtitle: const Text('Safest: keeps a copy off this phone'),
            onTap: () => Navigator.pop(ctx, 'share'),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt_rounded),
            title: const Text('Save to this phone'),
            onTap: () => Navigator.pop(ctx, 'save'),
          ),
          const SizedBox(height: Gap.sm),
        ],
      ),
    ),
  );
  if (where == 'save') {
    final uri = await FilePicker.saveFile(fileName: name, bytes: bytes);
    if (context.mounted) {
      showAppSnack(context, uri == null ? 'Not saved' : 'Backup saved as $name', error: uri == null);
    }
  } else if (where == 'share') {
    final f = await ref.read(exportServiceProvider).writeTemp(name, bytes);
    await ref
        .read(exportServiceProvider)
        .shareFile(f, mime: 'application/octet-stream', text: 'PG Manager backup ${Dates.short(manifest.createdAt)}');
  }
}
