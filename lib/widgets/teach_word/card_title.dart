import 'package:flutter/material.dart';
import 'package:ltrc/views/view_utils.dart';

class TeachWordCardTitle extends StatelessWidget {
  final Color iconsColor;
  final String sectionName;
  const TeachWordCardTitle(
      {required this.iconsColor, required this.sectionName, super.key});

  @override
  Widget build(BuildContext context) {
    double fontSize =
        getFontSize(context, 16); // 16 is the base font size for 360dp width

    return Container(
        width: fontSize * 8.0, // for 3 1.5 fontSize characters
        height: fontSize * 2.0, // word fontSize = 1.8
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(38 / 2)),
          color: iconsColor,
        ),
        child: Text(
          sectionName,
          style: TextStyle(
            fontSize: fontSize * 1.2, // was 24/360
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ));
  }
}
