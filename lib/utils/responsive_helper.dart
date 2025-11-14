import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ResponsiveHelper {
  // Check if running on web
  static bool get isWeb => kIsWeb;
  
  // Check if running on mobile
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  // Get screen width breakpoints
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }
  
  static bool isMobileSize(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
  
  // Get responsive padding
  static EdgeInsets getPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 80, vertical: 20);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }
  
  // Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 2;
    }
  }
  
  // Get max content width for web
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1400;
    } else if (isTablet(context)) {
      return 1000;
    } else {
      return double.infinity;
    }
  }
}

