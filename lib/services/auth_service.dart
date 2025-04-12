import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:check_list_app/models/user.dart';

class AuthService {
  static User? _currentUser;
  static String? _authToken;
  static Map<String, dynamic>? _currentShift;
  static const String _baseUrl = "https://vishakha.roblinx.com/api";

  static User? get currentUser => _currentUser;
  static String? get authToken => _authToken;
  static Map<String, dynamic>? get currentShift => _currentShift;

  static Future<bool> login(String username, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login');

      // Create a multipart request
      final request = http.MultipartRequest('POST', url);

      // Add form fields
      request.fields['user_name'] = username;
      request.fields['password'] = password;

      // Send the request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = json.decode(responseString);

      if (response.statusCode == 200 && responseData['status'] == true) {
        // Save auth token
        _authToken = responseData['token'];

        // Save user data
        final userData = responseData['user'];
        _currentUser = User(
          id: userData['id'].toString(),
          username: userData['user_name'],
          name: userData['name'],
          role: _mapStringToUserRole(userData['role']),
          // Parse department if available or leave empty
          department: userData['department'] ?? '',
          password: '',
        );

        // Save current shift information
        _currentShift = responseData['current_shift'];

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static void logout() {
    _currentUser = null;
    _authToken = null;
    _currentShift = null;
  }

  static bool get isLoggedIn => _currentUser != null && _authToken != null;

  static UserRole _mapStringToUserRole(String roleString) {
    // Map the role string from API to UserRole enum
    switch (roleString.toLowerCase()) {
      case 'ship incharge':
        return UserRole.shiftIncharge;
      case 'shift incharge':
        return UserRole.shiftIncharge;
      case 'hod':
        return UserRole.hod;
      case 'plant head':
        return UserRole.plantHead;
      default:
        return UserRole.shiftIncharge; // Default fallback
    }
  }

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

  // Helper method to get department name based on user role
  static String getDepartmentName() {
    if (_currentUser != null) {
      if (_currentUser!.department.isNotEmpty) {
        return _currentUser!.department;
      }

      switch (_currentUser!.role) {
        case UserRole.hod:
          return 'Department';
        case UserRole.shiftIncharge:
          return 'Production';
        case UserRole.plantHead:
          return 'All Departments';
      }
    }
    return 'Department';
  }

  // Helper method to get shift information as a formatted string
  static String getShiftInfo() {
    if (_currentShift != null) {
      final name = _currentShift!['name'] as String? ?? 'Shift';
      final shortName = _currentShift!['shortName'] as String? ?? '';

      return "$name ${shortName.isNotEmpty ? '- $shortName' : ''}";
    }
    return 'Shift';
  }
}
