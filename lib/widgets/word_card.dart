import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

String demoChar = "";

void setChar(word_) {
  demoChar = word_;
}

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.unitTitle,
    required this.word,
    required this.isBpmf,
    required this.sizedBoxWidth,
    required this.sizedBoxHeight,
    required this.fontSize,
  });

  final String word;
  final String unitTitle;
  final bool isBpmf;
  final double sizedBoxWidth;
  final double sizedBoxHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          setChar(word);
          if (!isBpmf) {
            Navigator.of(context).pushNamed('/teachWord',
                // Navigator.of(context).pushNamed('/getSvg',
                arguments: {
                  'word': word,
                  'isBpmf': isBpmf,
                  'unitTitle': unitTitle
                });
          } else {
            Navigator.of(context).pushNamed('/teachBpmf',
                // Navigator.of(context).pushNamed('/getSvg',
                arguments: {
                  'word': word,
                  'isBpmf': isBpmf,
                  'unitTitle': unitTitle
                });
          }
        },
        child: Container(
            width: sizedBoxWidth,
            height: sizedBoxHeight,
            decoration: BoxDecoration(
              color: "#F5F5DC".toColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  word,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            )));
  }
}
