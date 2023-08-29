import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class GradeAndProviderButton extends StatelessWidget {
  final double buttonWidth;
  final double buttonHeight;
  final String text;
  const GradeAndProviderButton(
      {Key? key,
        required this.buttonWidth,
        required this.buttonHeight,
        required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    double fontSize = 0;
    if (buttonWidth * 4 > 400) fontSize = 11;
    else fontSize = 9;

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
          '$text',
          style: TextStyle(
            color: '#000000'.toColor(),
            fontSize: fontSize,
            fontFamily: 'Serif'
          )
        )
      ),
    );
  }
}
