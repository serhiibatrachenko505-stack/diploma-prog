import '../db/app_db.dart';

/// Represents a vitamin value linked to a specific food item.
///
/// Stores the vitamin identifier, vitamin name, and the amount
/// of the vitamin per 100 grams of food.
class VitaminInFood {
  /// Identifier of the vitamin.
  final int vitaminId;
  /// Name of the vitamin.
  final String vitaminName;
  /// Amount of the vitamin per 100 grams of food.
  final double amountPer100g;

  /// Creates a vitamin-in-food record.
  const VitaminInFood({
    required this.vitaminId,
    required this.vitaminName,
    required this.amountPer100g,
  });

  /// Creates a [VitaminInFood] object from a database map representation.
  factory VitaminInFood.fromMap(Map<String, Object?> map) {
    return VitaminInFood(
        vitaminId: (map['vitamin_id'] as num).toInt(),
        vitaminName: map['vitamin_name'] as String,
        amountPer100g: (map['amount_per_100g'] as num).toDouble(),
    );
  }
}

/// Provides access to vitamin-to-food relationship data.
///
/// This class loads vitamin values assigned to foods and is used
/// by vitamin calculation services to aggregate vitamin amounts.
class VitFoodDao {
  /// Returns all vitamin values linked to the specified [foodId].
  ///
  /// Each result item contains the vitamin identifier, name,
  /// and amount per 100 grams of the selected food.
  Future<List<VitaminInFood>> getVitaminsForFood(int foodId) async {
    final db = await AppDb.instance.db;

    final rows = await db.rawQuery('''
      SELECT
        v.id   AS vitamin_id,
        v.name AS vitamin_name,
        vf.amount_per_100g
      FROM vit_food vf
      JOIN vitamins v ON v.id = vf.vitamin_id
      WHERE vf.food_id = ?
      ORDER BY v.name ASC
    ''', [foodId]);

    return rows.map((r) => VitaminInFood.fromMap(r)).toList();
  }

  /// Returns vitamin data for all foods whose identifiers are in [foodIds].
  ///
  /// The result contains raw joined rows with food identifiers,
  /// vitamin identifiers, vitamin names, and amounts per 100 grams.
  ///
  /// If [foodIds] is empty, an empty list is returned.
  Future<List<Map<String, Object?>>> getVitaminsForFoods(List<int> foodIds)
  async {
    if (foodIds.isEmpty) return [];

    final db = await AppDb.instance.db;
    final placeholders = List.filled(foodIds.length, '?').join(',');

    final rows = await db.rawQuery('''
      SELECT
        vf.food_id AS food_id,
        v.id       AS vitamin_id,
        v.name     AS vitamin_name,
        vf.amount_per_100g
      FROM vit_food vf
      JOIN vitamins v ON v.id = vf.vitamin_id
      WHERE vf.food_id IN ($placeholders)
      ORDER BY vf.food_id ASC, v.name ASC
    ''', foodIds);

    return rows;
  }
}