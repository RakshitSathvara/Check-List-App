import 'package:check_list_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

class TaskCategoryHeader extends StatelessWidget {
  final String title;
  final bool isExpandable;

  const TaskCategoryHeader({
    super.key,
    required this.title,
    this.isExpandable = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    
    // Special formatting for maintenance categories
    final bool isMaintenanceCategory = title.contains('Preventive/Planned');

    if (isMaintenanceCategory) {
      return Container(
        margin: EdgeInsets.only(
          bottom: isTablet ? 12.0 : 8.0,
          top: isTablet ? 8.0 : 4.0,
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

    // Regular category header - updated to match design and be tablet-responsive
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 10.0 : 6.0, 
        horizontal: isTablet ? 12.0 : 8.0
      ),
      margin: EdgeInsets.only(
        bottom: isTablet ? 12.0 : 8.0,
        top: isTablet ? 8.0 : 4.0,
      ),
      color: AppColors.headerBg,
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getScaledFontSize(context, 12),
          color: AppColors.categoryText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}