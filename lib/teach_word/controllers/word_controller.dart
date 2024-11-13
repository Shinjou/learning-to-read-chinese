// lib/teach_word/controllers/word_controller.dart

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/data/models/word_status_model.dart';
// import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
import 'package:ltrc/teach_word/presentation/teach_word_view_testing.dart';
// import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/teach_word/services/word_service.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/teach_word/states/word_state.dart';

class WordController extends StateNotifier<WordState> {
  final BuildContext context;
  final Ref ref;
  final FlutterTts tts;
  final AudioPlayer player;
  final WordService wordService;
  StrokeOrderAnimationController? _strokeController;

  WordController(
    this.context,
    this.ref,
    this.tts,
    this.player,
    this.wordService,
    WordState initialState,
  ) : super(initialState) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    tts.setLanguage("zh-tw");
    tts.setSpeechRate(0.5);
    tts.setVolume(1.0);
    tts.setCompletionHandler(_onAudioComplete);
  }

  void _onAudioComplete() {
    if (state.nextStepId == TeachWordSteps.steps['goToListen']) {
      incrementNextStepId();
    } else if (state.nextStepId == TeachWordSteps.steps['goToUse1']) {
      handleGoToUse();
    }
  }

  // Called by teach_word_view.dart
  void setStrokeController(
    StrokeOrderAnimationController controller, 
    BuildContext context, 
    WidgetRef ref, 
    TeachWordView widget,
    double fontSize
  ) {
    _strokeController = controller;

    // Add necessary callbacks with access to context, ref, and widget
    controller.addOnQuizCompleteCallback((summary) {
      _handleQuizComplete(summary, fontSize, context, ref, widget);
    });
    
    controller.addOnWrongStrokeCallback(_handleWrongStroke);
    controller.addOnCorrectStrokeCallback(_handleCorrectStroke);
    controller.addListener(_handleStrokeControllerStateChange);
    syncStateWithController(controller);
  }

  /*
  void setStrokeController(StrokeOrderAnimationController controller) {
    _strokeController = controller;
    
    // Add all necessary callbacks
    controller.addOnQuizCompleteCallback(_handleQuizComplete);
    controller.addOnWrongStrokeCallback(_handleWrongStroke);
    controller.addOnCorrectStrokeCallback(_handleCorrectStroke);
    controller.addListener(_handleStrokeControllerStateChange);
    syncStateWithController(controller);
  }
  */

  // Used by setStrokeController in this class
  void _handleQuizComplete(
    QuizSummary summary, 
    double fontSize,
    BuildContext context, 
    WidgetRef ref, 
    TeachWordView widget
  ) {
    if (state.nextStepId >= TeachWordSteps.steps['practiceWithBorder1']! &&
        state.nextStepId <= TeachWordSteps.steps['turnBorderOff']!) {
      state = state.copyWith(
        practiceTimeLeft: state.practiceTimeLeft - 1,
        nextStepId: state.nextStepId + 1,
      );

      Fluttertoast.showToast(
        msg: state.nextStepId == TeachWordSteps.steps['turnBorderOff']
            ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 ${state.practiceTimeLeft} 遍哦！"
            : "恭喜筆畫正確！讓我們再練習 ${state.practiceTimeLeft} 次哦！",
        fontSize: fontSize * 1.2,
      );
    } else if (state.nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']) {
      state = state.copyWith(
        practiceTimeLeft: state.practiceTimeLeft - 1,
        nextStepId: state.nextStepId + 1,
        isLearned: true,
      );

      // Use `updateWordStatus` with ref and widget now accessible
      updateWordStatus(context, ref, widget.wordsStatus[widget.wordIndex], true);

      Fluttertoast.showToast(
        msg: "恭喜筆畫正確！",
        fontSize: fontSize * 1.2,
      );
    }
  }
  
  /*
  void _handleQuizComplete(QuizSummary summary, double fontSize) {
    if (state.nextStepId >= TeachWordSteps.steps['practiceWithBorder1']! &&
        state.nextStepId <= TeachWordSteps.steps['turnBorderOff']!) {
      state = state.copyWith(
        practiceTimeLeft: state.practiceTimeLeft - 1,
        nextStepId: state.nextStepId + 1,
      );
      
      // Show success toast
      Fluttertoast.showToast(
        msg: state.nextStepId == TeachWordSteps.steps['turnBorderOff']
            ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 ${state.practiceTimeLeft} 遍哦！"
            : "恭喜筆畫正確！讓我們再練習 ${state.practiceTimeLeft} 次哦！",
        fontSize: fontSize * 1.2,
      );
    } else if (state.nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']) {
      state = state.copyWith(
        practiceTimeLeft: state.practiceTimeLeft - 1,
        nextStepId: state.nextStepId + 1,
        isLearned: true,
      );
      // _updateWordStatus(true);
      updateWordStatus(context, ref, widget.wordsStatus[widget.wordIndex], true); 
      
      // Show success toast
      Fluttertoast.showToast(
        msg: "恭喜筆畫正確！",
        fontSize: fontSize * 1.2,
      );
    }
  }
  */

  void syncStateWithController(StrokeOrderAnimationController controller) {
    state = state.copyWith(
      isAnimating: controller.isAnimating,
      isQuizzing: controller.isQuizzing,
      showOutline: controller.showOutline,
      currentStroke: controller.currentStroke,
    );

    // Add listener for state changes
    controller.addListener(_handleStrokeControllerStateChange);
  }

  Future<String> loadSvgData(String word) async {
    final noSvgList = [
      '吔', '姍', '媼', '嬤', '履', '搧', '枴', '椏', '欓', '汙',
      '溼', '漥', '痠', '礫', '粄', '粿', '綰', '蓆', '襬', '譟',
      '踖', '踧', '鎚', '鏗', '鏘', '陳', '颺', '齒'
    ];
    debugPrint('Loading SVG data for word: $word');
    String tempWord = word;

    if (noSvgList.contains(word)) {
      tempWord = '學';
      state = state.copyWith(svgExists: false);
    } else {
      state = state.copyWith(svgExists: true);
    }

    try {
      final response = await rootBundle.loadString('lib/assets/svg/$tempWord.json');
      return response.replaceAll("\"", "'");
    } catch (e) {
      state = state.copyWith(svgExists: false);
      handleError('svgError');
      return '';
    }
  }

  void handleNavigationLogic(TabController tabController, {required bool isNext}) {
    final isLastStep = state.nextStepId >= TeachWordSteps.steps['goToUse2']!;
    final isFirstTab = tabController.index == 0;

    if (isNext && !isLastStep) {
      incrementNextStepId();
      tabController.animateTo(tabController.index + 1);
    } else if (!isNext && !isFirstTab) {
      tabController.animateTo(tabController.index - 1);
      decrementNextStepId();
    }
  }

  void incrementNextStepId() {
    state = state.copyWith(nextStepId: state.nextStepId + 1);
  }

  void decrementNextStepId() {
    final step = max(TeachWordSteps.steps['goToListen']!, state.nextStepId - 1);
    state = state.copyWith(nextStepId: step);
  }

  Future<void> handleGoToUse() async {
    try {
      switch (state.vocabCount) {
        case 1:
          await playVocabAudio(0);
          state = state.copyWith(
            nextStepId: TeachWordSteps.steps['goToUse2']!,
            isLearned: true,
          );
          break;
        case 2:
          if (state.nextStepId == TeachWordSteps.steps['goToUse1']) {
            await playVocabAudio(0);
            incrementNextStepId();
          } else if (state.nextStepId == TeachWordSteps.steps['goToUse2']) {
            await playVocabAudio(1);
            state = state.copyWith(isLearned: true);
          }
          break;
      }
    } catch (e) {
      debugPrint('Error in handleGoToUse: $e');
      handleError('audioError');
    }
  }

  Future<void> playWordAudio() async {
    if (state.isBpmf) {
      await player.play(AssetSource('bopomo/${state.currentWord}.mp3'));
    } else {
      await tts.speak(state.currentWord);
    }
  }

  Future<void> playVocabAudio(int index) async {
    final vocab = state.wordsPhrase[state.wordIndex]['vocab${index + 1}'];
    final sentence = state.wordsPhrase[state.wordIndex]['sentence${index + 1}'];
    await tts.speak("$vocab。$sentence");
  }

  StrokeOrderAnimationController get strokeController {
    if (_strokeController == null) {
      throw StateError('StrokeController not set');
    }
    return _strokeController!;
  }

  void _handleStrokeControllerStateChange() {
    if (_strokeController == null) return;
    
    state = state.copyWith(
      isAnimating: _strokeController!.isAnimating,
      isQuizzing: _strokeController!.isQuizzing,
      showOutline: _strokeController!.showOutline,
      currentStroke: _strokeController!.currentStroke,
    );
  }
  

  void _handleWrongStroke(int strokeIndex) {
    if (!mounted) return;
    
    if (_strokeController != null && 
        state.nextStepId >= TeachWordSteps.steps['practiceWithBorder1']! &&
        state.nextStepId <= TeachWordSteps.steps['practiceWithoutBorder1']!) {
      
      // Show hint after specified number of mistakes
      if (_strokeController!.summary.mistakes[strokeIndex] >= _strokeController!.hintAfterStrokes) {
        _strokeController!.animateHint();
      }
    }
  }

  void _handleCorrectStroke(int strokeIndex) {
    if (!mounted) return;
    
    // Update state if needed
    state = state.copyWith(
      currentStroke: strokeIndex + 1,
    );
  }


  Future<void> initializeWord(WordStatus wordStatus, Map wordPhrase) async {
    final word = wordStatus.word;
    final wordData = await wordService.getWordData(word);

    state = state.copyWith(
      currentWord: word,
      currentWordStatus: wordStatus,
      isLearned: wordStatus.learned,
      nextStepId: 0,
      isBpmf: wordData.isBpmf,
      svgExists: wordData.svgExists,
      img1Exists: wordData.img1Exists,
      img2Exists: wordData.img2Exists,
      svgData: wordData.svgData,
      vocab1: wordPhrase['vocab1'] ?? '',
      vocab2: wordPhrase['vocab2'] ?? '',
      sentence1: wordPhrase['sentence1'] ?? '',
      sentence2: wordPhrase['sentence2'] ?? '',
      meaning1: wordPhrase['meaning1'] ?? '',
      meaning2: wordPhrase['meaning2'] ?? '',
      vocabCount: _calculateVocabCount(wordPhrase),
      wordsPhrase: [wordPhrase],
      wordIndex: 0,
    );

    if (wordData.svgExists && _strokeController != null) {
      _strokeController!.setStrokeOrder(wordData.svgData);
    }
  }

  int _calculateVocabCount(Map wordPhrase) {
    int count = 0;
    if (wordPhrase['vocab1']?.isNotEmpty ?? false) count++;
    if (wordPhrase['vocab2']?.isNotEmpty ?? false) count++;
    return count;
  }


  void handleError(String errorType) {
    ref.read(errorHandlerProvider).handleError(
      switch (errorType) {
        'noSvg' => '抱歉，「${state.currentWord}」還沒有筆順。請繼續。謝謝！',
        'noWord' => '「${state.currentWord}」不在SQL。請截圖回報。謝謝！',
        'jsonError' => '「${state.currentWord}」的筆順檔無法下載。請截圖回報。謝謝！',
        'svgError' => '「${state.currentWord}」筆順檔問題。請截圖回報。謝謝！',
        _ => '「${state.currentWord}」發生未知錯誤。請截圖回報。謝謝！',
      },
      showHomeButton: errorType != 'noSvg',
      onDismiss: errorType == 'noSvg' ? _handleNoSvgError : null,
    );
  }

  void _handleNoSvgError() {
    state = state.copyWith(
      nextStepId: TeachWordSteps.steps['goToUse1']!,
      isLearned: true,
    );
  }

  void updateState({
    int? nextStepId,
    int? currentTabIndex,
    bool? isLearned,
    int? practiceTimeLeft,
  }) {
    state = state.copyWith(
      nextStepId: nextStepId,
      currentTabIndex: currentTabIndex,
      isLearned: isLearned,
      practiceTimeLeft: practiceTimeLeft,
    );
  }

  Future<void> _playVocabAudio(int index) async {
    final vocab = state.wordsPhrase[state.wordIndex]['vocab${index + 1}'];
    final sentence = state.wordsPhrase[state.wordIndex]['sentence${index + 1}'];
    await tts.speak("$vocab。$sentence");
  }

  Future<void> _updateWordStatus(bool learned) async {
    try {
      final newStatus = state.currentWordStatus.copyWith(learned: learned);
      ref.read(learnedWordCountProvider.notifier).state += learned ? 1 : 0;
      await wordService.markWordAsLearned(newStatus);
      state = state.copyWith(
        currentWordStatus: newStatus,
        isLearned: learned,
      );
    } catch (e) {
      debugPrint('Error updating word status: $e');
      handleError('statusUpdateError');
    }
  }
