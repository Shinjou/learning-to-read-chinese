/* Completely over written by Claude on 2024/10/30
// lib/views/teach_word/state/teach_word_providers.dart
//  providers.dart handles "what", include all the state management, focuses on data
//  controllers.dart handles "how" (behavior), focuses on actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
// import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'dart:math';

// Word state provider
final teachWordStateProvider = StateNotifierProvider<TeachWordNotifier, TeachWordState>((ref) {
  return TeachWordNotifier();
});

// Stroke order controller provider
class StrokeOrderControllerNotifier extends StateNotifier<StrokeOrderAnimationController?> {
  StrokeOrderControllerNotifier() : super(null);

  void setController(StrokeOrderAnimationController controller) {
    debugPrint('Setting new stroke order controller');
    state?.dispose(); // Dispose old controller if exists
    state = controller;
  }

  @override
  void dispose() {
    debugPrint('Disposing StrokeOrderController');
    state?.dispose();
    super.dispose();
  }
}

final strokeOrderControllerProvider = StateNotifierProvider<StrokeOrderControllerNotifier, StrokeOrderAnimationController?>((ref) {
  return StrokeOrderControllerNotifier();
});

// Stroke animation state providers
final strokeAnimationPlayingProvider = StateProvider<bool>((ref) {
  final controller = ref.watch(strokeOrderControllerProvider);
  return controller?.isAnimating ?? false;
});

final strokeQuizActiveProvider = StateProvider<bool>((ref) {
  final controller = ref.watch(strokeOrderControllerProvider);
  return controller?.isQuizzing ?? false;
});

final showOutlineProvider = StateProvider<bool>((ref) {
  final controller = ref.watch(strokeOrderControllerProvider);
  return controller?.showOutline ?? false;
});

// Main state notifier
class TeachWordNotifier extends StateNotifier<TeachWordState> {
  TeachWordNotifier() : super(const TeachWordState(word: '', wordData: {}));

  void initializeWord(String word, Map<String, dynamic> wordData, bool isLearned, bool isBpmf) {
    debugPrint('initializeWord: $word, learned: $isLearned, isBpmf: $isBpmf');
    
    state = TeachWordState(
      word: word,
      wordData: wordData,
      isLearned: isLearned,
      isBpmf: isBpmf,
      nextStepId: 0,
    );
    
    _initializeWordData();
  }

  void processWordData(Map<String, dynamic>? wordData, int index, int totalLength) {
    debugPrint('Processing word data at index: $index');
    
    // Check for empty or invalid data
    if (wordData == null || wordData.isEmpty) {
      state = state.copyWith(
        wordExists: false,
        wordData: {},
        vocabCount: 0,
      );
      debugPrint('Word data is empty or null');
      return;
    }

    // Check index range
    if (index >= totalLength) {
      state = state.copyWith(
        wordExists: false,
        wordData: {},
        vocabCount: 0,
      );
      debugPrint('Word index out of range');
      return;
    }

    try {
      // Process vocab count
      int vocabCount = 0;
      if (wordData['vocab1']?.isNotEmpty ?? false) vocabCount++;
      if (wordData['vocab2']?.isNotEmpty ?? false) vocabCount++;

      // Update state with all word data
      state = state.copyWith(
        wordExists: true,
        wordData: wordData,
        vocabCount: vocabCount,
      );
      
      debugPrint('Word data processed successfully: exists: true, vocabCount: $vocabCount, vocab1: ${wordData['vocab1']}, vocab2: ${wordData['vocab2']}');
    } catch (error) {
      state = state.copyWith(
        wordExists: false,
        wordData: {},
        vocabCount: 0,
      );
      debugPrint('Error processing word data: $error');
    }
  }

  /*
  Future<void> initializeWordAndStroke() async {
    final state = ref.read(teachWordStateProvider);
    
    // Check if word exists in database
    if (!state.wordExists) {
      debugPrint('Word does not exist in database');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controllers.showErrorDialog(
          context,
          '',
          '「${state.word}」不在SQL。請截圖回報。謝謝！',
          ref.read(screenInfoProvider).fontSize,
        );
      });
      return;
    }

    // Process stroke order data
    try {
      final result = await readJson(state.word);
      final svgExists = ref.read(teachWordStateProvider).svgFileExists;
      debugPrint('Processing stroke data: ${state.word} ${svgExists ? "有筆順" : "沒有筆順"}');

      if (result.isNotEmpty) {
        // Initialize stroke controller
        await _controllers.initializeStrokeController(
          result,
          this,
          _handleQuizCompletion,
        );

        // Update state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(teachWordStateProvider.notifier).setSvgFileExists(true);
          if (svgExists) {
            debugPrint('Stroke data initialized: ${state.word} 筆順檔下載成功');
          } else {
            debugPrint('Stroke data initialized: 用"寫"替代，筆順檔下載成功');
          }
        });
      } else {
        // Handle empty result
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controllers.showErrorDialog(
            context,
            '',
            '「${state.word}」的筆順檔無法下載。請截圖回報。謝謝！',
            ref.read(screenInfoProvider).fontSize,
          );
          debugPrint('Error: ${state.word} 的筆順檔無法下載, svgExists: $svgExists');
          _numberOfNullStroke = 0;
          _showErrorDialog = false;
        });

        // Clear stroke controller
        ref.read(strokeOrderControllerProvider.notifier).setController(null);
        debugPrint('Stroke controller cleared due to empty result');
      }
    } catch (error) {
      // Handle error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controllers.showErrorDialog(
          context,
          '',
          '「${state.word}」筆順檔問題，請截圖回報。svgExists: ${state.svgFileExists}。謝謝！',
          ref.read(screenInfoProvider).fontSize,
        );
        _numberOfNullStroke = 0;
        _showErrorDialog = false;
      });

      // Clear stroke controller
      ref.read(strokeOrderControllerProvider.notifier).setController(null);
      debugPrint('Stroke controller cleared due to error: $error');
    }
  }
  */

  void _initializeWordData() {
    debugPrint('_initializeWordData() for: ${state.word}');
    
    int vocabCount = 0;
    if (state.wordData['vocab1']?.isNotEmpty ?? false) vocabCount++;
    if (state.wordData['vocab2']?.isNotEmpty ?? false) vocabCount++;

    state = state.copyWith(
      vocabCount: vocabCount,
      wordExists: true,
    );
    debugPrint('Word initialized with vocabCount: $vocabCount');
  }

  // State update methods
  void setSvgFileExists(bool exists) {
    debugPrint('setSvgFileExists: $exists for word: ${state.word}');
    state = state.copyWith(svgFileExists: exists);
  }

  void incrementNextStepId() {
    if (state.canNavigateNext) {
      state = state.copyWith(nextStepId: state.nextStepId + 1);
      debugPrint('incrementNextStepId to: ${state.nextStepId}');
    }
  }

  void decrementNextStepId() {
    state = state.copyWith(nextStepId: max(0, state.nextStepId - 1));
    debugPrint('decrementNextStepId to: ${state.nextStepId}');
  }

  void decrementPracticeTimeLeft() {
    if (state.practiceTimeLeft > 0) {
      state = state.copyWith(practiceTimeLeft: state.practiceTimeLeft - 1);
      debugPrint('decrementPracticeTimeLeft to: ${state.practiceTimeLeft}');
    }
  }

  void markWordAsLearned() {
    state = state.copyWith(isLearned: true);
    debugPrint('markWordAsLearned: ${state.word}');
  }  

  void handleWriteCompletion() {
    debugPrint('handleWriteCompletion at step: ${state.nextStepId}');
    
    if (state.nextStepId >= TeachWordConstants.steps['practiceWithBorder1']! &&
        state.nextStepId <= TeachWordConstants.steps['turnBorderOff']!) {
      decrementPracticeTimeLeft();
      incrementNextStepId();
    } else if (state.nextStepId == TeachWordConstants.steps['practiceWithoutBorder1']) {
      decrementPracticeTimeLeft();
      incrementNextStepId();
      markWordAsLearned();
    }
  }

  void updateVocabIndex(int index) {
    if (index >= 0 && index < state.vocabCount) {
      state = state.copyWith(vocabIndex: index);
      debugPrint('updateVocabIndex to: $index');
    }
  }  

  void setCurrentTabIndex(int index) {
    if (index >= 0 && index < TeachWordConstants.tabCount) {
      state = state.copyWith(currentTabIndex: index);
      debugPrint('setCurrentTabIndex to: $index');
    }
  }  

  void setImageExists(bool img1Exists, bool img2Exists) {
    state = state.copyWith(
      img1Exists: img1Exists,
      img2Exists: img2Exists,
    );
    debugPrint('Image exists flags updated: img1: $img1Exists, img2: $img2Exists');
  }

  void setIsBpmf(bool isBpmf) {
    state = state.copyWith(isBpmf: isBpmf);
    debugPrint('IsBpmf updated to: $isBpmf');
  }

  void resetState() {
    state = const TeachWordState(word: '', wordData: {});
    debugPrint('State reset to initial');
  }  
