import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dummy_data.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../utils/responsive_utils.dart';
import '../services/task_service.dart';
import '../services/auth_service.dart';
import '../utils/task_time_utils.dart';
import '../widgets/line_selection_dialog.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0; // 0 for Due Tasks, 1 for Completed Tasks
  late String _currentDateTime;
  late String _departmentName = "Department";
  late String _shiftName = "Shift";
  late String _shiftTimingDisplay = "";
  late String _userName = "User";
  late UserRole _userRole = UserRole.shiftIncharge;

  // Line selection variables
  int _selectedLineNumber = 1; // Default to Line 1
  String _selectedLineName = "Line 1"; // For display

  // Timer for updating time remaining
  Timer? _timeUpdateTimer;
  DateTime _currentTime = DateTime.now();
  String? _shiftStartTime;
  String? _shiftEndTime;

  // Map to keep track of checked tasks with section-specific keys
  final Map<String, bool> _checkedTasks = {};

  // Map to store calculated time remaining for tasks
  final Map<String, String> _taskTimeRemaining = {};

  // Set to track which tasks are currently being updated
  final Set<String> _updatingTasks = {};

  // State for API tasks - Operational
  List<Task> _todayOperationalTasks = [];
  List<Task> _tomorrowOperationalTasks = [];
  List<Task> _completedOperationalTasks = [];
  bool _isLoading = false;
  bool _isAnyOperationInProgress = false; // Track any ongoing operation
  String? _errorMessage;

  // State for API tasks - Maintenance
  List<Task> _todayMaintenanceTasks = [];
  List<Task> _tomorrowMaintenanceTasks = [];
  List<Task> _completedMaintenanceTasks = []; // For completed maintenance tasks
  bool _isMaintenanceLoading =
      false; // Separate loading state for maintenance tasks

  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set current time and update date time display
    _currentTime = DateTime.now();
    _updateDateTime();

    // Set user information from auth service
    _loadUserInfo();

    // Listen to tab changes
    _tabController.addListener(_onTabChanged);

    // Initialize with dummy data first
    final operationalTasks = getDummyOperationalTasks();
    for (var task in operationalTasks) {
      _checkedTasks[_getTaskKey(task.id, "today")] = task.isCompleted;
    }

    // Start timer to update time remaining calculations
    _startTimeUpdateTimer();

    // Show line selection dialog after a short delay
    // This allows the screen to render first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLineSelectionDialog();
    });
  }

  void _loadUserInfo() {
    final user = AuthService.currentUser;
    final shift = AuthService.currentShift;

    if (user != null) {
      setState(() {
        _userName = user.name;
        _userRole = user.role;
        _departmentName =
            user.department.isEmpty ? "Department" : user.department;
      });
    }

    if (shift != null) {
      setState(() {
        // Use shift information from login response
        final shiftName = shift['name'] as String? ?? "Shift";
        final shortName = shift['shortName'] as String? ?? "";
        _shiftName = "$shiftName ${shortName.isNotEmpty ? '- $shortName' : ''}";

        // Store shift timing for time remaining calculations
        _shiftStartTime = shift['start_time'] as String?;
        _shiftEndTime = shift['end_time'] as String?;

        // Format shift timing for display
        if (_shiftStartTime != null && _shiftEndTime != null) {
          _shiftTimingDisplay = TaskTimeUtils.getShiftTimingDisplay(
              _shiftStartTime!, _shiftEndTime!);
        }
      });
    }
  }

  // Start timer to update time remaining periodically
  void _startTimeUpdateTimer() {
    // Cancel existing timer if it exists
    _timeUpdateTimer?.cancel();

    // Update time every minute
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
        _updateDateTime();
        // Update time remaining for all tasks
        _updateTaskTimesRemaining();
      });
    });
  }

  // Update time remaining for all tasks based on current time
  void _updateTaskTimesRemaining() {
    if (_shiftEndTime == null) return;

    // Clear the map first to avoid stale data
    _taskTimeRemaining.clear();

    // Calculate time remaining for today's tasks from API
    for (var task in _todayOperationalTasks) {
      final key = _getTaskKey(task.id, 'today');
      _taskTimeRemaining[key] =
          TaskTimeUtils.calculateTimeRemaining(_currentTime, _shiftEndTime!);
    }

    // For tomorrow's tasks from API, set "1 day left"
    for (var task in _tomorrowOperationalTasks) {
      final key = _getTaskKey(task.id, 'tomorrow');
      _taskTimeRemaining[key] = "1 day left";
    }

    // Calculate time remaining for today's maintenance tasks
    for (var task in _todayMaintenanceTasks) {
      final key = _getTaskKey(task.id, 'maintenance_today');
      _taskTimeRemaining[key] =
          TaskTimeUtils.calculateTimeRemaining(_currentTime, _shiftEndTime!);
    }

    // For tomorrow's maintenance tasks, set "1 day left"
    for (var task in _tomorrowMaintenanceTasks) {
      final key = _getTaskKey(task.id, 'maintenance_tomorrow');
      _taskTimeRemaining[key] = "1 day left";
    }
  }

  // Helper method to generate a unique key for each task
  String _getTaskKey(String taskId, String section) {
    return "$section:$taskId";
  }

  void _updateDateTime() {
    final now = _currentTime;

    // Get the day with suffix (1st, 2nd, 3rd, etc.)
    final int day = now.day;
    final String daySuffix = _getDaySuffix(day);

    // Format the date as "8th April 2025 05:40"
    _currentDateTime =
        '$day$daySuffix ${_getMonthName(now.month)} ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  void _onTabChanged() {
    if (_tabController.index == 0) {
      // Operational tab selected
      if (_todayOperationalTasks.isEmpty && _tomorrowOperationalTasks.isEmpty) {
        // Fetch operational tasks if they're not loaded yet
        _fetchTasksBasedOnRole();
      }
    } else {
      // Maintenance tab selected
      if (_todayMaintenanceTasks.isEmpty && _tomorrowMaintenanceTasks.isEmpty) {
        // Fetch maintenance tasks if they're not loaded yet
        _fetchMaintenanceTasks();
      }
    }
    setState(() {});
  }

  // Method to show the line selection dialog
  Future<void> _showLineSelectionDialog() async {
    if (mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false, // User must select a line
        builder: (BuildContext dialogContext) {
          return LineSelectionDialog(
            initialLineNumber: _selectedLineNumber,
            onLineSelected: (lineNumber) {
              setState(() {
                _selectedLineNumber = lineNumber;
                _selectedLineName = "Line $lineNumber";
              });
              // Fetch tasks based on the selected line
              _fetchTasksBasedOnRole();
            },
          );
        },
      );
    }
  }

  // Method to trigger line selection change
  void _changeLine() {
    _showLineSelectionDialog();
  }

  // Fetch tasks based on user role
  Future<void> _fetchTasksBasedOnRole() async {
    // Check user role and call appropriate API
    if (_userRole == UserRole.hod) {
      await _fetchHODTasks();
    } else {
      await _fetchOperationalTasks();
    }
  }

  // Fetch HOD tasks from the API
  Future<void> _fetchHODTasks() async {
    setState(() {
      _isLoading = true;
      _isAnyOperationInProgress = true; // Set global loading state
      _errorMessage = null;
    });

    try {
      final tasksMap = await TaskService.fetchHODTasks();

      List<Task> todayTasks = [];
      List<Task> tomorrowTasks = [];
      List<Task> completedTasks = [];

      // Process today's tasks - separate completed from due tasks
      for (var task in tasksMap['today']!) {
        final key = _getTaskKey(task.id, 'today');
        _checkedTasks[key] = task.isCompleted;

        // Calculate time remaining for this task
        if (_shiftEndTime != null) {
          _taskTimeRemaining[key] = TaskTimeUtils.calculateTimeRemaining(
              _currentTime, _shiftEndTime!);
        }

        if (task.isCompleted) {
          // Add to completed tasks list
          completedTasks.add(task);
        } else {
          // Add to today's tasks list
          todayTasks.add(task);
        }
      }

      // Process tomorrow's tasks - separate completed from due tasks
      for (var task in tasksMap['tomorrow']!) {
        final key = _getTaskKey(task.id, 'tomorrow');
        _checkedTasks[key] = task.isCompleted;

        // Set "1 day left" for tomorrow's tasks
        _taskTimeRemaining[key] = "1 day left";

        if (task.isCompleted) {
          // Add to completed tasks list
          completedTasks.add(task);
        } else {
          // Add to tomorrow's tasks list
          tomorrowTasks.add(task);
        }
      }

      setState(() {
        _todayOperationalTasks = todayTasks;
        _tomorrowOperationalTasks = tomorrowTasks;
        _completedOperationalTasks =
            completedTasks; // Store completed tasks separately
        _isLoading = false;
        _isAnyOperationInProgress = false; // Clear global loading state
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load HOD tasks: $e';
        _isLoading = false;
        _isAnyOperationInProgress = false; // Clear global loading state
      });
    }
  }

  // Fetch operational tasks from the API with line number
  Future<void> _fetchOperationalTasks() async {
    setState(() {
      _isLoading = true;
      _isAnyOperationInProgress = true; // Set global loading state
      _errorMessage = null;
    });

    try {
      // Pass the selected line number to the API call
      final tasksMap = await TaskService.fetchOperationalTasks(
          lineNumber: _selectedLineNumber);

      List<Task> todayTasks = [];
      List<Task> tomorrowTasks = [];
      List<Task> completedTasks = [];

      // Process today's tasks - separate completed from due tasks
      for (var task in tasksMap['today']!) {
        final key = _getTaskKey(task.id, 'today');
        _checkedTasks[key] = task.isCompleted;

        // Calculate time remaining for this task
        if (_shiftEndTime != null) {
          _taskTimeRemaining[key] = TaskTimeUtils.calculateTimeRemaining(
              _currentTime, _shiftEndTime!);
        }

        if (task.isCompleted) {
          // Add to completed tasks list
          completedTasks.add(task);
        } else {
          // Add to today's tasks list
          todayTasks.add(task);
        }
      }

      // Process tomorrow's tasks - separate completed from due tasks
      for (var task in tasksMap['tomorrow']!) {
        final key = _getTaskKey(task.id, 'tomorrow');
        _checkedTasks[key] = task.isCompleted;

        // Set "1 day left" for tomorrow's tasks
        _taskTimeRemaining[key] = "1 day left";

        if (task.isCompleted) {
          // Add to completed tasks list
          completedTasks.add(task);
        } else {
          // Add to tomorrow's tasks list
          tomorrowTasks.add(task);
        }
      }

      setState(() {
        _todayOperationalTasks = todayTasks;
        _tomorrowOperationalTasks = tomorrowTasks;
        _completedOperationalTasks =
            completedTasks; // Store completed tasks separately
        _isLoading = false;
        _isAnyOperationInProgress = false; // Clear global loading state
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tasks: $e';
        _isLoading = false;
        _isAnyOperationInProgress = false; // Clear global loading state
      });
    }
  }

  // Fetch maintenance tasks with line number
  Future<void> _fetchMaintenanceTasks() async {
    setState(() {
      _isMaintenanceLoading = true;
      _isAnyOperationInProgress = true; // Set global loading state
      _errorMessage = null;
    });

    try {
      print(
          'Fetching maintenance tasks for user role: ${_userRole} and line: $_selectedLineNumber');

      // Call the appropriate API based on user role
      final Map<String, List<Task>> tasksMap;
      if (_userRole == UserRole.hod) {
        print('Calling HOD Maintenance API');
        tasksMap = await TaskService.fetchHODMaintenanceTasks();
      } else {
        print(
            'Calling Shift Incharge Maintenance API for line: $_selectedLineNumber');
        tasksMap = await TaskService.fetchMaintenanceTasks(
            lineNumber: _selectedLineNumber);
      }

      print(
          'Tasks received - Today: ${tasksMap['today']?.length ?? 0}, Tomorrow: ${tasksMap['tomorrow']?.length ?? 0}');

      List<Task> todayTasks = [];
      List<Task> tomorrowTasks = [];
      List<Task> completedTasks = [];

      // Process today's tasks - separate completed from due tasks
      if (tasksMap['today'] != null && tasksMap['today']!.isNotEmpty) {
        for (var task in tasksMap['today']!) {
          final key = _getTaskKey(task.id, 'maintenance_today');
          _checkedTasks[key] = task.isCompleted;

          // Calculate time remaining for this task
          if (_shiftEndTime != null) {
            _taskTimeRemaining[key] = TaskTimeUtils.calculateTimeRemaining(
                _currentTime, _shiftEndTime!);
          }

          if (task.isCompleted) {
            // Add to completed tasks list
            completedTasks.add(task);
            print('Adding completed task: ${task.name}');
          } else {
            // Add to today's tasks list
            todayTasks.add(task);
            print('Adding today\'s task: ${task.name}');
          }
        }
      } else {
        print('No today tasks found in response');
      }

      // Process tomorrow's tasks - separate completed from due tasks
      if (tasksMap['tomorrow'] != null && tasksMap['tomorrow']!.isNotEmpty) {
        for (var task in tasksMap['tomorrow']!) {
          final key = _getTaskKey(task.id, 'maintenance_tomorrow');
          _checkedTasks[key] = task.isCompleted;

          // Set "1 day left" for tomorrow's tasks
          _taskTimeRemaining[key] = "1 day left";

          if (task.isCompleted) {
            // Add to completed tasks list
            completedTasks.add(task);
            print('Adding completed task (tomorrow): ${task.name}');
          } else {
            // Add to tomorrow's tasks list
            tomorrowTasks.add(task);
            print('Adding tomorrow\'s task: ${task.name}');
          }
        }
      } else {
        print('No tomorrow tasks found in response');
      }

      print(
          'Processed tasks - Today: ${todayTasks.length}, Tomorrow: ${tomorrowTasks.length}, Completed: ${completedTasks.length}');

      setState(() {
        _todayMaintenanceTasks = todayTasks;
        _tomorrowMaintenanceTasks = tomorrowTasks;
        _completedMaintenanceTasks =
            completedTasks; // Store completed tasks separately
        _isMaintenanceLoading = false;
        _isAnyOperationInProgress = false; // Clear global loading state
        print('State updated with maintenance tasks');
      });
    } catch (e) {
      print('Error in _fetchMaintenanceTasks: $e');
      setState(() {
        _errorMessage = 'Failed to load maintenance tasks: $e';
        _isMaintenanceLoading = false;
        _isAnyOperationInProgress = false; // Clear global loading state
      });
    }
  }

  Future<void> _updateTaskCompletion(
      Task task, String section, bool isCompleted, BuildContext context) async {
    final taskKey = _getTaskKey(task.id, section);

    // For Shift Incharge role: Check if task has is_range=1 and user is trying to complete it
    if (isCompleted && task.isRange && _userRole == UserRole.shiftIncharge) {
      // Show numeric input dialog and get the value
      final numericValue = await _showNumericInputDialog(task, context);

      // If user cancelled or didn't enter a value, don't proceed with task completion
      if (numericValue == null) {
        return;
      }

      // Continue with task completion, now with the numeric value
      // In a real implementation, you'd pass this value to the API
    }

    // Start updating - show loaders
    setState(() {
      _updatingTasks.add(taskKey);
      _isAnyOperationInProgress = true; // Set global loading state
    });

    try {
      // Call the API to update the task status
      final success = await TaskService.updateTaskStatus(task.id, isCompleted);

      if (success) {
        setState(() {
          _checkedTasks[taskKey] = isCompleted;

          // Handle task movement between due and completed tasks
          if (isCompleted) {
            // Remove from the due tasks list and add to completed tasks
            if (section == 'today') {
              _todayOperationalTasks.removeWhere((t) => t.id == task.id);
              final completedTask = task.copyWith(isCompleted: true);
              _completedOperationalTasks.add(completedTask);
            } else if (section == 'tomorrow') {
              _tomorrowOperationalTasks.removeWhere((t) => t.id == task.id);
              final completedTask = task.copyWith(isCompleted: true);
              _completedOperationalTasks.add(completedTask);
            } else if (section == 'maintenance_today') {
              _todayMaintenanceTasks.removeWhere((t) => t.id == task.id);
              final completedTask = task.copyWith(isCompleted: true);
              _completedMaintenanceTasks.add(completedTask);
            } else if (section == 'maintenance_tomorrow') {
              _tomorrowMaintenanceTasks.removeWhere((t) => t.id == task.id);
              final completedTask = task.copyWith(isCompleted: true);
              _completedMaintenanceTasks.add(completedTask);
            }

            // Show notification when task is checked
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Task "${task.name}" marked as completed'),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            // Move task back to due tasks
            final uncompletedTask = task.copyWith(isCompleted: false);

            if (section.startsWith('maintenance')) {
              _completedMaintenanceTasks.removeWhere((t) => t.id == task.id);

              if (section == 'maintenance_today') {
                _todayMaintenanceTasks.add(uncompletedTask);
              } else if (section == 'maintenance_tomorrow') {
                _tomorrowMaintenanceTasks.add(uncompletedTask);
              }
            } else {
              _completedOperationalTasks.removeWhere((t) => t.id == task.id);

              if (section == 'today') {
                _todayOperationalTasks.add(uncompletedTask);
              } else if (section == 'tomorrow') {
                _tomorrowOperationalTasks.add(uncompletedTask);
              }
            }
          }
        });
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task status. Please try again.'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Show error message for exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating task: ${e.toString()}'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Stop updating - hide loaders
      if (mounted) {
        setState(() {
          _updatingTasks.remove(taskKey);
          // Only clear global loading if no tasks are being updated
          if (_updatingTasks.isEmpty) {
            _isAnyOperationInProgress = false;
          }
        });
      }
    }
  }

  // Add a new method to show the numeric input dialog
  Future<String?> _showNumericInputDialog(
      Task task, BuildContext context) async {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    // Extract min and max values from specification range if available
    String rangeText = task.specificationRange;
    String helperText = 'Enter measured value';

    if (rangeText.contains('to')) {
      final parts = rangeText.split('to');
      if (parts.length == 2) {
        String min = parts[0].trim();
        String max = parts[1].trim();
        helperText = 'Valid range: $min to $max';
      }
    }

    // Use a different approach to return the dialog result
    try {
      final result = await showDialog<String?>(
        context: context,
        barrierDismissible: false, // User must tap a button to close the dialog
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text(
              'Enter Measurement',
              style: TextStyle(
                fontSize: isTablet ? 20.0 : 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.name,
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                if (rangeText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Specification: $rangeText',
                      style: TextStyle(
                        fontSize: isTablet ? 14.0 : 12.0,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                TextField(
                  controller: textController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Measured Value',
                    helperText: helperText,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  // Input validation - only allow numbers and decimal point
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                  ],
                  autofocus: true,
                  onSubmitted: (value) {
                    // Allow pressing Enter to submit
                    if (value.isNotEmpty) {
                      Navigator.of(context).pop(value);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Return null for cancel
                },
                child: Text(
                  'CANCEL',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final value = textController.text;
                  if (value.isNotEmpty) {
                    Navigator.of(context).pop(value); // Return the input value
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  'SUBMIT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 16.0 : 14.0,
                  ),
                ),
              ),
            ],
          );
        },
      );

      return result; // This will be null if canceled or the input value if submitted
    } finally {
      // Ensure controller is disposed
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final bool isLandscape = ResponsiveUtils.isLandscape(context);

    // Determine if we should use a side-by-side layout on tablets in landscape
    final bool useSplitView = isTablet && isLandscape;

    return Scaffold(
      backgroundColor: Color(0xFFF9F5F4),
      body: SafeArea(
        child: Column(
          children: [
            // App Header
            _buildAppBar(),

            // Top loading indicator
            if (_isAnyOperationInProgress)
              Container(
                width: double.infinity,
                height: 4.0,
                color: Colors.transparent,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.purple[300]!),
                ),
              )
            else
              SizedBox(
                  height: 4.0), // Placeholder to maintain layout consistency

            // Date Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              color: const Color(0xFFE7DEF6),
              child: Column(
                children: [
                  Text(
                    _currentDateTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                    ),
                  ),
                  if (_shiftTimingDisplay.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _shiftTimingDisplay,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize:
                              ResponsiveUtils.getScaledFontSize(context, 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Tab Bar (Operational / Maintenance)
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: 8,
              ),
              height: isTablet ? 48 : 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: TabBar(
                  controller: _tabController,
                  indicator: const BoxDecoration(
                    color: Color(0xFFE7DEF6),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black,
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  labelPadding: EdgeInsets.zero,
                  labelStyle: TextStyle(
                    fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                  ),
                  tabs: [
                    Tab(
                      height: isTablet ? 48 : 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_tabController.index == 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child:
                                  Icon(Icons.check, size: isTablet ? 20 : 16),
                            ),
                          const Text('Operational'),
                        ],
                      ),
                    ),
                    Tab(
                      height: isTablet ? 48 : 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_tabController.index == 1)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child:
                                  Icon(Icons.check, size: isTablet ? 20 : 16),
                            ),
                          const Text('Maintenance'),
                        ],
                      ),
                    ),
                  ],
                  onTap: (index) {
                    setState(() {});
                  },
                ),
              ),
            ),

            // In landscape on tablet, show Due and Completed side by side
            Expanded(
              child: useSplitView
                  ? Row(
                      children: [
                        // Due Tasks (Left side)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Due Tasks',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getScaledFontSize(
                                        context, 16),
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF673AB7),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildOperationalDueTasksView(context),
                                    _buildMaintenanceDueTasksView(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Vertical divider
                        Container(
                          width: 1,
                          color: Colors.grey[300],
                        ),

                        // Completed Tasks (Right side)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Completed Tasks',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.getScaledFontSize(
                                        context, 16),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildOperationalCompletedTasksView(),
                                    _buildMaintenanceCompletedTasksView(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Operational Tab
                        _currentIndex == 0
                            ? _buildOperationalDueTasksView(context)
                            : _buildOperationalCompletedTasksView(),

                        // Maintenance Tab
                        _currentIndex == 0
                            ? _buildMaintenanceDueTasksView()
                            : _buildMaintenanceCompletedTasksView(),
                      ],
                    ),
            ),

            // Show bottom navigation only in portrait or on phones
            if (!useSplitView)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE7DEF6)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBottomNavButton(
                        title: 'Due Tasks',
                        isSelected: _currentIndex == 0,
                        onTap: () {
                          setState(() {
                            _currentIndex = 0;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildBottomNavButton(
                        title: 'Completed Tasks',
                        isSelected: _currentIndex == 1,
                        onTap: () {
                          setState(() {
                            _currentIndex = 1;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 20.0 : 16.0,
        horizontal: isTablet ? 24.0 : 16.0,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFF9F5F4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Icon
          Icon(Icons.menu, size: isTablet ? 28.0 : 24.0),

          // Page Title with Department, Shift, and Selected Line
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _departmentName,
                style: TextStyle(
                  fontSize: isTablet ? 18.0 : 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                _shiftName,
                style: TextStyle(
                  fontSize: isTablet ? 14.0 : 12.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 2),
              // Selected Line Indicator with Change Button
              GestureDetector(
                onTap: _changeLine, // Show line selection dialog on tap
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFE7DEF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedLineName,
                        style: TextStyle(
                          fontSize: isTablet ? 14.0 : 12.0,
                          color: Color(0xFF673AB7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.swap_horiz,
                        size: isTablet ? 16.0 : 14.0,
                        color: Color(0xFF673AB7),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Profile with User Name as tooltip and Role indicator
          Tooltip(
            message: "${_userName} (${AuthService.getRoleName(_userRole)})",
            child: Badge(
              isLabelVisible: _userRole != UserRole.shiftIncharge,
              backgroundColor: _userRole == UserRole.hod
                  ? Colors.purple[700]
                  : Colors.blue[700],
              label: Text(
                _userRole == UserRole.hod ? "HOD" : "PH",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                radius: isTablet ? 18.0 : 14.0,
                child: Icon(
                  Icons.person,
                  size: isTablet ? 20.0 : 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Color(0xFFFDF7FF),
        padding: EdgeInsets.symmetric(vertical: isTablet ? 16.0 : 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                color: isSelected ? const Color(0xFF673AB7) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: _getTextWidth(
                    title,
                    TextStyle(
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    )),
                height: 3,
                color: const Color(0xFF673AB7),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalDueTasksView(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display loading indicator when loading
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),

          // Display error message if there's an error
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),

          // Show HOD view-only mode info banner
          if (_userRole == UserRole.hod)
            Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      color: Colors.grey[600], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "HOD view mode: Tasks are read-only",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize:
                            ResponsiveUtils.getScaledFontSize(context, 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!_isLoading && _errorMessage == null) ...[
            // TODAY SECTION
            Padding(
              padding: EdgeInsets.only(
                top: isTablet ? 24.0 : 16.0,
                bottom: isTablet ? 12.0 : 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.today,
                    color: const Color(0xFF673AB7),
                    size: isTablet ? 24.0 : 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    "TODAY",
                    style: TextStyle(
                      color: const Color(0xFF673AB7),
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Today's tasks - no fallback to dummy data
            _todayOperationalTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "No tasks available for today",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize:
                              ResponsiveUtils.getScaledFontSize(context, 14),
                        ),
                      ),
                    ),
                  )
                : _buildTasksSection(
                    _todayOperationalTasks,
                    "today",
                  ),

            // TOMORROW SECTION
            Padding(
              padding: EdgeInsets.only(
                top: isTablet ? 32.0 : 24.0,
                bottom: isTablet ? 12.0 : 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: const Color(0xFF673AB7),
                    size: isTablet ? 24.0 : 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    "TOMORROW",
                    style: TextStyle(
                      color: const Color(0xFF673AB7),
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Tomorrow's tasks - no fallback to dummy data
            _tomorrowOperationalTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "No tasks available for tomorrow",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize:
                              ResponsiveUtils.getScaledFontSize(context, 14),
                        ),
                      ),
                    ),
                  )
                : _buildTasksSection(_tomorrowOperationalTasks, "tomorrow"),
          ],

          // Add some padding at the bottom
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  // Helper method to build task sections
  Widget _buildTasksSection(List<Task> tasks, String section) {
    // If no tasks are available, show a message
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "No tasks available",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
            ),
          ),
        ),
      );
    }

    // Group tasks by category
    Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedTasks.entries.map((entry) {
        final category = entry.key;
        final categoryTasks = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category label (HMI, BLOWER, etc.)
            Padding(
              padding: EdgeInsets.only(
                  top: ResponsiveUtils.isTablet(context) ? 16.0 : 12.0,
                  bottom: 4),
              child: Text(
                category,
                style: TextStyle(
                  color: const Color(
                      0xFFCAB3AC), // Soft brownish color for category
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Tasks in this category - pass the section parameter to each task
            ...categoryTasks.map((task) => _buildDueTaskItem(task, section)),
          ],
        );
      }).toList(),
    );
  }

  // Due Task Item with section parameter and enhanced time remaining display for all roles
  // Updated _buildDueTaskItem method in home_screen.dart
  Widget _buildDueTaskItem(Task task, String section) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final taskKey = _getTaskKey(task.id, section);
    final bool isChecked = _checkedTasks[taskKey] ?? false;
    final bool isUpdating = _updatingTasks.contains(taskKey);

    // Get time remaining from the map or use task's default value
    String timeRemaining = _taskTimeRemaining[taskKey] ?? task.timeRemaining;

    // If time remaining is still empty but task has a value, use it
    if (timeRemaining.isEmpty && task.timeRemaining.isNotEmpty) {
      timeRemaining = task.timeRemaining;
    }

    // Check if time remaining is critical (less than 1 hour or minutes left)
    final bool isTimeWarning = TaskTimeUtils.isTimeUrgent(timeRemaining);

    // Check if user is HOD (should not be able to change task status)
    final bool isHOD = _userRole == UserRole.hod;
    final bool isIncharge = _userRole == UserRole.shiftIncharge;

    // Check if this is a tomorrow task (disable for all users)
    final bool isTomorrowTask = section.contains('tomorrow');

    // Extract hours from timeRemaining if it contains "hours"
    String hoursValue = "";
    if (timeRemaining.contains("hour")) {
      final parts = timeRemaining.split(" ");
      if (parts.length > 0) {
        hoursValue = parts[0];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Small gap between items
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFEE), // Light gray background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16.0 : 12.0,
          horizontal: isTablet ? 16.0 : 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox or Loading indicator
            GestureDetector(
              onTap: isUpdating || isHOD || isTomorrowTask
                  ? null // Disable interaction while updating, for HOD users, or for tomorrow tasks
                  : () async {
                      // Toggle the status and update the task
                      await _updateTaskCompletion(
                          task, section, !isChecked, context);
                    },
              child: Container(
                margin: const EdgeInsets.only(right: 12, top: 2),
                height: isTablet ? 28.0 : 24.0,
                width: isTablet ? 28.0 : 24.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                  // Add a light gray overlay for HOD or tomorrow tasks to indicate it's disabled
                  boxShadow: isHOD || isTomorrowTask
                      ? [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                          )
                        ]
                      : null,
                ),
                child: isUpdating
                    ? SizedBox(
                        height: isTablet ? 20.0 : 16.0,
                        width: isTablet ? 20.0 : 16.0,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[400]!),
                          ),
                        ),
                      )
                    : isChecked
                        ? Icon(
                            Icons.check,
                            color: isHOD || isTomorrowTask
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            size: isTablet ? 20.0 : 16.0,
                          )
                        : null,
              ),
            ),

            // Task name and time remaining
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      fontSize: isTablet ? 18.0 : 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    timeRemaining,
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 14.0,
                      color: isTimeWarning
                          ? const Color(0xFFE53935)
                          : Colors.grey[600],
                      fontWeight:
                          isTimeWarning ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),

                  // Add indicator for tomorrow tasks (cannot be completed today)
                  if (isTomorrowTask)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Cannot be completed until tomorrow',
                        style: TextStyle(
                          fontSize: isTablet ? 12.0 : 10.0,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  // Add specification range display
                  if (task.specificationRange.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Spec: ${task.specificationRange}',
                        style: TextStyle(
                          fontSize: isTablet ? 14.0 : 12.0,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Operational Completed Tasks
  Widget _buildOperationalCompletedTasksView() {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display loading indicator when loading
          if (_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),

          if (!_isLoading) ...[
            // Header for completed tasks
            Padding(
              padding: EdgeInsets.only(
                  top: isTablet ? 16.0 : 8.0, bottom: isTablet ? 16.0 : 8.0),
              child: Text(
                "COMPLETED",
                style: TextStyle(
                  color: const Color(0xFFBDBDBD),
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // If no completed tasks, show message - no fallback to dummy data
            if (_completedOperationalTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No completed tasks yet",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                    ),
                  ),
                ),
              )
            else
              // Group tasks by category for a better organization
              _buildCompletedTasksSection(_completedOperationalTasks),
          ],
        ],
      ),
    );
  }

  // Build completed tasks section with category grouping
  Widget _buildCompletedTasksSection(List<Task> tasks) {
    // If no tasks are available, show a message
    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "No completed tasks available",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
            ),
          ),
        ),
      );
    }

    // Group tasks by category
    Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // If user is HOD, show a note about view-only mode
        if (_userRole == UserRole.hod)
          Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "HOD view mode: Tasks are read-only",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ...groupedTasks.entries.map((entry) {
          final category = entry.key;
          final categoryTasks = entry.value;

          // Skip "COMPLETED" category (for dummy data)
          if (category == 'COMPLETED') {
            return Column(
              children: categoryTasks
                  .map((task) => _buildCompletedTaskItem(task))
                  .toList(),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category label (except for 'COMPLETED')
              Padding(
                padding: EdgeInsets.only(
                    top: ResponsiveUtils.isTablet(context) ? 16.0 : 12.0,
                    bottom: 4),
                child: Text(
                  category,
                  style: TextStyle(
                    color: const Color(0xFFCAB3AC),
                    fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Tasks in this category
              ...categoryTasks.map((task) => _buildCompletedTaskItem(task)),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Completed Task Item
  Widget _buildCompletedTaskItem(Task task) {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    // Determine which section this task belongs to (today/tomorrow)
    final String section = task.id.length > 2
        ? 'completed'
        : (_todayOperationalTasks.any((t) => t.category == task.category)
            ? 'today'
            : 'tomorrow');

    final taskKey = _getTaskKey(task.id, section);
    final bool isUpdating = _updatingTasks.contains(taskKey);

    // Disable for all users - not just HODs
    final bool isDisabled = true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16.0 : 12.0,
          horizontal: isTablet ? 16.0 : 12.0,
        ),
        child: Row(
          children: [
            // Completed checkbox - disabled for all users
            Container(
              margin: const EdgeInsets.only(right: 12),
              height: isTablet ? 24.0 : 20.0,
              width: isTablet ? 24.0 : 20.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
                // Add subtle opacity to indicate it's disabled
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1,
                  )
                ],
              ),
              child: isUpdating
                  ? SizedBox(
                      height: isTablet ? 18.0 : 14.0,
                      width: isTablet ? 18.0 : 14.0,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isTablet ? 20.0 : 16.0,
                    ),
            ),

            // Task name and specification
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // Add specification range display
                  if (task.specificationRange.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Spec: ${task.specificationRange}',
                        style: TextStyle(
                          fontSize:
                              ResponsiveUtils.getScaledFontSize(context, 11),
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Maintenance Due Tasks
  Widget _buildMaintenanceDueTasksView() {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display loading indicator when loading
          if (_isMaintenanceLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),

          // Display error message if there's an error
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),

          // Show HOD view-only mode info banner
          if (_userRole == UserRole.hod)
            Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined,
                      color: Colors.grey[600], size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "HOD view mode: Tasks are read-only",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize:
                            ResponsiveUtils.getScaledFontSize(context, 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!_isMaintenanceLoading && _errorMessage == null) ...[
            // TODAY SECTION
            Padding(
              padding: EdgeInsets.only(
                top: isTablet ? 24.0 : 16.0,
                bottom: isTablet ? 12.0 : 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.today,
                    color: const Color(0xFF673AB7),
                    size: isTablet ? 24.0 : 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    "TODAY",
                    style: TextStyle(
                      color: const Color(0xFF673AB7),
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Today's maintenance tasks - no fallback to dummy data
            _todayMaintenanceTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "No maintenance tasks available for today",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize:
                              ResponsiveUtils.getScaledFontSize(context, 14),
                        ),
                      ),
                    ),
                  )
                : _buildTasksSection(
                    _todayMaintenanceTasks, "maintenance_today"),

            // TOMORROW SECTION
            Padding(
              padding: EdgeInsets.only(
                top: isTablet ? 32.0 : 24.0,
                bottom: isTablet ? 12.0 : 8.0,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: const Color(0xFF673AB7),
                    size: isTablet ? 24.0 : 20.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    "TOMORROW",
                    style: TextStyle(
                      color: const Color(0xFF673AB7),
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Tomorrow's maintenance tasks - no fallback to dummy data
            _tomorrowMaintenanceTasks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "No maintenance tasks available for tomorrow",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize:
                              ResponsiveUtils.getScaledFontSize(context, 14),
                        ),
                      ),
                    ),
                  )
                : _buildTasksSection(
                    _tomorrowMaintenanceTasks, "maintenance_tomorrow"),
          ],

          // Add some padding at the bottom
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  // Maintenance Completed Tasks
  Widget _buildMaintenanceCompletedTasksView() {
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display loading indicator when loading
          if (_isMaintenanceLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),

          if (!_isMaintenanceLoading) ...[
            Padding(
              padding: EdgeInsets.only(
                  top: isTablet ? 16.0 : 8.0, bottom: isTablet ? 16.0 : 8.0),
              child: Text(
                "COMPLETED",
                style: TextStyle(
                  color: const Color(0xFFBDBDBD),
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Show completed maintenance tasks - no fallback to dummy data
            if (_completedMaintenanceTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "No completed maintenance tasks yet",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                    ),
                  ),
                ),
              )
            else
              _buildCompletedTasksSection(_completedMaintenanceTasks),
          ],
        ],
      ),
    );
  }

  double _getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return textPainter.width;
  }
}
