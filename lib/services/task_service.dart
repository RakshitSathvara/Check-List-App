// task_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  static const String _baseUrl = "https://vishakha.roblinx.com/api";
  
  static Future<List<Task>> fetchOperationalTasks() async {
    try {
      final url = Uri.parse('$_baseUrl/shift-incharge-tasks');
      
      // Get the auth token from AuthService
      final authToken = AuthService.authToken;
      if (authToken == null) {
        throw Exception('Not authenticated');
      }
      
      // Make the GET request with the auth token
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == true) {
          final List<dynamic> tasksJson = responseData['tasks'];
          
          // Convert the JSON to Task objects
          return tasksJson.map((taskJson) {
            return Task(
              id: taskJson['task_id'].toString(),
              name: taskJson['check_points'],
              category: taskJson['equipment'],
              timeRemaining: '', // No time remaining info in API
              isCompleted: taskJson['completed'] == 1,
            );
          }).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load tasks');
        }
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching operational tasks: $e');
      // Return an empty list in case of error
      return [];
    }
  }
}