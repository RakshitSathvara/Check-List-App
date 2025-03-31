import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  static double getScaledFontSize(BuildContext context, double baseFontSize) {
    // Scale font sizes slightly larger on tablets
    return isTablet(context) ? baseFontSize * 1.2 : baseFontSize;
  }
  
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    // Provide more padding on tablets
    return isTablet(context) 
        ? const EdgeInsets.all(24.0)
        : const EdgeInsets.all(16.0);
  }
}