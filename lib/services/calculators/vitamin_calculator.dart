import 'package:diploma_work_prog/data/dao/vit_food_dao.dart';
import 'package:diploma_work_prog/models/portion.dart';

/// Stores the aggregated vitamin calculation result for daily mode.
///
/// The [mg] map contains total vitamin amounts in milligrams,
/// while [percent] contains the percentage share of each vitamin
/// in the total calculated amount.
class VitaminDayResult {
  /// Total vitamin amounts in milligrams.
  final Map<String, double> mg;
  /// Percentage share of each vitamin in the total calculated amount.
  final Map<String, double> percent;

  /// Creates a daily vitamin result with total amounts and percentage shares.
  const VitaminDayResult({required this.mg, required this.percent});
}

/// Calculates vitamin values for a single food or for a full list of portions.
///
/// Uses [VitFoodDao] to load vitamin-to-food relations and converts
/// values per 100 grams into result values for actual portion sizes.
class VitaminCalculator {
  /// Data access object used to load vitamin-to-food relations.
  final VitFoodDao dao;

  /// Creates a calculator that uses the provided [VitFoodDao]
  /// to access vitamin data.
  const VitaminCalculator(this.dao);

  /// Calculates vitamin amounts for a single food portion.
  ///
  /// Returns a map where the key is the vitamin name and the value
  /// is the calculated amount in milligrams for the specified [grams].
  ///
  /// Throws an [ArgumentError] if [grams] is not greater than zero.
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

  /// Calculates total vitamin amounts for the provided list of [portions].
  ///
  /// The method groups grams by food identifier, loads vitamin data for all
  /// involved foods, calculates total milligrams for each vitamin, and then
  /// converts the result into percentage shares.
  ///
  /// Returns a [VitaminDayResult] containing:
  /// - [VitaminDayResult.mg] — total vitamin amounts in milligrams;
  /// - [VitaminDayResult.percent] — percentage share of each vitamin.
  ///
  /// If the input list is empty or all portions have non-positive gram values,
  /// an empty result is returned.
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

  /// Converts absolute vitamin amounts into percentage shares.
  ///
  /// Returns a map in which each vitamin amount is represented
  /// as a percentage of the total sum of all vitamin values.
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