/* completely over written by Claude on 2024/10/30
// ./lib/views/teach_word/teach_word_controllers.dart
//  providers.dart handles "what" (state)
//  controllers.dart handles "how" (behavior)
//  providers.dart focuses on data
//  controllers.dart focuses on actions
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';


// Provider for TeachWordControllers
final teachWordControllersProvider = Provider.family<TeachWordControllers, TickerProvider>((ref, tickerProvider) {
  final tabController = TabController(
    length: TeachWordConstants.tabCount,
    vsync: tickerProvider,
  );
  
  return TeachWordControllers(ref as WidgetRef, tabController);
});

class TeachWordControllers {
  final WidgetRef ref;  
  final TabController tabController;
  StrokeOrderAnimationController? strokeOrderAnimationController;

  TeachWordControllers(this.ref, this.tabController) {
    debugPrint('TeachWordControllers initialized');

    tabController.addListener(() {
      final state = ref.read(teachWordStateProvider);
      debugPrint('Tab changed to: ${tabController.index} for word: ${state.word}');
    });
  }

  // Navigation Methods
  bool navigateToNextTab() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Attempting next navigation - current step: ${state.nextStepId}, learned: ${state.isLearned}');

    if (shouldShowNoSvgDialog(state)) {
      debugPrint('No SVG file exists, navigation blocked');
      return false;
    }

    // Check for no SVG when moving to Write tab
    if (!state.svgFileExists && 
        state.nextStepId > TeachWordConstants.steps['goToListen']! && 
        state.nextStepId < TeachWordConstants.steps['goToUse1']!) {
      debugPrint('No SVG file exists, showing dialog - from 聽一聽 to 寫一寫');
      onNoSvgError(state.word);
      return false;
    }

    if (!state.canNavigateNext) {
      debugPrint('Cannot navigate next - conditions not met');
      return false;
    }

    if (state.isLearned) {
      _navigateToNextTabLearned();
    } else {
      _navigateToNextTabUnlearned(state);
    }
    return true;
  }

  bool navigateToPreviousTab() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Attempting previous navigation - current step: ${state.nextStepId}, learned: ${state.isLearned}');

    if (shouldShowNoSvgDialog(state)) {
      debugPrint('No SVG file exists, navigation blocked');
      return false;
    }
    // Check for no SVG when moving back to Write tab
    if (!state.svgFileExists && state.nextStepId == TeachWordConstants.steps['goToUse1']) {
      debugPrint('No SVG file exists, showing dialog - from 用一用 to 寫一寫');
      onNoSvgError(state.word);
      return false;
    }

    if (tabController.index > 0) {
      if (state.isLearned) {
        _navigateToPreviousTabLearned();
      } else {
        _navigateToPreviousTabUnlearned(state);
      }
    }
    return true;
  }

  void _navigateToNextTabLearned() {
    int nextIndex = tabController.index + 1;
    if (nextIndex < tabController.length) {
      debugPrint('Learned word - moving to next tab: $nextIndex');
      tabController.animateTo(nextIndex);
    }
  }

  void _navigateToNextTabUnlearned(TeachWordState state) {
    int targetIndex = _getTargetTabIndex(state.nextStepId);
    if (targetIndex != tabController.index && targetIndex < tabController.length) {
      debugPrint('Unlearned word - moving to target tab: $targetIndex');
      tabController.animateTo(targetIndex);
    }
  }

  void _navigateToPreviousTabLearned() {
    debugPrint('Learned word - moving to previous tab');
    tabController.animateTo(tabController.index - 1);
  }

  void _navigateToPreviousTabUnlearned(TeachWordState state) {
    int targetIndex = _getTargetTabIndex(state.nextStepId - 1);
    debugPrint('Unlearned word - moving to target tab: $targetIndex');
    tabController.animateTo(targetIndex);
  }

  int _getTargetTabIndex(int stepId) {
    if (stepId < TeachWordConstants.steps['goToListen']!) {
      return 0; // Look tab
    } else if (stepId < TeachWordConstants.steps['goToWrite']!) {
      return 1; // Listen tab
    } else if (stepId < TeachWordConstants.steps['goToUse1']!) {
      return 2; // Write tab
    } else {
      return 3; // Use tab
    }
  }  

  // Stroke Order Control Methods
  Future<void> initializeStrokeController(
    String jsonData,
    TickerProvider vsync,
    Function(QuizSummary) onQuizComplete
  ) async {
    debugPrint('initializeStrokeController');
    strokeOrderAnimationController = StrokeOrderAnimationController(
      jsonData,
      vsync,
      onQuizCompleteCallback: onQuizComplete,
    );
    ref.read(strokeOrderControllerProvider.notifier).setController(strokeOrderAnimationController!);
  }

  Future<void> initializeWordAndStroke(
    BuildContext context,
    TickerProvider vsync,
    Function(QuizSummary) onQuizComplete,
    Future<String> Function(String) readJsonFunction,
  ) async {
    final state = ref.read(teachWordStateProvider);
    
    // Check if word exists in database
    if (!state.wordExists) {
      debugPrint('Word does not exist in database');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(
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
      final result = await readJsonFunction(state.word);
      final svgExists = ref.read(teachWordStateProvider).svgFileExists;
      debugPrint('Processing stroke data: ${state.word} ${svgExists ? "有筆順" : "沒有筆順"}');

      if (result.isNotEmpty) {
        // Initialize stroke controller
        await initializeStrokeController(
          result,
          vsync,
          onQuizComplete,
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
          showErrorDialog(
            context,
            '',
            '「${state.word}」的筆順檔無法下載。請截圖回報。謝謝！',
            ref.read(screenInfoProvider).fontSize,
          );
          debugPrint('Error: ${state.word} 的筆順檔無法下載, svgExists: $svgExists');
        });

        // Clear stroke controller
        ref.read(strokeOrderControllerProvider.notifier).state = null;
      }
    } catch (error) {
      // Handle error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(
          context,
          '',
          '「${state.word}」筆順檔問題，請截圖回報。svgExists: ${state.svgFileExists}。謝謝！',
          ref.read(screenInfoProvider).fontSize,
        );
      });

      // Clear stroke controller
      ref.read(strokeOrderControllerProvider.notifier).state = null;
      debugPrint('Stroke controller cleared due to error: $error');
    }
  }

  void handleStrokeOrderAnimation() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Handling stroke animation - stepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    if (state.canShowStrokeOrder && strokeOrderAnimationController != null) {
      if (!strokeOrderAnimationController!.isAnimating) {
        strokeOrderAnimationController!.startAnimation();
        if (state.nextStepId == TeachWordConstants.steps['seeAnimation']) {
          ref.read(teachWordStateProvider.notifier).incrementNextStepId();
        }
      } else {
        strokeOrderAnimationController!.stopAnimation();
      }
    }
  }

  void handleWriting() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Handling writing - stepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    if (state.canShowWriteButton && strokeOrderAnimationController != null) {
      strokeOrderAnimationController!.startQuiz();
    }
  }

  void handleOutlineToggle() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Handling outline toggle - stepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    if (state.canToggleOutline && strokeOrderAnimationController != null) {
      strokeOrderAnimationController!.setShowOutline(!strokeOrderAnimationController!.showOutline);
      
      if (state.nextStepId == TeachWordConstants.steps['turnBorderOff']) {
        ref.read(teachWordStateProvider.notifier).incrementNextStepId();
      }
    }
  }

  // Add methods to notify the view about NoSvg situations
  bool shouldShowNoSvgDialog(TeachWordState state) {
    if (!state.svgFileExists && 
        state.nextStepId > TeachWordConstants.steps['goToListen']! && 
        state.nextStepId < TeachWordConstants.steps['goToUse1']!) {
      debugPrint('No SVG when moving to Write tab');
      return true;
    }
    if (!state.svgFileExists && state.nextStepId == TeachWordConstants.steps['goToUse1']) {
      debugPrint('No SVG when moving back to Write tab');
      return true;
    }
    return false;
  }

  void showErrorDialog(BuildContext context, String title, String message, double fontSize) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,  // This ensures the dialog is modal
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize * 1.2,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize * 1.2,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '回首頁',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize * 1.2,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/mainPage');
              },
            ),
          ],
        );
      },
    );
  }


  // UI Feedback Methods
  void showPracticeCompletionToast(int practiceTimeLeft, bool isTurnOffBorder, double fontSize) {
    String message = isTurnOffBorder
        ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 $practiceTimeLeft 遍哦！"
        : "恭喜筆畫正確！讓我們再練習 $practiceTimeLeft 次哦！";

    Fluttertoast.showToast(
      msg: message,
      fontSize: fontSize * 1.2,
    );
  }

  void showCompletionToast(double fontSize) {
    Fluttertoast.showToast(
      msg: "恭喜筆畫正確！",
      fontSize: fontSize * 1.2,
    );
  }

  Future<void> showNoSvgDialog(BuildContext context, String title, String message, double fontSize) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,      
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize * 1.2,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize * 1.2,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '聽一聽',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize * 1.2,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                debugPrint('聽一聽 說：$word');
                final audioService = ref.read(audioServiceProvider);
                await audioService.playWordSound(word, isBpmf);
                ref.read(teachWordStateProvider.notifier).setCurrentTabIndex(1);
                debugPrint('寫一寫，上一頁1，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');   
                _controllers.tabController.animateTo(1);
                /* old code
                int savedNextStepId = nextStepId;
                int oldTabIndex = currentTabIndex.value;
                nextStepId = steps['goToWrite']!;
                currentTabIndex.value = 2;                
                debugPrint('聽一聽 說：$word');
                if (isBpmf) {
                  await player.play(AssetSource('bopomo/$word.mp3'));
                } else {
                  await ftts.speak(word);
                }
                debugPrint('寫一寫，上一頁1，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');            
                prevTab(); // it will update the nextStepId and currentTabIndex 
                nextStepId = steps['goToWrite']!;// sjf 10/8/24 hard code to go to 寫一寫
                debugPrint('寫一寫，上一頁2，force nextId to $nextStepId');
                return _tabController.animateTo(_tabController.index - 1);
                */
              },              
            ),
            TextButton(
              child: Text(
                '用一用',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize * 1.2,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Update state
                widget.wordsStatus[widget.wordIndex].learned = true;
                _updateWordStatusInDatabase();
                ref.read(teachWordStateProvider.notifier)
                  ..setCurrentTabIndex(3)
                  ..markWordAsLearned();
                _controllers.tabController.animateTo(3);                
                /* old code
                int savedNextStepId = nextStepId;
                widget.wordsStatus[widget.wordIndex].learned = true;
                _updateWordStatus(widget.wordsStatus[widget.wordIndex], learned: true);
                nextStepId = steps['goToUse1']!; // Force to goToUse1
                debugPrint('寫一寫，下一頁，savedId: $savedNextStepId,  nextId: $nextStepId，呼叫 handleGoToUse()');                   
                handleGoToUse();
                currentTabIndex.value += 1;
                return _tabController.animateTo(_tabController.index + 1);
                */
              },
            ),          
          ],
        );
      },
    );
  }

  void dispose() {    
    debugPrint('Disposing controllers');
    strokeOrderAnimationController?.dispose();
    tabController.dispose();
  }
}

