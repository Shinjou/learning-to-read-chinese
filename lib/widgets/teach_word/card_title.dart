import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ltrc/providers.dart';
// import 'package:ltrc/views/polyphonic_processor.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';
// import 'package:tuple/tuple.dart';

class TeachWordCardTitle extends ConsumerWidget {
  final Color iconsColor;
  final String sectionName;
  const TeachWordCardTitle({
    required this.iconsColor,
    required this.sectionName,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = getScreenInfo(context);
    double fontSize = screenInfo.fontSize;    

    return Container(
      width: fontSize * 8.0, // for 3 1.5 fontSize characters
      height: fontSize * 2.0, // word fontSize = 1.8
      alignment: Alignment.center,
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(38 / 2)),
        color: iconsColor,
      ),
      child: ZhuyinProcessing(
        text: sectionName,
        fontSize: fontSize * 1.2,
        color: Colors.black,
        highlightOn: false,
      ),
    );
  }
}