/*
  void setVocabIndex(int index) {
    if (index < 0 || index >= state.vocabCount) return;
    state = state.copyWith(vocabIndex: index);
  }

  void setCurrentTabIndex(int index) {
    if (index >= 0 && index < TeachWordConstants.tabCount) {
      debugPrint('setCurrentTabIndex to: $index');
      state = state.copyWith(currentTabIndex: index);
    }
  }

}

final teachWordStateProvider = StateNotifierProvider<TeachWordStateNotifier, TeachWordState>((ref) {
  return TeachWordStateNotifier();
});

// Provider to track learned word count
final learnedWordCountProvider = StateProvider<int>((ref) => 0);

// Provider to track current tab
// final currentTabIndexProvider = StateProvider<int>((ref) => 0);
var currentTabIndexProvider = StateProvider<int>((ref) => 0);

// Provider to access whether a word is learned
final isWordLearnedProvider = Provider<bool>((ref) => ref.watch(teachWordStateProvider).isWordLearned);
*/
}
*/

// teach_word_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';

// Main state provider
final teachWordStateProvider = StateNotifierProvider<TeachWordNotifier, TeachWordState>((ref) {
  return TeachWordNotifier();
});

// Audio providers
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    debugPrint('Disposing AudioPlayer');
    player.dispose();
  });
  return player;
});

final ttsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  tts.setLanguage("zh-tw");
  tts.setSpeechRate(0.5);
  tts.setVolume(1.0);
  ref.onDispose(() {
    debugPrint('Disposing FlutterTts');
    tts.stop();
  });
  return tts;
});

// Audio service provider
final audioServiceProvider = Provider((ref) {
  debugPrint('Creating AudioService');
  return AudioService(ref);
});

// Stroke order controller provider
class StrokeOrderControllerNotifier extends StateNotifier<StrokeOrderAnimationController?> {
  StrokeOrderControllerNotifier() : super(null);

  void setController(StrokeOrderAnimationController controller) {
    debugPrint('Setting new stroke order controller');
    state?.dispose();
    state = controller;
  }

  @override
  void dispose() {
    debugPrint('Disposing StrokeOrderController');
    state?.dispose();
    super.dispose();
  }
}

final strokeOrderControllerProvider = StateNotifierProvider<StrokeOrderControllerNotifier, StrokeOrderAnimationController?>((ref) {
  return StrokeOrderControllerNotifier();
});

// Stroke animation state providers
final strokeAnimationPlayingProvider = StateProvider<bool>((ref) {
  final controller = ref.watch(strokeOrderControllerProvider);
  return controller?.isAnimating ?? false;
});

final strokeQuizActiveProvider = StateProvider<bool>((ref) {
  final controller = ref.watch(strokeOrderControllerProvider);
  return controller?.isQuizzing ?? false;
});

