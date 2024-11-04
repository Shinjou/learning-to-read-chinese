// lib/teach_word/presentation/widgets/tabs/use_tab/bopomo_vocab_content.dart

import 'package:flutter/material.dart';

class BopomofoVocabContent extends StatelessWidget {
  final String word;
  final String vocab;
  final String sentence;

  const BopomofoVocabContent({
    super.key,
    required this.word,
    required this.vocab,
    required this.sentence,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          word,
          style: const TextStyle(
            fontSize: 40,
            fontFamily: "BpmfOnly",
          ),
        ),
        const SizedBox(height: 20),
        Text(
          vocab,
          style: const TextStyle(
            fontSize: 40,
            fontFamily: "BpmfOnly",
          ),
        ),
        const SizedBox(height: 20),
        Text(
          sentence,
          style: const TextStyle(
            fontSize: 40,
            fontFamily: "BpmfOnly",
          ),
        ),
      ],
    );
  }
}
