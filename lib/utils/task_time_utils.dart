import 'package:intl/intl.dart';

class TaskTimeUtils {
  // Calculate time remaining for a task based on shift end time
  static String calculateTimeRemaining(DateTime now, String shiftEndTimeStr) {
    try {
      // Parse shift end time
      final endTimeParts = shiftEndTimeStr.split(':');
      if (endTimeParts.length < 3) return '';
      
      // Create a DateTime for the shift end time on the current day
      final int endHour = int.parse(endTimeParts[0]);
      final int endMinute = int.parse(endTimeParts[1]);
      
      final DateTime shiftEnd = DateTime(
        now.year,
        now.month,
        now.day,
        endHour,
        endMinute,
      );
      
      // If shift end time is before the current time, it might be a night shift ending the next day
      final DateTime endTime = shiftEnd.isBefore(now)
          ? shiftEnd.add(const Duration(days: 1))
          : shiftEnd;
      
      // Calculate the difference
      final Duration remaining = endTime.difference(now);
      
      // Format based on the remaining time
      if (remaining.inDays > 0) {
        return '${remaining.inDays} day${remaining.inDays > 1 ? 's' : ''} left';
      } else if (remaining.inHours > 0) {
        return '${remaining.inHours} hour${remaining.inHours > 1 ? 's' : ''} left';
      } else if (remaining.inMinutes > 0) {
        return '${remaining.inMinutes} min${remaining.inMinutes > 1 ? 's' : ''} left';
      } else {
        return 'Due now';
      }
    } catch (e) {
      print('Error calculating time remaining: $e');
      return '';
    }
  }
  
  // Determine if the time remaining should be shown in red (urgent)
  static bool isTimeUrgent(String timeRemaining) {
    return timeRemaining.contains('min') || 
           timeRemaining.contains('Due now') ||
           (timeRemaining.contains('hour') && 
            timeRemaining.startsWith('1 hour'));
  }
  
  // Calculate percentage of shift completed
  static double calculateShiftProgress(DateTime now, String shiftStartTimeStr, String shiftEndTimeStr) {
    try {
      // Parse shift times
      final startTimeParts = shiftStartTimeStr.split(':');
      final endTimeParts = shiftEndTimeStr.split(':');
      
      if (startTimeParts.length < 3 || endTimeParts.length < 3) return 0.0;
      
      // Create DateTimes for the shift start and end times
      final int startHour = int.parse(startTimeParts[0]);
      final int startMinute = int.parse(startTimeParts[1]);
      final int endHour = int.parse(endTimeParts[0]);
      final int endMinute = int.parse(endTimeParts[1]);
      
      final DateTime shiftStart = DateTime(
        now.year,
        now.month,
        now.day,
        startHour,
        startMinute,
      );
      
      DateTime shiftEnd = DateTime(
        now.year,
        now.month,
        now.day,
        endHour,
        endMinute,
      );
      
      // Handle overnight shifts
      if (shiftEnd.isBefore(shiftStart)) {
        shiftEnd = shiftEnd.add(const Duration(days: 1));
      }
      
      // If the current time is before the shift start, return 0
      if (now.isBefore(shiftStart)) {
        return 0.0;
      }
      
      // If the current time is after the shift end, return 1 (100%)
      if (now.isAfter(shiftEnd)) {
        return 1.0;
      }
      
      // Calculate total shift duration in minutes
      final int totalMinutes = shiftEnd.difference(shiftStart).inMinutes;
      
      // Calculate elapsed time in minutes
      final int elapsedMinutes = now.difference(shiftStart).inMinutes;
      
      // Calculate and return the progress percentage
      return elapsedMinutes / totalMinutes;
    } catch (e) {
      print('Error calculating shift progress: $e');
      return 0.0;
    }
  }
  
  // Format the current time for display
  static String formatCurrentTime(DateTime now) {
    final formatter = DateFormat('hh:mm a');
    return formatter.format(now);
  }
  
  // Get a formatted string showing shift timing
  static String getShiftTimingDisplay(String startTime, String endTime) {
    try {
      // Parse and reformat the times for better display
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      if (startParts.length < 2 || endParts.length < 2) return "$startTime - $endTime";
      
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);
      
      // Create formatter for 12-hour time with AM/PM
      final formatter = DateFormat('hh:mm a');
      
      // Create temporary DateTime objects to format with the DateFormat
      final now = DateTime.now();
      final startDateTime = DateTime(now.year, now.month, now.day, startHour, startMinute);
      final endDateTime = DateTime(now.year, now.month, now.day, endHour, endMinute);
      
      return "${formatter.format(startDateTime)} - ${formatter.format(endDateTime)}";
    } catch (e) {
      print('Error formatting shift timing: $e');
      return "$startTime - $endTime";
    }
  }
}