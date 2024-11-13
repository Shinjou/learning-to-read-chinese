// lib/teach_word/providers/word_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/core/utils/error_utils.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/providers/teach_word_providers.dart';
import 'package:ltrc/teach_word/services/word_service.dart';
import 'package:ltrc/teach_word/controllers/word_controller.dart';
import 'package:ltrc/teach_word/states/word_state.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
// import 'package:path/path.dart';

// Services and utilities providers
final wordServiceProvider = Provider<WordService>((ref) => WordService());


// State providers
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

// Main word controller provider
final wordControllerProvider = StateNotifierProvider<WordController, WordState>((ref) {
  final wordService = ref.watch(wordServiceProvider);
  final tts = ref.watch(ttsProvider);
  final player = ref.watch(audioPlayerProvider);
  final initialState = ref.watch(initialWordStateProvider);
  final context = ref.read(contextProvider);
  
  return WordController(
    context,
    ref,
    tts,
    player,
    wordService,
    initialState,
  );
});

// Stroke controller provider
final strokeControllerProvider = StateProvider.family<StrokeOrderAnimationController, TickerProvider>((ref, ticker) {
  return StrokeOrderAnimationController(
    '',
    ticker,
  );
});

// Error handling provider and implementation
final errorHandlerProvider = Provider<ErrorHandler>((ref) => ErrorHandler(ref));

class ErrorHandler {
  final Ref ref;

  ErrorHandler(this.ref);

  void handleError(String message, {
    String title = '',
    bool showHomeButton = true,
    VoidCallback? onDismiss,
    VoidCallback? onRetry,
    BuildContext? context,
  }) {
    if (context == null) return;
    
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
    required BuildContext context,
  }) {
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

