import 'package:flutter/material.dart';

class BopomoContainer extends StatelessWidget {
  const BopomoContainer({super.key, required this.character, required this.color});
  
  final String character;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 51,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ), 
      child: Text(
        character, 
        style: const TextStyle(fontSize: 36),
        textAlign: TextAlign.center,
      ),
    );
  }
}