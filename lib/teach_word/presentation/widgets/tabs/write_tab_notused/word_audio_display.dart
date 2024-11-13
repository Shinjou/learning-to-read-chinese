// lib/teach_word/presentation/widgets/word_audio_display.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/view_utils.dart';

class WordAudioDisplay extends ConsumerWidget {
  final String word;
  final double fontSize;
  final bool isBpmf;
  final double maxWidth;

  const WordAudioDisplay({
    super.key,
    required this.word,
    required this.fontSize,
    required this.isBpmf,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: maxWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: darkBrown,
            ),
            child: Center(
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
            ),
          ),
        ],
      ),
    );
  }
}
