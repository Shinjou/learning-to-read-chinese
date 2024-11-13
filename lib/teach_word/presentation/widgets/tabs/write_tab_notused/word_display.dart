// lib/teach_word/presentation/widgets/word_display.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

class WordDisplay extends ConsumerWidget {
  final String word;
  final bool isBpmf;

  const WordDisplay({
    super.key,
    required this.word,
    required this.isBpmf, 
    required double maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);

    return Container(
      decoration: const BoxDecoration(
        color: darkBrown,
      ),
      child: Center(
        child: Image(
          width: screenInfo.screenWidth * 0.8,
          image: isBpmf
              ? AssetImage('lib/assets/img/bopomo/$word.png')
              : AssetImage('lib/assets/img/oldWords/$word.webp'),
          errorBuilder: (context, error, stackTrace) {
            return Text(
              word,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenInfo.fontSize * 8.0,
                color: backgroundColor,
                fontWeight: FontWeight.w100,
                fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
              ),
            );
          },
        ),
      ),
    );
  }
}
