// tab_bar_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

class TeachWordTabBarView extends ConsumerWidget {
  final Widget content;
  const TeachWordTabBarView({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use read instead of watch to prevent unnecessary rebuilds
    final screenInfo = ref.read(screenInfoProvider);
    final fontSize = screenInfo.fontSize;
    final deviceWidth = screenInfo.screenWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              child: Container(
                width: deviceWidth,
                decoration: BoxDecoration(
                  color: darkBrown,
                  border: Border.all(color: mediumGray, width: 6),
                ),
                child: Column(
                  children: [
                    SizedBox(height: fontSize * 0.2),
                    Expanded(child: content),
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
