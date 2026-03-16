/// Represents a food item with nutrition values per 100 grams.
///
/// Stores the food name and its calorie, protein, fat,
/// and carbohydrate values used in nutrition calculations.
class Food
{
  /// Unique database identifier of the food item.
  final int? id;
  /// Display name of the food item.
  final String name;
  /// Energy value in kilocalories per 100 grams.
  final double kcal;
  /// Protein amount in grams per 100 grams.
  final double proteins;
  /// Fats amount in grams per 100 grams.
  final double fats;
  /// Carbohydrates amount in grams per 100 grams.
  final double carbohydrates;

  /// Creates a food model with nutrition values per 100 grams.
  const Food({
    this.id,
    required this.name,
    required this.kcal,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
  });

  /// Converts this food object into a map suitable for database operations.
  Map<String, Object?> toMap() {
    return {
      if(id != null) 'id': id,
      'name': name,
      'kcal_per100g': kcal,
      'proteins_per100g': proteins,
      'fats_per100g': fats,
      'carbohydrates_per100g': carbohydrates,
    };
  }

  /// Creates a [Food] object from a database map representation.
  factory Food.fromMap(Map<String, Object?> map) =>
      Food(
        id: map['id'] as int,
        name: map['name'] as String,
        kcal: (map['kcal_per100g'] as num).toDouble(),
        proteins: (map['proteins_per100g'] as num).toDouble(),
        fats: (map['fats_per100g'] as num).toDouble(),
        carbohydrates: (map['carbohydrates_per100g'] as num).toDouble(),
      );
}