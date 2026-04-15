/// Represents a meal plan stored in the local database.
///
/// A meal plan currently contains only an identifier and a full textual
/// description. The [title] getter extracts a short user-friendly title
/// from the description when possible.
class MealPlan {
  /// Unique database identifier of the meal plan.
  final int id;

  /// Full textual description of the meal plan.
  final String description;

  /// Creates a meal plan model instance.
  const MealPlan({
    required this.id,
    required this.description,
  });

  /// Creates a [MealPlan] from a database row map.
  factory MealPlan.fromMap(Map<String, Object?> map) {
    return MealPlan(
      id: (map['id'] as num).toInt(),
      description: map['description'] as String,
    );
  }

  /// Converts this meal plan into a map representation.
  Map<String, Object?> toMap() => {
    'id': id,
    'description': description,
  };

  /// Returns a short title derived from the description.
  ///
  /// If the description starts with a prefix like
  /// `Weight loss plan: ...`, only the text before `:` is returned.
  /// Otherwise, a fallback title based on the identifier is used.
  String get title {
    final colonIndex = description.indexOf(':');

    if (colonIndex <= 0) {
      return 'Meal plan #$id';
    }

    return description.substring(0, colonIndex).trim();
  }
}