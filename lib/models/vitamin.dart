class Vitamin {
  final int? id;
  final String name;

  const Vitamin({
    this.id,
    required this.name,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  factory Vitamin.fromMap(Map<String, Object?> map) => Vitamin(
    id: (map['id'] as num?)?.toInt(),
    name: map['name'] as String,
  );
}