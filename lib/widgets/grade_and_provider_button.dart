import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
// import 'package:ltrc/views/view_utils.dart';
// import 'package:ltrc/providers.dart';

class GradeAndProviderButton extends ConsumerWidget {
  final double buttonWidth;
  final double buttonHeight;
  final String text;
  const GradeAndProviderButton(
      {super.key,
        required this.buttonWidth,
        required this.buttonHeight,
        required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    

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
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7)
            ),
          ),
          backgroundColor: WidgetStatePropertyAll('#D9D9D9'.toColor())
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
