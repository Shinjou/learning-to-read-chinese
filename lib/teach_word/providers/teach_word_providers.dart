// lib/teach_word/providers/teach_word_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/teach_word/states/navigation_state.dart';
import 'package:ltrc/teach_word/states/word_state.dart';

// new code
final wordStateProvider = StateNotifierProvider<WordStateNotifier, WordState?>((ref) {
  return WordStateNotifier();
});

class WordStateNotifier extends StateNotifier<WordState?> {
  WordStateNotifier() : super(null);

  void initialize({
    required String word,
    required int unitId,
    required String unitTitle,
    required bool isBpmf,
    required bool svgFileExist,
    required String svgData,
    required Map wordObj,
    required int vocabCnt,
    required bool isLearned,
    required WordStatus wordStatus,
  }) {
    final config = WordConfig(
      word: word,
      unitId: unitId,
      unitTitle: unitTitle,
      isBpmf: isBpmf,
      svgFileExist: svgFileExist,
      svgData: svgData,
      wordObj: wordObj,
      vocabCnt: vocabCnt,
    );

    state = WordState(
      config: config,
      isLearned: isLearned,
      wordStatus: wordStatus,
    );
  }

  void setWriteState(WriteState writeState) {
    if (state == null) return;
    state = state!.copyWith(writeState: writeState);
  }

  void updateLearnedStatus(bool isLearned) {
    if (state == null) return;
    state = state!.copyWith(isLearned: isLearned);
  }

  void updateTabIndex(int index) {
    if (state == null) return;
    state = state!.copyWith(currentTabIndex: index);
  }

  void updateWriteState(WriteState Function(WriteState) update) {
    if (state?.writeState == null) return;
    state = state!.copyWith(
      writeState: update(state!.writeState!),
    );
  }
}

// end of new code
// The following providers are the previous snippet

final contextProvider = Provider<BuildContext>((ref) {
  throw UnimplementedError('Context provider must be overridden at the widget level');
});

final navigationStateProvider = StateProvider<NavigationState>((ref) {
  final wordState = ref.watch(wordStateProvider);
  if (wordState == null) return const NavigationState();
  
  return NavigationState(
    currentTab: wordState.currentTabIndex,
    canNavigateNext: wordState.currentTabIndex < 3 && !wordState.isLearned,
    canNavigatePrev: wordState.currentTabIndex > 0,
  );
});

// New provider for the new word state

final wordConfigProvider = StateProvider<WordConfig?>((ref) => null);

final writeStateProvider = Provider<WriteState?>((ref) {
  return ref.watch(wordStateProvider)?.writeState;
});