final showOutlineProvider = StateProvider<bool>((ref) {
  final controller = ref.watch(strokeOrderControllerProvider);
  return controller?.showOutline ?? false;
});

// Audio service implementation
class AudioService {
  final ProviderRef _ref;
  bool _disposed = false;
  
  AudioService(this._ref) {
    _ref.onDispose(() {
      debugPrint('AudioService onDispose called');
      _dispose();
    });
  }

  Future<void> playWordSound(String word, bool isBpmf) async {
    if (_disposed) {
      debugPrint('Attempted to play sound after disposal');
      return;
    }
    
    try {
      if (isBpmf) {
        await _ref.read(audioPlayerProvider).play(AssetSource('bopomo/$word.mp3'));
      } else {
        await _ref.read(ttsProvider).speak(word);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _dispose() {
    debugPrint('Disposing AudioService');
    _disposed = true;
  }
}

// Main state notifier
class TeachWordNotifier extends StateNotifier<TeachWordState> {
  TeachWordNotifier() : super(const TeachWordState(word: '', wordData: {}));

  void initializeWord(String word, Map<String, dynamic> wordData, bool isLearned) {
    debugPrint('Initializing word: $word, learned: $isLearned');
    
    state = TeachWordState(
      word: word,
      wordData: wordData,
      isLearned: isLearned,
      nextStepId: 0,
    );
    
    _initializeWordData();
  }

  void _initializeWordData() {
    debugPrint('Initializing word data for: ${state.word}');
    
    int vocabCount = 0;
    if (state.wordData['vocab1']?.isNotEmpty ?? false) vocabCount++;
    if (state.wordData['vocab2']?.isNotEmpty ?? false) vocabCount++;

    state = state.copyWith(
      vocabCount: vocabCount,
      wordExists: true,
    );
  }

  void setSvgFileExists(bool exists) {
    debugPrint('Setting SVG file exists: $exists for word: ${state.word}');
    state = state.copyWith(svgFileExists: exists);
  }

  void incrementNextStepId() {
    if (state.canNavigateNext) {
      state = state.copyWith(nextStepId: state.nextStepId + 1);
      debugPrint('Step incremented to: ${state.nextStepId}');
    }
  }

  void decrementPracticeTimeLeft() {
    if (state.practiceTimeLeft > 0) {
      state = state.copyWith(practiceTimeLeft: state.practiceTimeLeft - 1);
      debugPrint('Practice time left: ${state.practiceTimeLeft}');
    }
  }

  void markWordAsLearned() {
    state = state.copyWith(isLearned: true);
    debugPrint('Word marked as learned: ${state.word}');
  }  

  void handleWriteCompletion() {
    debugPrint('Handling write completion at step: ${state.nextStepId}');
    
    if (state.nextStepId >= TeachWordConstants.steps['practiceWithBorder1']! &&
        state.nextStepId <= TeachWordConstants.steps['turnBorderOff']!) {
      decrementPracticeTimeLeft();
      incrementNextStepId();
    } else if (state.nextStepId == TeachWordConstants.steps['practiceWithoutBorder1']) {
      decrementPracticeTimeLeft();
      incrementNextStepId();
      markWordAsLearned();
    }
  }

  void updateVocabIndex(int index) {
    if (index >= 0 && index < state.vocabCount) {
      state = state.copyWith(vocabIndex: index);
      debugPrint('Vocab index updated to: $index');
    }
  }

  void setCurrentTabIndex(int index) {
    if (index >= 0 && index < TeachWordConstants.tabCount) {
      state = state.copyWith(currentTabIndex: index);
      debugPrint('Current tab index updated to: $index');
    }
  }

  void setIsBpmf(bool isBpmf) {
    state = state.copyWith(isBpmf: isBpmf);
    debugPrint('IsBpmf updated to: $isBpmf');
  }
}