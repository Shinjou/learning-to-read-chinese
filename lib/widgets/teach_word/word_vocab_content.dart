import 'package:flutter/material.dart';

class WordVocabContent extends StatelessWidget {
  final String vocab;
  final String meaning;
  final String sentence;
  const WordVocabContent({
    Key? key,
    required this.vocab,
    required this.meaning,
    required this.sentence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(vocab,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 45,
            color: Color.fromRGBO(245, 245, 220, 100),
          )),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text.rich(
            textAlign: TextAlign.start,
            TextSpan(
              text: "解釋：\n",
              style: const TextStyle(
                height: 1.1,
                fontSize: 18,
                color: Color.fromRGBO(228, 219, 124, 1),
                fontWeight: FontWeight.bold,
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: meaning,
                  style: const TextStyle(
                    color: Color.fromRGBO(245, 245, 220, 100),
                  ),
                ),
                const TextSpan(
                  text: '\n\n例句：\n',
                ),
                TextSpan(
                  text: sentence,
                  style: const TextStyle(
                    color: Color.fromRGBO(245, 245, 220, 100),
                  ),
                ),
              ])),
        ),
      ],
    );
  }
}
