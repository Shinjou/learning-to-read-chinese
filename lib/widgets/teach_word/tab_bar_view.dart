import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/extensions.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';


class TeachWordTabBarView extends ConsumerWidget {
  final Widget content;
  const TeachWordTabBarView({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = getScreenInfo(context);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    debugPrint('TeachWordTabBarView: Height: $deviceHeight, Width: $deviceWidth, fontSize: $fontSize');

    return Column(children: [
      SizedBox(
        
        height: (deviceHeight - 110) * 0.80, // 100 did not work in iPhone 14 pro max
        width: deviceWidth,
        child: Container(
          decoration: BoxDecoration(
            color: '#28231D'.toColor(),
            border: Border.all(color: '#999999'.toColor(), width: 6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: fontSize * 0.2,
              ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    ]);
  }
}