// Provider for TeachWordControllers
/*
final teachWordControllersProvider = Provider.family<TeachWordControllers, TickerProvider>((ref, tickerProvider) {
  final tabController = TabController(
    length: TeachWordConstants.tabCount,
    vsync: tickerProvider,
  );
  
  return TeachWordControllers(ref as WidgetRef, tabController);
});
*/

/*
  Future<void> handleNextInLookTab(TeachWordState state) async {
    debugPrint('handleNextInLookTab - starting navigation');
    navigateToNextTab(state);
    debugPrint('handleNextInLookTab - completed navigation');
  }

  void handlePreviousInListenTab(TeachWordState state) {
    debugPrint('TeachWordControllers handlePreviousInListenTab - before navigation');
    navigateToPrevTab(state);
    debugPrint('TeachWordControllers handlePreviousInListenTab - after navigation');
  }

  void handleNextInListenTab(TeachWordState state, WidgetRef ref) {
    debugPrint('handleNextInListenTab - starting navigation');
    // State update is now handled in the tab component
    navigateToNextTab(state);
    debugPrint('handleNextInListenTab - completed navigation');
  }

  void navigateToNextTab(TeachWordState state) {
    debugPrint('navigateToNextTab - current: ${state.currentTabIndex}, nextStepId: ${state.nextStepId}');
    if (state.currentTabIndex < TeachWordConstants.tabCount - 1) {
      tabController.animateTo(state.currentTabIndex + 1);
      debugPrint('Tab animation completed');
    }
  }

  void navigateToPrevTab(TeachWordState state) {
    debugPrint('TeachWordControllers navigateToPrevTab - currentTabIndex: ${state.currentTabIndex}');
    if (state.currentTabIndex > 0) {
      tabController.animateTo(state.currentTabIndex - 1);
    }
  }

  void handlePreviousInWriteTab(TeachWordState state) {
    navigateToPrevTab(state);
  }

  void handleNextInWriteTab(TeachWordState state) {
    navigateToNextTab(state);
  }

  void handlePreviousInUseTab(TeachWordState state, WidgetRef ref) {
    if (state.vocabIndex == 0) {
      navigateToPrevTab(state);
    }
  }

  void handleNextInUseTab(TeachWordState state, WidgetRef ref) {
    // Handle state changes before navigation
    if (state.nextStepId == TeachWordConstants.steps['goToUse${state.vocabIndex + 2}']) {
      ref.read(teachWordStateProvider.notifier).incrementNextStepId();
    }
    navigateToNextTab(state);
  }

  void incrementNextStepId(TeachWordState state, WidgetRef ref) {
    ref.read(teachWordStateProvider.notifier).incrementNextStepId();
  }

  void initializeStrokeAnimationController(String json, {
    required Function(QuizSummary) onQuizComplete,
  }) {
    strokeOrderAnimationController = StrokeOrderAnimationController(
      json,
      _tickerProvider,
      onQuizCompleteCallback: onQuizComplete,
    );
  }

  void startAnimation(TeachWordState state) async {
    if (strokeOrderAnimationController?.isAnimating == false) {
      strokeOrderAnimationController?.startAnimation();
      await playWordSound(state.word, state.isBpmf);
    }
  }

  void stopAnimation() {
    strokeOrderAnimationController?.stopAnimation();
  }


  Future<void> handleWriteToggle(TeachWordState state) async {
    await playWordSound(state.word, state.isBpmf);
    strokeOrderAnimationController?.startQuiz();
  }

  void handleOutlineToggle(TeachWordState state, WidgetRef ref) {
    if (state.nextStepId == TeachWordConstants.steps['turnBorderOff']) {
      ref.read(teachWordStateProvider.notifier).incrementNextStepId();
    }
    strokeOrderAnimationController?.setShowOutline(
      !strokeOrderAnimationController!.showOutline
    );
  }

  void handleQuizCompletion(QuizSummary summary, TeachWordState state, double fontSize) {
    if (state.nextStepId >= TeachWordConstants.steps['practiceWithBorder1']! &&
        state.nextStepId <= TeachWordConstants.steps['turnBorderOff']!) {
      showPracticeCompletionToast(
        state.practiceTimeLeft,
        state.nextStepId == TeachWordConstants.steps['turnBorderOff'],
        fontSize,
      );
    } else if (state.nextStepId == TeachWordConstants.steps['practiceWithoutBorder1']) {
      showCompletionToast(fontSize);
    }
    onQuizCompleteCallback?.call();
  }

  void showPracticeCompletionToast(int practiceTimeLeft, bool isLastPractice, double fontSize) {
    Fluttertoast.showToast(
      msg: isLastPractice 
        ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 $practiceTimeLeft 遍哦！"
        : "恭喜筆畫正確！讓我們再練習 $practiceTimeLeft 次哦！",
      fontSize: fontSize,
    );
  }

  void showCompletionToast(double fontSize) {
    Fluttertoast.showToast(
      msg: "恭喜筆畫正確！",
      fontSize: fontSize,
    );
  }



  void handleJsonError(BuildContext context, String word) {
    debugPrint('JSON error for word: $word');
    showErrorDialog(
      context,
      '',
      '「$word」不在SQL。請截圖回報。謝謝！',
    );
  }

  void handleJsonProcessError(BuildContext context, String word) {
    showErrorDialog(
      context,
      '',
      '「$word」筆順檔問題，請截圖回報。謝謝！',
    );
  }

  Future<void> playWordSound(String word, bool isBpmf) async {
    debugPrint('playWordSound: $word, isBpmf: $isBpmf');
    if (isBpmf) {
      await player?.play(AssetSource('bopomo/$word.mp3'));
    } else {
      await ftts?.speak(word);
    }
  }

  void dispose() {    
    debugPrint('Disposing controllers');
    tabController.dispose();
    strokeOrderAnimationController?.dispose();
    ftts?.stop();
    player?.dispose();
    ftts = null;
    player = null;
  }
}
*/
*/

