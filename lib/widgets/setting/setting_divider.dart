import 'package:flutter/material.dart';

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.grey.shade300,
      indent: 12,
      endIndent: 12,
      height: 4,
    );
  }
}