import 'package:flutter/material.dart';

import 'bopomo_container.dart';

class BopomoBlock extends StatelessWidget {
  const BopomoBlock({super.key, required this.character, required this.color});

  final String character;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: character,
      feedback: BopomoContainer( character : character, color : color ),
      child: BopomoContainer( character : character, color : color ),
    );
  }
}