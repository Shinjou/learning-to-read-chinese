import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class MainPageView extends StatelessWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: '28231D'.toColor(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.settings,
            color: 'F5F5DC'.toColor(),
            size: 38
          ),
        ]
      )
    );
  }
}