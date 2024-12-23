// lib/teach_word/presentation/teach_word_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/views/view_utils.dart'; 


const lookTabNum = 0;
const listenTabNum = lookTabNum + 1;
const writeTabNum = listenTabNum + 1;
const useTabNum = writeTabNum + 1;
const speakTabNum = useTabNum + 1;
const totalTabNum = speakTabNum + 1;

const List<String> tabNames = ['看一看', '聽一聽', '寫一寫', '用一用', '說一說'];

void showErrorDialog(BuildContext context, WidgetRef ref, String message, String title) {
  if (!context.mounted) return;

  final screenInfo = ref.read(screenInfoProvider); 
  final fontSize = screenInfo.fontSize;

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
              if (context.mounted) {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/mainPage');
              }
            },
          ),
        ],
      );
    },
  );
}

/// Navigates to the next character.
/// If currently on the last character, it loops back to the first character.
void goToNextCharacter({
  required BuildContext context,
  required WidgetRef ref,
  required int currentWordIndex,
  required List<dynamic> wordsStatus,
  required List<Map> wordsPhrase,
  required int unitId,
  required String unitTitle,
  required int widgetId,
}) {
  int nextIndex;
  if (currentWordIndex < wordsStatus.length - 1) {
    // Not the last character, go to next
    nextIndex = currentWordIndex + 1;
  } else {
    // Last character, loop to first
    nextIndex = 0;
  }

  // Navigate to TeachWordView with the new index
  if (context.mounted) {
    navigateWithProvider(
      context,
      '/teachWord',
      ref,
      arguments: {
        'unitId': unitId,
        'unitTitle': unitTitle,
        'wordsStatus': wordsStatus,
        'wordsPhrase': wordsPhrase,
        'wordIndex': nextIndex,
        'widgetId': widgetId,
      },
    );
  }
}

void navigateToTab(TabController tabController, int currentTab, int nextTab, bool wordIsLearned) {
  if (wordIsLearned) { // If the word is learned, the user can navigate to any tab
    tabController.animateTo(nextTab);
    debugPrint('navigateToTab: from ${tabNames[currentTab]} to ${tabNames[nextTab]}.');   
  } else if ((nextTab < currentTab) || (nextTab <= writeTabNum)) { // If the word is not learned, the user can only navigate to previous tabs, or to the Look tab and Listen tab
    tabController.animateTo(nextTab);
    debugPrint('navigateToTab: from ${tabNames[currentTab]} to ${tabNames[nextTab]}.');   
  } else { // If the word is not learned, the user cannot pass the Write tab
    tabController.animateTo(currentTab);
    debugPrint('navigateToTab: can not change. Stay at ${tabNames[currentTab]}.');
  }
}  

void navigateNextTab(TabController tabController) {
  if (tabController.index < tabController.length - 1) {
    tabController.animateTo(tabController.index + 1);
    debugPrint('navigateNextTab: from ${tabNames[tabController.previousIndex]} to ${tabNames[tabController.index]}.');     
  }  
}  

