// task_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class TaskService {
  static const String _baseUrl = "https://vishakha.roblinx.com/api";

  // In lib/services/task_service.dart - fix parsing of isCompleted property
// In fetchOperationalTasks method, change the Task creation to:

  static Future<Map<String, List<Task>>> fetchOperationalTasks(
      {int lineNumber = 1}) async {
    try {
      // Updated URL with line number for line-specific tasks
      final url = Uri.parse('$_baseUrl/incharge-tasks-by-line/$lineNumber');

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
          final Map<String, List<Task>> result = {'today': [], 'tomorrow': []};

          // Parse today's tasks
          if (responseData.containsKey('today_tasks')) {
            final List<dynamic> todayTasksJson = responseData['today_tasks'];
            result['today'] = todayTasksJson.map((taskJson) {
              return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['check_points'],
                  category: taskJson['equipment'],
                  // Fix completion status parsing - in API 1 means completed
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['specification_range'] ?? '',
                  isRange: taskJson['is_range'] == 1,
                  completedAt: taskJson['completed_at'],
                  timeRemaining: '');
            }).toList();
          }

          // Parse tomorrow's tasks - if present in the API response
          if (responseData.containsKey('tomorrow_tasks')) {
            final List<dynamic> tomorrowTasksJson =
                responseData['tomorrow_tasks'];
            result['tomorrow'] = tomorrowTasksJson.map((taskJson) {
              return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['check_points'],
                  category: taskJson['equipment'],
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['specification_range'] ?? '',
                  isRange: taskJson['is_range'] == 1,
                  completedAt: taskJson['completed_at'],
                  timeRemaining: '');
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
      return {'today': [], 'tomorrow': []};
    }
  }

  // New method to fetch HOD tasks
  static Future<Map<String, List<Task>>> fetchHODTasks() async {
    try {
      final url = Uri.parse('$_baseUrl/hod-tasks');

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
          final Map<String, List<Task>> result = {'today': [], 'tomorrow': []};

          // Parse today's tasks
          if (responseData.containsKey('today_tasks')) {
            final List<dynamic> todayTasksJson = responseData['today_tasks'];
            result['today'] = todayTasksJson.map((taskJson) {
              return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['check_points'],
                  category: taskJson['equipment'],
                  // Fix completion status parsing - in API 1 means completed
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['specification_range'] ?? '',
                  isRange: taskJson['is_range'] == 1,
                  completedAt: taskJson['completed_at'],
                  timeRemaining: '');
            }).toList();
          }

          // Parse tomorrow's tasks
          if (responseData.containsKey('tomorrow_tasks')) {
            final List<dynamic> tomorrowTasksJson =
                responseData['tomorrow_tasks'];
            result['tomorrow'] = tomorrowTasksJson.map((taskJson) {
              return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['check_points'],
                  category: taskJson['equipment'],
                  // Fix completion status parsing - in API 1 means completed
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['specification_range'] ?? '',
                  isRange: taskJson['is_range'] == 1,
                  completedAt: taskJson['completed_at'],
                  timeRemaining: '');
            }).toList();
          }

          return result;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to load tasks');
        }
      } else {
        throw Exception('Failed to load HOD tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching HOD tasks: $e');
      // Return empty lists in case of error
      return {'today': [], 'tomorrow': []};
    }
  }

  // Method to update task status
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
          throw Exception(
              responseData['message'] ?? 'Failed to update task status');
        }
      } else {
        throw Exception('Failed to update task status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating task status: $e');
      return false;
    }
  }

  static Future<Map<String, List<Task>>> fetchMaintenanceTasks(
      {int lineNumber = 1}) async {
    try {
      // Updated URL with line number for line-specific maintenance tasks
      final url = Uri.parse('$_baseUrl/maintenance-tasks-by-line/$lineNumber');

      print('Fetching maintenance tasks for line: $lineNumber');
      print('URL: $url');

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
        print('Maintenance API response received for line $lineNumber');

        if (responseData['status'] == true) {
          final Map<String, List<Task>> result = {'today': [], 'tomorrow': []};

          // Check if the response has a 'tasks' field that contains the task array directly
          if (responseData.containsKey('tasks')) {
            final List<dynamic> tasksJson = responseData['tasks'];
            print('Found ${tasksJson.length} maintenance tasks in tasks array');

            // For now, we'll put all tasks in 'today' since we don't have a clear distinction
            result['today'] = tasksJson.map((taskJson) {
              return Task(
                id: taskJson['task_id'].toString(),
                name: taskJson['activity_name'],
                // Provide a proper category for UI grouping
                category: "Today's Preventive/Planned Maintenance",
                // Format the frequency to a user-friendly time remaining
                timeRemaining: _formatFrequency(taskJson['frequency'] ?? ''),
                // IMPORTANT: Fix isCompleted logic (1 means completed, 0 means not completed)
                isCompleted: taskJson['completed'] == 1,
                specificationRange: taskJson['Measurement'] ?? 'Visual',
                isRange: false,
                completedAt: taskJson['completed_at'],
              );
            }).toList();

            print(
                'Parsed ${result['today']!.length} maintenance tasks for today');
          } else {
            print(
                'No "tasks" field found in response. Available fields: ${responseData.keys.join(', ')}');

            // Try to parse using the alternative structure with today_tasks/tomorrow_tasks
            if (responseData.containsKey('today_tasks')) {
              final List<dynamic> todayTasksJson = responseData['today_tasks'];
              result['today'] = todayTasksJson.map((taskJson) {
                return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['activity_name'],
                  category: "Today's Preventive/Planned Maintenance",
                  timeRemaining: _formatFrequency(taskJson['frequency'] ?? ''),
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['Measurement'] ?? 'Visual',
                  isRange: false,
                  completedAt: taskJson['completed_at'],
                );
              }).toList();
            }

            if (responseData.containsKey('tomorrow_tasks')) {
              final List<dynamic> tomorrowTasksJson =
                  responseData['tomorrow_tasks'];
              result['tomorrow'] = tomorrowTasksJson.map((taskJson) {
                return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['activity_name'],
                  category: "Next Day's Preventive/Planned Maintenance",
                  timeRemaining: "1 day left",
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['Measurement'] ?? 'Visual',
                  isRange: false,
                  completedAt: taskJson['completed_at'],
                );
              }).toList();
            }
          }

          return result;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to load maintenance tasks');
        }
      } else {
        throw Exception(
            'Failed to load maintenance tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching maintenance tasks: $e');
      // Return empty lists in case of error
      return {'today': [], 'tomorrow': []};
    }
  }

