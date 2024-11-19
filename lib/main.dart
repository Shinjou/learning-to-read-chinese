// main.dart 

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:ltrc/providers.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/views/log_in_view.dart';
import 'package:ltrc/views/polyphonic_processor.dart';
import 'package:ltrc/contants/routes.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    setupLogger();
    
    // Initialize databases
    await AllProvider().database;
    await UserProvider().database;
    await PolyphonicProcessor.instance.loadPolyphonicData();

    // Initialize audio providers
    final container = ProviderContainer(
      overrides: [
        // Pre-initialize audio providers
        ttsProvider.overrideWithValue(await initializeTts()),
        audioPlayerProvider.overrideWithValue(await initializeAudioPlayer()),
        // Ensure screenInfoProvider retains global state across the app
        // screenInfoProvider,
      ],
    );

    debugPrint('Main: Starting app initialization.');
    runApp(
      ProviderScope(
        child: UncontrolledProviderScope(
          container: container,
          child: const MyApp(),
        ),
      ),
    );
  } catch (e) {
    debugPrint('Failed to init the app: $e');
  }
}

Future<FlutterTts> initializeTts() async {
  final ftts = FlutterTts();

  ftts.setStartHandler(() { // Need more processing
    debugPrint("Main: TTS Started");  // we only saw "TTS Start", but no "TTS Complete". Why?
  });

  ftts.setCompletionHandler(() { // No "TTS Complete" message. Why?
    debugPrint("Main: TTS Completed");
  });

  ftts.setErrorHandler((msg) { // 
    debugPrint("Main: TTS Error: $msg");
  });

  await ftts.setLanguage("zh-tw");
  await ftts.setSpeechRate(0.5);
  await ftts.setVolume(1.0);
  debugPrint('Main: TTS initialized.');
  return ftts;
}

Future<AudioPlayer> initializeAudioPlayer() async {
  final player = AudioPlayer();
  debugPrint('Main: Audio player initialized.');
  return player;
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(gradeProvider);
    debugPrint('MyApp: Building app with grade: $grade');

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(screenInfoProvider.notifier).updateScreenInfo(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }  

  @override
  void didChangeMetrics() {
    if (mounted) {
      ref.read(screenInfoProvider.notifier).updateScreenInfo(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    if (screenInfo.screenHeight == 0 || screenInfo.screenWidth == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    return widget.child;
  }
}

/*
class ScreenInfoInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const ScreenInfoInitializer({super.key, required this.child});

  @override
  ScreenInfoInitializerState createState() => ScreenInfoInitializerState();
}

class ScreenInfoInitializerState extends ConsumerState<ScreenInfoInitializer> with WidgetsBindingObserver {
  late Future<void> _initFuture;
  double? _lastHeight;
  double? _lastWidth;
  double? _lastFontSize;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initializeScreenInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // Cancel any previous timer if it’s still active
    _debounceTimer?.cancel();

    // Set a timer to delay the update
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateScreenInfoIfChanged();
    });
  }

  Future<void> _initializeScreenInfo() async {
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) {
      _updateScreenInfoIfChanged();
    }
  }

  void _updateScreenInfoIfChanged() {
    if (!mounted) return;

    final screenInfoNotifier = ref.read(screenInfoProvider.notifier);
    screenInfoNotifier.init(context);
    final screenInfo = ref.read(screenInfoProvider);

    if (screenInfo.screenHeight != _lastHeight ||
        screenInfo.screenWidth != _lastWidth ||
        screenInfo.fontSize != _lastFontSize) {
      
      debugPrint("ScreenInfoInitializer: Updated screen info - H: ${screenInfo.screenHeight}, W: ${screenInfo.screenWidth}, F: ${screenInfo.fontSize}");

      _lastHeight = screenInfo.screenHeight;
      _lastWidth = screenInfo.screenWidth;
      _lastFontSize = screenInfo.fontSize;
    } else {
      debugPrint("ScreenInfoNotifier unchanged, no update necessary.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final screenInfo = ref.watch(screenInfoProvider);
        if (screenInfo.screenHeight == 0 || screenInfo.screenWidth == 0) {
          return const Center(child: CircularProgressIndicator());
        }

        return widget.child;
      },
    );
  }
}
*/

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
          style: TextStyle(fontSize: screenInfo.fontSize * 1.5),
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
