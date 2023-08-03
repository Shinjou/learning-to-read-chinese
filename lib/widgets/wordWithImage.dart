import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class WordWithImage extends StatelessWidget {
  const WordWithImage({super.key, required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 113,
      height: 150,
      child: Container( 
        color: "#F5F5DC".toColor(), 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(word, style: const TextStyle(fontSize: 32),),
            const Image(image: ResizeImage(AssetImage('lib/assets/oldWords/馬.png'), height: 83, width: 83))
          ],
        )
      )
    );
  }
}