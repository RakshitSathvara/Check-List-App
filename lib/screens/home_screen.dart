// screens/home_screen.dart
import 'package:check_list_app/services/auth_service.dart';
import 'package:check_list_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/task_tab_view.dart';
import '../models/dummy_data.dart';
import '../models/user.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0; // 0 for Due Tasks, 1 for Completed Tasks
  int _tabIndex = 0; // 0 for Operational, 1 for Maintenance
  final String _currentDateTime =
      DateFormat('dd MMMM yyyy HH:mm').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });

    // Check if user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AuthService.currentUser == null) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AuthService.logout();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String departmentTitle = user.department;
    if (user.role == UserRole.plantHead) {
      departmentTitle = "All Departments";
    }

    return Scaffold(
      drawer: _buildDrawer(user),
      body: SafeArea(
        child: Column(
          children: [
            // App Header
            _buildAppBar(departmentTitle),

            // Date Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              width: double.infinity,
              color: AppColors.tabPurple,
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
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppColors.tabPurple,
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(
                    height: 40, // Increase height to match design
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_tabIndex == 0) const Icon(Icons.check, size: 16),
                        const SizedBox(width: 4),
                        const Text('Operational'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 40, // Increase height to match design
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_tabIndex == 1) const Icon(Icons.check, size: 16),
                        const SizedBox(width: 4),
                        const Text('Maintenance'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Operational Tab
                  _currentIndex == 0
                      ? TaskTabView(tasks: getDummyOperationalTasks())
                      : TaskTabView(tasks: getCompletedOperationalTasks()),

                  // Maintenance Tab
                  _currentIndex == 0
                      ? TaskTabView(tasks: getDummyMaintenanceTasks())
                      : TaskTabView(tasks: getCompletedMaintenanceTasks()),
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

  Widget _buildDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.red,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AuthService.getRoleName(user.role),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.factory),
            title: const Text('Processes'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          // HOD and Plant Head specific menu items
          if (user.role == UserRole.hod || user.role == UserRole.plantHead)
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Alerts'),
              onTap: () {
                Navigator.pop(context);
                // Show a simple message for demo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Alerts feature is available for HODs and Plant Heads'),
                  ),
                );
              },
            ),
          // Plant Head specific menu items
          if (user.role == UserRole.plantHead)
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                // Show a simple message for demo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Analytics feature is available for Plant Heads'),
                  ),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(String departmentTitle) {
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),

          // Page Title
          Text(
            '$departmentTitle - Shift B',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Profile Icon
          GestureDetector(
            onTap: _logout,
            child: const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 14,
              child: Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
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
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 3,
            color: isSelected ? AppColors.selectedPurple : Colors.transparent,
          ),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isSelected ? AppColors.selectedPurple : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ),
  );
}
}
