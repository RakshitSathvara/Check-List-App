import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/responsive_utils.dart';
import 'task_item.dart';
import 'task_category_header.dart';

class TaskTabView extends StatelessWidget {
  final List<Task> tasks;

  const TaskTabView({
    super.key,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    
    // Group tasks by category
    Map<String, List<Task>> groupedTasks = {};
    
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    // For completed tasks, add a "COMPLETED" header text
    final bool showCompletedHeader = tasks.isNotEmpty && tasks.first.isCompleted;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24.0 : 16.0, 
        vertical: isTablet ? 12.0 : 8.0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add COMPLETED text for completed tasks view
          if (showCompletedHeader)
            Padding(
              padding: EdgeInsets.only(bottom: isTablet ? 16.0 : 12.0),
              child: Text(
                'COMPLETED',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          // Task categories and items
          ...groupedTasks.entries.map((entry) {
            final category = entry.key;
            final categoryTasks = entry.value;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header (except for 'COMPLETED')
                if (category != 'COMPLETED')
                  TaskCategoryHeader(title: category),
                
                // Task items in this category
                ...categoryTasks.map((task) => 
                  TaskItem(task: task)
                ),
                
                SizedBox(height: isTablet ? 24.0 : 16.0),
              ],
            );
          }),
        ],
      ),
    );
  }
}