// teach_word_controllers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
// import 'package:ltrc/providers.dart';

// Provider for TeachWordControllers
final teachWordControllersProvider = Provider.family<TeachWordControllers, TickerProvider>((ref, tickerProvider) {
  final tabController = TabController(
    length: TeachWordConstants.tabCount,
    vsync: tickerProvider,
  );
  
  return TeachWordControllers(ref as WidgetRef, tabController);
});

class TeachWordControllers {
  final WidgetRef ref;  
  final TabController tabController;
  StrokeOrderAnimationController? strokeOrderAnimationController;

  TeachWordControllers(this.ref, this.tabController) {
    debugPrint('TeachWordControllers initialized');
    
    tabController.addListener(() {
      final state = ref.read(teachWordStateProvider);
      debugPrint('Tab changed to: ${tabController.index} for word: ${state.word}');
    });
  }

  // Stroke Order Control Methods
  Future<void> initializeStrokeController(
    String jsonData,
    TickerProvider vsync,
    Function(QuizSummary) onQuizComplete
  ) async {
    debugPrint('Initializing stroke controller');
    strokeOrderAnimationController = StrokeOrderAnimationController(
      jsonData,
      vsync,
      onQuizCompleteCallback: onQuizComplete,
    );
    ref.read(strokeOrderControllerProvider.notifier).setController(strokeOrderAnimationController!);
  }

