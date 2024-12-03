// lib/teach_word/presentation/teach_word_utils.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';


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
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/mainPage');
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
        if (TeachWordSteps.steps[step] == 8) {
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

