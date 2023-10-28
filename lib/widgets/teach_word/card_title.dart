import 'package:flutter/material.dart';

class TeachWordCardTitle extends StatelessWidget {
  final Color iconsColor;
  final String sectionName;
  const TeachWordCardTitle(
      {required this.iconsColor, required this.sectionName, super.key});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    
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
        style: TextStyle(
          fontSize: deviceWidth * 24/360,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      )
    );
  }
}
