import 'package:check_list_app/models/user.dart';

class AuthService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<bool> login(String username, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    final users = getDummyUsers();
    
    for (var user in users) {
      if (user.username == username && user.password == password) {
        _currentUser = user;
        return true;
      }
    }
    
    return false;
  }

  static void logout() {
    _currentUser = null;
  }

  static bool get isLoggedIn => _currentUser != null;
  
  static String getRoleName(UserRole role) {
    switch (role) {
      case UserRole.shiftIncharge:
        return 'Shift Incharge';
      case UserRole.hod:
        return 'HOD';
      case UserRole.plantHead:
        return 'Plant Head';
    }
  }
}