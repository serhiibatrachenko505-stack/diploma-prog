import 'package:diploma_work_prog/data/dao/user_dao.dart';
import 'package:diploma_work_prog/models/user.dart';
import 'package:diploma_work_prog/utils/hash_utils/pswd_hash_util.dart';

class AuthService {
  final _userDao = UserDao();

  Future<({bool ok, String? error})> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final u = username.trim();
    final e = email.trim();

    if (u.isEmpty) return (ok: false, error: 'Username cannot be empty.');
    if (e.isEmpty) return (ok: false, error: 'Email cannot be empty.');
    if (password.length < 8) {
      return (ok: false, error: 'Password must be at least 8 characters.');
    }

    if (await _userDao.isUsernameTaken(u)) {
      return (ok: false, error: 'Username has been already taken.');
    }
    if (await _userDao.isEmailTaken(e)) {
      return (ok: false, error: 'Email has been already taken.');
    }

    final pair = HashUtil.hashNewPassword(password);

    final user = UserModel(
      username: u,
      email: e,
      passwordHash: pair.hash,
      salt: pair.salt,
      createdAt: DateTime.now(),
    );

    try {
      await _userDao.insertUser(user);
      return (ok: true, error: null);
    } catch (e) {
      return (ok: false, error: 'Saving error: $e');
    }
  }

  Future<({bool ok, String? error, UserModel? user})> login({
    required String login,
    required String password
  }) async {
    final user = await _userDao.findByUsernameOrEmail(login.trim());
    if(user == null) {
      return (ok: false, error: 'User not found.', user: null);
    }

    final ok = HashUtil.verify(password, user.salt, user.passwordHash);
    if (!ok) {
      return (ok: false, error: 'Wrong password.', user: null);
    }

    return (ok: true, error: null, user: user);
  }

  Future<({bool ok, String? error, UserModel? user})> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    final user = await _userDao.getById(userId);
    if (user == null) {
      return (ok: false, error: 'User not found.', user: null);
    }

    if (newPassword != confirmNewPassword) {
      return (ok: false, error: 'Passwords do not match.', user: null);
    }
    if (newPassword.length < 8) {
      return (ok: false,
      error: 'Password must be at least 8 characters.', user: null);
    }

    final oldOk = HashUtil.verify(oldPassword, user.salt, user.passwordHash);
    if (!oldOk) {
      return (ok: false, error: 'Wrong current password.', user: null);
    }

    final pair = HashUtil.hashNewPassword(newPassword);
    final updated = await _userDao.updatePassword(userId, pair.hash, pair.salt);

    if (updated != 1) {
      return (ok: false, error: 'Password update failed.', user: null);
    }

    final updatedUser = user.copyWith(passwordHash: pair.hash, salt: pair.salt);
    return (ok: true, error: null, user: updatedUser);
  }
}