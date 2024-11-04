// lib/teach_word/presentation/widgets/tabs/use_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/states/word_state.dart';

import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/teach_word/presentation/widgets/shared/card_title.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';


class UseTab extends ConsumerWidget {
  final VoidCallback onPreviousTab;

  const UseTab({
    super.key,
    required this.onPreviousTab,
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
              LeftRightSwitch(
                iconsColor: lightGray,
                iconsSize: screenInfo.fontSize * 2.0,
                rightBorder: false,
                middleWidget: TeachWordCardTitle(
                  // sectionName: '用一用',
                  iconsColor: lightGray,
                  title: '用一用',
                  canNavigatePrevious: true,
                  canNavigateNext: true,
                  onPrevious: onPreviousTab,
                  onNext: () {},
                ),
                isFirst: false,
                isLast: false,
                onLeftClicked: wordState.isLearned ? onPreviousTab : null,
              ),
              SizedBox(height: screenInfo.fontSize * 0.3),
              Align(
                alignment: isPortrait ? Alignment.center : Alignment.centerLeft,
                child: PageView.builder(
                  itemCount: wordState.vocabCount,
                  onPageChanged: (index) async {
                    if (wordState.nextStepId == TeachWordSteps.steps['goToUse${index + 1}']) {
                      await wordController.playVocabAudio(index);
                      if (index == wordState.vocabCount - 1) {
                        wordController.markWordAsLearned(wordState);
                      }
                    }
                  },
                  itemBuilder: (context, index) => VocabPage(
                    vocab: wordState.wordsPhrase[wordState.wordIndex]['vocab${index + 1}'],
                    sentence: wordState.wordsPhrase[wordState.wordIndex]['sentence${index + 1}'],
                    onAudioPlay: () => wordController.playVocabAudio(index),
                    pageIndex: index,
                    maxWidth: isPortrait
                        ? screenInfo.screenWidth * 0.8
                        : screenInfo.screenWidth * 0.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class WordAudioDisplay extends ConsumerWidget {
  final String word;
  final double fontSize;
  final bool isBpmf;
  final double maxWidth;

  const WordAudioDisplay({
    super.key,
    required this.word,
    required this.fontSize,
    required this.isBpmf,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: maxWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: darkBrown,
            ),
            child: Center(
              child: Text(
                word,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize * 8.0,
                  color: backgroundColor,
                  fontWeight: FontWeight.w100,
                  fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VocabPage extends ConsumerWidget {
  final int pageIndex;
  final String vocab;
  final String sentence;
  final VoidCallback onAudioPlay;
  final double maxWidth;

  const VocabPage({
    super.key,
    required this.pageIndex,
    required this.vocab,
    required this.sentence,
    required this.onAudioPlay,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordState = ref.watch(wordControllerProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    final meaning = wordState.wordsPhrase[wordState.wordIndex]['meaning${pageIndex + 1}'];
    final imgExist = pageIndex == 0 ? wordState.img1Exists : wordState.img2Exists;

    return SizedBox(
      width: maxWidth,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LeftRightSwitch(
                  iconsColor: lightGray,
                  iconsSize: screenInfo.fontSize * 2.0,
                  rightBorder: pageIndex == 0 && wordState.nextStepId == TeachWordSteps.steps['goToUse2'],
                  middleWidget: TeachWordCardTitle(
                    // sectionName: '用一用',
                    iconsColor: lightGray,
                    title: '用一用',
                    canNavigatePrevious: true,
                    canNavigateNext: true,
                    onPrevious: () {},
                    onNext: () {},
                  ),
                  isFirst: false,
                  isLast: pageIndex == wordState.vocabCount - 1,
                  onLeftClicked: pageIndex == 0 ? null : onAudioPlay,
                  onRightClicked: _buildRightClickHandler(wordState, pageIndex),
                ),
                wordState.isBpmf
                    ? BopomofoVocabContent(
                        word: wordState.currentWord,
                        vocab: vocab,
                        sentence: sentence,
                      )
                    : WordVocabContent(
                        vocab: vocab,
                        meaning: meaning,
                        sentence: sentence,
                        vocab2: wordState.wordsPhrase[wordState.wordIndex]
                            ['vocab${(pageIndex + 1) % wordState.vocabCount + 1}'],
                      ),
                if (imgExist && !wordState.isBpmf)
                  Image(
                    height: screenInfo.fontSize * 3.0,
                    image: AssetImage('lib/assets/img/vocabulary/$vocab.webp'),
                  ),
              ],
            ),
          ),
          Positioned(
            right: screenInfo.fontSize,
            bottom: screenInfo.fontSize,
            child: Text(
              "${pageIndex + 1} / ${wordState.vocabCount}",
              style: TextStyle(
                fontSize: screenInfo.fontSize * 0.75,
                color: backgroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  VoidCallback? _buildRightClickHandler(WordState wordState, int pageIndex) {
    if ((wordState.nextStepId == TeachWordSteps.steps['goToUse${pageIndex + 2}'] || 
         wordState.isLearned) && 
         pageIndex < wordState.vocabCount - 1) {
      return () => onAudioPlay();
    }
    return null;
  }
}


