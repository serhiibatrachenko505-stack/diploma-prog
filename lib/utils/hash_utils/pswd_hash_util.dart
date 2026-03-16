import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Provides helper methods for password hashing and verification.
///
/// This utility generates random salts, creates SHA-256 password hashes,
/// and verifies plain-text passwords against stored hash values.
class HashUtil {
  static String _randomSalt([int len = 16]) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(len, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Generates a new random salt and returns the corresponding password hash.
  ///
  /// Returns a record containing:
  /// - `hash` — the generated SHA-256 hash;
  /// - `salt` — the generated random salt.
  static ({String hash, String salt}) hashNewPassword(String password) {
    final salt = _randomSalt();
    final hash = sha256.convert(utf8.encode('$salt$password')).toString();
    return (hash: hash, salt: salt);
  }

  /// Generates a SHA-256 hash for the provided [password] and [salt].
  static String hashWithSalt(String password, String salt) {
    return sha256.convert(utf8.encode('$salt$password')).toString();
  }

  /// Verifies whether the provided plain-text password matches [expectedHash]
  /// when hashed with the given [salt].
  static bool verify(String passwordPlain, String salt, String expectedHash) {
    final computed = hashWithSalt(passwordPlain, salt);
    return computed == expectedHash;
  }
}
