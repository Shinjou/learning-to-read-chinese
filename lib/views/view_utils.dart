// view_utils.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/routes.dart';
import 'package:ltrc/providers.dart';
import 'package:stack_trace/stack_trace.dart';

class ScreenInfo {
  final double screenHeight;
  final double screenWidth;
  final double fontSize;
  final Orientation orientation;
  final bool isTablet;

  ScreenInfo({
    required this.screenHeight,
    required this.screenWidth,
    required this.fontSize,
    required this.orientation,
    required this.isTablet,
  });
}

class ScreenInfoNotifier extends StateNotifier<ScreenInfo> {
  ScreenInfoNotifier()
      : super(ScreenInfo(
          screenHeight: 0,
          screenWidth: 0,
          fontSize: 0,
          orientation: Orientation.portrait,
          isTablet: false,
        ));

  Timer? _debounceTimer;

  void init(BuildContext context) {
    if (_debounceTimer?.isActive ?? false) return;

    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      final mediaQuery = MediaQuery.of(context);
      double screenHeight = mediaQuery.size.height;
      double screenWidth = mediaQuery.size.width;
      double shortestSide = mediaQuery.size.shortestSide;
      Orientation orientation = mediaQuery.orientation;
      bool isTablet = shortestSide > 600;

      double baseScreenWidth = isTablet ? 600 : 360;
      double baseFontSize = isTablet ? 24.0 : 15.0;

      if (orientation == Orientation.landscape) {
        screenHeight = mediaQuery.size.shortestSide;
        screenWidth = screenHeight * 3 / 4;
      }

      double fontSize = (baseFontSize * screenWidth / baseScreenWidth).roundToDouble();

      // Only update if the state has changed
      if (screenHeight != state.screenHeight ||
          screenWidth != state.screenWidth ||
          fontSize != state.fontSize ||
          orientation != state.orientation) {
        
        final newState = ScreenInfo(
          screenHeight: screenHeight,
          screenWidth: screenWidth,
          fontSize: fontSize,
          orientation: orientation,
          isTablet: isTablet,
        );

        state = newState;
        debugPrint('ScreenInfoNotifier updated: H: $screenHeight, W: $screenWidth, F: $fontSize, $orientation, T: $isTablet');
      } else {
        debugPrint('ScreenInfoNotifier unchanged, no update necessary.');
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void updateFromContext(BuildContext context) {
    init(context);
  }  
}

/*
class ScreenInfo {
  final double screenHeight;
  final double screenWidth;
  final double fontSize;
  final Orientation orientation;
  final bool isTablet;

  ScreenInfo({
    required this.screenHeight,
    required this.screenWidth,
    required this.fontSize,
    required this.orientation,
    required this.isTablet,
  });
}

class ScreenInfoNotifier extends StateNotifier<ScreenInfo> {
  ScreenInfoNotifier() : super(ScreenInfo(
    screenHeight: 0,
    screenWidth: 0,
    fontSize: 0,
    orientation: Orientation.portrait,
    isTablet: false,
  ));

  void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    double screenHeight = mediaQuery.size.height;
    double screenWidth = mediaQuery.size.width;
    double shortestSide = mediaQuery.size.shortestSide;
    Orientation orientation = mediaQuery.orientation;
    bool isTablet = shortestSide > 600;

    double baseScreenWidth = isTablet ? 600 : 360;
    double baseFontSize = isTablet ? 24.0 : 15.0;

    if (orientation == Orientation.landscape) {
      screenHeight = mediaQuery.size.shortestSide;
      screenWidth = screenHeight * 3 / 4;
    }

    double fontSize = (baseFontSize * screenWidth / baseScreenWidth).roundToDouble();

    final newState = ScreenInfo(
      screenHeight: screenHeight,
      screenWidth: screenWidth,
      fontSize: fontSize,
      orientation: orientation,
      isTablet: isTablet,
    );

    if (newState != state) {
      state = newState;
      debugPrint('ScreenInfoNotifier updated: H: $screenHeight, W: $screenWidth, F: $fontSize, $orientation, T: $isTablet');
    }
  }
}
*/

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
    {Map<String, dynamic>? arguments}) {
   
  // Extract the caller method using the stack_trace package
  String callerInfo = "";
  try {
    // Capture the current stack trace
    final stackTrace = StackTrace.current;
    // Use Trace from stack_trace package to parse it
    final trace = Trace.from(stackTrace);

    // The second frame in the trace is likely the caller method
    final frame = trace.frames[1]; // Adjust frame index as needed
    callerInfo = '${frame.member} in ${frame.library}';
  } catch (e) {
    callerInfo = "Caller unknown";
  }
  final screenInfo = ref.read(screenInfoProvider);
  // Print the caller method and the route it will navigate to
  debugPrint("navigateWithProvider called by $callerInfo, to $routeName with screenInfo: H: ${screenInfo.screenHeight}, W: ${screenInfo.screenWidth}, F: ${screenInfo.fontSize}");

  final routes = AppRoutes.define();

  if (!routes.containsKey(routeName)) {
    debugPrint('Error: Route $routeName not found in AppRoutes.');
    return;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return routes[routeName]!(context);
      },
      settings: RouteSettings(name: routeName, arguments: arguments),
    ),
  ).then((_) {
      // Update screen info after navigation is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(screenInfoProvider.notifier).mounted) {
          ref.read(screenInfoProvider.notifier).updateFromContext(context);
        }
      });
      debugPrint('Navigation to $routeName completed');       
    }).catchError((error) {
      debugPrint('Error during navigation to $routeName: $error');
    }
  );
}
