import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';
import 'pin_pad.dart';

/// Asks the owner for their PIN before a sensitive action.
/// Returns true only when the correct PIN was entered.
Future<bool> requireOwnerPin(
  BuildContext context,
  WidgetRef ref, {
  String title = 'Confirm with PIN',
  required String message,
}) {
  final auth = ref.read(authServiceProvider);
  return confirmOwnerPin(
    context,
    title: title,
    message: message,
    length: AuthService.pinLength,
    verify: (pin) async => switch (await auth.verifyPin(pin)) {
      PinOk() => true,
      PinWrong() => false,
      PinLockedOut() => null,
    },
  );
}
