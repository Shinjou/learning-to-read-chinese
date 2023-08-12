import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/routes.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/registerView.dart';
import 'package:ltrc/views/teachWordView.dart';

void main() {
  // runApp(MyApp());
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          appBarTheme: AppBarTheme(
              iconTheme: const IconThemeData(color: Colors.white),
              foregroundColor: Colors.white,
              color: "#28231D".toColor()),
          scaffoldBackgroundColor: "#28231D".toColor(),
          useMaterial3: true,
        ),
        routes: AppRoutes.define(),
        home: TeachWordView());
  }
}
