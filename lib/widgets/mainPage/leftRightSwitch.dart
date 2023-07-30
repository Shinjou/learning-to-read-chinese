import 'package:flutter/material.dart';

class LeftRightSwitch extends StatefulWidget {
  const LeftRightSwitch({super.key});

  @override
  State<LeftRightSwitch> createState() => _LeftRightSwitchState();
}

class _LeftRightSwitchState extends State<LeftRightSwitch> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.chevron_left,
          color: Colors.white,
          size: 24,
        ),
        Container(
          width: 224,
          height: 57,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),

          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: Colors.white,
          size: 24,
        )
      ],
    );
  }
}