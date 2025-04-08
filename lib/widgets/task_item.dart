import 'package:check_list_app/services/auth_service.dart';
import 'package:check_list_app/services/task_service.dart';
import 'package:check_list_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../utils/responsive_utils.dart';

class TaskItem extends StatefulWidget {
  final Task task;

  const TaskItem({
    super.key,
    required this.task,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  late bool isChecked;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    isChecked = widget.task.isCompleted;
  }

  void _showTaskDetails() {
    final currentUser = AuthService.currentUser;
    final bool isTablet = ResponsiveUtils.isTablet(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          widget.task.name,
          style: TextStyle(
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${widget.task.category}',
              style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
            ),
            const SizedBox(height: 8),
            Text(
              'Specification: ${widget.task.specificationRange}',
              style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
            ),
            const SizedBox(height: 8),
            if (widget.task.timeRemaining.isNotEmpty)
              Text(
                'Time Remaining: ${widget.task.timeRemaining}',
                style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
              ),
            const SizedBox(height: 8),
            Text(
              'Status: ${widget.task.isCompleted ? 'Completed' : 'Pending'}',
              style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
            ),
            if (widget.task.completedAt != null && widget.task.completedAt!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Completed At: ${widget.task.completedAt}',
                  style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
                ),
              ),
            const SizedBox(height: 16),
            // Only HODs and Plant Head can see these details
            if (currentUser != null &&
                (currentUser.role == UserRole.hod ||
                    currentUser.role == UserRole.plantHead))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(
                    'Additional Information:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16.0 : 14.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: March 3, 2025 04:15 AM',
                    style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
                  ),
                  Text(
                    'Updated By: Rajesh Kumar',
                    style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CLOSE',
              style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
            ),
          ),
        ],
        contentPadding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final isTimeWarning = widget.task.timeRemaining.contains('hour') ||
        widget.task.timeRemaining.contains('mins');

    final currentUser = AuthService.currentUser;
    final bool canUpdateTasks =
        currentUser != null && currentUser.role == UserRole.shiftIncharge;

    // Scale sizing for tablets
    final double checkboxSize = isTablet ? 24.0 : 20.0;
    final double iconSize = isTablet ? 20.0 : 16.0;
    final double verticalPadding = isTablet ? 16.0 : 12.0;

    return GestureDetector(
      onTap: _showTaskDetails,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: isTablet ? 16.0 : 12.0,
          ),
          child: Row(
            children: [
              // Checkbox or Completed indicator
              if (widget.task.isCompleted)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  height: checkboxSize,
                  width: checkboxSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: iconSize,
                  ),
                )
              else
                SizedBox(
                  height: checkboxSize,
                  width: checkboxSize,
                  child: _isUpdating
                      ? SizedBox(
                          height: checkboxSize - 8,
                          width: checkboxSize - 8,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[400]!),
                          ),
                        )
                      : Checkbox(
                          value: isChecked,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: canUpdateTasks
                              ? (bool? value) async {
                                  if (value == null) return;
                                  
                                  setState(() {
                                    _isUpdating = true;
                                  });
                                  
                                  // Call API to update task status
                                  final success = await TaskService.updateTaskStatus(
                                      widget.task.id, value);
                                  
                                  if (mounted) {
                                    setState(() {
                                      _isUpdating = false;
                                      if (success) {
                                        isChecked = value;
                                      }
                                    });
                                  }

                                  if (success) {
                                    if (value) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Task "${widget.task.name}" marked as completed'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to update task status. Please try again.'),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                ),

              // Task name and time remaining
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.name,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getScaledFontSize(
                          context, 
                          14.0
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.task.timeRemaining.isNotEmpty)
                      Text(
                        widget.task.timeRemaining,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getScaledFontSize(
                            context, 
                            12.0
                          ),
                          color: isTimeWarning
                              ? AppColors.timeRed
                              : Colors.grey[600],
                          fontWeight: isTimeWarning
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    // Display specification range
                    if (widget.task.specificationRange.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Spec: ${widget.task.specificationRange}',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getScaledFontSize(
                              context, 
                              11.0
                            ),
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Add more spacing for tablets
              SizedBox(width: isTablet ? 16.0 : 8.0),
              
              // Optional: Add a detail icon for tablets
              if (isTablet)
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}