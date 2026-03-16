/// Represents a selected food portion used in calculations.
///
/// Stores the identifier of the food item and the weight
/// of the selected portion in grams.
class Portion {
  /// Identifier of the selected food item.
  final int foodId;
  /// Weight of the selected food portion in grams.
  final double grams;
  /// Creates a portion for the given food identifier and weight in grams.
  const Portion(this.foodId, this.grams);
}