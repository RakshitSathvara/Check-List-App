import 'package:flutter/material.dart';
import '../models/task.dart';
import 'task_item.dart';
import 'task_category_header.dart';

class TaskTabView extends StatelessWidget {
  final List<Task> tasks;

  const TaskTabView({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Group tasks by category
    Map<String, List<Task>> groupedTasks = {};
    
    for (var task in tasks) {
      if (!groupedTasks.containsKey(task.category)) {
        groupedTasks[task.category] = [];
      }
      groupedTasks[task.category]!.add(task);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: groupedTasks.entries.map((entry) {
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
              ).toList(),
              
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}