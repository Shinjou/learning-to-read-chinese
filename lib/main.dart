import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'package:ltrc/providers.dart';
import 'package:ltrc/data/providers/all_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/views/log_in_view.dart';

import 'package:ltrc/contants/routes.dart';
import 'package:ltrc/extensions.dart';

Future main() async{
  try {
    WidgetsFlutterBinding.ensureInitialized();
    setupLogger();
    await AllProvider.database; // Initialize all database    
    await UserProvider.database; // Initialize users database
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    debugPrint('Failed to init the database: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int grade = ref.watch(gradeProvider); 
    return MaterialApp(
      title: '學國語',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: "#F5F5DC".toColor()),
          foregroundColor: "#F5F5DC".toColor(),
          color: "#28231D".toColor()
        ),
        scaffoldBackgroundColor: "#28231D".toColor(),
        useMaterial3: true,
        fontFamily: grade < 3 ? 'Serif': 'Iceberg', 
        textTheme: const TextTheme(
          bodyMedium: TextStyle(),
          bodyLarge: TextStyle(),
        ).apply(
          bodyColor: "#F5F5DC".toColor(),
        )
      ),
      routes: AppRoutes.define(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LogInView();
  }
}


class FileLogger extends LogOutput {
  final File file;

  FileLogger(this.file);

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      file.writeAsString('$line\n', mode: FileMode.append, flush: true).catchError((e) {
        // Handle the error, e.g., logging it to your console or an error reporting service
        debugPrint('Error writing to log file: $e');
        // You might not need to return a File object here, just handle the error.
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

  // Use logger as usual
  logger.d("This is a debug message");
}
