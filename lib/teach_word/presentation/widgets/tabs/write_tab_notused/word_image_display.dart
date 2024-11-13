// lib/teach_word/presentation/widgets/word_image_display.dart

import 'package:flutter/material.dart';
import 'package:ltrc/views/view_utils.dart';

class WordImageDisplay extends StatelessWidget {
  final String word;
  final double fontSize;
  final bool isBpmf;

  const WordImageDisplay({
    super.key,
    required this.word,
    required this.fontSize,
    required this.isBpmf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: darkBrown,
      ),
      child: Center(
        child: Image(
          width: fontSize * 17.6,
          image: isBpmf
              ? AssetImage('lib/assets/img/bopomo/$word.png')
              : AssetImage('lib/assets/img/oldWords/$word.webp'),
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                word,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize * 8.0,
                  color: backgroundColor,
                  fontWeight: FontWeight.w100,
                  fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
