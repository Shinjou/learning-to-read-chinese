// main.dart 

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

/*
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
        recorderProvider.overrideWithValue(await initializeRecorder()),
        speechToTextProvider.overrideWithValue(await initializeSpeechToText()),
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
*/

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    setupLogger();
    
    // Initialize databases
    await AllProvider().database;
    await UserProvider().database;
    await PolyphonicProcessor.instance.loadPolyphonicData();

    // Initialize providers with better error handling
    FlutterTts? tts;
    AudioPlayer? audioPlayer;
    AudioRecorder? recorder;
    SpeechToText? speechToText;
    
    try {
      tts = await initializeTts();
      audioPlayer = await initializeAudioPlayer();
      recorder = await initializeRecorder();
      speechToText = await initializeSpeechToText();
    } catch (e) {
      debugPrint('Error initializing audio services: $e');
      // Handle initialization failures gracefully
      if (tts == null) debugPrint('TTS failed to initialize');
      if (audioPlayer == null) debugPrint('AudioPlayer failed to initialize');
      if (recorder == null) debugPrint('Recorder failed to initialize');
      if (speechToText == null) debugPrint('SpeechToText failed to initialize');
    }

    final container = ProviderContainer(
      overrides: [
        if (tts != null) ttsProvider.overrideWithValue(tts),
        if (audioPlayer != null) audioPlayerProvider.overrideWithValue(audioPlayer),
        if (recorder != null) recorderProvider.overrideWithValue(recorder),
        if (speechToText != null) speechToTextProvider.overrideWithValue(speechToText),
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
  } catch (e, stack) {
    debugPrint('Failed to init the app: $e');
    debugPrint('Stack trace: $stack');
  }
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
