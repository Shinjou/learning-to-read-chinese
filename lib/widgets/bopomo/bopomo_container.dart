import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';


class BopomoContainer extends ConsumerWidget {
  const BopomoContainer(
      {super.key,
      this.character,
      this.innerWidget,
      required this.color,
      required this.onPressed});

  final VoidCallback onPressed;
  final String? character;
  final Color color;
  final Widget? innerWidget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = getScreenInfo(context);
    double fontSize = screenInfo.fontSize;    

    return InkWell(
      onTap: onPressed,
      child: Container(
        width: fontSize * 2.5, // was 44
        height: fontSize * 3.0, // was 50
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(fontSize), // 12
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 6),
                blurRadius: 4,
              )
            ]),
        child: (character == null)
            ? innerWidget
            : Text(
                character!,
                style: TextStyle(fontSize: fontSize * 1.2), // was 30
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
