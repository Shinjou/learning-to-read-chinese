// view_utils.dart
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/routes.dart';
import 'package:ltrc/providers.dart';
// import 'package:stack_trace/stack_trace.dart';

// Color constants: from whit to black. Some can be merged.
const Color whiteColor = Colors.white;
const Color lightYellow = Color(0xFFFFFF93);
const Color beige = Color(0xFFF5F5DC);
const Color backgroundColor = Color.fromRGBO(245, 245, 220, 100);
const Color lightGray = Color(0xFFD9D9D9);
const Color paleYellow = Color(0xFFF8F88E);
const Color lightSkyBlue = Color(0xFF7DDEF8);
const Color explanationColor = Color.fromRGBO(228, 219, 124, 1);
const Color vibrantOrange = Color(0xFFF8A339);
const Color warmOrange = Color(0xFFF8A23A);
const Color goldenOrange = Color(0xFFD19131);
const Color brightRed = Color(0xFFFF0303);
const Color mediumGray = Color(0xFF999999);
const Color indianRed = Color(0xFFB65454);
const Color darkOliveGreen = Color(0xFF48742C);
const Color deepBlue = Color(0xFF013E6D);
const Color darkCyan = Color(0xFF023E6E);
const Color dimGray = Color(0xFF404040);
const Color darkBrown = Color(0xFF28231D);
const Color veryDarkGray = Color(0xFF1E1E1E);
const Color veryDarkGrayishBlue = Color(0xFF1C1B1F);
const Color black = Color(0xFF000000);

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

/*
void navigateWithProvider(
    BuildContext context, 
    String routeName, 
    WidgetRef ref, 
    {Map<String, dynamic>? arguments}) {
   
  // Extract the caller method using the stack_trace package
  // Only enable the following code in development mode

  if (kDebugMode) {
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
    debugPrint("navigateWithProvider called by $callerInfo, to $routeName");
  }

  final screenInfo = ref.read(screenInfoProvider);
  debugPrint("navigateWithProvider screenInfo: H: ${screenInfo.screenHeight}, W: ${screenInfo.screenWidth}, F: ${screenInfo.fontSize}");

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
*/

/* 11/7/2024
void navigateWithProvider(
  BuildContext context,
  String routeName,
  WidgetRef ref, 
  {
    Map<String, dynamic>? arguments,
    int offset = 0,
  }) {

  // Extract the caller method using the stack_trace package for debugging purposes
  if (kDebugMode) {
    String callerInfo = "";
    try {
      final stackTrace = StackTrace.current;
      final trace = Trace.from(stackTrace);
      final frame = trace.frames[1];
      callerInfo = '${frame.member} in ${frame.library}';
    } catch (e) {
      callerInfo = "Caller unknown";
    }
    debugPrint("navigateWithProvider called by $callerInfo, to $routeName");
  }

  final routes = AppRoutes.define();
  if (!routes.containsKey(routeName)) {
    debugPrint('Error: Route $routeName not found in AppRoutes.');
    return;
  }

  // Adjust the wordIndex in arguments if it exists and apply the offset
  if (arguments != null && arguments.containsKey('wordIndex')) {
    arguments['wordIndex'] = (arguments['wordIndex'] as int) + offset;
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return routes[routeName]!(context);
      },
      settings: RouteSettings(name: routeName, arguments: arguments),
    ),
  ).then((_) {
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
*/

// view_utils.dart

void navigateWithProvider(
  BuildContext context,
  String routeName,
  WidgetRef ref, 
  {
    Map<String, dynamic>? arguments,
    int offset = 0,
  }) {

  // Extract the caller method using the stack_trace package for debugging purposes
  /*
  if (kDebugMode) {
    String callerInfo = "";
    try {
      final stackTrace = StackTrace.current;
      final trace = Trace.from(stackTrace);
      final frame = trace.frames[1];
      callerInfo = '${frame.member} in ${frame.library}';
    } catch (e) {
      callerInfo = "Caller unknown";
    }
    debugPrint("navigateWithProvider called by $callerInfo, to $routeName");
  }
  
  // Check the initial arguments and offset
  debugPrint("navigateWithProvider: Initial arguments - $arguments, offset - $offset");
  */

  final routes = AppRoutes.define();
  if (!routes.containsKey(routeName)) {
    debugPrint('Error: Route $routeName not found in AppRoutes.');
    return;
  }

  // Adjust the wordIndex in arguments if it exists and apply the offset
  if (arguments != null && arguments.containsKey('wordIndex')) {
    final initialWordIndex = arguments['wordIndex'];
    arguments['wordIndex'] = (initialWordIndex as int) + offset;
    debugPrint("navigateWithProvider: Adjusted wordIndex - initial: $initialWordIndex, offset: $offset, new: ${arguments['wordIndex']}");
  } else {
    debugPrint("navigateWithProvider: No wordIndex in arguments or arguments are null.");
  }

  // Read and print the screenInfo state for debugging
  final screenInfo = ref.read(screenInfoProvider);
  debugPrint("navigateWithProvider: Current screenInfo - H: ${screenInfo.screenHeight}, W: ${screenInfo.screenWidth}, F: ${screenInfo.fontSize}, Orientation: ${screenInfo.orientation}, isTablet: ${screenInfo.isTablet}");

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) {
        return routes[routeName]!(context);
      },
      settings: RouteSettings(name: routeName, arguments: arguments),
    ),
  ).then((_) {
      // Post-navigation: update screenInfo and confirm completion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(screenInfoProvider.notifier).mounted) {
          ref.read(screenInfoProvider.notifier).updateFromContext(context);
          debugPrint("navigateWithProvider: screenInfo updated post-navigation");
        }
      });
      debugPrint('navigateWithProvider: Navigation to $routeName completed');       
    }).catchError((error) {
      debugPrint('navigateWithProvider: Error during navigation to $routeName: $error');
    }
  );
}
