import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class WordWithImage extends StatelessWidget {
  const WordWithImage({
    super.key,
    required this.word,
    required this.imgPath,
    required this.sizedBoxWidth,
    required this.sizedBoxHeight,
    required this.fontSize,
    required this.imgSize,
  });

  final String word;
  final String imgPath;
  final double sizedBoxWidth;
  final double sizedBoxHeight;
  final double fontSize;
  final int imgSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).pushNamed('/teachWord');
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
            Image(
              image: ResizeImage(
                AssetImage(imgPath),
                height: imgSize, 
                width: imgSize,
              )
            )
          ],
        )
      )
    );
  }
}
