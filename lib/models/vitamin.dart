/// Represents a vitamin reference item stored in the database.
///
/// Contains the vitamin identifier and its display name.
class Vitamin {
  /// Unique database identifier of the vitamin.
  final int? id;
  /// Name of the vitamin.
  final String name;

  /// Creates a vitamin model instance.
  const Vitamin({
    this.id,
    required this.name,
  });

  /// Converts this vitamin object into a map suitable for database operations.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }

  /// Creates a [Vitamin] object from a database map representation.
  factory Vitamin.fromMap(Map<String, Object?> map) => Vitamin(
    id: (map['id'] as num?)?.toInt(),
    name: map['name'] as String,
  );
}