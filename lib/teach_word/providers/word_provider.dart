// lib/teach_word/providers/word_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/core/utils/error_utils.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/services/word_service.dart';
import '../controllers/word_controller.dart';
import '../states/word_state.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';


// Context provider - must be overridden at widget level
final contextProvider = Provider<BuildContext>((ref) {
  throw UnimplementedError('Context provider must be overridden at the widget level');
});

// Word controller provider with correct constructor parameters
final wordControllerProvider = StateNotifierProvider<WordController, WordState>((ref) {
  final context = ref.watch(contextProvider);
  final wordService = ref.watch(wordServiceProvider);
  final initialState = ref.watch(initialWordStateProvider);
  final tts = ref.watch(ttsProvider);
  final player = ref.watch(audioPlayerProvider);

  return WordController(
    context,
    ref,
    tts,
    player,
    wordService,
    initialState,
  );
});

final strokeControllerProvider = StateProvider.family<StrokeOrderAnimationController, TickerProvider>((ref, ticker) {
  return StrokeOrderAnimationController(
    '',
    ticker,
  );
});

final initialWordStateProvider = Provider<WordState>((ref) {
  return WordState(
    currentWord: '',
    currentWordStatus: WordStatus(
      id: 0,
      userAccount: '',
      word: '',
      learned: false,
      liked: false,
    ),
  );
});

final wordServiceProvider = Provider<WordService>((ref) {
  return WordService();
});

// Error handler provider
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler(ref);
});

class ErrorHandler {
  final Ref ref;

  ErrorHandler(this.ref);

  void handleError(String message, {
    String title = '',
    bool showHomeButton = true,
    VoidCallback? onDismiss,
    VoidCallback? onRetry,
  }) {
    final context = ref.read(contextProvider);
    ErrorUtils.showError(
      context,
      message,
      title: title,
      showHomeButton: showHomeButton,
      onDismiss: onDismiss,
      onRetry: onRetry,
    );
  }

  void showNoSvgError({
    required String word,
    required VoidCallback onListenPressed,
    required VoidCallback onUsePressed,
  }) {
    final context = ref.read(contextProvider);
    ErrorUtils.showError(
      context,
      '抱歉，「$word」還沒有筆順。請繼續。謝謝！',
      title: '',
      showHomeButton: false,
      onDismiss: onUsePressed,
      onRetry: onListenPressed,
    );
  }
}

// Audio state provider and related classes
class AudioPlaybackState {
  final bool isPlaying;
  final bool isSpeaking;

  const AudioPlaybackState({
    this.isPlaying = false,
    this.isSpeaking = false,
  });

  AudioPlaybackState copyWith({
    bool? isPlaying,
    bool? isSpeaking,
  }) {
    return AudioPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

final audioStateProvider = StateProvider<AudioPlaybackState>((ref) {
  return const AudioPlaybackState();
});

// Navigation state provider and related classes
class NavigationState {
  final int currentTab;
  final bool canNavigateNext;
  final bool canNavigatePrev;

  const NavigationState({
    this.currentTab = 0,
    this.canNavigateNext = true,
    this.canNavigatePrev = false,
  });

  NavigationState copyWith({
    int? currentTab,
    bool? canNavigateNext,
    bool? canNavigatePrev,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      canNavigateNext: canNavigateNext ?? this.canNavigateNext,
      canNavigatePrev: canNavigatePrev ?? this.canNavigatePrev,
    );
  }
}

final navigationStateProvider = StateProvider<NavigationState>((ref) {
  return const NavigationState();
});
