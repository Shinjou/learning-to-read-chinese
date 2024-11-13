// lib/teach_word/presentation/teach_word_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';


void showErrorDialog(BuildContext context, String message, String title, double fontSize) {
  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              '回首頁',
              style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2),
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

Future<void> showNoSvgDialog(BuildContext context, String message, String title, double fontSize, FlutterTts ftts, String word, bool isBpmf, AudioPlayer player, VoidCallback onPreviousTab, VoidCallback onNextTab) async {
  if (!context.mounted) return;
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              '聽一聽',
              style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              if (isBpmf) {
                await player.play(AssetSource('bopomo/$word.mp3'));
              } else {
                await ftts.speak(word);
              }
              onPreviousTab();
            },
          ),
          TextButton(
            child: Text(
              '用一用',
              style: TextStyle(color: Colors.black, fontSize: fontSize * 1.2),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onNextTab();
            },
          ),
        ],
      );
    },
  );
}

void navigateToTab(TabController tabController, int currentTab, int nextTab, bool wordIsLearned) {
  if (wordIsLearned) { // If the word is learned, the user can navigate to any tab
    tabController.animateTo(nextTab);
  } else if (nextTab <= currentTab){ // If the word is not learned, the user can only navigate to previous tabs
    tabController.animateTo(nextTab);
  } else { // If the word is not learned, the user cannot navigate to future tabs
      tabController.animateTo(currentTab);
  }
}  

void navigateNextTab(TabController tabController) {
  if (tabController.index < tabController.length - 1) {
    tabController.animateTo(tabController.index + 1);
  }  
}  

void navigatePreviousTab(TabController tabController) {
    if (tabController.index > 0) {
      tabController.animateTo(tabController.index - 1);
    }
}  

Future<void> speakWord(String word, bool isBpmf, AudioPlayer player, FlutterTts ftts) async {
  if (isBpmf) {
    await player.play(AssetSource('bopomo/$word.mp3'));
  } else {
    await ftts.speak(word);
  }
}

Future<void> updateWordStatus(
  BuildContext context,
  WidgetRef ref,  
  WordStatus newStatus,
  bool learned,
) async {
  if (!context.mounted) return;

  try {
    newStatus.learned = learned;
    ref.read(learnedWordCountProvider.notifier).state += learned ? 1 : 0;
    await WordStatusProvider().updateWordStatus(status: newStatus);

    if (context.mounted) {
      // Set the state to update UI if necessary
      debugPrint('updateWordStatus: newStatus.learned: $learned');
    }
  } catch (e) {
    debugPrint('Error in updateWordStatus: $e');
    // Optional: Add error handling like showing a snackbar or alert
  }
}

void incrementNextStepId(
  ValueNotifier<int> nextStepIdNotifier,
) {
  nextStepIdNotifier.value += 1;
  debugPrint('incrementNextStepId: nextId: ${nextStepIdNotifier.value}');
}

