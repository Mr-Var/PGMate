import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';

enum AuthStage { loading, onboarding, locked, unlocked }

class AuthController extends Notifier<AuthStage> {
  DateTime? _backgroundedAt;

  /// Re-lock when the app has been in the background longer than this.
  static const relockAfter = Duration(minutes: 1);

  AuthService get _auth => ref.read(authServiceProvider);

  @override
  AuthStage build() {
    Future.microtask(refresh);
    return AuthStage.loading;
  }

  Future<void> refresh() async {
    final hasPin = await _auth.hasPin();
    final profile = await ref.read(databaseProvider).settingsDao.getProfile();
    if (!hasPin || profile == null) {
      state = AuthStage.onboarding;
    } else if (state != AuthStage.unlocked) {
      state = AuthStage.locked;
    }
  }

  Future<PinCheck> unlockWithPin(String pin) async {
    final result = await _auth.verifyPin(pin);
    if (result is PinOk) state = AuthStage.unlocked;
    return result;
  }

  Future<bool> unlockWithBiometrics() async {
    if (!await _auth.isBiometricEnabled()) return false;
    final ok = await _auth.authenticateWithBiometrics('Unlock PG Manager');
    if (ok) state = AuthStage.unlocked;
    return ok;
  }

  void completeOnboarding() => state = AuthStage.unlocked;

  void lock() {
    if (state == AuthStage.unlocked) state = AuthStage.locked;
  }

  void onBackground() => _backgroundedAt = DateTime.now();

  void onForeground() {
    final at = _backgroundedAt;
    _backgroundedAt = null;
    if (at != null && DateTime.now().difference(at) > relockAfter) lock();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthStage>(AuthController.new);
