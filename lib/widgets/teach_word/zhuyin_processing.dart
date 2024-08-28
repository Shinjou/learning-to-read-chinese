import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/polyphonic_processor.dart';
import 'package:tuple/tuple.dart';

class ZhuyinProcessing extends ConsumerWidget {
  final String text;
  final double fontSize;
  final Color color;
  final bool highlightOn;

  const ZhuyinProcessing({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.highlightOn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int grade = ref.watch(gradeProvider);

    if (grade < 5) {
      return FutureBuilder<Tuple2<List<TextSpan>, String>>(
        // future: _processText(fontSize, text),
        future: PolyphonicProcessor.instance.process(text, fontSize, color, highlightOn),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return RichText(
              text: TextSpan(children: snapshot.data!.item1),
              // style: TextStyle(
              //   fontSize: fontSize,
              //   color: color,
              // ),
            );
          } else if (snapshot.hasError) {
            return Text('Error loading polyphonic data',
              style: TextStyle(
                fontSize: fontSize,
                color: color,
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } else {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
        ),
      );
    }
  }
}
