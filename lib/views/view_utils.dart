// view_utils.dart
import 'package:flutter/material.dart';

bool isTablet(BuildContext context) {
  var shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide > 600; // You can adjust this threshold
}

double getScreenScaleFactor(BuildContext context, double baseScreenWidth) {
  double screenScaleFactor;
  if (isTablet(context)) {
    double shortestWidth = MediaQuery.of(context).size.shortestSide;
    screenScaleFactor = shortestWidth / baseScreenWidth;
  } else {
    screenScaleFactor = MediaQuery.of(context).size.width / baseScreenWidth;
  }
  return screenScaleFactor;
}

double getFontSize(BuildContext context, double baseFontSize) {
  baseFontSize = 15.0; // 強迫改成 15
  double screenScaleFactor = getScreenScaleFactor(context, 360);
  return baseFontSize * screenScaleFactor;
}

double getIconSize(BuildContext context, double baseIconSize) {
  double screenScaleFactor = getScreenScaleFactor(context, 360);
  return baseIconSize * screenScaleFactor;
}

