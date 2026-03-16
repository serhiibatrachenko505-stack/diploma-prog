import 'package:diploma_work_prog/models/vitamin.dart';

import '../db/app_db.dart';

class VitaminDao {
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