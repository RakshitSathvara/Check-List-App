import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import '../models/task.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0; // 0 for Due Tasks, 1 for Completed Tasks
  final String _currentDateTime = '3rd March 2025 05:40';

  // Map to keep track of checked tasks
  final Map<String, bool> _checkedTasks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize checked tasks from dummy data
    final operationalTasks = getDummyOperationalTasks();
    for (var task in operationalTasks) {
      _checkedTasks[task.id] = task.isCompleted;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Tab Bar (Operational / Maintenance)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 40,
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
                  tabs: [
                    Tab(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_tabController.index == 0)
                            const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(Icons.check, size: 16),
                            ),
                          const Text('Operational'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_tabController.index == 1)
                            const Padding(
                              padding: EdgeInsets.only(right: 4.0),
                              child: Icon(Icons.check, size: 16),
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

            const SizedBox(height: 8),

            const Divider(
              height: 1,
              color: Colors.grey,
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
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

            // Bottom Navigation
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFDF7FF),
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
          const Icon(Icons.menu),

          // Page Title
          const Text(
            'Rolling - Shift B',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Profile Icon
          const CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 14,
            child: Icon(
              Icons.person,
              size: 16,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Color(0XFFFDF7FF),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
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
                      fontSize: 14,
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
    // Get the tasks from dummy data
    final tasks = getDummyOperationalTasks();

    // Group tasks by category
    Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedTasks.entries.map((entry) {
          final category = entry.key;
          final categoryTasks = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category label (HMI, BLOWER, etc.)
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 4),
                child: Text(
                  category,
                  style: const TextStyle(
                    color:
                        Color(0xFFD0B0A0), // Soft brownish color for category
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              // Tasks in this category
              ...categoryTasks.map((task) => _buildDueTaskItem(task)),
            ],
          );
        }).toList(),
      ),
    );
  }

// Due Task Item
  Widget _buildDueTaskItem(Task task) {
    bool isChecked = _checkedTasks[task.id] ?? false;
    final bool isTimeWarning = task.timeRemaining.contains('hour') ||
        task.timeRemaining.contains('mins');

    return Container(
      margin: const EdgeInsets.only(bottom: 1), // Small gap between items
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFEE), // Light gray background
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (task.timeRemaining.isNotEmpty)
                    Text(
                      task.timeRemaining,
                      style: TextStyle(
                        fontSize: 14,
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

// Operational Completed Tasks with proper background
  Widget _buildOperationalCompletedTasksView() {
    // Get completed tasks from dummy data
    final completedTasks = getCompletedOperationalTasks();

    return Container(
      color: const Color(0xFFF9F5F4), // Match the container background color
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // COMPLETED Header
            const Padding(
              padding: EdgeInsets.only(top: 16, bottom: 12, left: 8),
              child: Text(
                "COMPLETED",
                style: TextStyle(
                  color: Color(0xFFD2BDB7), // Light brown/beige color
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Completed task items
            ...completedTasks.map((task) => _buildCompletedTaskItem(task)),
          ],
        ),
      ),
    );
  }

// Completed Task Item with enhanced rounded corners
  Widget _buildCompletedTaskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F4),
        borderRadius: BorderRadius.circular(12), // Rounded corners
        border: Border.all(
          color: Colors.grey.shade200,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias, // Ensures content respects the rounded corners
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            // Completed checkbox - gray square with check icon
            Container(
              margin: const EdgeInsets.only(right: 16),
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF999494), // Gray background
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),

            // Task name in gray
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF757575), // Gray text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Maintenance Due Tasks
  Widget _buildMaintenanceDueTasksView() {
    // Get maintenance tasks from dummy data
    final tasks = getDummyMaintenanceTasks();

    // Group tasks by category
    Map<String, List<Task>> groupedTasks = {};
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              "COMPLETED",
              style: TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 12,
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
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.list,
            size: 20,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
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
