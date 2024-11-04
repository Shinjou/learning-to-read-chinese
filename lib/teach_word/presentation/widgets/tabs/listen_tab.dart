// lib/teach_word/presentation/widgets/tabs/listen_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/presentation/widgets/word_audio_display.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/teach_word/presentation/widgets/shared/card_title.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';

class ListenTab extends ConsumerWidget {
  final VoidCallback onPreviousTab;
  final VoidCallback onNextTab;

  const ListenTab({
    super.key,
    required this.onPreviousTab,
    required this.onNextTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordState = ref.watch(wordControllerProvider);
    final screenInfo = ref.watch(screenInfoProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final isPortrait = maxWidth < maxHeight;

        return SingleChildScrollView(
          child: Column(
            children: [
              LeftRightSwitch(
                iconsColor: lightGray,
                iconsSize: screenInfo.fontSize * 2.0,
                rightBorder: wordState.nextStepId == 1,
                middleWidget: TeachWordCardTitle(
                  // sectionName: '聽一聽',
                  iconsColor: lightGray,
                  title: '聽一聽',
                  canNavigatePrevious: true,
                  canNavigateNext: true,
                  onPrevious: () {},
                  onNext: () {},
                ),
                isFirst: false,
                isLast: false,
                onLeftClicked: (wordState.nextStepId == 1 || wordState.isLearned)
                    ? onPreviousTab
                    : null,
                onRightClicked: (wordState.nextStepId == 1 || wordState.isLearned)
                    ? onNextTab
                    : null,
              ),
              SizedBox(height: screenInfo.fontSize * 0.3),
              Align(
                alignment: isPortrait ? Alignment.center : Alignment.centerLeft,
                child: WordAudioDisplay(
                  word: wordState.currentWord,
                  fontSize: screenInfo.fontSize,
                  isBpmf: wordState.isBpmf,
                  maxWidth: isPortrait
                      ? screenInfo.screenWidth * 0.8
                      : screenInfo.screenWidth * 0.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
