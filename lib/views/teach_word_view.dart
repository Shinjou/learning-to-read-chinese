// teach_word_view.dart 
//（Needs to incorporate the changes or comments from teach_word_view_ok.dart）

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';
import 'package:ltrc/widgets/word_card.dart';
import 'package:provider/provider.dart';

class TeachWordView extends ConsumerStatefulWidget {
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;

  const TeachWordView({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
  });

  @override
  TeachWordViewState createState() => TeachWordViewState();
}

class TeachWordViewState extends ConsumerState<TeachWordView>
    with TickerProviderStateMixin {
  StrokeOrderAnimationController? _strokeOrderAnimationControllers;
  late TabController _tabController;
  FlutterTts ftts = FlutterTts();
  final player = AudioPlayer();
  late Map wordsPhrase;
  late Map wordObj;
  int vocabCnt = 0;
  bool img1Exist = false;
  bool img2Exist = false;
  bool wordExist = false; // 字存在，但是 json 可能不存在 (svgFileExist = false)
  bool svgFileExist = false; // 字存在，json 也存在
  double fontSize = 0; // 移到這裡，因為其他地方也會用到
  int practiceTimeLeft = 4;
  int nextStepId = 0;
  bool isBpmf = false;
  int vocabIndex = 0;
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);
  // Define the color used for the background
  static const Color backgroundColor = Color.fromRGBO(245, 245, 220, 100);
  bool get wordIsLearned =>
      widget.wordsStatus[widget.wordIndex].learned; // 這才是正確的方法
  bool _showErrorDialog = false;
  bool _firstNullStroke = true;

  void nextTab() async {
    // nextTab() is called in many places, one setState() is called
    // it will update the nextStepId, currentTabIndex, and call showNoSvgDialog() if no SVG in 寫一寫    
    // debugPrint('nextTab invoked at nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}, stack: ${StackTrace.current}');   
    debugPrint('nextTab invoked at nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}');   
    // If we're already at the last step, stop advancing
    if (nextStepId >= steps['goToUse2']!) {
      debugPrint('nextTab: Reached the final step, stopping navigation.');
      return;
    }

    int savedNextStepId = nextStepId;
    currentTabIndex.value += 1;

    if (svgFileExist) {
      if (wordIsLearned) { // 字已學
        if (savedNextStepId > 1 && savedNextStepId < 8) { // 1-7 different steps in 寫一寫         
          nextStepId = steps['goToUse1']!;
          debugPrint('nextTab 字已學，要從“寫一寫”中的任一步驟，跳到“用一用”，savedId: $savedNextStepId，nextId: $nextStepId');
        } else { // 0, 8, 9
          // nextStepId += 1; sjf 9/8/24
          debugPrint('nextTab 字已學，savedId: $savedNextStepId，nextId: $nextStepId');
        }
      } else { // 字未學，一步一步來  
        // nextStepId += 1; sjf 9/8/24
        debugPrint('nextTab 字未學，savedId: $savedNextStepId，nextId: $nextStepId');
      }
    } else { // no SVG
      if (nextStepId > 0 && nextStepId < 8) {
        debugPrint('nextTab no SVG1. 從 “聽一聽”到“寫一寫”. Show error message.');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 選聽一聽，nextStepId = goToListen; 選用一用，nextStepId = goToUse1
          await showNoSvgDialog('','抱歉，「${widget.wordsStatus[widget.wordIndex].word}」還沒有筆順。請繼續。謝謝！');
        });
        return; // Exit early to avoid updating `nextStepId`
      }
    }
    nextStepId = min(steps['goToUse2']!, nextStepId); // Make sure it is not greater than goToUse2
    debugPrint('nextTab svgFileExist $svgFileExist, savedId: $savedNextStepId, nextId: $nextStepId');

    // Make sure we don't exceed the allowed steps
    nextStepId = min(steps['goToUse2']!, nextStepId);

    // Proceed to speak and navigate
    if (nextStepId == steps['goToListen']) {
      // 0
      incrementNextStepId();
    } else if (nextStepId == steps['goToWrite'] || nextStepId == (steps['goToWrite']! + 1)) { // 1 & 2 sjf 9/8/24
      // 1、2
      incrementNextStepId();
      await ftts.speak(widget.wordsStatus[widget.wordIndex].word); // Keep speaking logic intact
    } else if (nextStepId == steps['goToUse1'] || nextStepId == steps['goToUse2']) {
      // 8、9
      await handleGoToUseStep();  // Follow your speaking behavior here
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('', '「${widget.wordsStatus[widget.wordIndex].word}」程序問題。請截圖回報。謝謝！');
      });
    }

    // debugPrint('nextTab completed, nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}, stack: ${StackTrace.current}');
    debugPrint('nextTab completed, nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}');
  }

  void prevTab() async {
    // prevTab() is called in many places, one setState() is called
    // it will update the nextStepId, currentTabIndex, and call showNoSvgDialog() if no SVG in 寫一寫    
    // debugPrint('prevTab invoked at nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}, stack: ${StackTrace.current}');
    debugPrint('prevTab invoked at nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}');

    int currentTabValue = currentTabIndex.value;
    int savedNextStepId = nextStepId;

    debugPrint('prevTab currentTab $currentTabValue, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');

    if (currentTabValue > 0) { // to prevent negative value
      currentTabIndex.value -= 1;
    }

    if (svgFileExist) { // 有筆順
      if (wordIsLearned) { // 字已學
        if (nextStepId > 0 && nextStepId < 8) { // 1-7 different steps in 寫一寫
          nextStepId = steps['goToListen']!;
          debugPrint('prevTab 字已學，要從“寫一寫”中的任一步驟，退回到“聽一聽” nextId: $nextStepId');
        } else { // 0, 8, 9
          nextStepId -= 1;
          if (nextStepId == steps['goToPracticeWithoutBorder1']) {
            nextStepId = steps['goToWrite']!;
          } else if (nextStepId < steps['goToListen']!) {
            nextStepId = steps['goToListen']!;
          }
          debugPrint('prevTab 字已學，nextStepId 從 0,8,9 變成 $nextStepId');
        }
      } else { // 字未學，一步一步來
        nextStepId -= 1;
        debugPrint('prevTab 字未學，savedId: $savedNextStepId，nextId: $nextStepId');
      }
    } else { // 沒有筆順
      if (nextStepId == steps['goToUse1']) {
        // 從 “用一用1”，退回去“寫一寫”
        debugPrint('prevTab no svg1. 從 “用一用1”退回到“寫一寫”. Show error message.');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 選上一頁，nextStepId = goToListen; 選下一頁，nextStepId = goToUse1
          await showNoSvgDialog('','抱歉，「${widget.wordsStatus[widget.wordIndex].word}」還沒有筆順。請繼續。謝謝！');
        });
        debugPrint('prevTab no svg2. 從 “用一用1”退回到“寫一寫”. nextId = $nextStepId.');   
      } else {
        nextStepId -= 1;
        debugPrint('prevTab no svg3. savedId = $savedNextStepId, nextId = $nextStepId');
      }
    }

    nextStepId = max(0, nextStepId); // Make sure it is not negative
    debugPrint('prevTab svgFileExist $svgFileExist, wordIsLearned: $wordIsLearned, savedId: $savedNextStepId, nextId: $nextStepId');

    if (nextStepId > steps['goToUse2']!) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('', '「${widget.wordsStatus[widget.wordIndex].word}」程序問題2。請截圖回報。謝謝！');
      });
    }
    // setState(() {});
  }


  void incrementNextStepId() {
    setState(() {
      nextStepId += 1;
      // debugPrint('setState incrementNextStepId: nextId: $nextStepId, stack: ${StackTrace.current}');
      debugPrint('setState incrementNextStepId: nextId: $nextStepId');
    });
  }

  Future<void> handleGoToUseStep() async {
    // debugPrint('handleGoToUseStep invoked, nextStepId: $nextStepId, vocabCnt: $vocabCnt, stack: ${StackTrace.current}');
    debugPrint('handleGoToUseStep invoked, nextStepId: $nextStepId, vocabCnt: $vocabCnt');
    if (vocabCnt == 1) {
      debugPrint('handleGoToUseStep vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, sentence1: ${wordObj['sentence1']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
      await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
      WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
      ref.read(learnedWordCountProvider.notifier).state += 1;
      await WordStatusProvider.updateWordStatus(status: newStatus);
      setState(() {
        newStatus.learned = true;
        debugPrint('setState handleGoToUseStep: newStatus.learned = true');        
      });
    } else { // vocabCnt == 2
      if (nextStepId == steps['goToUse1']) {
        debugPrint('handleGoToUseStep vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, sentence1: ${wordObj['sentence1']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
        await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        setState(() {
          nextStepId += 1;
          debugPrint('setState handleGoToUseStep: nextStepId: $nextStepId');
        });
      } else {
        debugPrint('handleGoToUseStep vocabCnt: $vocabCnt, vocab2: ${wordObj['vocab2']}, sentence2: ${wordObj['sentence2']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
        await ftts.speak("${wordObj['vocab2']}。${wordObj['sentence2']}");
        setState(() {
          nextStepId += 1;
          nextStepId = min(steps['goToUse2']!, nextStepId); // Ensure not greater than goToUse2
          debugPrint('setState handleGoToUseStep: nextStepId: $nextStepId');
        });
      }
    }

    debugPrint('handleGoToUseStep completed, nextStepId: $nextStepId');
  }


  Future myLoadAsset(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  void getWord() async {
    // getWord() is called in initState(), NO setState() is called
    int tempIndex = widget
        .wordIndex; // change widget.wordIndex to tempIndex in this function
    bool phraseEmpty = widget.wordsPhrase.isEmpty;
    debugPrint('getWord begin: phraseEmpty: $phraseEmpty, tempIndex: $tempIndex');
    if (phraseEmpty) {
      debugPrint('getWord error: wordsPhrase is empty');
      wordObj = {};
      wordExist = false;
      return;
    } else {
      debugPrint('getWord index: $tempIndex, length: ${widget.wordsPhrase.length}');
      if (!(tempIndex < widget.wordsPhrase.length)) {
        debugPrint('getWord error: wordIndex is out of range');
        wordObj = {};
        wordExist = false;
        return;
      }
    }

    wordObj = widget.wordsPhrase[tempIndex];
    try {
      // Process vocab1
      if (wordObj['vocab1'] != "") {
        vocabCnt += 1;
      }
      // Process vocab2
      if (wordObj['vocab2'] != "") {
        vocabCnt += 1;
      }

      wordExist = true; // 字存在，但是 json 可能不存在 (svgFileExist = false)
      debugPrint('getWord end: wordExist: $wordExist, vocabCnt: $vocabCnt, ${wordObj['vocab1']}, ${wordObj['vocab2']}');
    } catch (error) {
      wordExist = false;
      debugPrint('getWord error: : $error。wordExist: $wordExist,${wordObj['vocab1']}');
    }
  }

  late List<Widget> useTabView;
  // bool _didChangeDependenciesCalled = false;  

  @override
  void initState() {
    super.initState();
    debugPrint('initState begin, wordExist: $wordExist, svgFileExist: $svgFileExist, nextId: $nextStepId, wordIsLearned: $wordIsLearned');    
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);

    // Initialize the TabController
    _tabController = TabController(length: 4, vsync: this);

    // Setup completion handler for TTS
    ftts.setCompletionHandler(() async {
      // debugPrint('\nTTS handler completed, nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}, , wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist, stack: ${StackTrace.current}');
      debugPrint('\nTTS handler completed, nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}, , wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');

      if (!context.mounted) return;

      WordStatus newStatus = widget.wordsStatus[widget.wordIndex];

      if (nextStepId == steps['goToListen']) { // 聽一聽, 0
        debugPrint('TTS handler goToListen, call incrementNextStepId, newStatus: $newStatus, nextId: $nextStepId');
        incrementNextStepId();
      } else if (nextStepId == steps['goToUse1']) { // 用一用1, 8
        debugPrint('TTS handler goToUse1, call handleGoToUse1, newStatus: $newStatus, nextId: $nextStepId');
        await handleGoToUse1(newStatus);
      } else if (nextStepId == steps['goToUse2']) { // 用一用2, 9
        debugPrint('TTS handler goToUse2, call updateWordStatus, newStatus: $newStatus, nextId: 0');
        await updateWordStatus(newStatus, learned: true, nextStepId: 0);
      }
      debugPrint("Speech has completed");
    });

    // Determine if the word is BPMF
    isBpmf = initials.contains(widget.wordsStatus[widget.wordIndex].word) ||
        prenuclear.contains(widget.wordsStatus[widget.wordIndex].word) ||
        finals.contains(widget.wordsStatus[widget.wordIndex].word);

    getWord(); // wordObj, wordExist, img1Exist, img2Exist, vocabCnt will be set, NO setState() is called
    checkWordExistence(); // setState is called once in readJsonAndProcess()
    debugPrint('initState end, wordExist: $wordExist, svgFileExist: $svgFileExist, nextId: $nextStepId, wordIsLearned: $wordIsLearned');
  }

  Future<void> handleGoToUse1(WordStatus newStatus) async {
    debugPrint('handleGoToUse1. vocab #: $vocabCnt, newStatus: $newStatus, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
    if (vocabCnt == 1) {
      await updateWordStatus(newStatus, learned: true, nextStepId: 0);
    } else {
      incrementNextStepId();
    }
  }

  Future<void> updateWordStatus(WordStatus newStatus,
      {required bool learned, required int nextStepId}) async {
    debugPrint('updateWordStatus. mounted: $mounted, learned: $learned, nextId: $nextStepId');
    if (!context.mounted) return;
    setState(() {
      newStatus.learned = learned;
      this.nextStepId = nextStepId;
      debugPrint('setState updateWordStatus: newStatus.learned: $learned, nextId: $nextStepId');
    });

    ref.read(learnedWordCountProvider.notifier).state += 1;
    await WordStatusProvider.updateWordStatus(status: newStatus);
  }

  void checkWordExistence() {
    if (!wordExist) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('','「${widget.wordsStatus[widget.wordIndex].word}」不在SQL。請截圖回報。謝謝！');
      });
    } else {
      readJsonAndProcess(); // setState() is called here
    }
  }

  Future<void> readJsonAndProcess() async {
    // setState() is called in this function
    try {
      final result = await readJson();
      debugPrint('readJsonAndProcess: ${widget.wordsStatus[widget.wordIndex].word} ${svgFileExist ? "有筆順" : "沒有筆順"}');
      if (result.isNotEmpty) {
        setState(() {
          _strokeOrderAnimationControllers = StrokeOrderAnimationController(
              result, this,
              onQuizCompleteCallback: handleQuizCompletion);
          debugPrint('setState readJsonAndProcess: ${widget.wordsStatus[widget.wordIndex].word} 筆順檔下載成功');
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog('','「${widget.wordsStatus[widget.wordIndex].word}」的筆順檔無法下載。請截圖回報。謝謝！');
          debugPrint('readJsonAndProcess error: ${widget.wordsStatus[widget.wordIndex].word} 的筆順檔無法下載, svgFileExist: $svgFileExist');
          _firstNullStroke = true; // Reset the flag
          _showErrorDialog = false; // Reset the flag           
        });        
        setState(() {
          _strokeOrderAnimationControllers = null;
          debugPrint('setState readJsonAndProcess error: ${widget.wordsStatus[widget.wordIndex].word} 的筆順檔無法下載, svgFileExist: $svgFileExist');
        });
      }
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('','「${widget.wordsStatus[widget.wordIndex].word}」筆順檔問題，請截圖回報。svgFileExist: $svgFileExist。謝謝！');
        _firstNullStroke = true; // Reset the flag
        _showErrorDialog = false; // Reset the flag           
      });
      setState(() {
        _strokeOrderAnimationControllers = null;
        // svgFileExist is set in readJson(). Should not be set here.
        debugPrint('setState readJsonAndProcess error: ${widget.wordsStatus[widget.wordIndex].word} 筆順檔問題, svgFileExist: $svgFileExist');
      });
    }
  }

  Future<String> readJson() async {
    // Define the noSvgList. This list needs to be updated every new school semester
    List<String> noSvgList = [
      '吔', '姍', '媼', '嬤', '履', '搧', '枴', '椏', '欓', '汙',
      '溼', '漥', '痠', '礫', '粄', '粿', '綰', '蓆', '襬', '譟',
      '踖', '踧', '鎚', '鏗', '鏘', '陳', '颺', '齒'
    ];

    String word = widget.wordsStatus[widget.wordIndex].word; // Ensure wordsStatus and wordIndex are initialized

    // If the word is in the noSvgList, set svgFileExist to false and use '學' as a fallback
    if (noSvgList.contains(word)) {
      word = '學'; // Set the word to "學" to avoid null checking in the rest of code
      svgFileExist = false;
    } else {
      svgFileExist = true;
    }

    debugPrint('readJson() word: $word, svgFileExist: $svgFileExist');
  
    // Proceed with loading the SVG file. If svgFileExist is false, 
    // load “學” so that 看一看、聽一聽、用一用 still work.
    try {
      final String response = await rootBundle.loadString('lib/assets/svg/$word.json');
      return response.replaceAll("\"", "'"); // Replace double quotes with single quotes in the response
    } catch (e) {
      // Handle error if the SVG file does not exist or cannot be loaded
      svgFileExist = false;
      debugPrint('readJson() error: $e, svgFileExist: $svgFileExist');
      return ''; // Return an empty string in case of error
    }
  }

  void handleQuizCompletion(QuizSummary summary) {
    if (nextStepId >= steps['practiceWithBorder1']! &&
        nextStepId <= steps['turnBorderOff']!) {
      setState(() {
        practiceTimeLeft -= 1;
        nextStepId += 1;
        debugPrint('setState handleQuizCompletion: practiceTimeLeft: $practiceTimeLeft, nextId: $nextStepId');
      });
      Fluttertoast.showToast(
        msg: [
          nextStepId == steps['turnBorderOff']
              ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 $practiceTimeLeft 遍哦！"
              : "恭喜筆畫正確！讓我們再練習 $practiceTimeLeft 次哦！"
        ].join(),
        fontSize: 30,
      );
    } else {
      if (nextStepId == steps['practiceWithoutBorder1']) {
        setState(() {
          practiceTimeLeft -= 1;
          nextStepId += 1;
          widget.wordsStatus[widget.wordIndex].learned = true; // 設成“已學”
          debugPrint('setState handleQuizCompletion 要進入用一用1,practiceTimeLeft: $practiceTimeLeft, nextId: $nextStepId, learned: true');
        });
      }
      Fluttertoast.showToast(
        msg: ["恭喜筆畫正確！"].join(),
        fontSize: fontSize * 1.2,
      );
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
              color: Colors.black, // Set text color to black
              fontSize: fontSize * 1.2, // Set font size
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black, // Set text color to black
              fontSize: fontSize * 1.2, // Set font size
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '回首頁',
                style: TextStyle(
                  color: Colors.black, // Set text color to black
                  fontSize: fontSize * 1.2, // Set font size
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacementNamed(
                    '/mainPage'); // Navigate to Home screen
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
    String word = widget.wordsStatus[widget.wordIndex].word;
    
    showDialog(
      context: context,
      barrierDismissible: false,  // This ensures the dialog is modal
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black, // Set text color to black
              fontSize: fontSize * 1.2, // Set font size
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black, // Set text color to black
              fontSize: fontSize * 1.2, // Set font size
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '聽一聽',
                style: TextStyle(
                  color: Colors.black, // Set text color to black
                  fontSize: fontSize * 1.2, // Set font size
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                int savedNextStepId = nextStepId;
                int oldTabIndex = currentTabIndex.value;
                nextStepId = steps['goToListen']!; // 9/11/24 sjf
                currentTabIndex.value = 1;      // 9/11/24 sjf
                debugPrint('聽一聽 說：$word');  // 移到前面，因為 await 會有延遲
                if (isBpmf) {
                  await player.play(AssetSource('bopomo/$word.mp3'));
                } else {
                  await ftts.speak(word);
                }
                debugPrint('寫一寫，上一頁1，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');            
                prevTab(); // it will update the nextStepId and currentTabIndex                
                return _tabController.animateTo(_tabController.index - 1);
              },
            ),
            TextButton(
              child: Text(
                '用一用',
                style: TextStyle(
                  color: Colors.black, // Set text color to black
                  fontSize: fontSize * 1.2, // Set font size
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                int savedNextStepId = nextStepId;
                nextStepId = steps['goToUse1']!; // Force to goToUse1
                // vocabCnt = 2;
                debugPrint('寫一寫，下一頁，savedId: $savedNextStepId,  nextId: $nextStepId，呼叫 handleGoToUseStep()');                   
                handleGoToUseStep();
                currentTabIndex.value += 1;
                return _tabController.animateTo(_tabController.index + 1);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Map<String, int> steps = { // 沒有看一看
    'goToListen': 0, // 聽一聽
    'goToWrite': 1, // 寫一寫
    'seeAnimation': 2, // 寫一寫-筆順
    'practiceWithBorder1': 3, // 寫一寫-寫字-有邊框
    'practiceWithBorder2': 4, // 寫一寫-寫字-有邊框
    'practiceWithBorder3': 5, // 寫一寫-寫字-有邊框
    'turnBorderOff': 6, // 寫一寫-關掉邊框
    'practiceWithoutBorder1': 7, // 寫一寫-寫字-無邊框
    'goToUse1': 8, // 用一用-例句1
    'goToUse2': 9, // 用一用-例句2
  };

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    // debugPrint('teach_word_view H: $deviceHeight, W: $deviceWidth, fontSize: $fontSize, stack: ${StackTrace.current}');
    debugPrint('teach_word_view H: $deviceHeight, W: $deviceWidth, fontSize: $fontSize');

    double availableWidth = deviceWidth - 10; // 10 padding on each side
    double availableHeight = deviceHeight - 10; // example padding top and bottom
    double nonConsumedHeight = deviceHeight * 0.15; // was 0.20;
    var gray85Color = '#D9D9D9'.toColor();

    String word = widget.wordsStatus[widget.wordIndex].word;
    int unitId = widget.unitId;
    String unitTitle = widget.unitTitle;
    debugPrint('\nbuild word: $word, nextId: $nextStepId, wordIsLearned: $wordIsLearned');

    // 不知道為何每一個字都會出現 _strokeOrderAnimationControllers is null 一次。
    // 若出現第二次，則有問題。    
    if (_strokeOrderAnimationControllers == null) {
      debugPrint('build _strokeOrder is null, _firstNullStroke: $_firstNullStroke, nextId: $nextStepId');
      if (_firstNullStroke) {
        _firstNullStroke = false;
        return LayoutBuilder(builder: (context, constraints) { return Container(); });
      } else {
        _showErrorDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_showErrorDialog) {
            showErrorDialog('','「$word」沒有筆順2。請截圖回報。謝謝！');
            _firstNullStroke = true; // Reset the flag
            _showErrorDialog = false; // Reset the flag           
          }
        });
        // Return a fallback widget to avoid returning null
        return LayoutBuilder(builder: (context, constraints) { return Container(); }); // or any other placeholder widget
      }
    }

    debugPrint('build _strokeOrder is not null, word: $word, nextId: $nextStepId, wordIsLearned: $wordIsLearned, vocabCnt: $vocabCnt, vocabIndex: $vocabIndex');

    List<Widget> useTabView = [
      TeachWordTabBarView( // 用一用 - 例句1
        content: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevents unbounded height issues
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: availableWidth, 
                    ),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min, // Prevents infinite height
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        LeftRightSwitch(
                          // LeftRightSwitch for 用一用
                          iconsColor: gray85Color,
                          iconsSize: fontSize * 2.0, 
                          rightBorder: nextStepId == steps['goToUse2'],
                          middleWidget: TeachWordCardTitle(
                              sectionName: '用一用', iconsColor: gray85Color),
                          isFirst: false,
                          isLast: (vocabCnt == 1),
                          onLeftClicked: wordIsLearned
                              ? () {
                                  int savedNextStepId = nextStepId;
                                  int oldTabIndex = currentTabIndex.value;
                                  nextStepId = steps['goToUse1']!; // Force to goToUse1
                                  currentTabIndex.value = 3;       // Force to 3
                                  debugPrint('用一用1，上一頁1，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');
                                  prevTab(); // prevTab() will update the nextStepId and currentTabIndex, and will speak for 用一用
                                  return _tabController.animateTo(_tabController.index - 1);
                                }
                              : null,
                          onRightClicked: (nextStepId == steps['goToUse2'] || wordIsLearned)
                              ? () async {
                                  if (nextStepId == steps['goToUse2']) {
                                    await ftts.speak(
                                        "${wordObj['vocab2']}。${wordObj['sentence2']}");
                                    WordStatus newStatus =
                                        widget.wordsStatus[widget.wordIndex];
                                    debugPrint('用一用1，下一頁1 vocab2: ${wordObj['vocab2']}, newStatus: $newStatus}');
                                    setState(() {
                                      newStatus.learned = true; // I never saw this flag set. Why?
                                      debugPrint('setState 用一用1，下一頁1， newStatus.learned: true');
                                    });
                                    ref.read(learnedWordCountProvider.notifier).state += 1;
                                    await WordStatusProvider.updateWordStatus(
                                        status: newStatus);
                                  }
                                  setState(() {
                                    vocabIndex = 1;
                                    debugPrint('setState 用一用1，下一頁1， vocabIndex: $vocabIndex');
                                  });
                                }
                              : null,
                        ),
                        isBpmf
                            ? BopomofoVocabContent(
                                word: word,
                                vocab: wordObj['vocab1'],
                                sentence: "${wordObj['sentence1']}",
                              )
                            : WordVocabContent(
                                vocab: wordObj['vocab1'],
                                meaning: wordObj['meaning1'],
                                sentence: "${wordObj['sentence1']}\n",
                                vocab2: wordObj['vocab2'],
                              ),
                        SizedBox(height: fontSize * 0.2), // Adjust height as needed
                        // Instead of Expanded, use SizedBox or Flexible with constrained height
                        SizedBox(
                          height: fontSize * 3.0, // Adjust height for the image or icon
                          child: (img1Exist && !isBpmf)
                              ? Image(
                                  height: fontSize * 3.0,
                                  image: AssetImage('lib/assets/img/vocabulary/${wordObj['vocab1']}.webp'),
                                )
                              : SizedBox(height: fontSize * 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              // Position the text at the bottom right
              right: fontSize, 
              bottom: fontSize, 
              child: Text(
                "1 / $vocabCnt",
                style: TextStyle(
                  fontSize: fontSize * 0.75,
                  fontWeight: FontWeight.normal,
                  color: backgroundColor,
                ),
              ),
            ),
          ],
        ),
      ),
      // Same structure for the second sentence tab
      (vocabCnt == 2)
          ? TeachWordTabBarView( // 用一用 - 例句2
              content: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: availableWidth,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              LeftRightSwitch(
                                iconsColor: gray85Color,
                                iconsSize: fontSize * 2.0,
                                rightBorder: false,
                                middleWidget: TeachWordCardTitle(
                                    sectionName: '用一用', iconsColor: gray85Color),
                                isFirst: false,
                                isLast: true,
                                onLeftClicked: wordIsLearned
                                    ? () {
                                        debugPrint('用一用2，上一頁1，nextId: $nextStepId，叫 prevTab()');
                                        prevTab();  // prevTab() will update the nextStepId and currentTabIndex, and will speak for 用一用
                                        ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
                                        setState(() {
                                          vocabIndex = 0;
                                          debugPrint('setState 用一用2，上一頁1， vocabIndex: $vocabIndex');
                                        });
                                      }
                                    : null,
                              ),
                              isBpmf
                                  ? BopomofoVocabContent(
                                      word: word,
                                      vocab: wordObj['vocab2'],
                                      sentence: "${wordObj['sentence2']}",
                                    )
                                  : WordVocabContent(
                                      vocab: wordObj['vocab2'],
                                      meaning: wordObj['meaning2'],
                                      sentence: "${wordObj['sentence2']}\n",
                                      vocab2: wordObj['vocab1'],
                                    ),
                              SizedBox(height: fontSize * 0.2), 
                              // Similarly here, avoid using Expanded
                              SizedBox(
                                height: fontSize * 3.0,
                                child: (img2Exist && !isBpmf)
                                    ? Image(
                                        height: fontSize * 3.0,
                                        image: AssetImage('lib/assets/img/vocabulary/${wordObj['vocab2']}.webp'),
                                      )
                                    : SizedBox(height: fontSize * 0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: fontSize, 
                    bottom: fontSize, 
                    child: Text(
                      "2 / $vocabCnt",
                      style: TextStyle(
                        fontSize: fontSize * 0.75,
                        fontWeight: FontWeight.normal,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                ],
              ))
          : LayoutBuilder(builder: (context, constraints) { return Container(); })
    ];
    
    /*
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
            onPressed: () => Navigator.pop(context),
          ),
          title: (unitId == -1)
              ? Text(unitTitle, style: TextStyle(fontSize: fontSize))
              : Text(("${unitId.toString().padLeft(2, '0')} | $unitTitle"),
                  style: TextStyle(fontSize: fontSize)),
          actions: <Widget>[
            IconButton(
              onPressed: () => navigateWithProvider(context, '/mainPage', ref),
              icon: Icon(Icons.home_filled, size: fontSize * 1.5),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.image, size: fontSize * 0.75)),
              Tab(icon: Icon(Icons.hearing, size: fontSize * 0.75)),
              Tab(icon: Icon(Icons.create, size: fontSize * 0.75)),
              Tab(icon: Icon(Icons.school, size: fontSize * 0.75)),
            ],
            controller: _tabController,
            onTap: (index) {
              _tabController.index = currentTabIndex.value;
            },
            labelColor: '#28231D'.toColor(),
            dividerColor: '#999999'.toColor(),
            unselectedLabelColor: '#999999'.toColor(),
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: '#999999'.toColor(),
            ),
          ),
        ),
        body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              TeachWordTabBarView( // 看一看 （不在 steps 裡）
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,  // Ensure the column shrinks to fit its content
                    children: [
                      Flexible(  
                        fit: FlexFit.loose,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: availableWidth * 0.90,  // 90% of the available width
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,  // Shrink the column to fit its content
                              children: <Widget>[
                                LeftRightSwitch( // 看一看及左右按鈕
                                  iconsColor: gray85Color,
                                  iconsSize: max(fontSize * 2.0, 48.0),  // Ensure a minimum tap target size
                                  rightBorder: nextStepId == steps['goToListen'],
                                  middleWidget: TeachWordCardTitle(
                                    sectionName: '看一看',
                                    iconsColor: gray85Color,
                                  ),
                                  isFirst: true,
                                  isLast: false,
                                  onRightClicked: (nextStepId == steps['goToListen']! || wordIsLearned)
                                    ? () async {
                                        nextTab();
                                        if (isBpmf) {
                                          await player.play(AssetSource('bopomo/$word.mp3'));
                                        } else {
                                          await ftts.speak(word);
                                        }
                                        return _tabController.animateTo(_tabController.index + 1);
                                      }
                                    : null,
                                ),
                                SizedBox(height: fontSize * 0.3),  // Some small space between widgets
                                Flexible(  // Replacing Expanded with Flexible to prevent overflow issues
                                  fit: FlexFit.loose,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF28231D),
                                            ),
                                            child: Center(
                                              child: Image(
                                                width: max(17.6 * fontSize, 300.0),  // was 300
                                                image: isBpmf
                                                  ? AssetImage('lib/assets/img/bopomo/$word.png')
                                                  : AssetImage('lib/assets/img/oldWords/$word.webp'),  // change png to webp
                                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                  // Log the error
                                                  debugPrint('Error loading image: $exception');

                                                  // Return the Text widget as a fallback
                                                  return Center(
                                                    child: Text(
                                                      word,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: fontSize * 8.0,  // Adjust font size
                                                        color: backgroundColor,  // Ensure backgroundColor is defined or use a default color
                                                        fontWeight: FontWeight.w100,
                                                        fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              TeachWordTabBarView( // 聽一聽
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Prevents the Column from expanding infinitely
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: availableHeight * 0.9, // Constrain the available height
                          maxWidth: availableWidth * 0.9, // Constrain the available width
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // Prevents unbounded height issues
                          children: <Widget>[
                            LeftRightSwitch( // 聽一聽及左右按鈕
                              iconsColor: gray85Color,
                              iconsSize: max(fontSize * 2.0, 48.0), // Ensure a minimum tap target size
                              rightBorder: nextStepId == steps['goToWrite'],
                              middleWidget: TeachWordCardTitle(
                                  sectionName: '聽一聽', iconsColor: gray85Color),
                              isFirst: false,
                              isLast: false,
                              onLeftClicked: (nextStepId == steps['goToWrite'] || wordIsLearned)
                                  ? () {
                                      debugPrint(
                                          '聽一聽，上一頁，wordIsLearned: $wordIsLearned，nextId: $nextStepId，叫 prevTab()');
                                      prevTab();
                                      return _tabController.animateTo(
                                          _tabController.index - 1);
                                    }
                                  : null,
                              onRightClicked: (nextStepId == steps['goToWrite'] || wordIsLearned)
                                  ? () {
                                      int savedNextStepId = nextStepId;
                                      nextStepId = steps['goToWrite']!; // Force to goToWrite
                                      debugPrint(
                                          '聽一聽，下一頁，savedId: $savedNextStepId, nextId: $nextStepId，叫 nextTab()');
                                      nextTab();
                                      return _tabController.animateTo(
                                          _tabController.index + 1);
                                    }
                                  : null,
                            ),
                            SizedBox(height: fontSize * 0.3),

                            // Constrained box to ensure the available space is properly allocated
                            SizedBox(
                              height: (availableHeight * 0.4), // Adjust the height to the required size
                              width: availableWidth * 0.9, // Adjust the width to the required size
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  LayoutBuilder(builder: (context, constraints) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF28231D),
                                      ),
                                      child: Center(
                                        child: Text(
                                          word,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: fontSize * 8.0, // Adjust font size to be reasonable
                                            color: backgroundColor,
                                            fontWeight: FontWeight.w100,
                                            fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  Positioned(
                                    bottom: 8.0,
                                    right: 8.0,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          iconSize: fontSize * 1.2,
                                          color: backgroundColor,
                                          onPressed: () async {
                                            debugPrint('聽一聽2 說：$word');
                                            if (isBpmf) {
                                              await player.play(
                                                  AssetSource('bopomo/$word.mp3'));
                                            } else {
                                              await ftts.speak(word);
                                            }
                                          },
                                          icon: Icon(Icons.volume_up,
                                              size: fontSize * 1.5),
                                        ),
                                        Text(
                                          '讀音',
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: fontSize * 0.75,
                                            color: backgroundColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              TeachWordTabBarView( // 寫一寫
                content: ChangeNotifierProvider<StrokeOrderAnimationController>.value(
                  value: _strokeOrderAnimationControllers!,
                  child: Consumer<StrokeOrderAnimationController>(
                    builder: (context, controller, child) {
                      double availableWidth = deviceWidth - 20; // 10 padding on each side
                      double availableHeight = deviceHeight - 20; // Padding on top and bottom
                      double nonConsumedHeight = deviceHeight * 0.2; // Adjust as needed

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: availableWidth * 0.90,
                            maxHeight: availableHeight - nonConsumedHeight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Ensure the column takes only the necessary space
                            children: <Widget>[
                              LeftRightSwitch(
                                iconsColor: gray85Color,
                                iconsSize: max(fontSize * 2.0, 48.0), // Ensure a minimum tap target size
                                rightBorder: nextStepId == steps['goToUse1'],
                                middleWidget: TeachWordCardTitle(
                                  sectionName: '寫一寫',
                                  iconsColor: gray85Color,
                                ),
                                isFirst: false,
                                isLast: false,
                                onLeftClicked: wordIsLearned
                                    ? () async {
                                        int savedNextStepId = nextStepId;
                                        int oldTabIndex = currentTabIndex.value;
                                        nextStepId = steps['goToWrite']!;
                                        currentTabIndex.value = 2;
                                        debugPrint('回去 聽一聽 說：$word');
                                        if (isBpmf) {
                                          await player.play(AssetSource('bopomo/$word.mp3'));
                                        } else {
                                          await ftts.speak(word);
                                        }
                                        debugPrint(
                                            '寫一寫，上一頁2，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');
                                        prevTab();
                                        return _tabController.animateTo(_tabController.index - 1);
                                      }
                                    : null,
                                onRightClicked: (nextStepId == steps['goToUse1'] || wordIsLearned)
                                    ? () {
                                        nextTab();
                                        return _tabController.animateTo(_tabController.index + 1);
                                      }
                                    : null,
                              ),
                              SizedBox(height: fontSize * 0.2),

                              // Constrained Container for the animation and icons
                              SizedBox(
                                width: availableWidth,
                                height: (availableHeight - nonConsumedHeight) * 0.5, // Allocate 50% of the available height
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Container(
                                      decoration: !isBpmf
                                          ? const BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage("lib/assets/img/box.png"),
                                                fit: BoxFit.fitWidth,
                                              ),
                                            )
                                          : BoxDecoration(color: '#28231D'.toColor()),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Positioned(
                                            left: 10,
                                            top: 5,
                                            child: Column(children: [
                                              _buildPracticeTimeIcon(
                                                  practiceTimeLeft >= 4 && !wordIsLearned,
                                                  fontSize,
                                                  '#999999',
                                                  '#F8A339'),
                                              _buildPracticeTimeIcon(
                                                  practiceTimeLeft >= 3 && !wordIsLearned,
                                                  fontSize,
                                                  '#999999',
                                                  '#F8A339'),
                                              _buildPracticeTimeIcon(
                                                  practiceTimeLeft >= 2 && !wordIsLearned,
                                                  fontSize,
                                                  '#999999',
                                                  '#F8A339'),
                                              SizedBox(height: fontSize * 0.9),
                                              _buildPracticeTimeIcon(
                                                  practiceTimeLeft >= 1 && !wordIsLearned,
                                                  fontSize,
                                                  '#999999',
                                                  '#F8A3A9'),
                                            ]),
                                          ),
                                          FittedBox(
                                            child: StrokeOrderAnimator(
                                              _strokeOrderAnimationControllers!,
                                              key: UniqueKey(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // GridView for icons and labels (筆順、寫字、邊框)
                              Flexible(
                                fit: FlexFit.loose, // Allow this to take up the remaining space
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.0,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 3,
                                  shrinkWrap: true, // Use only the space needed by children
                                  physics: const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                                  children: <Widget>[
                                    buildIconButtonWithLabel(
                                      context: context,
                                      border: nextStepId == steps['seeAnimation'],
                                      iconData: [Icons.pause, Icons.play_arrow],
                                      label: '筆順',
                                      isSelected: controller.isAnimating,
                                      onPressed: !controller.isQuizzing
                                          ? () async {
                                              if (!controller.isAnimating) {
                                                controller.startAnimation();
                                                if (isBpmf) {
                                                  await player.play(AssetSource('bopomo/$word.mp3'));
                                                } else {
                                                  await ftts.speak(word);
                                                }
                                                debugPrint('筆順 $word');
                                                if (nextStepId == steps['seeAnimation']) {
                                                  setState(() {
                                                    nextStepId += 1;
                                                    debugPrint('setState 筆順 $word, nextStepId: $nextStepId');
                                                  });
                                                }
                                              } else {
                                                controller.stopAnimation();
                                                debugPrint("stop animation // nextStepId update time");
                                              }
                                            }
                                          : null,
                                      fontSize: fontSize,
                                    ),
                                    buildIconButtonWithLabel(
                                      context: context,
                                      border: !controller.isQuizzing && (nextStepId == steps['practiceWithBorder1']),
                                      iconData: [Icons.edit_off, Icons.edit],
                                      label: '寫字',
                                      isSelected: controller.isQuizzing,
                                      onPressed: (nextStepId == steps['practiceWithBorder1'] || wordIsLearned)
                                          ? () async {
                                              controller.startQuiz();
                                              if (isBpmf) {
                                                await player.play(AssetSource('bopomo/$word.mp3'));
                                              } else {
                                                await ftts.speak(word);
                                              }
                                              debugPrint('寫字 $word');
                                            }
                                          : null,
                                      fontSize: fontSize,
                                    ),
                                    buildIconButtonWithLabel(
                                      context: context,
                                      border: nextStepId == steps['turnBorderOff'],
                                      iconData: [Icons.remove_red_eye, Icons.remove_red_eye_outlined],
                                      label: '邊框',
                                      isSelected: controller.showOutline,
                                      onPressed: (nextStepId == steps['turnBorderOff'] || wordIsLearned)
                                          ? () {
                                              if (nextStepId == steps['turnBorderOff']) {
                                                setState(() {
                                                  nextStepId += 1;
                                                  debugPrint('setState 邊框 $word, nextStepId: $nextStepId');
                                                });
                                              }
                                              controller.setShowOutline(!controller.showOutline);
                                            }
                                          : null,
                                      fontSize: fontSize,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              useTabView[vocabIndex]
            ]),
        bottomNavigationBar: BottomAppBar(
            height: 4.0 * fontSize, // was 100, 5.9
            elevation: 0,
            color: '#28231D'.toColor(),
            child: LeftRightSwitch(
                iconsColor: '#F5F5DC'.toColor(),
                iconsSize: fontSize * 2.0, // was 48, 2.5
                rightBorder: false,
                middleWidget: WordCard(
                    unitId: unitId,
                    unitTitle: unitTitle,
                    wordsStatus: widget.wordsStatus,
                    wordsPhrase: widget.wordsPhrase,
                    wordIndex: widget.wordIndex,
                    sizedBoxWidth: 10 * fontSize, // was 7.5
                    sizedBoxHeight: 4.0 * fontSize, // was 88
                    fontSize: fontSize * 1.2,
                    isBpmf: isBpmf,
                    isVertical: false,
                    disable: true),
                isFirst: (widget.wordIndex == 0),
                isLast: (widget.wordIndex == widget.wordsStatus.length - 1),
                onLeftClicked: () {
                  navigateWithProvider(
                    context,
                    '/teachWord',  // Adjust this route name as per your AppRoutes definition
                    ref,
                    arguments: {
                      'unitId': widget.unitId,
                      'unitTitle': widget.unitTitle,
                      'wordsStatus': widget.wordsStatus,
                      'wordsPhrase': widget.wordsPhrase,
                      'wordIndex': widget.wordIndex - 1,
                    },
                  );                  
                },
                onRightClicked: () {
                  navigateWithProvider(
                    context,
                    '/teachWord',  // Adjust this route name as per your AppRoutes definition
                    ref,
                    arguments: {
                      'unitId': widget.unitId,
                      'unitTitle': widget.unitTitle,
                      'wordsStatus': widget.wordsStatus,
                      'wordsPhrase': widget.wordsPhrase,
                      'wordIndex': widget.wordIndex + 1,
                    },
                  );                  
                })),
      ),
    );
    */

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          /*
          titleSpacing: 0, // Remove extra spacing
          toolbarHeight: fontSize * 1.5, // Adjust if necessary
          title: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: deviceWidth * 0.90,  // Constrain to device width
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,  // Align items closer
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, size: fontSize * 3.0), // testing
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Center(  // Center the title
                    child: (unitId == -1)
                        ? Text(unitTitle, style: TextStyle(fontSize: fontSize * 1.2))
                        : Text(
                            "${unitId.toString().padLeft(2, '0')} | $unitTitle",
                            style: TextStyle(fontSize: fontSize * 1.2),
                          ),
                  ),
                ),
                IconButton(
                  onPressed: () => navigateWithProvider(context, '/mainPage', ref),
                  icon: Icon(Icons.home_filled, size: fontSize * 1.5),
                ),
              ],
            ),
          ),
          */
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
            onPressed: () => Navigator.pop(context),
          ),
          title: (unitId == -1)
              ? Text(unitTitle, style: TextStyle(fontSize: fontSize * 1.2))
              : Text(("${unitId.toString().padLeft(2, '0')} | $unitTitle"),
                  style: TextStyle(fontSize: fontSize * 1.2)),
          actions: <Widget>[
            IconButton(
              // onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
              onPressed: () => navigateWithProvider(context, '/mainPage', ref),
              icon: Icon(Icons.home_filled, size: fontSize * 1.5),
            ),
          ],          
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight), // TabBar height
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: availableWidth,  // Constrain to device width
              ),
              child: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.image, size: fontSize * 0.75)),
                  Tab(icon: Icon(Icons.hearing, size: fontSize * 0.75)),
                  Tab(icon: Icon(Icons.create, size: fontSize * 0.75)),
                  Tab(icon: Icon(Icons.school, size: fontSize * 0.75)),
                ],
                controller: _tabController,
                onTap: (index) {
                  _tabController.index = currentTabIndex.value;
                },
                labelColor: '#28231D'.toColor(),
                dividerColor: '#999999'.toColor(),
                unselectedLabelColor: '#999999'.toColor(),
                // indicatorSize: TabBarIndicatorSize.label,  // Cover only the label
                indicatorSize: TabBarIndicatorSize.tab,  // Ensure indicator covers the tab
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),  // Keep padding small
                indicator: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: '#999999'.toColor(),  // Visible color
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            TeachWordTabBarView(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: deviceWidth * 0.90,  // Limit content to 90% of device width
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              LeftRightSwitch(
                                iconsColor: gray85Color,
                                iconsSize: max(fontSize * 2.0, 48.0),
                                rightBorder: nextStepId == steps['goToListen'],
                                middleWidget: TeachWordCardTitle(
                                  sectionName: '看一看',
                                  iconsColor: gray85Color,
                                ),
                                isFirst: true,
                                isLast: false,
                                onRightClicked: (nextStepId == steps['goToListen'] || wordIsLearned)
                                    ? () async {
                                        nextTab();
                                        if (isBpmf) {
                                          await player.play(AssetSource('bopomo/$word.mp3'));
                                        } else {
                                          await ftts.speak(word);
                                        }
                                        return _tabController.animateTo(_tabController.index + 1);
                                      }
                                    : null,
                              ),
                              SizedBox(height: fontSize * 0.3),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF28231D),
                                          ),
                                          child: Center(
                                            child: Image(
                                              width: max(17.6 * fontSize, 300.0),
                                              image: isBpmf
                                                  ? AssetImage('lib/assets/img/bopomo/$word.png')
                                                  : AssetImage('lib/assets/img/oldWords/$word.webp'),
                                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                debugPrint('Error loading image: $exception');
                                                return Center(
                                                  child: Text(
                                                    word,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: fontSize * 8.0,
                                                      color: backgroundColor,
                                                      fontWeight: FontWeight.w100,
                                                      fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TeachWordTabBarView(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: deviceHeight * 0.9,
                        maxWidth: deviceWidth * 0.9,  // Constrain width to 90% of deviceWidth
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          LeftRightSwitch(
                            iconsColor: gray85Color,
                            iconsSize: max(fontSize * 2.0, 48.0),
                            rightBorder: nextStepId == steps['goToWrite'],
                            middleWidget: TeachWordCardTitle(
                              sectionName: '聽一聽',
                              iconsColor: gray85Color,
                            ),
                            isFirst: false,
                            isLast: false,
                            onLeftClicked: (nextStepId == steps['goToWrite'] || wordIsLearned)
                                ? () {
                                    prevTab();
                                    return _tabController.animateTo(_tabController.index - 1);
                                  }
                                : null,
                            onRightClicked: (nextStepId == steps['goToWrite'] || wordIsLearned)
                                ? () {
                                    nextTab();
                                    return _tabController.animateTo(_tabController.index + 1);
                                  }
                                : null,
                          ),
                          SizedBox(height: fontSize * 0.3),
                          SizedBox(
                            height: (deviceHeight * 0.4),
                            width: deviceWidth * 0.9,  // Limit width to 90% of deviceWidth
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                LayoutBuilder(builder: (context, constraints) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF28231D),
                                    ),
                                    child: Center(
                                      child: Text(
                                        word,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: fontSize * 8.0,
                                          color: backgroundColor,
                                          fontWeight: FontWeight.w100,
                                          fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TeachWordTabBarView(
              content: ChangeNotifierProvider<StrokeOrderAnimationController>.value(
                value: _strokeOrderAnimationControllers!,
                child: Consumer<StrokeOrderAnimationController>(
                  builder: (context, controller, child) {
                    // double availableWidth = deviceWidth - 20;  // 10 padding on each side
                    // double availableHeight = deviceHeight - 20;  // Padding on top and bottom
                    // double nonConsumedHeight = deviceHeight * 0.2;  // Adjust as needed

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: availableWidth * 0.90,
                          maxHeight: availableHeight - nonConsumedHeight,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,  // Ensure the column takes only the necessary space
                          children: <Widget>[
                            LeftRightSwitch(
                              iconsColor: gray85Color,
                              iconsSize: max(fontSize * 2.0, 48.0),  // Ensure a minimum tap target size
                              rightBorder: nextStepId == steps['goToUse1'],
                              middleWidget: TeachWordCardTitle(
                                sectionName: '寫一寫',
                                iconsColor: gray85Color,
                              ),
                              isFirst: false,
                              isLast: false,
                              onLeftClicked: wordIsLearned
                                  ? () async {
                                      int savedNextStepId = nextStepId;
                                      int oldTabIndex = currentTabIndex.value;
                                      nextStepId = steps['goToWrite']!;
                                      currentTabIndex.value = 2;
                                      debugPrint('回去 聽一聽 說：$word');
                                      if (isBpmf) {
                                        await player.play(AssetSource('bopomo/$word.mp3'));
                                      } else {
                                        await ftts.speak(word);
                                      }
                                      debugPrint(
                                          '寫一寫，上一頁2，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');
                                      prevTab();
                                      return _tabController.animateTo(_tabController.index - 1);
                                    }
                                  : null,
                              onRightClicked: (nextStepId == steps['goToUse1'] || wordIsLearned)
                                  ? () {
                                      nextTab();
                                      return _tabController.animateTo(_tabController.index + 1);
                                    }
                                  : null,
                            ),
                            SizedBox(height: fontSize * 0.2),

                            // Constrained Container for the animation and icons
                            SizedBox(
                              width: availableWidth,
                              height: (availableHeight - nonConsumedHeight) * 0.5,  // Allocate 50% of the available height
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    decoration: !isBpmf
                                        ? const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage("lib/assets/img/box.png"),
                                              fit: BoxFit.fitWidth,
                                            ),
                                          )
                                        : BoxDecoration(color: '#28231D'.toColor()),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          left: 10,
                                          top: 5,
                                          child: Column(children: [
                                            _buildPracticeTimeIcon(
                                                practiceTimeLeft >= 4 && !wordIsLearned,
                                                fontSize,
                                                '#999999',
                                                '#F8A339'),
                                            _buildPracticeTimeIcon(
                                                practiceTimeLeft >= 3 && !wordIsLearned,
                                                fontSize,
                                                '#999999',
                                                '#F8A339'),
                                            _buildPracticeTimeIcon(
                                                practiceTimeLeft >= 2 && !wordIsLearned,
                                                fontSize,
                                                '#999999',
                                                '#F8A339'),
                                            SizedBox(height: fontSize * 0.9),
                                            _buildPracticeTimeIcon(
                                                practiceTimeLeft >= 1 && !wordIsLearned,
                                                fontSize,
                                                '#999999',
                                                '#F8A3A9'),
                                          ]),
                                        ),
                                        FittedBox(
                                          child: StrokeOrderAnimator(
                                            _strokeOrderAnimationControllers!,
                                            key: UniqueKey(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            // GridView for icons and labels (筆順、寫字、邊框)
                            Flexible(
                              fit: FlexFit.loose,  // Allow this to take up the remaining space
                              child: GridView.count(
                                crossAxisCount: 3,
                                childAspectRatio: 1.0,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 3,
                                shrinkWrap: true,  // Use only the space needed by children
                                physics: const NeverScrollableScrollPhysics(),  // Disable GridView's scrolling
                                children: <Widget>[
                                  buildIconButtonWithLabel(
                                    context: context,
                                    border: nextStepId == steps['seeAnimation'],
                                    iconData: [Icons.pause, Icons.play_arrow],
                                    label: '筆順',
                                    isSelected: controller.isAnimating,
                                    onPressed: !controller.isQuizzing
                                        ? () async {
                                            if (!controller.isAnimating) {
                                              controller.startAnimation();
                                              if (isBpmf) {
                                                await player.play(AssetSource('bopomo/$word.mp3'));
                                              } else {
                                                await ftts.speak(word);
                                              }
                                              debugPrint('筆順 $word');
                                              if (nextStepId == steps['seeAnimation']) {
                                                setState(() {
                                                  nextStepId += 1;
                                                  debugPrint('setState 筆順 $word, nextStepId: $nextStepId');
                                                });
                                              }
                                            } else {
                                              controller.stopAnimation();
                                              debugPrint("stop animation // nextStepId update time");
                                            }
                                          }
                                        : null,
                                    fontSize: fontSize,
                                  ),
                                  buildIconButtonWithLabel(
                                    context: context,
                                    border: !controller.isQuizzing && (nextStepId == steps['practiceWithBorder1']),
                                    iconData: [Icons.edit_off, Icons.edit],
                                    label: '寫字',
                                    isSelected: controller.isQuizzing,
                                    onPressed: (nextStepId == steps['practiceWithBorder1'] || wordIsLearned)
                                        ? () async {
                                            controller.startQuiz();
                                            if (isBpmf) {
                                              await player.play(AssetSource('bopomo/$word.mp3'));
                                            } else {
                                              await ftts.speak(word);
                                            }
                                            debugPrint('寫字 $word');
                                          }
                                        : null,
                                    fontSize: fontSize,
                                  ),
                                  buildIconButtonWithLabel(
                                    context: context,
                                    border: nextStepId == steps['turnBorderOff'],
                                    iconData: [Icons.remove_red_eye, Icons.remove_red_eye_outlined],
                                    label: '邊框',
                                    isSelected: controller.showOutline,
                                    onPressed: (nextStepId == steps['turnBorderOff'] || wordIsLearned)
                                        ? () {
                                            if (nextStepId == steps['turnBorderOff']) {
                                              setState(() {
                                                nextStepId += 1;
                                                debugPrint('setState 邊框 $word, nextStepId: $nextStepId');
                                              });
                                            }
                                            controller.setShowOutline(!controller.showOutline);
                                          }
                                        : null,
                                    fontSize: fontSize,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            useTabView[vocabIndex],
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          height: 4.0 * fontSize,
          elevation: 0,
          color: '#28231D'.toColor(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: deviceWidth,  // Constrain the bottom app bar to the device width
            ),
            child: LeftRightSwitch(
              iconsColor: '#F5F5DC'.toColor(),
              iconsSize: fontSize * 2.0,
              rightBorder: false,
              middleWidget: WordCard(
                unitId: unitId,
                unitTitle: unitTitle,
                wordsStatus: widget.wordsStatus,
                wordsPhrase: widget.wordsPhrase,
                wordIndex: widget.wordIndex,
                sizedBoxWidth: 10 * fontSize,
                sizedBoxHeight: 4.0 * fontSize,
                fontSize: fontSize * 1.2,
                isBpmf: isBpmf,
                isVertical: false,
                disable: true,
              ),
              isFirst: (widget.wordIndex == 0),
              isLast: (widget.wordIndex == widget.wordsStatus.length - 1),
              onLeftClicked: () {
                navigateWithProvider(
                  context,
                  '/teachWord',
                  ref,
                  arguments: {
                    'unitId': widget.unitId,
                    'unitTitle': widget.unitTitle,
                    'wordsStatus': widget.wordsStatus,
                    'wordsPhrase': widget.wordsPhrase,
                    'wordIndex': widget.wordIndex - 1,
                  },
                );
              },
              onRightClicked: () {
                navigateWithProvider(
                  context,
                  '/teachWord',
                  ref,
                  arguments: {
                    'unitId': widget.unitId,
                    'unitTitle': widget.unitTitle,
                    'wordsStatus': widget.wordsStatus,
                    'wordsPhrase': widget.wordsPhrase,
                    'wordIndex': widget.wordIndex + 1,
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

  }

  // Helper method to create an icon button with a label
  Widget buildIconButtonWithLabel({
    required BuildContext context,
    required bool border,
    required List<IconData> iconData,
    required String label,
    required bool isSelected,
    required Function()? onPressed, // Change the type to Function()?
    required double fontSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              border: border
                  ? Border.all(color: '#FFFF93'.toColor(), width: 1.5)
                  : null,
            ),
            child: IconButton(
              icon: Icon(
                isSelected ? iconData[0] : iconData[1],
                size: fontSize * 1.0,
              ),
              color: backgroundColor,
              onPressed: onPressed != null
                  ? () => onPressed()
                  : null, // Use a closure to call the function
            ),
          );
        }),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeTimeIcon(bool condition, double fontSize, String defaultColorHex, String activeColorHex) {
    return Icon(
      condition ? Icons.check_circle_outline_outlined : Icons.check_circle,
      color: condition ? defaultColorHex.toColor() : activeColorHex.toColor(),
      size: fontSize * 1.5,
    );
  }

}
