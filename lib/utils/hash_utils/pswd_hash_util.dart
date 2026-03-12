import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class HashUtil {
  static String _randomSalt([int len = 16]) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(len, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  static ({String hash, String salt}) hashNewPassword(String password) {
    final salt = _randomSalt();
    final hash = sha256.convert(utf8.encode('$salt$password')).toString();
    return (hash: hash, salt: salt);
  }

  static String hashWithSalt(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  static bool verify(String passwordPlain, String salt, String expectedHash) {
    final computed = hashWithSalt(passwordPlain, salt);
    return computed == expectedHash;
  }
}
