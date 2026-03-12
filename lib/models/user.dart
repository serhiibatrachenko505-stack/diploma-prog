class UserModel{
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String passwordHash;
  final String salt;
  final DateTime createdAt;
  final int? mealPlanId;

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