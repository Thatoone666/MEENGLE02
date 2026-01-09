import 'package:flutter/material.dart';
import 'dart:math' show sqrt;

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

// Extension methods for responsive values
extension ResponsiveDouble on num {
  double h(BuildContext context) =>
      this * (MediaQuery.of(context).size.height / 812.0);
  
  double w(BuildContext context) =>
      this * (MediaQuery.of(context).size.width / 375.0);
  
  double r(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    final refDiagonal = sqrt((375 * 375) + (812 * 812));
    return this * (diagonal / refDiagonal);
  }
}

// Breakpoint values
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  
  static double get maxContentWidth => 1440;
  
  static EdgeInsets responsivePadding(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (ResponsiveLayout.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 48);
    } else {
      return const EdgeInsets.symmetric(horizontal: 64);
    }
  }
  
  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > maxContentWidth ? maxContentWidth : width;
  }
}