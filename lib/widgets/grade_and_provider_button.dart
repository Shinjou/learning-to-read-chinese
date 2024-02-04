import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/view_utils.dart';

class GradeAndProviderButton extends StatelessWidget {
  final double buttonWidth;
  final double buttonHeight;
  final String text;
  const GradeAndProviderButton(
      {super.key,
        required this.buttonWidth,
        required this.buttonHeight,
        required this.text});

  @override
  Widget build(BuildContext context) {
    double fontSize = getFontSize(context, 16); // 16 is the base font size for 360dp width

    return Container(
      width: buttonWidth,
      height: buttonHeight,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 6),
            blurRadius: 6
          )
        ]
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7)
            ),
          ),
          backgroundColor: MaterialStatePropertyAll('#D9D9D9'.toColor())
        ),
        child: Text(
          text,
          style: TextStyle(
            color: '#000000'.toColor(),
            fontSize: fontSize,
          )
        )
      ),
    );
  }
}
