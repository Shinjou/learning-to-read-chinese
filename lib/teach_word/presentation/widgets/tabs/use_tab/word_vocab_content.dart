// lib/teach_word/presentation/widgets/tabs/use_tab/word_vocab_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

class WordVocabContent extends ConsumerWidget {
  final String vocab;
  final String meaning;
  final String sentence;
  final String vocab2;

  const WordVocabContent({
    super.key,
    required this.vocab,
    required this.meaning,
    required this.sentence,
    required this.vocab2,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);

    return Column(
      children: [
        Text(
          vocab,
          style: TextStyle(
            fontSize: screenInfo.fontSize * 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: screenInfo.fontSize * 0.5),
        Text(
          meaning,
          style: TextStyle(
            fontSize: screenInfo.fontSize,
            color: explanationColor,
          ),
        ),
        SizedBox(height: screenInfo.fontSize * 0.5),
        Text(
          sentence,
          style: TextStyle(
            fontSize: screenInfo.fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
