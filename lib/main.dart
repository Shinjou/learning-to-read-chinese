// main.dart 

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
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

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    setupLogger();
    
    // Initialize databases and data
    await Future.wait([
      AllProvider().database,
      UserProvider().database,
      PolyphonicProcessor.instance.loadPolyphonicData(),
    ]);

    // Initialize core services
    final serviceInitializer = ServiceInitializer();
    final providers = await serviceInitializer.initializeServices();

    final container = ProviderContainer(overrides: providers);

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
    runApp(const ErrorApp());
  }
}

class ServiceInitializer {
  Future<List<Override>> initializeServices() async {
    final providers = <Override>[];
    
    try {
      debugPrint('Initializing core services...');
      
      // Initialize TTS
      final tts = await initializeTts();
      providers.add(ttsProvider.overrideWithValue(tts));
      debugPrint('TTS initialized');
      
      // Initialize Audio Player
      final player = await initializeAudioPlayer();
      providers.add(audioPlayerProvider.overrideWithValue(player));
      debugPrint('Audio player initialized');
      
      // Initialize Speech Recognition
      final speech = await initializeSpeechToText();
      providers.add(speechToTextProvider.overrideWithValue(speech));
      debugPrint('Speech recognition initialized');
      
      // Initialize Recorder
      final recorder = await initializeRecorder();
      providers.add(recorderProvider.overrideWithValue(recorder));
      debugPrint('Audio recorder initialized');
      
      debugPrint('All core services initialized successfully');
      
    } catch (e, stack) {
      debugPrint('Service initialization failed: $e');
      debugPrint('Stack trace: $stack');
      throw Exception('Failed to initialize core services: $e');
    }

    if (providers.isEmpty) {
      throw Exception('No services were initialized successfully');
    }

    return providers;
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
      return const Center(child: CircularProgressIndicator());
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

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '應用程式初始化失敗',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Phoenix.rebirth(context);
                },
                child: const Text('重新啟動'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void setupLogger() async {
  if (!kDebugMode) {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/app.log');
    Logger(
      output: FileOutput(file: file),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: false,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTime,
      ),
    );
  }
}