  void handleStrokeOrderAnimation() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Handling stroke animation - stepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    if (state.canShowStrokeOrder && strokeOrderAnimationController != null) {
      if (!strokeOrderAnimationController!.isAnimating) {
        strokeOrderAnimationController!.startAnimation();
        if (state.nextStepId == TeachWordConstants.steps['seeAnimation']) {
          ref.read(teachWordStateProvider.notifier).incrementNextStepId();
        }
      } else {
        strokeOrderAnimationController!.stopAnimation();
      }
    }
  }

  void handleWriting() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Handling writing - stepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    if (state.canShowWriteButton && strokeOrderAnimationController != null) {
      strokeOrderAnimationController!.startQuiz();
    }
  }

  void handleOutlineToggle() {
    final state = ref.read(teachWordStateProvider);
    debugPrint('Handling outline toggle - stepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    if (state.canToggleOutline && strokeOrderAnimationController != null) {
      strokeOrderAnimationController!.setShowOutline(!strokeOrderAnimationController!.showOutline);
      
      if (state.nextStepId == TeachWordConstants.steps['turnBorderOff']) {
        ref.read(teachWordStateProvider.notifier).incrementNextStepId();
      }
    }
  }

  bool shouldShowNoSvgDialog(TeachWordState state) {
    if (!state.svgFileExists && 
        state.nextStepId > TeachWordConstants.steps['goToListen']! && 
        state.nextStepId < TeachWordConstants.steps['goToUse1']!) {
      debugPrint('No SVG when moving to Write tab');
      return true;
    }
    if (!state.svgFileExists && state.nextStepId == TeachWordConstants.steps['goToUse1']) {
      debugPrint('No SVG when moving back to Write tab');
      return true;
    }
    return false;
  }

  void showErrorDialog(BuildContext context, String title, String message, double fontSize) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize * 1.2,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize * 1.2,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '回首頁',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: fontSize * 1.2,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/mainPage');
              },
            ),
          ],
        );
      },
    );
  }

  void showPracticeCompletionToast(int practiceTimeLeft, bool isTurnOffBorder, double fontSize) {
    String message = isTurnOffBorder
        ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 $practiceTimeLeft 遍哦！"
        : "恭喜筆畫正確！讓我們再練習 $practiceTimeLeft 次哦！";

    Fluttertoast.showToast(
      msg: message,
      fontSize: fontSize * 1.2,
    );
  }

  void showCompletionToast(double fontSize) {
    Fluttertoast.showToast(
      msg: "恭喜筆畫正確！",
      fontSize: fontSize * 1.2,
    );
  }

  void dispose() {    
    debugPrint('Disposing controllers');
    strokeOrderAnimationController?.dispose();
    tabController.dispose();
  }
}