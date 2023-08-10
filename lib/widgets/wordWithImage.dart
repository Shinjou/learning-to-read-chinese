import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class WordWithImage extends StatelessWidget {
  const WordWithImage({super.key, required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 113,
      height: 155,
      child: Container( 
        decoration: BoxDecoration(
          color: "#F5F5DC".toColor(),
          borderRadius: BorderRadius.circular(12),
        ), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word, style: const TextStyle(fontSize: 48),),
            const Image(image: ResizeImage(AssetImage('lib/assets/oldWords/馬.png'), height: 83, width: 83))
          ],
        )
      )
    );
  }
}