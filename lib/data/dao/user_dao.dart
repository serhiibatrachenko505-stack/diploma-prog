import 'package:diploma_work_prog/models/user.dart';
import 'package:sqflite/sqflite.dart';

import '../db/app_db.dart';

/// Provides database access methods for [UserModel] records.
///
/// This class is responsible for inserting users, searching users,
/// checking uniqueness constraints, and updating user-related fields
/// in the local SQLite database.
class UserDao {
  /// Inserts a new [UserModel] into the database.
  ///
  /// Returns the identifier of the inserted row.
  Future<int> insertUser(UserModel user) async {
    final db = await AppDb.instance.db;

    return await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// Finds a user by username or email.
  ///
  /// Returns the matching [UserModel] if found, or `null` otherwise.
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

  /// Checks whether the specified [username] already exists in the database.
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

  /// Checks whether the specified [email] already exists in the database.
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

  /// Updates the meal plan assigned to the user with the given [userId].
  ///
  /// Returns the number of updated rows.
  Future<int> setMealPlan(int userId, int? mealPlanId) async {
    final db = await AppDb.instance.db;

    return db.update(
        'users',
        {'meal_plan_id': mealPlanId},
        where: 'id = ?',
        whereArgs: [userId],
    );
  }

  /// Returns a user by the given database identifier.
  ///
  /// Returns `null` if the user does not exist.
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

  /// Updates the username of the provided [user].
  ///
  /// Validates the new value, checks uniqueness, updates the database,
  /// and returns an updated [UserModel].
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

  /// Updates the full name of the provided [user].
  ///
  /// If the new value is empty after trimming, the stored full name
  /// is set to `null`. Returns an updated [UserModel].
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

  /// Updates the stored password hash and salt for the given [userId].
  ///
  /// Returns the number of updated rows.
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

  /// Updates the email address of the provided [user].
  ///
  /// Validates the new value, checks uniqueness, updates the database,
  /// and returns an updated [UserModel].
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