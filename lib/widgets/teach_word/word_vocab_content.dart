import 'package:flutter/material.dart';

class WordVocabContent extends StatelessWidget {
  final String vocab;
  final String meaning;
  final String sentence;
  const WordVocabContent({
    super.key,
    required this.vocab,
    required this.meaning,
    required this.sentence,
  });

  @override
  Widget build(BuildContext context) {

    double deviceWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(vocab,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: deviceWidth * 0.125,
            color: const Color.fromRGBO(245, 245, 220, 100),
          )),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text.rich(
            textAlign: TextAlign.start,
            TextSpan(
              text: "解釋：\n",
              style: TextStyle(
                height: 1.1,
                fontSize: deviceWidth / 20,
                color: const Color.fromRGBO(228, 219, 124, 1),
                fontWeight: FontWeight.bold,
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: meaning,
                  style: TextStyle(
                    fontSize: deviceWidth / 20,
                    color: const Color.fromRGBO(245, 245, 220, 100),
                  ),
                ),
                TextSpan(
                  text: '\n\n例句：\n',
                  style: TextStyle(
                    fontSize: deviceWidth / 20,
                  ),
                ),
                TextSpan(
                  text: sentence,
                  style: TextStyle(
                    fontSize: deviceWidth / 20,
                    color: const Color.fromRGBO(245, 245, 220, 100),
                  ),
                ),
              ])),
        ),
      ],
    );
  }
}
