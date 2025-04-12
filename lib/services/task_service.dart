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

  static Future<Map<String, List<Task>>> fetchOperationalTasks({int lineNumber = 1}) async {
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
            final List<dynamic> tomorrowTasksJson = responseData['tomorrow_tasks'];
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

  static Future<Map<String, List<Task>>> fetchHODTasks({required int lineId}) async {
    // Added required lineId parameter
    try {
      // *** MODIFIED URL ***: Construct the URL for fetching HOD tasks by line ID
      final url = Uri.parse('$_baseUrl/hod-tasks-by-line/$lineId');
      print('Fetching HOD tasks for line: $lineId from URL: $url'); // Log URL

      // Retrieve the authentication token
      final authToken = AuthService.authToken;
      if (authToken == null) {
        print('Authentication token not found for HOD tasks.');
        throw Exception('Not authenticated');
      }

      // Make the GET request with the authentication token
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Check API status
        if (responseData['status'] == true) {
          final Map<String, List<Task>> result = {'today': [], 'tomorrow': []};

          // Parse today's HOD tasks
          if (responseData.containsKey('today_tasks')) {
            final List<dynamic> todayTasksJson = responseData['today_tasks'];
            result['today'] = todayTasksJson.map((taskJson) {
              return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['check_points'] ?? 'N/A',
                  category: taskJson['equipment'] ?? 'N/A',
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['specification_range'] ?? '',
                  isRange: taskJson['is_range'] == 1,
                  completedAt: taskJson['completed_at'],
                  timeRemaining: '');
            }).toList();
          }

          // Parse tomorrow's HOD tasks
          if (responseData.containsKey('tomorrow_tasks')) {
            final List<dynamic> tomorrowTasksJson = responseData['tomorrow_tasks'];
            result['tomorrow'] = tomorrowTasksJson.map((taskJson) {
              return Task(
                  id: taskJson['task_id'].toString(),
                  name: taskJson['check_points'] ?? 'N/A',
                  category: taskJson['equipment'] ?? 'N/A',
                  isCompleted: taskJson['completed'] == 1,
                  specificationRange: taskJson['specification_range'] ?? '',
                  isRange: taskJson['is_range'] == 1,
                  completedAt: taskJson['completed_at'],
                  timeRemaining: '');
            }).toList();
          }

          return result;
        } else {
          print('API returned status false for HOD tasks: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to load HOD tasks');
        }
      } else {
        print('Failed to load HOD tasks. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load HOD tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching HOD tasks: $e');
      return {'today': [], 'tomorrow': []}; // Fallback
    }
  }

  // Method to update task status
  // Updated method for TaskService class
  static Future<bool> updateTaskStatus(
    String taskId,
    bool isCompleted, {
    String? value,
    String? remark,
    int? lineId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/task/update-status');

      // Get the auth token from AuthService
      final authToken = AuthService.authToken;
      if (authToken == null) {
        throw Exception('Not authenticated');
      }

      // Convert boolean to int (0 or 1)
      final status = isCompleted ? 1 : 0;

      // Create a multipart request for form-data
      final request = http.MultipartRequest('POST', url);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $authToken';

      // Add form fields
      request.fields['task_id'] = taskId;
      request.fields['status'] = status.toString();
      request.fields['value'] = value ?? '';
      request.fields['remark'] = remark ?? '';
      if (lineId != null) {
        request.fields['line_id'] = lineId.toString();
      }

      print('Sending form data: ${request.fields}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

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

  static Future<Map<String, List<Task>>> fetchMaintenanceTasks({int lineNumber = 1}) async {
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

            print('Parsed ${result['today']!.length} maintenance tasks for today');
          } else {
            print('No "tasks" field found in response. Available fields: ${responseData.keys.join(', ')}');

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
              final List<dynamic> tomorrowTasksJson = responseData['tomorrow_tasks'];
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
          throw Exception(responseData['message'] ?? 'Failed to load maintenance tasks');
        }
      } else {
        throw Exception('Failed to load maintenance tasks: ${response.statusCode}');
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
  static Future<Map<String, List<Task>>> fetchHODMaintenanceTasks({required int lineId}) async { // Added required lineId parameter
    try {
      // *** MODIFIED URL ***: Construct the URL for fetching HOD maintenance tasks by line ID
      final url = Uri.parse('$_baseUrl/hod-maintenance-tasks-by-line/$lineId');
      print('Fetching HOD maintenance tasks for line: $lineId from URL: $url');

      // Retrieve authentication token
      final authToken = AuthService.authToken;
      if (authToken == null) {
        print('Authentication token not found for HOD maintenance tasks.');
        throw Exception('Not authenticated');
      }

      // Make the GET request
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      // Check for successful response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('HOD Maintenance API response: ${response.body}'); // Log the full response

        // Check API status
        if (responseData['status'] == true) {
          final Map<String, List<Task>> result = {'today': [], 'tomorrow': []};

          // Parse today's HOD maintenance tasks (assuming they are in 'today_tasks')
          if (responseData.containsKey('today_tasks')) {
            final List<dynamic> todayTasksJson = responseData['today_tasks'];
            result['today'] = todayTasksJson.map((taskJson) {
              return Task(
                id: taskJson['task_id'].toString(),
                name: taskJson['activity_name'] ?? 'N/A',
                category: "Today's Preventive/Planned Maintenance",
                timeRemaining: _formatFrequency(taskJson['frequency'] ?? ''), // Use helper
                isCompleted: taskJson['completed'] == 1,
                specificationRange: taskJson['Measurement'] ?? 'Visual',
                isRange: false,
                completedAt: taskJson['completed_at'],
              );
            }).toList();
          } else {
             print('No "today_tasks" found in HOD maintenance response.');
          }

          // Parse tomorrow's HOD maintenance tasks (assuming they are in 'tomorrow_tasks')
          if (responseData.containsKey('tomorrow_tasks')) {
            final List<dynamic> tomorrowTasksJson = responseData['tomorrow_tasks'];
            result['tomorrow'] = tomorrowTasksJson.map((taskJson) {
              return Task(
                id: taskJson['task_id'].toString(),
                name: taskJson['activity_name'] ?? 'N/A',
                category: "Next Day's Preventive/Planned Maintenance",
                timeRemaining: "1 day left", // Placeholder for tomorrow
                isCompleted: taskJson['completed'] == 1,
                specificationRange: taskJson['Measurement'] ?? 'Visual',
                isRange: false,
                completedAt: taskJson['completed_at'],
              );
            }).toList();
          } else {
            print('No "tomorrow_tasks" found in HOD maintenance response.');
          }

          return result;
        } else {
          print('API returned status false for HOD maintenance tasks: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to load HOD maintenance tasks');
        }
      } else {
        print('Failed to load HOD maintenance tasks. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load HOD maintenance tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching HOD maintenance tasks: $e');
      return {'today': [], 'tomorrow': []}; // Fallback
    }
  }

  // Updated method for TaskService class
  static Future<bool> updateMaintenanceTaskStatus(
    String taskId,
    bool isCompleted, {
    String? remarks,
    int? lineId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/maintainance_task-update-status');

      // Get the auth token from AuthService
      final authToken = AuthService.authToken;
      if (authToken == null) {
        throw Exception('Not authenticated');
      }

      // Convert boolean to int (0 or 1)
      final status = isCompleted ? 1 : 0;

      // Create a multipart request for form-data
      final request = http.MultipartRequest('POST', url);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $authToken';

      // Add form fields
      request.fields['task_id'] = taskId;
      request.fields['status'] = status.toString();
      request.fields['remarks'] = remarks ?? '';
      if (lineId != null) {
        request.fields['line_id'] = lineId.toString();
      }

      print('Sending maintenance form data: ${request.fields}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          print('Maintenance task status updated successfully: ${responseData['message']}');
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update maintenance task status');
        }
      } else {
        throw Exception('Failed to update maintenance task status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating maintenance task status: $e');
      return false;
    }
  }

  static Future<bool> sendDailyReport() async {
    try {
      final url = Uri.parse('$_baseUrl/send-daily-report');

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
          print('Daily report sent successfully: ${responseData['message']}');
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to send daily report');
        }
      } else {
        throw Exception('Failed to send daily report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending daily report: $e');
      return false;
    }
  }
}
