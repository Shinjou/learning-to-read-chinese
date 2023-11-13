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
    String subSentence = sentence;
    if (subSentence.length > 25) {
      subSentence = "${subSentence.substring(0, 25)}...。";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container( 
          alignment: Alignment.center,
          child: Column(
            children: [
              Text(vocab,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  color: Color.fromRGBO(245, 245, 220, 100),
                  fontFamily: 'BpmfOnly',
              )),
              Image(
                height: 140,
                image: AssetImage(
                  'lib/assets/img/bopomo/$word.png'),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                  textAlign: TextAlign.left,
                  TextSpan(
                    text: subSentence.split(vocab)[0],
                    style: const TextStyle(
                      height: 1.1,
                      fontSize: 36,
                      color: Color.fromRGBO(245, 245, 220, 100),
                      fontFamily: 'BpmfOnly',
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: vocab,
                        style: const TextStyle(
                          color: Color.fromRGBO(228, 219, 124, 1),
                        ),
                      ),
                      TextSpan(
                        text: subSentence.split(vocab)[1],
                      ),
                  ])),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