Future<void> handleGoToUse(
  int vocabCnt,
  int nextStepId,
  Map wordObj,
  FlutterTts ftts,
  ValueNotifier<int> nextStepIdNotifier,
) async {
  debugPrint('utils handleGoToUse invoked. vocabCnt: $vocabCnt, nextId: $nextStepId');

  switch (vocabCnt) {
    case 1:
      await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
      nextStepIdNotifier.value = TeachWordSteps.steps['goToUse2']!;
      debugPrint('handleGoToUse: nextStepId updated to ${nextStepIdNotifier.value}');
      break;

    case 2:
      if (nextStepId == TeachWordSteps.steps['goToUse1']) {
        await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        nextStepIdNotifier.value += 1;
        debugPrint('handleGoToUse: nextStepId incremented to ${nextStepIdNotifier.value}');
      } else if (nextStepId == TeachWordSteps.steps['goToUse2']) {
        await ftts.speak("${wordObj['vocab2']}。${wordObj['sentence2']}");
        debugPrint('handleGoToUse: nextStepId remains ${nextStepIdNotifier.value}');
      }
      break;

    default:
      debugPrint('handleGoToUse Error: vocabCnt $vocabCnt, nextStepId $nextStepId');
  }
}



  /* The following methods should be moved from WriteTab to a central place
  void nextTab() async {
    if (kDebugMode) {
      final stackTrace = StackTrace.current.toString().split('\n');
      final relevantStackTrace = '\n${stackTrace[0]}\n${stackTrace[1]}';
      debugPrint('nextTab invoked for $word, at nextStepId: $nextStepId, currentTabIndex: $currentTabIndex.value, stack: $relevantStackTrace');
    }

    if (nextStepId >= TeachWordSteps.steps['goToUse2']!) {
      debugPrint('nextTab: Reached the final step, stopping navigation.');
      return;
    }

    int savedNextStepId = nextStepId;
    currentTabIndex.value += 1;

    if (svgFileExist) {
      if (wordIsLearned) { // 字已學
        if (savedNextStepId > 1 && savedNextStepId < 8) { // 1-7 different TeachWordSteps.steps in 寫一寫   
          nextStepId = TeachWordSteps.steps['goToUse1']!;
          debugPrint('nextTab $word, 字已學，要從"寫一寫"中的任一步驟，跳到"用一用"，savedId: $savedNextStepId，nextId: $nextStepId');
        } else { // 0, 8, 9
          debugPrint('nextTab $word,字已學，savedId: $savedNextStepId，nextId: $nextStepId');
        }
      } else { // 字未學，一步一步來  
        debugPrint('nextTab $word,字未學，savedId: $savedNextStepId，nextId: $nextStepId');
      }
    } else { // no SVG
      if (nextStepId > TeachWordSteps.steps['goToListen']! && nextStepId < TeachWordSteps.steps['goToUse1']!) {
        debugPrint('nextTab $word,no SVG1. 從 "聽一聽"到"寫一寫". Show error message.');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showNoSvgDialog('','抱歉，「$word」還沒有筆順。請繼續。謝謝！');
        });
        return; // Exit early to avoid updating `nextStepId`
      }
    }
    nextStepId = min(TeachWordSteps.steps['goToUse2']!, nextStepId);
    debugPrint('nextTab $word,svgFileExist $svgFileExist, savedId: $savedNextStepId, nextId: $nextStepId');

    if (nextStepId == TeachWordSteps.steps['goToListen']) {
      // 0      
      incrementNextStepId();
    } else if (nextStepId == TeachWordSteps.steps['goToWrite'] || nextStepId == (TeachWordSteps.steps['goToWrite']! + 1)) { // 1 & 2 sjf 9/8/24
      // 1、2
      incrementNextStepId();
      await _speakWord();
    } else if (nextStepId == TeachWordSteps.steps['goToUse1'] || nextStepId == TeachWordSteps.steps['goToUse2']) {
      await handleGoToUse();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('', '「$word」程序問題。請截圖回報。謝謝！');
      });
    }

    debugPrint('nextTab completed, nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}');
  }

  void prevTab() async {
    if (kDebugMode) {
      final stackTrace = StackTrace.current.toString().split('\n');
      final relevantStackTrace = '\n${stackTrace[0]}\n${stackTrace[1]}';
      debugPrint('prevTab invoked at nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}, stack: $relevantStackTrace');
    }    

    int currentTabValue = currentTabIndex.value;
    int savedNextStepId = nextStepId;

    debugPrint('prevTab currentTab $currentTabValue, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');

    if (currentTabValue > 0) { // to prevent negative value
      currentTabIndex.value -= 1;
    }

    if (svgFileExist) { // 有筆順
      if (wordIsLearned) { // 字已學
        if (nextStepId > 0 && nextStepId < 8) { // 1-7 different steps in 寫一寫
          nextStepId = TeachWordSteps.steps['goToListen']!;
          debugPrint('prevTab 字已學，要從"寫一寫"中的任一步驟，退回到"聽一聽" nextId: $nextStepId');
        } else { // 0, 8, 9
          nextStepId -= 1;
          if (nextStepId == TeachWordSteps.steps['goToPracticeWithoutBorder1']) {
            nextStepId = TeachWordSteps.steps['goToWrite']!;
          } else if (nextStepId < TeachWordSteps.steps['goToListen']!) {
            nextStepId = TeachWordSteps.steps['goToListen']!;
          }
          debugPrint('prevTab 字已學，nextStepId 從 0,8,9 變成 $nextStepId');
        }
      } else { // 字未學，一步一步來
        nextStepId -= 1;
        debugPrint('prevTab 字未學，savedId: $savedNextStepId，nextId: $nextStepId');
      }
    } else { // 沒有筆順
      // Check if we're at 'goToUse2', step back to 'goToUse1'
      if (nextStepId == TeachWordSteps.steps['goToUse2']) {
        nextStepId -= 1;
        debugPrint('prevTab no svg0. 從 "用一用2"退回到"用一用1". nextId = $nextStepId.');
        return;
      }

      // Check if we're at 'goToUse1', step back to 'goToWrite' and show error dialog
      if (nextStepId == TeachWordSteps.steps['goToUse1']) {
        debugPrint('prevTab no svg1. 從 "用一用1"退回到"寫一寫". Show error message.');
        
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showNoSvgDialog(
            '', 
            '抱歉，「$word」還沒有筆順。請繼續。謝謝！'
          );
        });
        
        nextStepId = TeachWordSteps.steps['practiceWithoutBorder1']!;
        debugPrint('prevTab no svg2. 從 "用一用1"退回到"寫一寫". nextId = $nextStepId.');
        return;
      }

      // For other cases, decrement the step by 1
      nextStepId -= 1;
      nextStepId = max(0, nextStepId);
      debugPrint('prevTab no svg3. savedId = $savedNextStepId, nextId = $nextStepId');
    }
  }

  void incrementNextStepId() {
    setState(() {
      nextStepId += 1;
      debugPrint('setState incrementNextStepId: nextId: $nextStepId');
    });
  }

  Future<void> handleGoToUse() async {
    debugPrint('handleGoToUse invoked. vocabCnt: $vocabCnt, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');

    switch (vocabCnt) {
      case 1:
        debugPrint('handleGoToUse vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, sentence1: ${wordObj['sentence1']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
        await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        setState(() {
          nextStepId = TeachWordSteps.steps['goToUse2']!;
          debugPrint('setState handleGoToUse: newStatus.learned = true');
        });
        break;

      case 2:
        switch (nextStepId) {
          case int stepId when stepId == TeachWordSteps.steps['goToUse1']:
            debugPrint('handleGoToUse vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, sentence1: ${wordObj['sentence1']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
            await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
            setState(() {
              nextStepId += 1;
              debugPrint('setState handleGoToUse: nextStepId: $nextStepId');
            });
            break;

          case int stepId when stepId == TeachWordSteps.steps['goToUse2']:
            debugPrint('handleGoToUse vocabCnt: $vocabCnt, vocab2: ${wordObj['vocab2']}, sentence2: ${wordObj['sentence2']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
            await ftts.speak("${wordObj['vocab2']}。${wordObj['sentence2']}");
            setState(() {
              debugPrint('setState handleGoToUse: nextStepId: $nextStepId');
            });
            break;

          default:
            debugPrint('Unexpected nextStepId for vocabCnt 2: $nextStepId');
        }
        break;

      default:
        debugPrint('handleGoToUse Error! vocabCnt: $vocabCnt, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
    }

    debugPrint('handleGoToUse completed, nextStepId: $nextStepId');
  }  

  Future<void> _speakWord(word) async {
    if (isBpmf) {
      await player.play(AssetSource('bopomo/$word.mp3'));
    } else {
      await ftts.speak(word);
    }
  }

  Future<void> _updateWordStatus(WordStatus newStatus, {required bool learned}) async {
    debugPrint('_updateWordStatus. mounted: ${context.mounted}, learned: $learned, nextStepId: $nextStepId');
    if (!context.mounted) return;

    try {
      newStatus.learned = learned;
      
      ref.read(learnedWordCountProvider.notifier).state += learned ? 1 : 0;
      
      await WordStatusProvider().updateWordStatus(status: newStatus);
      
      if (mounted) {
        setState(() {
          debugPrint('setState _updateWordStatus: newStatus.learned: $learned, nextStepId: $nextStepId');
        });
      }
    } catch (e) {
      debugPrint('Error in _updateWordStatus: $e');
      // Handle error (e.g., show a snackbar to the user)      
    }
  }  

  void showErrorDialog(String message, String title) {
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

  // Show error dialog for 寫一寫 if there is no SVG file
  Future<void> showNoSvgDialog(String message, String title) async {
    if (!context.mounted) return;
    // String word = widget.wordsStatus[widget.wordIndex].word;
    
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
                int savedNextStepId = nextStepId;
                int oldTabIndex = currentTabIndex.value;
                nextStepId = TeachWordSteps.steps['goToWrite']!;
                currentTabIndex.value = 2;                
                debugPrint('聽一聽 說：$word');
                speakWord(word, isBpmf, player, ftts,);
                debugPrint('寫一寫，上一頁1，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');            
                // prevTab(); // it will update the nextStepId and currentTabIndex 
                nextStepId = TeachWordSteps.steps['goToWrite']!;// sjf 10/8/24 hard code to go to 寫一寫
                debugPrint('寫一寫，上一頁2，force nextId to $nextStepId');
                // return tabController.animateTo(tabController.index - 1);
                widget.onPreviousTab();
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
                int savedNextStepId = nextStepId;
                widget.wordsStatus[widget.wordIndex].learned = true;
                _updateWordStatus(widget.wordsStatus[widget.wordIndex], learned: true);
                nextStepId = TeachWordSteps.steps['goToUse1']!; // Force to goToUse1
                debugPrint('寫一寫，下一頁，savedId: $savedNextStepId,  nextId: $nextStepId，呼叫 handleGoToUse()');                   
                handleGoToUse();
                currentTabIndex.value += 1;
                return tabController.animateTo(tabController.index + 1);
              },
            ),
          ],
        );
      },
    );
  }

  */ 
  // End of methods to be moved to a central place
