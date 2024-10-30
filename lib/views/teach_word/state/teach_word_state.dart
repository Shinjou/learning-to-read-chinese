// lib/views/teach_word/state/teach_word_state.dart
// State for the TeachWord view, a foundational part of the app.
import 'package:flutter/foundation.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';

@immutable
class TeachWordState {
  final String word;
  final bool wordExists;
  final bool svgFileExists;
  final bool isLearned;
  final int nextStepId;
  final int practiceTimeLeft;
  final Map<String, dynamic> wordData;
  final int vocabCount;
  final int vocabIndex;
  final bool isBpmf;
  final bool img1Exists;
  final bool img2Exists;  
  final int currentTabIndex; 

  const TeachWordState({
    required this.word,
    this.wordExists = false,
    this.svgFileExists = false,
    this.isLearned = false,
    this.nextStepId = 0,
    this.practiceTimeLeft = 4,
    required this.wordData,
    this.vocabCount = 0,
    this.vocabIndex = 0,
    this.isBpmf = false,
    this.img1Exists = false, 
    this.img2Exists = false,     
    this.currentTabIndex = 0,
  });

  // Write tab control helpers
  bool get canShowStrokeOrder => 
    svgFileExists && (isLearned || nextStepId == TeachWordConstants.steps['seeAnimation']);

  bool get canShowWriteButton =>
    svgFileExists && (isLearned || 
    (nextStepId > TeachWordConstants.steps['seeAnimation']! &&
     nextStepId <= TeachWordConstants.steps['turnBorderOff']!));

  bool get canToggleOutline =>
    svgFileExists && (isLearned || nextStepId == TeachWordConstants.steps['turnBorderOff']);

  bool get canNavigateNext =>
    isLearned || nextStepId < TeachWordConstants.steps['goToUse2']!;

  bool get canNavigatePrevious => true;  // Always allow going back

  TeachWordState copyWith({
    String? word,
    bool? wordExists,
    bool? svgFileExists,
    bool? isLearned,
    int? nextStepId,
    int? practiceTimeLeft,
    Map<String, dynamic>? wordData,
    int? vocabCount,
    int? vocabIndex,
    bool? isBpmf,
    bool? img1Exists,
    bool? img2Exists,    
    int? currentTabIndex,
  }) {
    return TeachWordState(
      word: word ?? this.word,
      wordExists: wordExists ?? this.wordExists,
      svgFileExists: svgFileExists ?? this.svgFileExists,
      isLearned: isLearned ?? this.isLearned,
      nextStepId: nextStepId ?? this.nextStepId,
      practiceTimeLeft: practiceTimeLeft ?? this.practiceTimeLeft,
      wordData: wordData ?? this.wordData,
      vocabCount: vocabCount ?? this.vocabCount,
      vocabIndex: vocabIndex ?? this.vocabIndex,
      isBpmf: isBpmf ?? this.isBpmf,
      img1Exists: img1Exists ?? this.img1Exists,
      img2Exists: img2Exists ?? this.img2Exists,  
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,    
    );
  }

  @override
  String toString() {
    return 'TeachWordState(word: $word, exists: $wordExists, svg: $svgFileExists, '
           'learned: $isLearned, stepId: $nextStepId, practiceLeft: $practiceTimeLeft)';
  }
}
