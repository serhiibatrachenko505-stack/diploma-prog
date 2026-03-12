import '../db/app_db.dart';

class VitaminInFood {
  final int vitaminId;
  final String vitaminName;
  final double amountPer100g;

  const VitaminInFood({
    required this.vitaminId,
    required this.vitaminName,
    required this.amountPer100g,
  });

  factory VitaminInFood.fromMap(Map<String, Object?> map) {
    return VitaminInFood(
        vitaminId: (map['vitamin_id'] as num).toInt(),
        vitaminName: map['vitamin_name'] as String,
        amountPer100g: (map['amount_per_100g'] as num).toDouble(),
    );
  }
}

class VitFoodDao {
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