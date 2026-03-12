import '../db/app_db.dart';
import 'package:diploma_work_prog/models/food.dart';

class FoodDao {
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