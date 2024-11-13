// lib/teach_word/presentation/widgets/tabs/write_tab/practice_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/teach_word/controllers/word_controller.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';

class PracticeControls extends ConsumerWidget {
  final StrokeOrderAnimationController controller;
  final double fontSize;
  final int nextStepId;
  final bool isLearned;

  const PracticeControls({
    super.key,
    required this.controller,
    required this.fontSize,
    required this.nextStepId,
    required this.isLearned,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final wordState = ref.watch(wordControllerProvider);
    final wordController = ref.read(wordControllerProvider.notifier);

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      mainAxisSpacing: 2,
      crossAxisSpacing: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        _buildControlButton(
          border: (nextStepId == TeachWordSteps.steps['seeAnimation'] && !isLearned),
          icons: [Icons.pause, Icons.play_arrow],
          label: '筆順',
          isSelected: controller.isAnimating,
          onPressed: _handleAnimationPress(controller, wordController),
        ),
        _buildControlButton(
          border: ((nextStepId > TeachWordSteps.steps['seeAnimation']! && 
                   nextStepId < TeachWordSteps.steps['turnBorderOff']!) && 
                   !isLearned && !controller.isQuizzing) || 
                   (nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']!),
          icons: [Icons.edit_off, Icons.edit],
          label: '寫字',
          isSelected: controller.isQuizzing,
          onPressed: _handleWritingPress(controller, wordController),
        ),
        _buildControlButton(
          border: (nextStepId == TeachWordSteps.steps['turnBorderOff'] && !isLearned),
          icons: [Icons.remove_red_eye, Icons.remove_red_eye_outlined],
          label: '邊框',
          isSelected: controller.showOutline,
          onPressed: _handleOutlinePress(controller, wordController),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required bool border,
    required List<IconData> icons,
    required String label,
    required bool isSelected,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: border
              ? BoxDecoration(
                  border: Border.all(
                    color: lightYellow,
                    width: 1.5,
                  ),
                )
              : null,
          child: IconButton(
            icon: Icon(
              isSelected ? icons[0] : icons[1],
              size: fontSize * 1.0,
            ),
            color: backgroundColor,
            onPressed: onPressed,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }

  VoidCallback? _handleAnimationPress(
    StrokeOrderAnimationController controller,
    WordController wordController,
  ) {
    return (!controller.isQuizzing && 
            (nextStepId == TeachWordSteps.steps['seeAnimation'] || isLearned))
        ? () {
            if (!controller.isAnimating) {
              controller.startAnimation();
              wordController.playWordAudio();
              if (nextStepId == TeachWordSteps.steps['seeAnimation']) {
                wordController.incrementNextStepId();
              }
            } else {
              controller.stopAnimation();
            }
          }
        : null;
  }

  VoidCallback? _handleWritingPress(
    StrokeOrderAnimationController controller,
    WordController wordController,
  ) {
    return ((nextStepId > TeachWordSteps.steps['seeAnimation']! && 
             nextStepId < TeachWordSteps.steps['turnBorderOff']!) || 
             isLearned || 
             (nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']!))
        ? () {
            controller.startQuiz();
            wordController.playWordAudio();
          }
        : null;
  }

  VoidCallback? _handleOutlinePress(
    StrokeOrderAnimationController controller,
    WordController wordController,
  ) {
    return (nextStepId == TeachWordSteps.steps['turnBorderOff'] || isLearned)
        ? () {
            if (nextStepId == TeachWordSteps.steps['turnBorderOff']) {
              wordController.incrementNextStepId();
            }
            controller.setShowOutline(!controller.showOutline);
          }
        : null;
  }
}
