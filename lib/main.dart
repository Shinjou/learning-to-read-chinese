// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import 'package:ltrc/providers.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/views/log_in_view.dart';
import 'package:ltrc/views/polyphonic_processor.dart';

import 'package:ltrc/contants/routes.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/view_utils.dart';

Future main() async {
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '學國語',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: "#F5F5DC".toColor()),
          foregroundColor: "#F5F5DC".toColor(),
          color: "#28231D".toColor(),
        ),
        scaffoldBackgroundColor: "#28231D".toColor(),
        useMaterial3: true,
        fontFamily: ref.watch(gradeProvider) < 5 ? 'BpmfIansui' : 'Iansui',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(),
          bodyLarge: TextStyle(),
        ).apply(
          bodyColor: "#F5F5DC".toColor(),
        ),
      ),
      routes: AppRoutes.define(),
      home: const HomePageInitializer(),
    );
  }
}

class HomePageInitializer extends StatelessWidget {
  const HomePageInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenInfo = getScreenInfo(context);
    
    return ProviderScope(
      overrides: [
        screenInfoProvider.overrideWith((ref) => screenInfo),
      ],
      child: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OrientationBuilder(
      builder: (context, orientation) {
        debugPrint("main: Orientation changed: ${MediaQuery.of(context).orientation == Orientation.portrait ? 'Portrait' : 'Landscape'}");
        final screenInfo = getScreenInfo(context);

        /* Can not update directly in the build method
        ref.read(screenInfoProvider.notifier).state = screenInfo;
        debugPrint("HomePage screenInfoProvider: ${screenInfo.screenHeight}, ${screenInfo.screenWidth}, ${screenInfo.fontSize}");
        */
        // Defer the state update until after the current frame is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(screenInfoProvider.notifier).state = screenInfo;
          debugPrint("HomePage screenInfoProvider: ${screenInfo.screenHeight}, ${screenInfo.screenWidth}, ${screenInfo.fontSize}");
        });

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '學國語',
              style: TextStyle(fontSize: screenInfo.fontSize),
            ),
          ),
          body: const LogInView(),
        );
      },
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
