import 'package:diploma_work_prog/models/vitamin.dart';

import '../db/app_db.dart';

/// Provides database access methods for [Vitamin] records.
///
/// This class reads vitamin reference data from the local SQLite
/// database and converts database rows into [Vitamin] objects.
class VitaminDao {
  /// Returns all vitamins ordered by name.
  ///
  /// Optional [limit] and [offset] values can be used for pagination.
  Future<List<Vitamin>> getAll({int? limit, int? offset}) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'vitamins',
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );

    return rows.map((row) => Vitamin.fromMap(row)).toList();
  }

  /// Returns a single [Vitamin] by its database [id].
  ///
  /// Returns `null` if no matching vitamin is found.
  Future<Vitamin?> getById(int id) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'vitamins',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return Vitamin.fromMap(rows.first);
  }

  /// Searches vitamins by a partial name match.
  ///
  /// Returns a list of vitamins whose names contain the provided [query].
  /// The result is ordered alphabetically and limited by [limit].
  Future<List<Vitamin>> searchByName(String query, {int limit = 50}) async {
    final db = await AppDb.instance.db;

    final text = query.trim();
    if (text.isEmpty) return [];

    final rows = await db.query(
      'vitamins',
      where: 'LOWER(name) LIKE LOWER(?)',
      whereArgs: ['%$text%'],
      orderBy: 'name ASC',
      limit: limit,
    );

    return rows.map((row) => Vitamin.fromMap(row)).toList();
  }
}