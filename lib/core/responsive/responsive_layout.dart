
import 'package:flutter/material.dart';

import 'responsive_sizes.dart';

/// -----------------------------------------------------------------------------
/// ResponsiveLayout
/// Provides device-based widget switching with constraint-safe layout.
/// Pages must define their own Scaffold.
/// -----------------------------------------------------------------------------

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktopWeb,
    required this.ultraHD4K,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktopWeb;
  final Widget ultraHD4K;
  
  static bool isMobile(BuildContext context) =>
      ResponsiveSizes.whichDevice() == ResponsiveSizes.mobile;

  static bool isTablet(BuildContext context) =>
      ResponsiveSizes.whichDevice() == ResponsiveSizes.tablet;

  static bool isDesktop(BuildContext context) =>
      ResponsiveSizes.whichDevice() == ResponsiveSizes.desktopWeb;

  static bool isUltraHD(BuildContext context) =>
      ResponsiveSizes.whichDevice() == ResponsiveSizes.ultraHD4K;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.minHeight,
            maxHeight: constraints.hasBoundedHeight
                ? constraints.maxHeight
                : MediaQuery.of(context).size.height,
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
          ),
          child: _buildResponsiveWidget(),
        );
      },
    );
  }

  Widget _buildResponsiveWidget() {
    switch (ResponsiveSizes.whichDevice()) {
      case ResponsiveSizes.mobile:
        return mobile;
      case ResponsiveSizes.tablet:
        return tablet;
      case ResponsiveSizes.desktopWeb:
        return desktopWeb;
      default:
        return ultraHD4K;
    }
  }
}
