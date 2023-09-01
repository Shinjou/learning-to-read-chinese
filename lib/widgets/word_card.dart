import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.sizedBoxWidth,
    required this.sizedBoxHeight,
    required this.fontSize,
  });

  final String word;
  final double sizedBoxWidth;
  final double sizedBoxHeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).pushNamed(
          '/teachWord', 
          arguments:{'word': word} 
        );
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
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        )
      )
    );
  }
}
