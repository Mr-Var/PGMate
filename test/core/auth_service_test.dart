import 'package:flutter_test/flutter_test.dart';
import 'package:pg_manager/core/services/auth_service.dart';
import 'package:pg_manager/core/services/pin_hasher.dart';

void main() {
  late MemorySecureStore store;
  late AuthService auth;

  setUp(() {
    store = MemorySecureStore();
    auth = AuthService(store: store, iterations: 1000);
  });

  test('PBKDF2 is deterministic per salt and differs across salts', () {
    final salt = PinHasher.newSalt();
    expect(PinHasher.hashSync('2580', salt, iterations: 1000), PinHasher.hashSync('2580', salt, iterations: 1000));
    expect(
      PinHasher.hashSync('2580', salt, iterations: 1000),
      isNot(PinHasher.hashSync('2580', PinHasher.newSalt(), iterations: 1000)),
    );
  });

  test('PIN is never stored in plain text', () async {
    await auth.setPin('2580');
    expect(store.data.values.any((v) => v.contains('2580')), isFalse);
    expect(await auth.hasPin(), isTrue);
  });

  test('rejects weak PINs', () {
    expect(AuthService.validatePin('1111'), isNotNull);
    expect(AuthService.validatePin('1234'), isNotNull);
    expect(AuthService.validatePin('123'), isNotNull);
    expect(AuthService.validatePin('2580'), isNull);
  });

  test('verifies correct PIN and counts wrong attempts', () async {
    await auth.setPin('2580');
    expect(await auth.verifyPin('2580'), isA<PinOk>());
    final wrong = await auth.verifyPin('0000');
    expect(wrong, isA<PinWrong>());
    expect((wrong as PinWrong).attemptsLeft, AuthService.maxAttempts - 1);
  });

  test('locks out after too many attempts, even for the correct PIN', () async {
    await auth.setPin('2580');
    PinCheck last = const PinOk();
    for (var i = 0; i < AuthService.maxAttempts; i++) {
      last = await auth.verifyPin('9999');
    }
    expect(last, isA<PinLockedOut>());
    expect(await auth.verifyPin('2580'), isA<PinLockedOut>());
  });
}
