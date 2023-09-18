import 'package:flutter/material.dart';

class BopomoContainer extends StatelessWidget {
  const BopomoContainer({
    super.key, 
    this.character,
    this.innerWidget,
    required this.color, 
    required this.onPressed 
  });
  
  final VoidCallback onPressed;
  final String? character;
  final Color color;
  final Widget? innerWidget;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap : onPressed,
      child : Container(
        width: 44,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(0, 6),
              blurRadius: 4,
            )
          ]
        ), 
        child: (character == null) ? innerWidget :
          Text(
            character!, 
            style: const TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
      ),
    );
  }
}