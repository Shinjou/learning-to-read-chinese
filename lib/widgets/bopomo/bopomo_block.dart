import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class BopomoBlock extends StatelessWidget {
  const BopomoBlock({super.key, required this.character, required this.color});

  final String character;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: character,
      feedback: SizedBox(
        width: 44,
        height: 51,
        child: Container( 
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ), 
          child: Text(
            character, 
            style: const TextStyle(fontSize: 36),
            textAlign: TextAlign.center,
          ),
        )
      ),
      child: SizedBox(
        width: 44,
        height: 51,
        child: Container( 
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ), 
          child: Text(
            character, 
            style: const TextStyle(fontSize: 36),
            textAlign: TextAlign.center,
          ),
        )
      )
    );
  }
}