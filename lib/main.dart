// main.dart 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import 'package:ltrc/providers.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/views/log_in_view.dart';
import 'package:ltrc/views/polyphonic_processor.dart';
import 'package:ltrc/contants/routes.dart';
// import 'package:ltrc/extensions.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    setupLogger();
    await AllProvider.database;
    await UserProvider.database;
    await PolyphonicProcessor.instance.loadPolyphonicData();

    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    debugPrint('Failed to init the database: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '學國語',
      theme: _buildThemeData(grade),
      routes: AppRoutes.define(),
      home: const ScreenInfoInitializer(child: HomePage()),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }

  ThemeData _buildThemeData(int grade) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: beige),
        foregroundColor: beige,
        color: darkBrown,
      ),
      scaffoldBackgroundColor: darkBrown,
      useMaterial3: true,
      fontFamily: grade < 5 ? 'BpmfIansui' : 'Iansui',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(),
        bodyLarge: TextStyle(),
      ).apply(
        bodyColor: beige,
      ),
    );
  }
}

class ScreenInfoInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const ScreenInfoInitializer({super.key, required this.child});

  @override
  ScreenInfoInitializerState createState() => ScreenInfoInitializerState();
}

class ScreenInfoInitializerState extends ConsumerState<ScreenInfoInitializer> with WidgetsBindingObserver {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initializeScreenInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateScreenInfo();
  }

  Future<void> _initializeScreenInfo() async {
    // Wait for the first frame to ensure we have valid metrics
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      _updateScreenInfo();
    }
  }

  void _updateScreenInfo() {
    if (mounted) {
      ref.read(screenInfoProvider.notifier).init(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());  // Show a loading spinner until the screen info is ready
        }

        final screenInfo = ref.watch(screenInfoProvider);
        if (screenInfo.screenHeight == 0 || screenInfo.screenWidth == 0) {
          return const Center(child: CircularProgressIndicator());  // Show a spinner while screen info is zero
        }

        return widget.child;
      },
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    debugPrint("HomePage build: H: ${screenInfo.screenHeight}, W: ${screenInfo.screenWidth}, F: ${screenInfo.fontSize}, ${screenInfo.orientation}, T: ${screenInfo.isTablet}");

    if (screenInfo.screenHeight == 0 || screenInfo.screenWidth == 0) {
      return const Center(child: CircularProgressIndicator());  // Show a spinner if screen info is still not ready
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '學國語',
          style: TextStyle(fontSize: screenInfo.fontSize),
        ),
      ),
      body: const LogInView(),
    );
  }
}


class FileLogger extends LogOutput {
  final File file;

  FileLogger(this.file);

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      file.writeAsString('$line\n', mode: FileMode.append, flush: true).catchError((e) {
        debugPrint('Error writing to log file: $e');
        return file;
      });
    }
  }
}

Future<File> _getLogFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/app_logs.txt');
}

void setupLogger() async {
  final file = await _getLogFile();
  var logger = Logger(
    output: FileLogger(file),
  );

  logger.d("This is a debug message");
}
