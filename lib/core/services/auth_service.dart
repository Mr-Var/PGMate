import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'pin_hasher.dart';

/// Minimal key-value contract so the auth logic can be unit-tested
/// without platform channels.
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class PlatformSecureStore implements SecureStore {
  const PlatformSecureStore([this._storage = const FlutterSecureStorage()]);
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);
  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class MemorySecureStore implements SecureStore {
  final Map<String, String> data = {};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async => data[key] = value;
  @override
  Future<void> delete(String key) async => data.remove(key);
}

sealed class PinCheck {
  const PinCheck();
}

class PinOk extends PinCheck {
  const PinOk();
}

class PinWrong extends PinCheck {
  const PinWrong(this.attemptsLeft);
  final int attemptsLeft;
}

class PinLockedOut extends PinCheck {
  const PinLockedOut(this.until);
  final DateTime until;
}

class AuthService {
  AuthService({required this.store, LocalAuthentication? localAuth, this.iterations = PinHasher.defaultIterations})
      : _localAuth = localAuth ?? LocalAuthentication();

  final SecureStore store;
  final LocalAuthentication _localAuth;
  final int iterations;

  static const pinLength = 4;
  static const maxAttempts = 5;
  static const lockoutDuration = Duration(seconds: 30);

  static const _kHash = 'pin_hash';
  static const _kSalt = 'pin_salt';
  static const _kIterations = 'pin_iterations';
  static const _kFailed = 'pin_failed_attempts';
  static const _kLockedUntil = 'pin_locked_until';
  static const _kBiometric = 'biometric_enabled';

  Future<bool> hasPin() async => (await store.read(_kHash)) != null;

  static String? validatePin(String pin) {
    if (!RegExp('^\\d{$pinLength}\$').hasMatch(pin)) return 'PIN must be $pinLength digits';
    if (RegExp(r'^(\d)\1+$').hasMatch(pin)) return 'Avoid repeating the same digit';
    if ('0123456789'.contains(pin) || '9876543210'.contains(pin)) return 'Avoid sequential digits';
    return null;
  }

  Future<void> setPin(String pin) async {
    final error = validatePin(pin);
    if (error != null) throw ArgumentError(error);
    final salt = PinHasher.newSalt();
    final hash = await PinHasher.hash(pin, salt, iterations: iterations);
    await store.write(_kSalt, salt);
    await store.write(_kIterations, '$iterations');
    await store.write(_kHash, hash);
    await store.delete(_kFailed);
    await store.delete(_kLockedUntil);
  }

  Future<DateTime?> lockedUntil() async {
    final raw = await store.read(_kLockedUntil);
    if (raw == null) return null;
    final until = DateTime.fromMillisecondsSinceEpoch(int.parse(raw));
    return until.isAfter(DateTime.now()) ? until : null;
  }

  Future<PinCheck> verifyPin(String pin) async {
    final until = await lockedUntil();
    if (until != null) return PinLockedOut(until);

    final hash = await store.read(_kHash);
    final salt = await store.read(_kSalt);
    if (hash == null || salt == null) return const PinWrong(0);
    final iters = int.tryParse(await store.read(_kIterations) ?? '') ?? iterations;

    final candidate = await PinHasher.hash(pin, salt, iterations: iters);
    if (PinHasher.equals(candidate, hash)) {
      await store.delete(_kFailed);
      await store.delete(_kLockedUntil);
      return const PinOk();
    }

    final failed = (int.tryParse(await store.read(_kFailed) ?? '') ?? 0) + 1;
    if (failed >= maxAttempts) {
      final lockUntil = DateTime.now().add(lockoutDuration);
      await store.write(_kLockedUntil, '${lockUntil.millisecondsSinceEpoch}');
      await store.delete(_kFailed);
      return PinLockedOut(lockUntil);
    }
    await store.write(_kFailed, '$failed');
    return PinWrong(maxAttempts - failed);
  }

  Future<bool> isBiometricEnabled() async => (await store.read(_kBiometric)) == 'true';

  Future<void> setBiometricEnabled(bool enabled) => store.write(_kBiometric, '$enabled');

  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      final types = await _localAuth.getAvailableBiometrics();
      return types.isNotEmpty;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics(String reason) async {
    try {
      return await _localAuth.authenticate(localizedReason: reason, biometricOnly: true);
    } on PlatformException {
      return false;
    } on LocalAuthException {
      return false;
    }
  }
}
