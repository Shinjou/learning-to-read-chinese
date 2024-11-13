// lib/teach_word/states/word_state.dart

import 'package:ltrc/data/models/word_status_model.dart';

enum QuizMode { none, practice, test }
enum StrokeMode { animation, practice, review }

class WordState {
  final String currentWord;
  final int unitId;
  final String unitTitle;
  final String fallbackWord;
  final bool isLearned;
  final int nextStepId;
  final bool isBpmf;
  final bool svgExists;
  final int practiceTimeLeft;
  final int currentTabIndex;
  final bool isQuizzing;
  final bool isAnimating;
  final StrokeMode strokeMode;
  final QuizMode quizMode;
  final bool showOutline;
  final int vocabCount;
  final String vocab1;
  final String vocab2;
  final String sentence1;
  final String sentence2;
  final String meaning1;
  final String meaning2;
  final WordStatus currentWordStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;
  final bool img1Exists;
  final bool img2Exists;
  final int currentStroke;
  final String svgData;

  const WordState({
    required this.currentWord,
    this.unitId = 0,
    this.unitTitle = '',
    this.fallbackWord = '學',
    this.isLearned = false,
    this.nextStepId = 0,
    this.isBpmf = false,
    this.svgExists = false,
    this.practiceTimeLeft = 4,
    this.currentTabIndex = 0,
    this.isQuizzing = false,
    this.isAnimating = false,
    this.strokeMode = StrokeMode.animation,
    this.quizMode = QuizMode.none,
    this.showOutline = true,
    this.vocabCount = 0,
    this.vocab1 = '',
    this.vocab2 = '',
    this.sentence1 = '',
    this.sentence2 = '',
    this.meaning1 = '',
    this.meaning2 = '',
    required this.currentWordStatus,
    this.wordsPhrase = const [],
    this.wordIndex = 0,
    this.img1Exists = false,
    this.img2Exists = false,
    this.currentStroke = 0,
    this.svgData = '',
  });

  WordState copyWith({
    String? currentWord,
    int? unitId,
    String? unitTitle,
    String? fallbackWord,
    bool? isLearned,
    int? nextStepId,
    bool? isBpmf,
    bool? svgExists,
    int? practiceTimeLeft,
    int? currentTabIndex,
    bool? isQuizzing,
    bool? isAnimating,
    StrokeMode? strokeMode,
    QuizMode? quizMode,
    bool? showOutline,
    int? vocabCount,
    String? vocab1,
    String? vocab2,
    String? sentence1,
    String? sentence2,
    String? meaning1,
    String? meaning2,
    WordStatus? currentWordStatus,
    List<Map>? wordsPhrase,
    int? wordIndex,
    bool? img1Exists,
    bool? img2Exists,
    int? currentStroke,
    String? svgData,
  }) {
    return WordState(
      currentWord: currentWord ?? this.currentWord,
      unitId: unitId ?? this.unitId,
      unitTitle: unitTitle ?? this.unitTitle,
      fallbackWord: fallbackWord ?? this.fallbackWord,
      isLearned: isLearned ?? this.isLearned,
      nextStepId: nextStepId ?? this.nextStepId,
      isBpmf: isBpmf ?? this.isBpmf,
      svgExists: svgExists ?? this.svgExists,
      practiceTimeLeft: practiceTimeLeft ?? this.practiceTimeLeft,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isQuizzing: isQuizzing ?? this.isQuizzing,
      isAnimating: isAnimating ?? this.isAnimating,
      strokeMode: strokeMode ?? this.strokeMode,
      quizMode: quizMode ?? this.quizMode,
      showOutline: showOutline ?? this.showOutline,
      vocabCount: vocabCount ?? this.vocabCount,
      vocab1: vocab1 ?? this.vocab1,
      vocab2: vocab2 ?? this.vocab2,
      sentence1: sentence1 ?? this.sentence1,
      sentence2: sentence2 ?? this.sentence2,
      meaning1: meaning1 ?? this.meaning1,
      meaning2: meaning2 ?? this.meaning2,
      currentWordStatus: currentWordStatus ?? this.currentWordStatus,
      wordsPhrase: wordsPhrase ?? this.wordsPhrase,
      wordIndex: wordIndex ?? this.wordIndex,
      img1Exists: img1Exists ?? this.img1Exists,
      img2Exists: img2Exists ?? this.img2Exists,
      currentStroke: currentStroke ?? this.currentStroke,
      svgData: svgData ?? this.svgData,
    );
  }
}