void navigatePreviousTab(TabController tabController) {
    if (tabController.index > 0) {
      tabController.animateTo(tabController.index - 1);
      debugPrint('navigatePreviousTab: from ${tabNames[tabController.previousIndex]} to ${tabNames[tabController.index]}.');         
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

Future<void> handleGoToUse(
  int vocabCnt,
  int vocabIndex,
  int nextStepId,
  Map wordObj,
  FlutterTts ftts,
  // ValueNotifier<int> nextStepIdNotifier,
) async {
  debugPrint('utils handleGoToUse vocabCnt: $vocabCnt, vocabIndex=$vocabIndex, nextId: $nextStepId');

  try {
    switch (vocabCnt) {
      case 1:
        await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        break;
      case 2:
        final step = vocabIndex == 0 ? 'goToUse1' : 'goToUse2';
        debugPrint('nextId=${TeachWordSteps.steps[step]}, vocab1: ${wordObj['vocab1']}, vocab2: ${wordObj['vocab2']}');
        if (TeachWordSteps.steps[step] == TeachWordSteps.steps['goToUse1']) {
          await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        } else {
          await ftts.speak("${wordObj['vocab2']}。${wordObj['sentence2']}");
        }
        break;
      default:
        debugPrint('Unexpected vocabCnt: $vocabCnt');
    }
  } catch (e) {
    debugPrint('Error in handleGoToUse: $e');
  }
}

Future<void> handleGoToSpeak(
  int vocabCnt,
  int vocabIndex,
  int nextStepId,
  Map wordObj,
  FlutterTts ftts,
  // ValueNotifier<int> nextStepIdNotifier,
) async {
  debugPrint('utils handleGoToSpeak vocabCnt: $vocabCnt, vocabIndex=$vocabIndex, nextId: $nextStepId');

  try {
    switch (vocabCnt) {
      case 1:
        await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        break;
      case 2:
        final step = vocabIndex == 0 ? 'goToSpeak1' : 'goToSpeak2';
        debugPrint('nextId=${TeachWordSteps.steps[step]}, vocab1: ${wordObj['vocab1']}, vocab2: ${wordObj['vocab2']}');
        if (TeachWordSteps.steps[step] == TeachWordSteps.steps['goToSpeak1']) {
          await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        } else {
          await ftts.speak("${wordObj['vocab2']}。${wordObj['sentence2']}");
        }
        break;
      default:
        debugPrint('Unexpected vocabCnt: $vocabCnt');
    }
  } catch (e) {
    debugPrint('Error in handleGoToSpeak: $e');
  }
}

class CountdownDisplay extends ConsumerWidget {
  final int countdownValue;
  final double fontSize;

  const CountdownDisplay({
    super.key,
    required this.countdownValue,
    required this.fontSize,
  });

  static int? _lastBeepedValue;

  void _playBeep(AudioPlayer player) async {
    try {
      if (_lastBeepedValue != countdownValue) {
        _lastBeepedValue = countdownValue; // Update last beeped value

        if (countdownValue > 0) {
          debugPrint('Playing short beep. CountdownValue: $countdownValue');
          await player.play(AssetSource('sounds/short_beep.mp3'), volume: 1.0);
        } else {
          // Long beep was played in _notifier 
          debugPrint('Playing long beep. Do nothing. CountdownValue: $countdownValue.');
          // await player.play(AssetSource('sounds/long_beep.mp3'), volume: 1.0);
        }
      } else {
        debugPrint('Skipped beep. CountdownValue: $countdownValue already beeped.');
      }
    } catch (e) {
      debugPrint('Error playing beep: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(audioPlayerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('Widget Rebuilt. CountdownValue: $countdownValue');
      _playBeep(player);
    });

    // Debug: Confirm the countdownValue has reached 0
    if (countdownValue == 0) {
      debugPrint('Countdown reached 0. Long beep should play.');
    }

    // Color circleColor = Colors.green;
    Color circleColor = Colors.white;
    if (countdownValue <= 1) {
      // circleColor = Colors.red;
      circleColor = Colors.white;
    }

    /*
    return Center(
      child: SizedBox(
        width: fontSize * 10,
        height: fontSize * 10,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            // countdownValue > 0 ? countdownValue.toString() : "GO",
            countdownValue.toString(),
            key: ValueKey<int>(countdownValue),
            style: TextStyle(
                fontSize: fontSize * 5,
                fontWeight: FontWeight.bold,
                color: circleColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
    */

    return Center(
      child: SizedBox(
        width: fontSize * 10,
        height: fontSize * 10,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            countdownValue > 0 ? countdownValue.toString() : "",
            // Use a separate key for the "GO" state so AnimatedSwitcher sees it
            // as a completely different widget than any numeric countdown.
            key: ValueKey<int>(countdownValue > 0 ? countdownValue : -1),
            style: TextStyle(
              fontSize: fontSize * 5,
              fontWeight: FontWeight.bold,
              color: circleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );


  }
}


