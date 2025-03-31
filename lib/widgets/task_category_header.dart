import 'package:check_list_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class TaskCategoryHeader extends StatelessWidget {
  final String title;
  final bool isExpandable;

  const TaskCategoryHeader({
    Key? key,
    required this.title,
    this.isExpandable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Special formatting for maintenance categories
    final bool isMaintenanceCategory = title.contains('Preventive/Planned');

    if (isMaintenanceCategory) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
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

    // Regular category header - updated to match design
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.headerBg,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.categoryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
