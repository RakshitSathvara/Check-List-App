
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

// Sample users for testing
List<User> getDummyUsers() {
  return [
    // Shift Incharges
    User(
      id: 'si001',
      username: 'incharge1',
      password: 'password',
      name: 'Rajesh Kumar',
      role: UserRole.shiftIncharge,
      department: 'Rolling',
    ),
    User(
      id: 'si002',
      username: 'incharge2',
      password: 'password',
      name: 'Vijay Singh',
      role: UserRole.shiftIncharge,
      department: 'Furnace',
    ),
    
    // HODs
    User(
      id: 'hod001',
      username: 'hod1',
      password: 'password',
      name: 'Sunil Sharma',
      role: UserRole.hod,
      department: 'Rolling',
    ),
    User(
      id: 'hod002',
      username: 'hod2',
      password: 'password',
      name: 'Anil Patel',
      role: UserRole.hod,
      department: 'Furnace',
    ),
    
    // Plant Head
    User(
      id: 'ph001',
      username: 'planthead',
      password: 'password',
      name: 'Rakesh Verma',
      role: UserRole.plantHead,
      department: 'All',
    ),
  ];
}