// Helper method to format frequency string into a more user-friendly time remaining format
  static String _formatFrequency(String frequency) {
    // If frequency is empty, return empty string
    if (frequency.isEmpty) return '';

    // Format frequency based on its value
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Today';
      case 'weekly':
        return 'This week';
      case 'monthly':
        return 'This month';
      case 'quarterly':
        return 'This quarter';
      case 'yearly':
        return 'This year';
      default:
        return frequency; // Return as is if we don't recognize the format
    }
  }

// Method to fetch maintenance tasks for HOD
  static Future<Map<String, List<Task>>> fetchHODMaintenanceTasks() async {
    try {
      final url = Uri.parse('$_baseUrl/hod-maintenance-tasks');

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
        print('HOD Maintenance API response: ${response.body}'); // Debug log

        if (responseData['status'] == true) {
          final Map<String, List<Task>> result = {'today': [], 'tomorrow': []};

          // Parse today's tasks - Note: they're directly at the top level as 'today_tasks', not under 'tasks'
          if (responseData.containsKey('today_tasks')) {
            final List<dynamic> todayTasksJson = responseData['today_tasks'];
            result['today'] = todayTasksJson.map((taskJson) {
              return Task(
                id: taskJson['task_id'].toString(),
                name: taskJson['activity_name'],
                category:
                    "Today's Preventive/Planned Maintenance", // Group tasks under this category
                timeRemaining: taskJson['frequency'] ?? '',
                isCompleted: taskJson['completed'] == 1,
                specificationRange: taskJson['Measurement'] ?? 'Visual',
                isRange: false,
                completedAt: taskJson['completed_at'],
              );
            }).toList();
          }

          // Parse tomorrow's tasks - Also directly at the top level
          if (responseData.containsKey('tomorrow_tasks')) {
            final List<dynamic> tomorrowTasksJson =
                responseData['tomorrow_tasks'];
            result['tomorrow'] = tomorrowTasksJson.map((taskJson) {
              return Task(
                id: taskJson['task_id'].toString(),
                name: taskJson['activity_name'],
                category:
                    "Next Day's Preventive/Planned Maintenance", // Group tasks under this category
                timeRemaining:
                    "1 day left", // Always show as "1 day left" for tomorrow's tasks
                isCompleted: taskJson['completed'] == 1,
                specificationRange: taskJson['Measurement'] ?? 'Visual',
                isRange: false,
                completedAt: taskJson['completed_at'],
              );
            }).toList();
          }

          return result;
        } else {
          throw Exception(responseData['message'] ??
              'Failed to load HOD maintenance tasks');
        }
      } else {
        throw Exception(
            'Failed to load HOD maintenance tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching HOD maintenance tasks: $e');
      // Return empty lists in case of error
      return {'today': [], 'tomorrow': []};
    }
  }

  static Future<bool> updateMaintenanceTaskStatus(
      String taskId, bool isCompleted) async {
    try {
      final url = Uri.parse('$_baseUrl/maintainance_task-update-status');

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
          print(
              'Maintenance task status updated successfully: ${responseData['message']}');
          return true;
        } else {
          throw Exception(responseData['message'] ??
              'Failed to update maintenance task status');
        }
      } else {
        throw Exception(
            'Failed to update maintenance task status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating maintenance task status: $e');
      return false;
    }
  }
}
