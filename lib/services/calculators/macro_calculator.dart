import 'package:diploma_work_prog/data/dao/food_dao.dart';
import 'package:diploma_work_prog/models/portion.dart';

class NutritionResult {
  final double grams;
  final double kcal;
  final double proteins;
  final double fats;
  final double carbohydrates;

  const NutritionResult({
    required this.grams,
    required this.kcal,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
  });

  static const zero = NutritionResult(
    grams: 0,
    kcal: 0,
    proteins: 0,
    fats: 0,
    carbohydrates: 0,
  );
}

class NutritionCalculator {
  final FoodDao foodDao;
  const NutritionCalculator(this.foodDao);

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