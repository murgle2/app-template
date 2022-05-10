class User {
  final int userId;
  final String email;
  final bool isActive;
  final Role role;
  final int points;
  bool usesDarkTheme;

  User(
      {required this.userId,
      required this.email,
      required this.isActive,
      required this.role,
      required this.points,
      required this.usesDarkTheme});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['id'],
        email: json['email'],
        isActive: json['is_active'],
        role: Role.values[(json['role'])],
        points: json['points'],
        usesDarkTheme: json['uses_dark_theme']);
  }
}

enum Role { base, verified, editor, admin }
