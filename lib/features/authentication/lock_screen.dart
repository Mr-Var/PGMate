import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pin_pad.dart';
import 'auth_controller.dart';
import 'recovery_widgets.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String? _error;
  bool _busy = false;
  bool _biometricEnabled = false;
  DateTime? _lockedUntil;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final auth = ref.read(authServiceProvider);
    final enabled = await auth.isBiometricEnabled() && await auth.canUseBiometrics();
    final until = await auth.lockedUntil();
    if (!mounted) return;
    setState(() => _biometricEnabled = enabled);
    if (until != null) _startLockout(until);
    if (enabled && until == null) _biometric();
  }

  void _startLockout(DateTime until) {
    _ticker?.cancel();
    setState(() => _lockedUntil = until);
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      if (DateTime.now().isAfter(until)) {
        t.cancel();
        setState(() {
          _lockedUntil = null;
          _error = null;
        });
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _biometric() async {
    await ref.read(authControllerProvider.notifier).unlockWithBiometrics();
  }

  Future<void> _onPin(String pin) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(authControllerProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case PinOk():
        break;
      case PinWrong(:final attemptsLeft):
        setState(() => _error = 'Incorrect PIN · $attemptsLeft ${attemptsLeft == 1 ? 'attempt' : 'attempts'} left');
      case PinLockedOut(:final until):
        _startLockout(until);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(pgProfileProvider).value;
    final t = Theme.of(context).textTheme;
    final locked = _lockedUntil;
    final secondsLeft = locked == null ? 0 : locked.difference(DateTime.now()).inSeconds + 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Gap.xl),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(Radii.lg)),
                    child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: Gap.lg),
                  Text(
                    profile?.name ?? 'PG Manager',
                    style: t.headlineSmall?.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(
                    locked != null ? 'Too many attempts. Try again in ${secondsLeft}s' : 'Enter your PIN to unlock',
                    style: t.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.78)),
                  ),
                  const SizedBox(height: Gap.xxl),
                  IgnorePointer(
                    ignoring: locked != null,
                    child: AnimatedOpacity(
                      opacity: locked != null ? 0.4 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: PinPad(
                        dark: true,
                        length: AuthService.pinLength,
                        busy: _busy,
                        errorText: _error,
                        onBiometric: _biometricEnabled ? _biometric : null,
                        onCompleted: _onPin,
                      ),
                    ),
                  ),
                  const SizedBox(height: Gap.lg),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.white.withValues(alpha: 0.85)),
                    onPressed: () async {
                      if (await showForgotPin(context, ref)) {
                        ref.read(authControllerProvider.notifier).completeOnboarding();
                      }
                    },
                    child: const Text('Forgot PIN?'),
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
