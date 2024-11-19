import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/polyphonic_processor.dart';
import 'package:tuple/tuple.dart';

class ZhuyinProcessing extends ConsumerWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight? fontWeight;
  final bool centered;   

  const ZhuyinProcessing({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    this.fontWeight,
    this.centered = false,     
  });

  Widget _buildText(BuildContext context, WidgetRef ref) {
    int grade = ref.read(gradeProvider);
    bool highlightOn = kDebugMode; // Set highlightOn to true in debug mode

    if (grade < 5) {
      return FutureBuilder<Tuple2<List<TextSpan>, String>>(
        future: PolyphonicProcessor.instance.process(text, fontSize, color, highlightOn),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return RichText(
              text: TextSpan(
                children: snapshot.data!.item1,
                style: TextStyle(
                  fontSize: fontSize,
                  color: color,
                  fontWeight: fontWeight,
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
              'Error loading polyphonic data',
              style: TextStyle(
                fontSize: fontSize,
                color: color,
                fontWeight: fontWeight,
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
          fontWeight: fontWeight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget textWidget = _buildText(context, ref);
    return centered ? Center(child: textWidget) : textWidget;
  }
}

