import 'package:check_list_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';

class TaskItem extends StatefulWidget {
  final Task task;

  const TaskItem({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.isCompleted;
  }

  void _showTaskDetails() {
    final currentUser = AuthService.currentUser;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.task.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${widget.task.category}'),
            const SizedBox(height: 8),
            if (widget.task.timeRemaining.isNotEmpty)
              Text('Time Remaining: ${widget.task.timeRemaining}'),
            const SizedBox(height: 8),
            Text('Status: ${widget.task.isCompleted ? 'Completed' : 'Pending'}'),
            const SizedBox(height: 16),
            // Only HODs and Plant Head can see these details
            if (currentUser != null && 
               (currentUser.role == UserRole.hod || 
                currentUser.role == UserRole.plantHead))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    'Additional Information:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Last Updated: March 3, 2025 04:15 AM'),
                  const Text('Updated By: Rajesh Kumar'),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTimeWarning = widget.task.timeRemaining.contains('hour') || 
                         widget.task.timeRemaining.contains('mins');
    
    final currentUser = AuthService.currentUser;
    final bool canUpdateTasks = currentUser != null && 
                              currentUser.role == UserRole.shiftIncharge;
    
    return GestureDetector(
      onTap: _showTaskDetails,
      child: Container(
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
              if (widget.task.isCompleted)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(2),
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
                Checkbox(
                  value: isChecked,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: canUpdateTasks ? (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                    // In a real app, we would update the task status in the database
                    
                    // Show success message for demo purposes
                    if (value == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Task "${widget.task.name}" marked as completed'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } : null,
                ),
              
              // Task name and time remaining
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.task.timeRemaining.isNotEmpty)
                      Text(
                        widget.task.timeRemaining,
                        style: TextStyle(
                          fontSize: 12,
                          color: isTimeWarning ? Colors.red : Colors.grey[600],
                          fontWeight: isTimeWarning ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Info icon for more details
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}