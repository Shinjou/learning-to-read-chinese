// view_utils.dart
import 'package:flutter/material.dart';

class ScreenInfo {
  final double screenHeight;
  final double screenWidth;
  final double fontSize;

  ScreenInfo({
    required this.screenHeight,
    required this.screenWidth,
    required this.fontSize,
  });
}

ScreenInfo getScreenInfo(BuildContext context) {
  // Get MediaQuery data only once
  var mediaQueryData = MediaQuery.of(context);
  double screenHeight = mediaQueryData.size.height;
  double screenWidth = mediaQueryData.size.width;
  double shortestSide = mediaQueryData.size.shortestSide;

  // Determine if device is a tablet
  bool isTabletDevice = shortestSide > 600; // You can adjust this threshold

  // Set base values based on device type
  double baseScreenWidth = isTabletDevice ? 600 : 360;
  double baseFontSize = isTabletDevice ? 24.0 : 15.0;

  double fontSize = baseFontSize * screenWidth / baseScreenWidth;

  return ScreenInfo(
    screenHeight: screenHeight,
    screenWidth: screenWidth,
    fontSize: fontSize,
  );
}

