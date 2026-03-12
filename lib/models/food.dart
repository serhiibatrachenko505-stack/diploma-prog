class Food
{
  final int? id;
  final String name;
  final double kcal;
  final double proteins;
  final double fats;
  final double carbohydrates;

  const Food({
    this.id,
    required this.name,
    required this.kcal,
    required this.proteins,
    required this.fats,
    required this.carbohydrates,
  });

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