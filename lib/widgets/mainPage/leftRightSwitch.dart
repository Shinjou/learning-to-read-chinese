import 'package:flutter/material.dart';

class LeftRightSwitch extends StatelessWidget {
  final Color iconsColor;
  final double iconsSize;
  const LeftRightSwitch({Key? key, required this.iconsColor, required this.iconsSize}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.chevron_left,
          shadows: const[Shadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 4)],
          color: iconsColor,
          size: iconsSize,
        ),
        Container(
          width: MediaQuery.of(context).size.width*0.44,
          height: 38,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(38/2)),
            color: iconsColor,
          ),
          child: const Text(
            "看一看",
            style: TextStyle(
              fontSize: 24,
            ),
          )
        ),
        Icon(
          Icons.chevron_right,
          color: iconsColor,
          size: iconsSize,
        )
      ],
    );
  }
}