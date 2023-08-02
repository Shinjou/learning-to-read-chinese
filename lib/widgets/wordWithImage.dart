import 'package:flutter/material.dart';

class WordWithImage extends StatelessWidget {
  const WordWithImage({super.key, required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word),
            Image.asset(word)
          ],
        )
      )
    );
  }
}