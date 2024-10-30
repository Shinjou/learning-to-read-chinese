// Claude version 

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
  final Ref _ref;
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