// tabs/look_tab.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';

class LookTab extends ConsumerWidget {
  final TeachWordControllers controllers;
  final TeachWordState state;
  final ScreenInfo screenInfo;

  const LookTab({
    super.key,
    required this.controllers,
    required this.state,
    required this.screenInfo,
  });

  String get word => state.word;
  bool get isBpmf => state.isBpmf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building LookTab - word: ${state.word}, nextStepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    return TeachWordTabBarView(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenInfo.screenWidth * 0.90,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildLookHeader(context, ref),
                      SizedBox(height: screenInfo.fontSize * 0.3),
                      _buildLookImage(context, ref),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookHeader(BuildContext context, WidgetRef ref) {
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: screenInfo.fontSize * 2.0,
      rightBorder: true,
      middleWidget: const TeachWordCardTitle(
        sectionName: '看一看',
        iconsColor: lightGray,
      ),
      isFirst: true,
      isLast: false,
      /*
      onRightClicked: state.isLearned || state.nextStepId == TeachWordConstants.steps['goToListen']
          ? () async {
              debugPrint('Navigate next clicked in LookTab');
              await _handleNext(ref);
              controllers.navigateToNextTab();
            }
          : null,
      */
      onRightClicked: () async { // Always allow Right Click in LookTab
        debugPrint('Navigate next clicked in LookTab');
        await _handleNext(ref);
        controllers.navigateToNextTab();
      },
    );
  }

  Widget _buildLookImage(BuildContext context, WidgetRef ref) {
    return Flexible(
      fit: FlexFit.loose,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: darkBrown,
            ),
            child: Center(
              child: Image(
                width: max(17.6 * screenInfo.fontSize, 300.0),
                image: state.isBpmf
                    ? AssetImage('lib/assets/img/bopomo/${state.word}.png')
                    : AssetImage('lib/assets/img/oldWords/${state.word}.webp'),
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image: $error');
                  return Center(
                    child: Text(
                      state.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenInfo.fontSize * 8.0,
                        color: backgroundColor,
                        fontWeight: FontWeight.w100,
                        fontFamily: state.isBpmf ? "BpmfOnly" : "BpmfIansui",
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(WidgetRef ref) async {
    debugPrint('LookTab _handleNext called - nextStepId: ${state.nextStepId}');
    
    // Increment step before playing sound
    ref.read(teachWordStateProvider.notifier).incrementNextStepId();
    final audioService = ref.read(audioServiceProvider);
    audioService.playWordSound(word, isBpmf);
  }
}