//====  Begin  ======================================================================
  void markWordAsLearned(WordState wordState) {
    state = state.copyWith(
      isLearned: true,
    );
    _updateWordStatus(true);
  }


  void handleStrokeAnimationPressed(WordState state) {
    if (!state.isQuizzing) {
      if (!state.isAnimating) {
        startAnimation();
        playWordAudio();
        if (state.nextStepId == TeachWordSteps.steps['seeAnimation']) {
          incrementNextStepId();
        }
      } else {
        stopAnimation();
      }
    }
  }

  void startPracticeMode(WordState state) {
    if (state.strokeMode != StrokeMode.practice) {
      state = state.copyWith(
        strokeMode: StrokeMode.practice,
        quizMode: QuizMode.practice,
        isQuizzing: true,
      );
      strokeController.startQuiz();
    }
  }

  void toggleOutline(WordState state) {
    state = state.copyWith(
      showOutline: !state.showOutline,
    );
    strokeController.setShowOutline(!strokeController.showOutline);
  }

  void startAnimation() {
    state = state.copyWith(
      isAnimating: true,
      strokeMode: StrokeMode.animation,
    );
    strokeController.startAnimation();
  }

  void stopAnimation() {
    state = state.copyWith(
      isAnimating: false,
    );
    strokeController.stopAnimation();
  }

  void checkStroke(List<Offset> strokes) {
    // Implement stroke checking logic here
    strokeController.checkStroke(strokes);
  }


//==== End  ==========================================================================


  @override
  void dispose() {
    tts.stop();
    player.dispose();
    if (_strokeController != null) {
      _strokeController!.removeListener(_handleStrokeControllerStateChange);
    }    
    super.dispose();
  }
}

