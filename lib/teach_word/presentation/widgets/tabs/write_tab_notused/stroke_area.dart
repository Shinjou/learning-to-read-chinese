// lib/teach_word/presentation/widgets/tabs/write_tab/stroke_area.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';  // Keep existing
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';  

class StrokeArea extends ConsumerWidget {
  final StrokeOrderAnimationController controller;
  final double fontSize;
  final int practiceTimeLeft;

  const StrokeArea({
    super.key,
    required this.controller,
    required this.fontSize,
    required this.practiceTimeLeft, required showOutline, required currentStroke, required onStrokeDrawn, required double maxWidth, required double maxHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    final wordState = ref.watch(wordControllerProvider);

    return SizedBox(
      width: screenInfo.screenWidth * 0.8,
      height: screenInfo.screenWidth * 0.8,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: !wordState.isBpmf
                ? const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("lib/assets/img/box.png"),
                      fit: BoxFit.contain,
                    ),
                  )
                : const BoxDecoration(color: darkBrown),
            child: StrokeOrderAnimator(
              controller,
              key: UniqueKey(),
            ),
          ),
          Positioned(
            left: 10,
            top: 5,
            child: Column(
              children: [
                _buildPracticeTimeIcon(practiceTimeLeft >= 4),
                _buildPracticeTimeIcon(practiceTimeLeft >= 3),
                _buildPracticeTimeIcon(practiceTimeLeft >= 2),
                SizedBox(height: fontSize * 0.9),
                _buildPracticeTimeIcon(practiceTimeLeft >= 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeTimeIcon(bool isActive) {
    return Icon(
      isActive ? Icons.check_circle_outline_outlined : Icons.check_circle,
      color: isActive ? mediumGray : warmOrange,
      size: fontSize * 1.5,
    );
  }
}
