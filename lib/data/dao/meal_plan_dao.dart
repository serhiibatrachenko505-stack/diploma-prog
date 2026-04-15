import 'package:diploma_work_prog/data/db/app_db.dart';
import 'package:diploma_work_prog/models/meal_plan.dart';

/// Provides database access methods for [MealPlan] records.
///
/// This DAO is responsible for reading meal plans from the local SQLite
/// database. At the current stage the application only needs read access,
/// because plans are seeded as reference data.
class MealPlanDao {
  /// Returns all meal plans stored in the database ordered by identifier.
  Future<List<MealPlan>> getAll() async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'meal_plans',
      orderBy: 'id ASC',
    );

    return rows.map(MealPlan.fromMap).toList();
  }

  /// Returns a meal plan by its database identifier.
  ///
  /// Returns `null` if no matching plan exists.
  Future<MealPlan?> getById(int planId) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'meal_plans',
      where: 'id = ?',
      whereArgs: [planId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return MealPlan.fromMap(rows.first);
  }

  /// Finds the first meal plan whose description starts with [prefix].
  ///
  /// This is useful because seeded plans currently store both the short
  /// title and the long description inside the same `description` field,
  /// for example `Weight loss plan: ...`.
  ///
  /// Returns `null` if no matching plan exists.
  Future<MealPlan?> findByDescriptionPrefix(String prefix) async {
    final db = await AppDb.instance.db;

    final rows = await db.query(
      'meal_plans',
      where: 'description LIKE ?',
      whereArgs: ['$prefix%'],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return MealPlan.fromMap(rows.first);
  }
}