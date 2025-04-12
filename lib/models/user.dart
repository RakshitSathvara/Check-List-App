
// models/user.dart
enum UserRole {
  shiftIncharge,
  hod,
  plantHead
}

class User {
  final String id;
  final String username;
  final String password;
  final String name;
  final UserRole role;
  final String department; // Furnace, Rolling, Annealing, Cutting, Deep Process

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.department,
  });
}