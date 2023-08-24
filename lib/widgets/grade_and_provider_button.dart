import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class GradeAndProviderButton extends StatelessWidget {
  final double buttonWidth;
  final double buttonHeight;
  const GradeAndProviderButton(
      {Key? key,
        required this.buttonWidth,
        required this.buttonHeight,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
          ),
          backgroundColor: "#D9D9D9".toColor(),

        ),
        child: Text()
      ),
    );
  }
}
