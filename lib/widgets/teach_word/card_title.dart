import 'package:flutter/material.dart';

class TeachWordCardTitle extends StatelessWidget {
  final Color iconsColor;
  const TeachWordCardTitle({required this.iconsColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        );
  }
}