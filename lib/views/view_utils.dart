// view_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/routes.dart';
import 'package:ltrc/providers.dart';

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
  var orientation = mediaQueryData.orientation;
  bool isTabletDevice = shortestSide > 600; // You can adjust this threshold

  // Set base values based on device type
  double baseScreenWidth = isTabletDevice ? 600 : 360;
  double baseFontSize = isTabletDevice ? 24.0 : 15.0;

  // Adjust screenHeight and screenWidth in landscape mode
  if (orientation == Orientation.landscape) {
    screenHeight = mediaQueryData.size.shortestSide;
    screenWidth = screenHeight * 3 / 4;
  }

  double fontSize = (baseFontSize * screenWidth / baseScreenWidth).roundToDouble();  
  /* Ignore the caller information because it's not reliable
  String callerInfo = "";
  try {
    final stackTrace = StackTrace.current;
    final frames = stackTrace.toString().split("\n");
    if (frames.length > 2) {
      // Extract the method name from the stack trace line
      RegExp regExp = RegExp(r'#\d+\s+([a-zA-Z0-9_]+)');
      var match = regExp.firstMatch(frames[2]);
      if (match != null) {
        callerInfo = match.group(1) ?? "Unknown";
      }
    }
  } catch (e) {
    callerInfo = "Caller unknown";
  }
  */
  // Print debug information without caller
  debugPrint("getScreenInfo: height=$screenHeight, width=$screenWidth, fontSize=$fontSize, isTablet=$isTabletDevice");

  return ScreenInfo(
    screenHeight: screenHeight,
    screenWidth: screenWidth,
    fontSize: fontSize,
  );
}




/* Usage of navigateWithProvider
1. No arguments to pass: mainPage needs to be defined in AppRoutes
onPressed: () => navigateWithProvider(context, '/mainPage', ref),
2. With arguments to pass: units needs to be defined in AppRoutes
onPressed: () => navigateWithProvider(
  context, 
  '/units', 
  ref, 
  arguments: {'units': units}
),
*/
void navigateWithProvider(
    BuildContext context, 
    String routeName, 
    WidgetRef ref, 
    {Object? arguments}) {
  // Recalculate the screen info before navigation
  final screenInfo = getScreenInfo(context);
  ref.read(screenInfoProvider.notifier).state = screenInfo;

  // Extract the caller method and the method it will navigate to
  String callerInfo = "";
  try {
    final stackTrace = StackTrace.current;
    final frames = stackTrace.toString().split("\n");

    if (frames.length > 2) {
      // Extract the caller method from the stack trace line
      RegExp regExp = RegExp(r'#\d+\s+([a-zA-Z0-9_\.]+)');
      var match = regExp.firstMatch(frames[2]);
      if (match != null) {
        callerInfo = match.group(1) ?? "Unknown";
      }
    }
  } catch (e) {
    callerInfo = "Caller unknown";
  }  

  // Print the caller method and the route it will navigate to
  debugPrint("navigateWithProvider called by $callerInfo, to $routeName with screenInfo: $screenInfo");  

  final routes = AppRoutes.define();

  if (!routes.containsKey(routeName)) {
    // Capture the current stack trace
    final stackTrace = StackTrace.current.toString();
    // Log the error with additional context
    debugPrint('Error: Route $routeName not found in AppRoutes. \nCalled from: $stackTrace');
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return ProviderScope(
          overrides: [
            screenInfoProvider.overrideWith((ref) => screenInfo), // Correctly override with the value function
          ],
          child: routes[routeName]!(context), // Safely access the route
        );
      },
      settings: RouteSettings(name: routeName, arguments: arguments),
    ),
  );
}
