// Claude's version

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