// tab_bar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';

class TeachWordTabBarView extends ConsumerWidget {
  final Widget content;
  const TeachWordTabBarView({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    debugPrint('TeachWordTabBarView: H: $deviceHeight, W: $deviceWidth, F: $fontSize');

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: '#28231D'.toColor(),
                  border: Border.all(color: '#999999'.toColor(), width: 6),
                ),
                child: Column(
                  children: [
                    SizedBox(height: fontSize * 0.2),
                    Expanded(
                      child: SingleChildScrollView(
                        child: content,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
