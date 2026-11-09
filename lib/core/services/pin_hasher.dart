import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// PBKDF2-HMAC-SHA256 for owner PIN storage. The plain PIN is never stored.
abstract final class PinHasher {
  static const defaultIterations = 60000;
  static const _keyLength = 32;

  static String newSalt() {
    final rnd = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => rnd.nextInt(256)));
  }

  /// Runs off the UI thread so the PIN pad never janks.
  static Future<String> hash(String pin, String salt, {int iterations = defaultIterations}) =>
      Isolate.run(() => hashSync(pin, salt, iterations: iterations));

  static String hashSync(String pin, String salt, {int iterations = defaultIterations}) {
    final hmac = Hmac(sha256, utf8.encode(pin));
    final saltBytes = base64Decode(salt);
    // Single block is enough because SHA-256 output == key length.
    var u = hmac.convert([...saltBytes, 0, 0, 0, 1]).bytes;
    final out = Uint8List.fromList(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < _keyLength; j++) {
        out[j] ^= u[j];
      }
    }
    return base64Encode(out);
  }

  /// Constant-time comparison to avoid timing leaks.
  static bool equals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
