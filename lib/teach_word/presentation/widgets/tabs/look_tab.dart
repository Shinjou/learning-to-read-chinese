// lib/teach_word/presentation/widgets/tabs/look_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/presentation/widgets/word_display.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/teach_word/presentation/widgets/shared/card_title.dart';

class LookTab extends ConsumerWidget {
  final VoidCallback onNextTab;

  const LookTab({
    super.key,
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
              TeachWordCardTitle(
                // sectionName: '看一看',
                iconsColor: lightGray,
                title: '看一看',
                canNavigatePrevious: true,
                canNavigateNext: true,
                onPrevious: () {},
                onNext: () {},
              ),
              SizedBox(height: screenInfo.fontSize * 0.3),
              Align(
                alignment: isPortrait ? Alignment.center : Alignment.centerLeft,
                child: WordDisplay(
                  word: wordState.currentWord,
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

