import 'package:flutter/material.dart';

class TeachWordCardTitle extends StatelessWidget {
  final Color iconsColor;
  final String sectionName;
  const TeachWordCardTitle(
      {required this.iconsColor, required this.sectionName, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.44,
      height: 38,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(38 / 2)),
        color: iconsColor,
      ),
      child: Text(
        sectionName,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      )
    );
  }
}
