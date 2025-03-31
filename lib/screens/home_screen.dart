import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Header
            _buildAppBar(),

            // Date Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              color: const Color(0xFFE1BEE7),
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
                    color: Color(0xFFE1BEE7),
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
        color: Colors.white,
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
              width: _getTextWidth(title, TextStyle(
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HMI Category
          _buildCategoryHeader("HMI"),
          _buildTaskItem("Waterflow", "5 hours left", false),
          _buildTaskItem("Physical condition", "2 hours left", false),

          // BLOWER Category
          _buildCategoryHeader("BLOWER"),
          _buildTaskItem("Motor Vibration", "1 hour left", false),
          _buildTaskItem("Impeller condition", "1 day left", false),
          _buildTaskItem("Top suction mesh condition", "2 hours left", false),

          // PNEUMATIC VALVE Category
          _buildCategoryHeader("PNEUMATIC VALVE"),
          _buildTaskItem("Air leakage", "6 hours left", false),
          _buildTaskItem("Bellow condition", "30 mins left", false),
        ],
      ),
    );
  }

  // Operational Completed Tasks
  Widget _buildOperationalCompletedTasksView() {
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
          _buildTaskItem("Bottom suction mesh condition", "", true),
          _buildTaskItem("Belt condition", "", true),
          _buildTaskItem("Motor temperature", "", true),
          _buildTaskItem("Abnormal noise", "", true),
        ],
      ),
    );
  }

  // Maintenance Due Tasks
  Widget _buildMaintenanceDueTasksView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Maintenance
          _buildMaintenanceHeader("Today's Preventive/Planned Maintenance"),
          _buildTaskItem("Cold Glass (L/R)", "3 hours Left", false),
          _buildTaskItem("Burner Cleaning", "1 hour Left", false),
          _buildTaskItem("Top Roller Cleaning By Brush", "4 hours Left", false),
          _buildTaskItem("Top Roller Washing", "30 mins left", false),

          // Next Day's Maintenance
          _buildMaintenanceHeader("Next Day's Preventive/Planned Maintenance"),
          _buildTaskItem("Bottom Roller Washing", "1 day left", false),
          _buildTaskItem("Hanging Bricks Cleaning", "1 day left", false),
        ],
      ),
    );
  }

  // Maintenance Completed Tasks
  Widget _buildMaintenanceCompletedTasksView() {
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
          _buildTaskItem("Zernul Bricks", "", true),
          _buildTaskItem("Washing Pump in Running Condition", "", true),
          _buildTaskItem("M/c Oil Pump Working", "", true),
          _buildTaskItem("Water Inlet Temp.", "", true),
          _buildTaskItem("Water Outlet Temp. Top and Bottom Roller", "", true),
          _buildTaskItem("Water Outlet Temp. Carraige Roller", "", true),
          _buildTaskItem("Any Abnormal Sound in Rolling M/c", "", true),
        ],
      ),
    );
  }

  // Category Header (HMI, BLOWER, etc.)
  Widget _buildCategoryHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      color: const Color(0xFFF5F5F5),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF9E9E9E),
          fontWeight: FontWeight.w500,
        ),
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

  // Task Item
  Widget _buildTaskItem(String name, String timeRemaining, bool isCompleted) {
    final bool isTimeWarning =
        timeRemaining.contains('hour') || timeRemaining.contains('mins');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Checkbox or Completed indicator
            if (isCompleted)
              Container(
                margin: const EdgeInsets.only(right: 12),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(right: 12),
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

            // Task name and time remaining
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (timeRemaining.isNotEmpty)
                    Text(
                      timeRemaining,
                      style: TextStyle(
                        fontSize: 12,
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

  double _getTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);
  
  return textPainter.width;
}
}
