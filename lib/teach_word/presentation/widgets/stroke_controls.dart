// lib/teach_word/presentation/widgets/stroke_controls.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/teach_word/controllers/word_controller.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/teach_word/states/word_state.dart';
import 'package:ltrc/views/view_utils.dart';

class StrokeControls extends ConsumerWidget {
  final StrokeMode mode;
  final VoidCallback onAnimatePressed;
  final VoidCallback onPracticePressed;
  final VoidCallback onOutlineToggled;

  const StrokeControls({
    super.key,
    required this.mode,
    required this.onAnimatePressed,
    required this.onPracticePressed,
    required this.onOutlineToggled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordState = ref.watch(wordControllerProvider);
    final wordController = ref.read(wordControllerProvider.notifier);
    final screenInfo = ref.watch(screenInfoProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAnimationButton(wordState, wordController, screenInfo.fontSize),
        _buildPracticeButton(wordState, wordController, screenInfo.fontSize),
        _buildOutlineButton(wordState, wordController, screenInfo.fontSize),
      ],
    );
  }

  Widget _buildAnimationButton(WordState state, WordController controller, double fontSize) {
    bool canAnimate = !state.isQuizzing && 
        (TeachWordSteps.isAtStep(state.nextStepId, 'seeAnimation') || state.isLearned);

    return _buildControlButton(
      icon: state.isAnimating ? Icons.pause : Icons.play_arrow,
      label: '筆順',
      onPressed: canAnimate ? onAnimatePressed : null,
      fontSize: fontSize,
    );
  }

  Widget _buildPracticeButton(WordState state, WordController controller, double fontSize) {
    bool canPractice = (TeachWordSteps.isBetweenSteps(state.nextStepId, 'seeAnimation', 'turnBorderOff') ||
                        state.isLearned ||
                        TeachWordSteps.isAtStep(state.nextStepId, 'practiceWithoutBorder1'));

    return _buildControlButton(
      icon: state.isQuizzing ? Icons.edit_off : Icons.edit,
      label: '寫字',
      onPressed: canPractice ? onPracticePressed : null,
      fontSize: fontSize,
    );
  }

  Widget _buildOutlineButton(WordState state, WordController controller, double fontSize) {
    bool canToggleOutline = TeachWordSteps.isAtStep(state.nextStepId, 'turnBorderOff') || 
                           state.isLearned;

    return _buildControlButton(
      icon: Icons.remove_red_eye,
      label: '邊框',
      onPressed: canToggleOutline ? onOutlineToggled : null,
      fontSize: fontSize,
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required double fontSize,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: fontSize * 1.5),
          onPressed: onPressed,
          color: backgroundColor,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }
}
