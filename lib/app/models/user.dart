enum UserRole { admin, staff }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;
  final DateTime? lastOpen;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isActive = true,
    this.lastOpen,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] == 'admin' ? UserRole.admin : UserRole.staff,
        isActive: json['is_active'] == null ? true : json['is_active'] as bool,
        lastOpen: json['last_open'] != null ? DateTime.tryParse(json['last_open'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.name,
        'is_active': isActive,
        'last_open': lastOpen?.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    bool? isActive,
    DateTime? lastOpen,
  }) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        lastOpen: lastOpen ?? this.lastOpen,
      );
}
