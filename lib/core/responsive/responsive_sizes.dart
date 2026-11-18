import 'package:flutter/material.dart';

enum ResponsiveSizes {
  mobile,
  tablet,
  desktopWeb,
  ultraHD4K; // New category for 4K/Ultra HD screens

  static double responsiveHeight = 0.0;
  

  // TIP: Determines device type based on rendered screen size
  // Uses FlutterView instead of BuildContext
  static ResponsiveSizes whichDevice() {

    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final physicalSizeWidth = view.physicalSize.width;
    final physicalSizeHeight = view.physicalSize.height;
    final devicePixelRatio = view.devicePixelRatio;
    
    // Convert physical width to logical width
    final widthInLogicalPixels = physicalSizeWidth / devicePixelRatio;
    final heightInLogicalPixels = physicalSizeHeight / devicePixelRatio;
   
    responsiveHeight = heightInLogicalPixels;

    // Breakpoints for different screen sizes, including 4K/Ultra HD
    return switch (widthInLogicalPixels) {
      <= 600.0 => ResponsiveSizes.mobile,  // Phones
      >= 600.1 && <= 1024.0 => ResponsiveSizes.tablet,  // Tablets
      >= 1024.1 && <= 1920.0 => ResponsiveSizes.desktopWeb,  // Standard Desktop/Web
      _ => ResponsiveSizes.ultraHD4K // 4K Ultra HD screens (above 1920px)
    };
  }
}
