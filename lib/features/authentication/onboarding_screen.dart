import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/state_views.dart';
import '../settings/pg_profile_form.dart';
import 'auth_controller.dart';

enum _Step { profile, createPin, confirmPin, biometric }

/// First-run setup: PG details → create PIN → confirm PIN → biometrics.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.profile;
  String? _firstPin;
  String? _pinError;
  bool _busy = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _resumeIfProfileExists();
  }

  Future<void> _resumeIfProfileExists() async {
    final profile = await ref.read(databaseProvider).settingsDao.getProfile();
    if (profile != null && mounted) setState(() => _step = _Step.createPin);
  }

  Future<void> _saveProfile(PgProfileData d) async {
    await ref.read(databaseProvider).settingsDao.saveProfile(
          name: d.name,
          address: d.address,
          ownerName: d.ownerName,
          ownerPhone: d.ownerPhone,
          upiId: d.upiId,
          defaultRentDueDay: d.rentDueDay,
        );
    if (mounted) setState(() => _step = _Step.createPin);
  }

  Future<void> _onPin(String pin) async {
    final auth = ref.read(authServiceProvider);
    if (_step == _Step.createPin) {
      final error = AuthService.validatePin(pin);
      if (error != null) {
        setState(() => _pinError = error);
        return;
      }
      setState(() {
        _firstPin = pin;
        _pinError = null;
        _step = _Step.confirmPin;
      });
      return;
    }
    if (pin != _firstPin) {
      setState(() {
        _pinError = 'PINs did not match. Start again.';
        _firstPin = null;
        _step = _Step.createPin;
      });
      return;
    }
    setState(() => _busy = true);
    await auth.setPin(pin);
    final canBio = await auth.canUseBiometrics();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _biometricAvailable = canBio;
      _step = canBio ? _Step.biometric : _step;
    });
    if (!canBio) _finish();
  }

  Future<void> _finish({bool enableBiometric = false}) async {
    final auth = ref.read(authServiceProvider);
    if (enableBiometric) {
      final ok = await auth.authenticateWithBiometrics('Confirm fingerprint to enable biometric unlock');
      await auth.setBiometricEnabled(ok);
      if (!ok && mounted) showAppSnack(context, 'Biometric unlock not enabled. You can turn it on in Settings.');
    }
    await ref.read(databaseProvider).settingsDao.log('auth', null, 'pin_created');
    ref.read(authControllerProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stepIndex = _step.index.clamp(0, 2);
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_step) {
            _Step.profile => ListView(
                key: const ValueKey('profile'),
                padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xl, Gap.xl, Gap.xxl),
                children: [
                  _Progress(step: stepIndex),
                  const SizedBox(height: Gap.xl),
                  const _BrandMark(),
                  const SizedBox(height: Gap.lg),
                  Text('Set up your PG', style: t.headlineMedium),
                  const SizedBox(height: Gap.xs),
                  Text(
                    'These details appear on receipts and reports. Everything is stored only on this phone.',
                    style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: Gap.xl),
                  PgProfileForm(submitLabel: 'Continue', onSubmit: _saveProfile),
                ],
              ),
            _Step.createPin || _Step.confirmPin => _PinStep(
                key: ValueKey(_step),
                progress: _Progress(step: stepIndex),
                title: _step == _Step.createPin ? 'Create your PIN' : 'Confirm your PIN',
                subtitle: _step == _Step.createPin
                    ? 'Choose a ${AuthService.pinLength}-digit PIN to protect tenant and payment data.'
                    : 'Enter the same PIN again.',
                error: _pinError,
                busy: _busy,
                onCompleted: _onPin,
              ),
            _Step.biometric => Padding(
                key: const ValueKey('bio'),
                padding: const EdgeInsets.all(Gap.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const Icon(Icons.fingerprint_rounded, size: 72, color: AppColors.primary),
                    const SizedBox(height: Gap.lg),
                    Text('Unlock faster', style: t.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: Gap.sm),
                    Text(
                      'Use your fingerprint to open PG Manager. Your PIN will still be needed for sensitive actions.',
                      style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    if (_biometricAvailable)
                      FilledButton(
                        onPressed: () => _finish(enableBiometric: true),
                        child: const Text('Enable biometric unlock'),
                      ),
                    const SizedBox(height: Gap.sm),
                    TextButton(onPressed: _finish, child: const Text('Not now')),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}

class _PinStep extends StatelessWidget {
  const _PinStep({
    super.key,
    required this.progress,
    required this.title,
    required this.subtitle,
    required this.error,
    required this.busy,
    required this.onCompleted,
  });

  final Widget progress;
  final String title;
  final String subtitle;
  final String? error;
  final bool busy;
  final Future<void> Function(String) onCompleted;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        children: [
          progress,
          const SizedBox(height: Gap.xxl),
          const Icon(Icons.lock_outline_rounded, size: 40, color: AppColors.primary),
          const SizedBox(height: Gap.lg),
          Text(title, style: t.headlineSmall),
          const SizedBox(height: Gap.sm),
          Text(subtitle, style: t.bodyMedium?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: Gap.xl),
          PinPad(length: AuthService.pinLength, errorText: error, busy: busy, onCompleted: onCompleted),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    const labels = ['PG details', 'Create PIN', 'Confirm'];
    return Semantics(
      label: 'Step ${step + 1} of 3: ${labels[step]}',
      child: Row(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (i < 2) const SizedBox(width: Gap.sm),
          ],
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(Radii.md)),
        child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
