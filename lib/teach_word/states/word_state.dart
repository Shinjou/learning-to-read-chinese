// lib/teach_word/states/word_state.dart

import 'package:ltrc/data/models/word_status_model.dart';

enum QuizMode { none, practice, test }
enum StrokeMode { animation, practice, review }

class WordState {
  final String currentWord;
  final bool isLearned;
  final int nextStepId;
  final bool isBpmf;
  final bool svgExists;
  final int practiceTimeLeft;
  final bool isQuizzing;
  final bool isAnimating;
  final StrokeMode strokeMode;
  final bool showOutline;
  final WordStatus currentWordStatus;
  final int currentStroke;

  const WordState({
    required this.currentWord,
    this.isLearned = false,
    this.nextStepId = 0,
    this.isBpmf = false,
    this.svgExists = false,
    this.practiceTimeLeft = 4,
    this.isQuizzing = false,
    this.isAnimating = false,
    this.strokeMode = StrokeMode.animation,
    this.showOutline = true,
    required this.currentWordStatus,
    this.currentStroke = 0,
  });

  WordState copyWith({
    String? currentWord,

    bool? isLearned,
    int? nextStepId,
    bool? isBpmf,
    bool? svgExists,
    int? practiceTimeLeft,
    bool? isQuizzing,
    bool? isAnimating,
    StrokeMode? strokeMode,
    bool? showOutline,
    WordStatus? currentWordStatus,
    int? currentStroke,
  }) {
    return WordState(
      currentWord: currentWord ?? this.currentWord,
      isLearned: isLearned ?? this.isLearned,
      nextStepId: nextStepId ?? this.nextStepId,
      isBpmf: isBpmf ?? this.isBpmf,
      svgExists: svgExists ?? this.svgExists,
      practiceTimeLeft: practiceTimeLeft ?? this.practiceTimeLeft,
      isQuizzing: isQuizzing ?? this.isQuizzing,
      isAnimating: isAnimating ?? this.isAnimating,
      strokeMode: strokeMode ?? this.strokeMode,
      showOutline: showOutline ?? this.showOutline,
      currentWordStatus: currentWordStatus ?? this.currentWordStatus,
      currentStroke: currentStroke ?? this.currentStroke,
    );
  }
}

