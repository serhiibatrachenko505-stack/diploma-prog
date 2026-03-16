/// Represents an application user stored in the local database.
///
/// Contains authentication-related fields, profile information,
/// creation date, and an optional assigned meal plan identifier.
class UserModel{
  /// Unique database identifier of the user.
  final int? id;
  /// Unique username used for login and identification.
  final String username;
  /// User email address.
  final String email;
  /// Optional full name of the user.
  final String? fullName;
  /// Hashed password value stored in the database.
  final String passwordHash;
  /// Random salt used for password hashing.
  final String salt;
  /// Date and time when the user record was created.
  final DateTime createdAt;
  /// Optional identifier of the meal plan assigned to the user.
  final int? mealPlanId;

  /// Creates a user model instance.
  const UserModel({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.passwordHash,
    required this.salt,
    required this.createdAt,
    this.mealPlanId,
  });

  /// Converts this user model into a map suitable for database operations.
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'username': username,
    'email': email,
    'full_name': fullName,
    'password_hash': passwordHash,
    'password_salt': salt,
    'created_at': createdAt.toIso8601String(),
    'meal_plan_id': mealPlanId,
  };

  /// Creates a [UserModel] from a database map representation.
  factory UserModel.fromMap(Map<String, Object?> map) => UserModel(
    id: (map['id'] as num?)?.toInt(),
    username: map['username'] as String,
    email: map['email'] as String,
    fullName: map['full_name'] as String?,
    passwordHash: map['password_hash'] as String,
    salt: map['password_salt'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    mealPlanId: (map['meal_plan_id'] as num?)?.toInt(),
  );

  /// Returns a copy of this user with selected fields replaced.
  ///
  /// If [fullNameToNull] is `true`, the full name is explicitly reset to `null`.
  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    bool fullNameToNull = false,
    String? passwordHash,
    String? salt,
    DateTime? createdAt,
    int? mealPlanId,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullNameToNull ? null : (fullName ?? this.fullName),
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      createdAt: createdAt ?? this.createdAt,
      mealPlanId: mealPlanId ?? this.mealPlanId,
    );
  }
}