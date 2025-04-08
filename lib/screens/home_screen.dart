import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import '../models/task.dart';
import '../utils/responsive_utils.dart';
import '../services/task_service.dart';

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

  // Map to keep track of checked tasks
  final Map<String, bool> _checkedTasks = {};
  
  // State for API tasks
  List<Task> _todayOperationalTasks = [];
  List<Task> _tomorrowOperationalTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Set current date time with proper formatting
    _updateDateTime();
    
    // Listen to tab changes
    _tabController.addListener(_onTabChanged);

    // Initialize with dummy data first
    final operationalTasks = getDummyOperationalTasks();
    for (var task in operationalTasks) {
      _checkedTasks[task.id] = task.isCompleted;
    }
    
    // Fetch operational tasks from API when the screen loads
    _fetchOperationalTasks();
  }
  
  void _updateDateTime() {
    final now = DateTime.now();
    
    // Get the day with suffix (1st, 2nd, 3rd, etc.)
    final int day = now.day;
    final String daySuffix = _getDaySuffix(day);
    
    // Format the date as "8th April 2025 05:40"
    _currentDateTime = '$day$daySuffix ${_getMonthName(now.month)} ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
  
  void _onTabChanged() {
    if (_tabController.index == 0 && _todayOperationalTasks.isEmpty && _tomorrowOperationalTasks.isEmpty) {
      // Fetch operational tasks when operational tab is selected
      _fetchOperationalTasks();
    }
    setState(() {});
  }
  
  // Fetch operational tasks from the API
  Future<void> _fetchOperationalTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final tasksMap = await TaskService.fetchOperationalTasks();
      
      // Update the task completion status in _checkedTasks
      for (var task in [...tasksMap['today']!, ...tasksMap['tomorrow']!]) {
        if (!_checkedTasks.containsKey(task.id)) {
          _checkedTasks[task.id] = task.isCompleted;
        }
      }
      
      setState(() {
        _todayOperationalTasks = tasksMap['today']!;
        _tomorrowOperationalTasks = tasksMap['tomorrow']!;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tasks: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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

            // Date Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              color: const Color(0xFFE7DEF6),
              child: Center(
                child: Text(
                  _currentDateTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                  ),
                ),
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
                              child: Icon(Icons.check, size: isTablet ? 20 : 16),
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
                              child: Icon(Icons.check, size: isTablet ? 20 : 16),
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
                                    fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF673AB7),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildOperationalDueTasksView(),
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
                                    fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
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
                            ? _buildOperationalDueTasksView()
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

          // Page Title
          Text(
            'Rolling - Shift B',
            style: TextStyle(
              fontSize: isTablet ? 18.0 : 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Profile Icon
          CircleAvatar(
            backgroundColor: Colors.grey,
            radius: isTablet ? 18.0 : 14.0,
            child: Icon(
              Icons.person,
              size: isTablet ? 20.0 : 16.0,
              color: Colors.white,
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

  // Operational Due Tasks
  Widget _buildOperationalDueTasksView() {
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
          
          // Today's tasks or dummy data if no tasks available
          _buildTasksSection(_todayOperationalTasks.isNotEmpty 
              ? _todayOperationalTasks 
              : getDummyOperationalTasks()),
          
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
          
          // Tomorrow's tasks
          _buildTasksSection(_tomorrowOperationalTasks),
          
          // Add some padding at the bottom
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  // Helper method to build task sections
  Widget _buildTasksSection(List<Task> tasks) {
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
                bottom: 4
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: const Color(0xFFCAB3AC), // Soft brownish color for category
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 16),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Tasks in this category
            ...categoryTasks.map((task) => _buildDueTaskItem(task)),
          ],
        );
      }).toList(),
    );
  }

  // Due Task Item
  Widget _buildDueTaskItem(Task task) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    bool isChecked = _checkedTasks[task.id] ?? false;
    final bool isTimeWarning = task.timeRemaining.contains('hour') ||
        task.timeRemaining.contains('mins');

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
            // Checkbox
            GestureDetector(
              onTap: () {
                setState(() {
                  _checkedTasks[task.id] = !isChecked;
                });

                // Show notification when task is checked
                if (_checkedTasks[task.id] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Task "${task.name}" marked as completed'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12, top: 2),
                height: isTablet ? 28.0 : 24.0,
                width: isTablet ? 28.0 : 24.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isChecked
                    ? Icon(
                        Icons.check,
                        color: Colors.grey[600],
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
                  if (task.timeRemaining.isNotEmpty)
                    Text(
                      task.timeRemaining,
                      style: TextStyle(
                        fontSize: isTablet ? 16.0 : 14.0,
                        color: isTimeWarning
                            ? const Color(0xFFE53935)
                            : Colors.grey[600],
                        fontWeight:
                            isTimeWarning ? FontWeight.bold : FontWeight.normal,
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
    // Get completed tasks from dummy data
    final completedTasks = getCompletedOperationalTasks();
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: isTablet ? 16.0 : 8.0,
              bottom: isTablet ? 16.0 : 8.0
            ),
            child: Text(
              "COMPLETED",
              style: TextStyle(
                color: const Color(0xFFBDBDBD),
                fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...completedTasks
              .map((task) => _buildCompletedTaskItem(task))
              .toList(),
        ],
      ),
    );
  }

  // Completed Task Item
  Widget _buildCompletedTaskItem(Task task) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    
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
            // Completed checkbox
            Container(
              margin: const EdgeInsets.only(right: 12),
              height: isTablet ? 24.0 : 20.0,
              width: isTablet ? 24.0 : 20.0,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: isTablet ? 20.0 : 16.0,
              ),
            ),

            // Task name
            Expanded(
              child: Text(
                task.name,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Header (HMI, BLOWER, etc.)
  Widget _buildCategoryHeader(String title) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 8.0 : 6.0,
        horizontal: isTablet ? 12.0 : 8.0,
      ),
      margin: EdgeInsets.only(
        top: isTablet ? 24.0 : 16.0,
        bottom: isTablet ? 12.0 : 8.0,
      ),
      color: const Color(0xFFF5F5F5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
          color: const Color(0xFF9E9E9E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Maintenance Due Tasks
  Widget _buildMaintenanceDueTasksView() {
    // Get maintenance tasks from dummy data
    final tasks = getDummyMaintenanceTasks();
    final bool isTablet = ResponsiveUtils.isTablet(context);

    // Group tasks by category
    Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedTasks.entries.map((entry) {
          final category = entry.key;
          final categoryTasks = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Maintenance category header
              _buildMaintenanceHeader(category),

              // Tasks in this category
              ...categoryTasks.map((task) => _buildDueTaskItem(task)).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }

  // Maintenance Completed Tasks
  Widget _buildMaintenanceCompletedTasksView() {
    // Get completed maintenance tasks from dummy data
    final completedTasks = getCompletedMaintenanceTasks();
    final bool isTablet = ResponsiveUtils.isTablet(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: isTablet ? 16.0 : 8.0,
              bottom: isTablet ? 16.0 : 8.0
            ),
            child: Text(
              "COMPLETED",
              style: TextStyle(
                color: const Color(0xFFBDBDBD),
                fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...completedTasks
              .map((task) => _buildCompletedTaskItem(task))
              .toList(),
        ],
      ),
    );
  }

  // Maintenance Category Header with arrow
  Widget _buildMaintenanceHeader(String title) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    
    return Container(
      margin: EdgeInsets.only(
        top: isTablet ? 24.0 : 16.0,
        bottom: isTablet ? 12.0 : 8.0,
      ),
      child: Row(
        children: [
          Icon(
            Icons.list,
            size: isTablet ? 24.0 : 20.0,
            color: Colors.grey,
          ),
          SizedBox(width: isTablet ? 12.0 : 8.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveUtils.getScaledFontSize(context, 14),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: isTablet ? 20.0 : 16.0,
            color: Colors.grey,
          ),
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