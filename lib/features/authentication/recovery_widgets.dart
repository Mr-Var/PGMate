import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/state_views.dart';

/// Shows a freshly created recovery code in large letters and asks the owner
/// to write it down. Resolves once they confirm.
Future<void> showRecoveryCode(BuildContext context, WidgetRef ref, String code) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) => _RecoveryCodeSheet(code: code),
  );
}

class _RecoveryCodeSheet extends ConsumerStatefulWidget {
  const _RecoveryCodeSheet({required this.code});
  final String code;

  @override
  ConsumerState<_RecoveryCodeSheet> createState() => _RecoveryCodeSheetState();
}

class _RecoveryCodeSheetState extends ConsumerState<_RecoveryCodeSheet> {
  bool _written = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Write down this code', style: t.headlineSmall),
            const SizedBox(height: Gap.sm),
            Text(
              'If you ever forget your PIN, this code lets you set a new one. '
              'Write it on paper and keep it safe. Without it, a forgotten PIN cannot be reset.',
              style: t.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: Gap.xl),
            Container(
              padding: const EdgeInsets.symmetric(vertical: Gap.xl),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(Radii.lg),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: SelectableText(
                widget.code,
                textAlign: TextAlign.center,
                style: AppTheme.figure(30, color: AppColors.textPrimary).copyWith(letterSpacing: 2),
              ),
            ),
            const SizedBox(height: Gap.md),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.read(exportServiceProvider).whatsapp('PG Manager recovery code (keep private): ${widget.code}'),
              icon: const Icon(Icons.chat_outlined),
              label: const Text('Also send to a family member on WhatsApp'),
            ),
            const SizedBox(height: Gap.md),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _written,
              onChanged: (v) => setState(() => _written = v ?? false),
              title: Text('I have written this code down', style: t.titleMedium),
            ),
            const SizedBox(height: Gap.sm),
            FilledButton(onPressed: _written ? () => Navigator.pop(context) : null, child: const Text('Continue')),
          ],
        ),
      ),
    );
  }
}

/// "Forgot PIN?" flow on the lock screen: recovery code, then a new PIN.
/// Returns true when the PIN was reset (the app is then unlocked).
Future<bool> showForgotPin(BuildContext context, WidgetRef ref) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _ForgotPinSheet(),
  );
  return ok ?? false;
}

class _ForgotPinSheet extends ConsumerStatefulWidget {
  const _ForgotPinSheet();

  @override
  ConsumerState<_ForgotPinSheet> createState() => _ForgotPinSheetState();
}

class _ForgotPinSheetState extends ConsumerState<_ForgotPinSheet> {
  final _code = TextEditingController();
  String? _codeError;
  String? _first;
  String? _pinError;
  bool _codeEntered = false;
  bool _busy = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _onPin(String pin) async {
    if (_first == null) {
      final e = AuthService.validatePin(pin);
      setState(() {
        _pinError = e;
        if (e == null) _first = pin;
      });
      return;
    }
    if (pin != _first) {
      setState(() {
        _first = null;
        _pinError = 'PINs did not match. Enter the new PIN again.';
      });
      return;
    }
    setState(() => _busy = true);
    final result = await ref.read(authServiceProvider).resetPinWithRecoveryCode(_code.text, pin);
    if (!mounted) return;
    switch (result) {
      case PinOk():
        Navigator.pop(context, true);
      case PinWrong(:final attemptsLeft):
        setState(() {
          _busy = false;
          _first = null;
          _codeEntered = false;
          _codeError = 'That recovery code is not correct · $attemptsLeft tries left';
        });
      case PinLockedOut():
        setState(() {
          _busy = false;
          _first = null;
          _codeEntered = false;
          _codeError = 'Too many tries. Wait 30 seconds and try again.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _codeEntered ? (_first == null ? 'Choose a new PIN' : 'Enter the new PIN again') : 'Forgot your PIN?',
              style: t.headlineSmall,
            ),
            const SizedBox(height: Gap.sm),
            if (!_codeEntered) ...[
              Text(
                'Type the recovery code you wrote down when you set up the app.',
                style: t.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: Gap.lg),
              TextField(
                controller: _code,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                style: AppTheme.figure(22).copyWith(letterSpacing: 1.5),
                decoration: InputDecoration(hintText: 'XXXX-XXXX-XXXX', errorText: _codeError),
              ),
              const SizedBox(height: Gap.lg),
              FilledButton(
                onPressed: () {
                  if (AuthService.normalizeRecoveryCode(_code.text).length != 12) {
                    setState(() => _codeError = 'The code has 12 letters and numbers');
                    return;
                  }
                  setState(() {
                    _codeError = null;
                    _codeEntered = true;
                  });
                },
                child: const Text('Next'),
              ),
              const SizedBox(height: Gap.md),
              Text(
                'Lost the code? Your data can still be restored from a backup after reinstalling the app.',
                style: t.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ] else
              Center(
                child: PinPad(length: AuthService.pinLength, busy: _busy, errorText: _pinError, onCompleted: _onPin),
              ),
          ],
        ),
      ),
    );
  }
}

/// Creates a new recovery code from Settings (after the PIN is confirmed).
Future<void> regenerateRecoveryCode(BuildContext context, WidgetRef ref) async {
  final code = await ref.read(authServiceProvider).createRecoveryCode();
  if (!context.mounted) return;
  await showRecoveryCode(context, ref, code);
  if (context.mounted) showAppSnack(context, 'New recovery code saved. The old one no longer works.');
}
