// lib/widgets/teach_word/zhuyin_processing.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/polyphonic_processor.dart';
import 'package:tuple/tuple.dart';

class ZhuyinProcessing extends ConsumerWidget {
  final String? text;
  final InlineSpan? span;
  final double fontSize;
  final Color color;
  final FontWeight? fontWeight;
  final bool centered;

  // Original constructor for compatibility with old callers
  const ZhuyinProcessing({
    super.key,
    required String textParam,
    required this.fontSize,
    required this.color,
    this.fontWeight,
    this.centered = false,
  }) : text = textParam,
       span = null;

  // New named constructor for InlineSpan
  const ZhuyinProcessing.fromSpan({
    super.key,
    required InlineSpan spanParam,
    required this.fontSize,
    required this.color,
    this.fontWeight,
    this.centered = false,
  }) : span = spanParam,
       text = null;

  Widget _buildTextFromString(BuildContext context, WidgetRef ref, String inputText) {
    int grade = ref.read(gradeProvider);
    bool highlightOn = kDebugMode; // highlightOn in debug mode

    if (grade < 5) {
      return FutureBuilder<Tuple2<List<TextSpan>, String>>(
        future: PolyphonicProcessor.instance.process(inputText, fontSize, color, highlightOn),
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
        inputText,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        ),
      );
    }
  }

  Future<List<TextSpan>> _processSpan(WidgetRef ref, InlineSpan inputSpan) async {
    int grade = ref.read(gradeProvider);
    bool highlightOn = kDebugMode;

    if (grade >= 5) {
      // For grade >= 5, no zhuyin processing, just convert to TextSpans
      return _convertInlineSpanToTextSpans(inputSpan);
    } else {
      // For grade < 5, process for zhuyin
      return await _processSpanForZhuyin(inputSpan, highlightOn);
    }
  }

  Future<List<TextSpan>> _processSpanForZhuyin(InlineSpan inputSpan, bool highlightOn) async {
    if (inputSpan is TextSpan) {
      if (inputSpan.text != null) {
        // Leaf node with text
        final processed = await PolyphonicProcessor.instance.process(
          inputSpan.text!,
          fontSize,
          color,
          highlightOn
        );
        // processed.item1 is List<TextSpan>
        // Merge styles
        return processed.item1.map((ts) {
          return TextSpan(
            text: ts.text,
            style: _mergeTextStyles(ts.style, inputSpan.style),
            children: ts.children,
            recognizer: ts.recognizer,
          );
        }).toList();
      } else if (inputSpan.children != null && inputSpan.children!.isNotEmpty) {
        // Non-leaf with children
        List<TextSpan> result = [];
        for (var child in inputSpan.children!) {
          var childSpans = await _processSpanForZhuyin(child, highlightOn);
          // Apply parent style to each child span
          for (var cs in childSpans) {
            result.add(TextSpan(
              text: cs.text,
              style: _mergeTextStyles(cs.style, inputSpan.style),
              children: cs.children,
              recognizer: cs.recognizer,
            ));
          }
        }
        return result;
      } else {
        // Empty TextSpan
        return [];
      }
    } else if (inputSpan is WidgetSpan) {
      // Return widget as is
      return [TextSpan(children: [inputSpan])];
    } else {
      return [];
    }
  }

  Future<List<TextSpan>> _convertInlineSpanToTextSpans(InlineSpan span) async {
    if (span is TextSpan) {
      if ((span.children == null || span.children!.isEmpty) && span.text != null) {
        return [TextSpan(
          text: span.text,
          style: span.style ?? TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight)
        )];
      } else {
        List<TextSpan> result = [];
        if (span.text != null && span.text!.isNotEmpty) {
          result.add(TextSpan(
            text: span.text,
            style: span.style ?? TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight),
          ));
        }
        if (span.children != null) {
          for (var child in span.children!) {
            var childTs = await _convertInlineSpanToTextSpans(child);
            result.addAll(childTs);
          }
        }
        return result;
      }
    } else if (span is WidgetSpan) {
      return [TextSpan(children: [span])];
    } else {
      return [];
    }
  }

  TextStyle? _mergeTextStyles(TextStyle? childStyle, TextStyle? parentStyle) {
    if (parentStyle == null) return childStyle;
    if (childStyle == null) return parentStyle;
    return parentStyle.merge(childStyle);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget finalWidget;
    if (span != null) {
      // Process InlineSpan
      finalWidget = FutureBuilder<List<TextSpan>>(
        future: _processSpan(ref, span!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return RichText(
              text: TextSpan(
                children: snapshot.data!,
                style: TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight),
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
              'Error loading polyphonic data',
              style: TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } else {
      // Process original string logic
      finalWidget = _buildTextFromString(context, ref, text!);
    }

    return centered ? Center(child: finalWidget) : finalWidget;
  }
}

