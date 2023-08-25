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
              borderRadius: BorderRadius.circular(20)
            ),
          ),
          backgroundColor: MaterialStatePropertyAll('D9D9D9'.toColor())
        ),
        child: Text(
          '$text',
          style: TextStyle(
            color: '000000'.toColor(),
            fontSize: 11,
            fontFamily: 'Serif'
          )
        )
      ),
    );
  }
}
