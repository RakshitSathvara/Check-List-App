// task_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  static const String _baseUrl = "https://vishakha.roblinx.com/api";
  
  static Future<Map<String, List<Task>>> fetchOperationalTasks() async {
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
          final Map<String, List<Task>> result = {
            'today': [],
            'tomorrow': []
          };
          
          // Parse today's tasks
          if (responseData.containsKey('today_tasks')) {
            final List<dynamic> todayTasksJson = responseData['today_tasks'];
            result['today'] = todayTasksJson.map((taskJson) {
              return Task(
                id: taskJson['task_id'].toString(),
                name: taskJson['check_points'],
                category: taskJson['equipment'],
                timeRemaining: '', // No time remaining info in API
                isCompleted: taskJson['completed'] == 1,
                specificationRange: taskJson['specification_range'],
                isRange: taskJson['is_range'] == 1,
                completedAt: taskJson['completed_at'],
              );
            }).toList();
          }
          
          // Parse tomorrow's tasks
          if (responseData.containsKey('tomorrow_tasks')) {
            final List<dynamic> tomorrowTasksJson = responseData['tomorrow_tasks'];
            result['tomorrow'] = tomorrowTasksJson.map((taskJson) {
              return Task(
                id: taskJson['task_id'].toString(),
                name: taskJson['check_points'],
                category: taskJson['equipment'],
                timeRemaining: '', // No time remaining info in API
                isCompleted: taskJson['completed'] == 1,
                specificationRange: taskJson['specification_range'],
                isRange: taskJson['is_range'] == 1,
                completedAt: taskJson['completed_at'],
              );
            }).toList();
          }
          
          return result;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load tasks');
        }
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching operational tasks: $e');
      // Return empty lists in case of error
      return {
        'today': [],
        'tomorrow': []
      };
    }
  }
  
  // New method to update task status
  static Future<bool> updateTaskStatus(String taskId, bool isCompleted) async {
    try {
      final url = Uri.parse('$_baseUrl/task/update-status');
      
      // Get the auth token from AuthService
      final authToken = AuthService.authToken;
      if (authToken == null) {
        throw Exception('Not authenticated');
      }
      
      // Convert boolean to int (0 or 1)
      final status = isCompleted ? 1 : 0;
      
      // Make the POST request with the auth token
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'task_id': taskId,
          'status': status,
        }),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == true) {
          print('Task status updated successfully: ${responseData['message']}');
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update task status');
        }
      } else {
        throw Exception('Failed to update task status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating task status: $e');
      return false;
    }
  }
}