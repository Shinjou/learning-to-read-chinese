// lib/teach_word/presentation/widgets/tabs/write_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/teach_word/controllers/word_controller.dart';
import 'package:ltrc/teach_word/presentation/widgets/shared/card_title.dart';

import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/teach_word/states/word_state.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';


class WriteTab extends ConsumerWidget {
  final VoidCallback onPreviousTab;
  final VoidCallback onNextTab;

  const WriteTab({
    super.key,
    required this.onPreviousTab,
    required this.onNextTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordState = ref.watch(wordControllerProvider);
    final wordController = ref.read(wordControllerProvider.notifier);
    final screenInfo = ref.watch(screenInfoProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final isPortrait = maxWidth < maxHeight;

        return SingleChildScrollView(
          child: Column(
            children: [
              TeachWordCardTitle(
                title: '寫一寫',
                canNavigatePrevious: true,
                canNavigateNext: wordState.isLearned,
                onPrevious: onPreviousTab,
                onNext: onNextTab, 
                iconsColor: lightGray,
              ),
              SizedBox(height: screenInfo.fontSize * 0.3),
              Align(
                alignment: Alignment.center,
                child: StrokeArea(
                  controller: wordController.strokeController,
                  fontSize: screenInfo.fontSize,
                  practiceTimeLeft: wordState.practiceTimeLeft,
                  currentStroke: wordState.currentStroke,
                  showOutline: wordState.showOutline,
                  onStrokeDrawn: (strokes) => wordController.checkStroke(strokes),
                  maxWidth: isPortrait
                      ? screenInfo.screenWidth * 0.8
                      : screenInfo.screenWidth * 0.4,
                  maxHeight: isPortrait
                      ? screenInfo.screenWidth * 0.8
                      : screenInfo.screenHeight * 0.5,
                ),
              ),
              SizedBox(height: screenInfo.fontSize * 0.3),
              _buildControlButtons(wordState, wordController, screenInfo.fontSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlButtons(WordState state, WordController controller, double fontSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxWidth < constraints.maxHeight;

        if (isPortrait) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimationButton(state, controller, fontSize),
              _buildPracticeButton(state, controller, fontSize),
              _buildOutlineButton(state, controller, fontSize),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAnimationButton(state, controller, fontSize),
              _buildPracticeButton(state, controller, fontSize),
              _buildOutlineButton(state, controller, fontSize),
            ],
          );
        }
      },
    );
  }

  Widget _buildAnimationButton(WordState state, WordController controller, double fontSize) {
    bool canAnimate = !state.isQuizzing && 
        (TeachWordSteps.isAtStep(state.nextStepId, 'seeAnimation') || state.isLearned);

    return ControlButton(
      icon: state.isAnimating ? Icons.pause : Icons.play_arrow,
      label: '筆順',
      fontSize: fontSize,
      onPressed: canAnimate ? () => controller.handleStrokeAnimationPressed(state) : null,
    );
  }

  Widget _buildPracticeButton(WordState state, WordController controller, double fontSize) {
    bool canPractice = (TeachWordSteps.isBetweenSteps(state.nextStepId, 'seeAnimation', 'turnBorderOff') ||
                        state.isLearned ||
                        TeachWordSteps.isAtStep(state.nextStepId, 'practiceWithoutBorder1'));

    return ControlButton(
      icon: state.isQuizzing ? Icons.edit_off : Icons.edit,
      label: '寫字',
      fontSize: fontSize,
      onPressed: canPractice ? () => controller.startPracticeMode(state) : null,
    );
  }

  Widget _buildOutlineButton(WordState state, WordController controller, double fontSize) {
    bool canToggleOutline = TeachWordSteps.isAtStep(state.nextStepId, 'turnBorderOff') || 
                           state.isLearned;

    return ControlButton(
      icon: Icons.remove_red_eye,
      label: '邊框',
      fontSize: fontSize,
      onPressed: canToggleOutline ? () => controller.toggleOutline(state) : null,
    );
  }
}


class StrokeArea extends ConsumerWidget {
  final StrokeOrderAnimationController controller;
  final int practiceTimeLeft;
  final int currentStroke;
  final bool showOutline;
  final void Function(List<Offset>) onStrokeDrawn;
  final double fontSize;
  final double maxWidth;
  final double maxHeight;

  const StrokeArea({
    super.key,
    required this.controller,
    required this.practiceTimeLeft,
    required this.currentStroke,
    required this.showOutline,
    required this.onStrokeDrawn,
    required this.fontSize,
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

class ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double fontSize;
  final VoidCallback? onPressed;

  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.fontSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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


