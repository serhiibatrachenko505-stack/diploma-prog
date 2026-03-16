import 'package:diploma_work_prog/models/food.dart';

import '../db/app_db.dart';

/// Provides database access methods for [Food] records.
///
/// This class is responsible for reading food data from the local
/// SQLite database and converting database rows into [Food] objects.
class FoodDao {
  /// Returns all food items ordered by name.
  ///
  /// Optional [limit] and [offset] values can be used for pagination.
  Future<List<Food>> getAll({int? limit, int? offset}) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'food',
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );

    return rows.map((row) => Food.fromMap(row)).toList();
  }

  /// Searches food items by a partial name match.
  ///
  /// Returns a list of foods whose names contain the provided [query].
  /// The result is ordered alphabetically and limited by [limit].
  Future<List<Food>> searchByName(String query, {int limit = 50}) async {
    final db = await AppDb.instance.db;

    final text = query.trim();
    if (text.isEmpty) return [];

    final rows = await db.query(
      'food',
      where: 'LOWER(name) LIKE LOWER(?)',
      whereArgs: ['%$text%'],
      orderBy: 'name ASC',
      limit: limit,
    );

    return rows.map((row) => Food.fromMap(row)).toList();
  }

  /// Returns a single [Food] by its database [id].
  ///
  /// Returns `null` if no matching food item is found.
  Future<Food?> getById(int id) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'food',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return Food.fromMap(rows.first);
  }

  /// Returns all food items whose identifiers are included in [ids].
  ///
  /// If the input list is empty, an empty list is returned.
  Future<List<Food>> getByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final db = await AppDb.instance.db;
    final placeholders = List.filled(ids.length, '?').join(',');

    final rows = await db.rawQuery(
      'SELECT * FROM food WHERE id IN ($placeholders)',
      ids,
    );

    return rows.map((r) => Food.fromMap(r)).toList();
  }
}