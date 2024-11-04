// lib/teach_word/presentation/widgets/stroke_area.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/views/view_utils.dart';


class StrokeArea extends ConsumerWidget {
  final StrokeOrderAnimationController controller;
  final int practiceTimeLeft;
  final int currentStroke;
  final bool showOutline;
  final void Function(List<Offset>) onStrokeDrawn;
  final double maxWidth;
  final double maxHeight;

  const StrokeArea({
    super.key,
    required this.controller,
    required this.practiceTimeLeft,
    required this.currentStroke,
    required this.showOutline,
    required this.onStrokeDrawn,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);

    return SizedBox(
      width: maxWidth,
      height: maxHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/img/box.png"),
                fit: BoxFit.contain,
              ),
            ),
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
                _buildPracticeTimeIcon(practiceTimeLeft >= 4, screenInfo.fontSize),
                _buildPracticeTimeIcon(practiceTimeLeft >= 3, screenInfo.fontSize),
                _buildPracticeTimeIcon(practiceTimeLeft >= 2, screenInfo.fontSize),
                SizedBox(height: screenInfo.fontSize * 0.9),
                _buildPracticeTimeIcon(practiceTimeLeft >= 1, screenInfo.fontSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeTimeIcon(bool isActive, double fontSize) {
    return Icon(
      isActive ? Icons.check_circle_outline_outlined : Icons.check_circle,
      color: isActive ? mediumGray : warmOrange,
      size: fontSize * 1.5,
    );
  }
}

