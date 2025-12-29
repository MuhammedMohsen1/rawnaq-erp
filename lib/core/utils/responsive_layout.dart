import 'package:flutter/material.dart';

/// Responsive layout widget that displays different widgets based on screen size
/// 
/// Breakpoints:
/// - Mobile: < 768px
/// - Tablet: 768px - 1200px
/// - Desktop: > 1200px
class ResponsiveLayout extends StatelessWidget {
  /// Widget to display on mobile screens (< 768px)
  final Widget mobile;

  /// Widget to display on tablet screens (768px - 1200px)
  final Widget? tablet;

  /// Widget to display on desktop screens (> 1200px)
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final isTablet = constraints.maxWidth >= 768 && constraints.maxWidth < 1200;

        if (isMobile) {
          return mobile;
        } else if (isTablet && tablet != null) {
          return tablet!;
        } else if (desktop != null) {
          return desktop!;
        } else {
          // Fallback: use tablet if available, otherwise mobile
          return tablet ?? mobile;
        }
      },
    );
  }

  /// Helper method to get current screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 768) {
      return ScreenType.mobile;
    } else if (width >= 768 && width < 1200) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  /// Helper method to check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// Helper method to check if current screen is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  /// Helper method to check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }
}

/// Screen type enum
enum ScreenType {
  mobile,
  tablet,
  desktop,
}


