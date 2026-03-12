import 'package:diploma_work_prog/data/dao/vit_food_dao.dart';
import 'package:diploma_work_prog/models/portion.dart';

class VitaminDayResult {
  final Map<String, double> mg;
  final Map<String, double> percent;

  const VitaminDayResult({required this.mg, required this.percent});
}

class VitaminCalculator {
  final VitFoodDao dao;
  const VitaminCalculator(this.dao);

  Future<Map<String, double>> calculateForFood({
    required int foodId,
    required double grams,
  }) async {
    if (grams <= 0) throw ArgumentError('Grams must be > 0');

    final factor = grams / 100.0;
    final rows = await dao.getVitaminsForFood(foodId);

    final mg = <String, double>{};
    for (final r in rows) {
      mg[r.vitaminName] = r.amountPer100g * factor;
    }
    return mg;
  }

  Future<VitaminDayResult> calculateForList(List<Portion> portions) async {
    if (portions.isEmpty) {
      return const VitaminDayResult(mg: {}, percent: {});
    }

    final gramsByFoodId = <int, double>{};
    for (final p in portions) {
      if (p.grams <= 0) continue;
      gramsByFoodId[p.foodId] = (gramsByFoodId[p.foodId] ?? 0) + p.grams;
    }

    if (gramsByFoodId.isEmpty) {
      return const VitaminDayResult(mg: {}, percent: {});
    }

    final rows = await dao.getVitaminsForFoods(gramsByFoodId.keys.toList());

    final mg = <String, double>{};
    for (final row in rows) {
      final foodId = (row['food_id'] as num).toInt();
      final vitaminName = row['vitamin_name'] as String;
      final per100 = (row['amount_per_100g'] as num).toDouble();

      final grams = gramsByFoodId[foodId] ?? 0.0;
      final factor = grams / 100.0;

      mg[vitaminName] = (mg[vitaminName] ?? 0.0) + per100 * factor;
    }

    final percent = _toPercentShare(mg);
    return VitaminDayResult(mg: mg, percent: percent);
  }

  Map<String, double> _toPercentShare(Map<String, double> mg) {
    final sum = mg.values.fold<double>(0.0, (a, b) => a + (b.isFinite ? b : 0.0));
    final res = <String, double>{};

    if (sum <= 0) return res;

    for (final e in mg.entries) {
      res[e.key] = (e.value / sum) * 100.0;
    }
    return res;
  }
}