import 'package:diploma_work_prog/data/dao/food_dao.dart';
import 'package:diploma_work_prog/models/portion.dart';

/// Represents the aggregated nutrition values for one or more food portions.
///
/// Stores the total weight in grams together with the calculated
/// energy and macronutrient values.
class NutritionResult {
  /// Total weight of all selected portions in grams.
  final double grams;
  /// Total energy value in kilocalories.
  final double kcal;
  /// Total protein amount in grams.
  final double proteins;
  /// Total fats amount in grams.
  final double fats;
  /// Total carbohydrates amount in grams.
  final double carbohydrates;

  /// Creates a nutrition result object with total grams, calories,
  /// proteins, fats, and carbohydrates.
  const NutritionResult({
    required this.grams,
    required this.kcal,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
  });

  /// A zero-value result used when no portions are provided.
  static const zero = NutritionResult(
    grams: 0,
    kcal: 0,
    proteins: 0,
    fats: 0,
    carbohydrates: 0,
  );
}

/// Calculates total nutrition values for a list of food portions.
///
/// Uses [FoodDao] to load food data and then aggregates calories,
/// proteins, fats, and carbohydrates based on portion weight.
class NutritionCalculator {
  /// Data access object used to load food nutrition data.
  final FoodDao foodDao;

  /// Creates a calculator that uses the provided [FoodDao]
  /// to access food nutrition data.
  const NutritionCalculator(this.foodDao);

  /// Calculates total nutrition values for the provided [portions].
  ///
  /// Returns a [NutritionResult] containing the total grams, calories,
  /// proteins, fats, and carbohydrates for the full list.
  ///
  /// Returns [NutritionResult.zero] if the list is empty.
  ///
  /// Throws an [ArgumentError] if any portion has a non-positive
  /// gram value.
  Future<NutritionResult> calculate(List<Portion> portions) async {
    if (portions.isEmpty) return NutritionResult.zero;

    final gramsByFoodId = <int, double>{};
    for (final p in portions) {
      if (p.grams <= 0) {
        throw ArgumentError('Grams must be > 0 (foodId=${p.foodId})');
      }
      gramsByFoodId[p.foodId] = (gramsByFoodId[p.foodId] ?? 0) + p.grams;
    }

    final foods = await foodDao.getByIds(gramsByFoodId.keys.toList());
    final foodById = {for (final f in foods) f.id!: f};

    double totalGrams = 0, totalKcal = 0, totalP = 0, totalF = 0, totalC = 0;

    for (final entry in gramsByFoodId.entries) {
      final food = foodById[entry.key];
      if (food == null) continue;

      final grams = entry.value;
      final factor = grams / 100.0;

      totalGrams += grams;
      totalKcal += food.kcal * factor;
      totalP += food.proteins * factor;
      totalF += food.fats * factor;
      totalC += food.carbohydrates * factor;
    }

    return NutritionResult(
      grams: totalGrams,
      kcal: totalKcal,
      proteins: totalP,
      fats: totalF,
      carbohydrates: totalC,
    );
  }
}