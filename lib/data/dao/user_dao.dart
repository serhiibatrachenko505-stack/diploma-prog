import 'package:diploma_work_prog/models/user.dart';
import 'package:sqflite/sqflite.dart';

import '../db/app_db.dart';

class UserDao {
  Future<int> insertUser(UserModel user) async {
    final db = await AppDb.instance.db;

    return await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<UserModel?> findByUsernameOrEmail(String login) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
        'users',
        where: 'username = ? OR email = ?',
        whereArgs: [login, login],
        limit: 1,
    );

    if(rows.isEmpty) return null;

    return UserModel.fromMap(rows.first);
  }

  Future<bool> isUsernameTaken(String username) async {
    final db = await AppDb.instance.db;
    final rows = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<bool> isEmailTaken(String email) async {
    final db = await AppDb.instance.db;
    final rows = await db.query(
        'users',
        columns: ['id'],
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
    );

    return rows.isNotEmpty;
  }

  Future<int> setMealPlan(int userId, int? mealPlanId) async {
    final db = await AppDb.instance.db;

    return db.update(
        'users',
        {'meal_plan_id': mealPlanId},
        where: 'id = ?',
        whereArgs: [userId],
    );
  }

  Future<UserModel?> getById(int userId) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
    );

    if(rows.isEmpty) {
      return null;
    }
    
    return UserModel.fromMap(rows.first);
  }

  Future<UserModel> updateUserName(UserModel user, String newUserName) async {
    final db = await AppDb.instance.db;

    if (user.id == null) {
      throw StateError('Cannot update username: user.id is null');
    }

    final trimmed = newUserName.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }

    if (trimmed == user.username) {
      return user;
    }

    final taken = await isUsernameTaken(trimmed);
    if (taken) {
      throw StateError('Username is already taken');
    }

    await db.update(
      'users',
      {'username': trimmed},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return user.copyWith(username: trimmed);
  }


  Future<UserModel> updateFullName(UserModel user, String newFullName) async {
    final db = await AppDb.instance.db;

    if (user.id == null) {
      throw StateError('Cannot update full name: user.id is null');
    }

    final trimmed = newFullName.trim();
    final valueToStore = trimmed.isEmpty ? null : trimmed;

    await db.update(
      'users',
      {'full_name': valueToStore},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    if (valueToStore == null) {
      return user.copyWith(fullNameToNull: true);
    }
    return user.copyWith(fullName: valueToStore);
  }

  Future<int> updatePassword(
      int userId, String newPasswordHash, String newSalt) async {
    final db = await AppDb.instance.db;

    return db.update(
      'users',
      {
        'password_hash': newPasswordHash,
        'password_salt': newSalt,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<UserModel> updateEmail(UserModel user, String newEmail) async {
    final db = await AppDb.instance.db;

    if (user.id == null) {
      throw StateError('Cannot update email: user.id is null');
    }

    final trimmed = newEmail.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }

    if (trimmed == user.email) {
      return user;
    }

    final taken = await isEmailTaken(trimmed);
    if (taken) {
      throw StateError('Email is already taken');
    }

    await db.update(
      'users',
      {'email': trimmed},
      where: 'id = ?',
      whereArgs: [user.id],
    );

    return user.copyWith(email: trimmed);
  }
}