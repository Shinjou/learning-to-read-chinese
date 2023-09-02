import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.learned,
    required this.sizedBoxWidth,
    required this.sizedBoxHeight,
    required this.fontSize,
  });

  final String word;
  final double sizedBoxWidth;
  final double sizedBoxHeight;
  final double fontSize;
  final bool learned;

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
          color: learned ? "#F8F88E".toColor():"#F5F5DC".toColor(),
          borderRadius: BorderRadius.circular(12),
        ), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              learned ? Icons.check_circle : Icons.circle_outlined,
              size: 12,
              color: learned ? "#F8A339".toColor() : "#999999".toColor(),
            ),
            Text(
              word, 
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
            ),
            Inkwell(
              onTap: (){},
              child: Row(
                children:[
                  Icon(
                    liked ? Icons.favorite : Icons.favorite_outlined,
                    size: 12,
                  ),
                ]
              )
            )
          ],
        )
      )
    );
  }
}
