// ignore_for_file: unused_local_variable

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
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';
import 'package:ltrc/widgets/word_card.dart';
import 'package:provider/provider.dart';
import 'package:ltrc/views/view_utils.dart';

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
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);
  // Define the color used for the background
  static const Color backgroundColor = Color.fromRGBO(245, 245, 220, 100);
  bool get wordIsLearned =>
      widget.wordsStatus[widget.wordIndex].learned; // 這才是正確的方法
  bool _showErrorDialog = false;
  bool _firstNullStroke = true;

  void nextTab() async {
    // nextTab() is called in many places, one setState() is called
    int currentTabValue = currentTabIndex.value;
    debugPrint(
        'nextTab nextStepId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist, currentTab $currentTabValue');
    currentTabIndex.value++;

    if (svgFileExist) {
      if ((wordIsLearned) && (nextStepId > 1 && nextStepId < 8)) {
        // 1-7 different steps in 寫一寫
        // debugPrint('nextTab 字已學，要從“寫一寫”中的任一步驟，跳到“用一用”');
        nextStepId = steps['goToUse1']!;
      }
    } else {
      if (nextStepId > 0 && nextStepId < 8) {
        debugPrint('nextTab no svg. Show error message.');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 選上一頁，nextStepId = goToListen; 選下一頁，nextStepId = goToUse1
          showErrorDialog2('',
              '抱歉，「${widget.wordsStatus[widget.wordIndex].word}」還沒有筆順。請繼續。謝謝！');
        });
        setState(() {});
      } else {
        // Handle other cases if necessary
      }
    }

    if (nextStepId == steps['goToListen']) {
      // 0
      incrementNextStepId();
    } else if (nextStepId == steps['goToWrite']) {
      // 1
      incrementNextStepId();
    } else if (nextStepId == steps['goToUse1']) {
      // 8
      // debugPrint('nextTab goToUse1, call handleGoToUseStep');
      await handleGoToUseStep();
    } else if (nextStepId == steps['goToUse2']) {
      // 9
      // debugPrint('nextTab goToUse2, call handleGoToUseStep');
      await handleGoToUseStep();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(
            '', '「${widget.wordsStatus[widget.wordIndex].word}」程序問題。請截圖回報。謝謝！');
      });
    }
    // }
  }

  void prevTab() async {
    int currentTabValue = currentTabIndex.value;
    debugPrint(
        'prevTab nextStepId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist, currentTab $currentTabValue');
    currentTabIndex.value--;

    if (svgFileExist) {
      if ((wordIsLearned) && (nextStepId > 0 && nextStepId < 8)) {
        // 1-7 different steps in 寫一寫
        // debugPrint('prevTab 字已學，要從“學一學”中的任一步驟，跳到“聽一聽”');
        nextStepId = steps['goToListen']!;
      }
    } else {
      // no svg
      if (nextStepId == steps['goToUse1']) {
        // 從 “用一用”，退回去“寫一寫”
        debugPrint('prevTab no svg. Show error message.');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 選上一頁，nextStepId = goToListen; 選下一頁，nextStepId = goToUse1
          showErrorDialog2('',
              '「${widget.wordsStatus[widget.wordIndex].word}」沒有筆順。請截圖回報。謝謝！');
        });
        setState(() {});
      } else {
        // Handle other cases if necessary
      }
    }

    if (nextStepId == steps['goToUse2']) {
      // 9
      // debugPrint('prevTab goToUse2, go back to goToUse1');
      nextStepId = steps['goToUse1']!;
    } else if (nextStepId == steps['goToUse1']) {
      // 8
      // debugPrint('prevTab goToUse1, go back to goToWrite');
      nextStepId = steps['goToWrite']!;
    } else if (nextStepId == steps['goToWrite']) {
      // 1
      nextStepId = steps['goToListen']!;
    } else if (nextStepId == steps['goToListen']) {
      // 0
      nextStepId = steps['goToListen']!;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(
            '', '「${widget.wordsStatus[widget.wordIndex].word}」程序問題2。請截圖回報。謝謝！');
      });
    }
  }

  void incrementNextStepId() {
    setState(() {
      nextStepId += 1;
    });
  }

  Future<void> handleGoToUseStep() async {
    // debugPrint('handleGoToUseStep vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, vocab2: ${wordObj['vocab2']}, nextStepId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
    var result =
        await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
    // debugPrint('handleGoToUseStep-2 vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, vocab2: ${wordObj['vocab2']}, nextStepId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist, result: $result');
    if (vocabCnt == 1) {
      WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
      ref.read(learnedWordCountProvider.notifier).state += 1;
      // debugPrint('handleGoToUseStep vocabCnt = 1, newStatus: $newStatus, nextStepId: $nextStepId');
      await WordStatusProvider.updateWordStatus(status: newStatus);
      setState(() {
        newStatus.learned = true; // I never saw this flag set. Why?
        // nextStepId = 100; // temp disabled for testing sjf
      });
    } else {
      setState(() {
        nextStepId += 1;
        // debugPrint('handleGoToUseStep vocabCnt = $vocabCnt, nextStepId: $nextStepId');
      });
    }
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
    debugPrint(
        'getWord begin: phraseEmpty: $phraseEmpty, tempIndex: $tempIndex');
    if (phraseEmpty) {
      debugPrint('getWord error: wordsPhrase is empty');
      wordObj = {};
      wordExist = false;
      return;
    } else {
      // debugPrint('getWord index: $tempIndex, length: ${widget.wordsPhrase.length}');
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
      // debugPrint('getWord end: wordExist: $wordExist, vocabCnt: $vocabCnt, ${wordObj['vocab1']}, ${wordObj['vocab2']}');
    } catch (error) {
      wordExist = false;
      // debugPrint('getWord error: : $error。wordExist: $wordExist,${wordObj['vocab1']}');
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint(
        'initState begin, wordIsLearned: $wordIsLearned, nextStepID: $nextStepId, wordExist: $wordExist, svgFileExist: $svgFileExist');
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);

    // Initialize the TabController
    _tabController = TabController(length: 4, vsync: this);

    // Setup completion handler for TTS
    ftts.setCompletionHandler(() async {
      debugPrint(
          '\nTTS handler called. mounted: $mounted, nextStepId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');

      if (!mounted) return;

      WordStatus newStatus = widget.wordsStatus[widget.wordIndex];

      if (nextStepId == steps['goToListen']) {
        // debugPrint('TTS handler goToListen, call incrementNextStepId, newStatus: $newStatus, nextStepId: $nextStepId');
        incrementNextStepId();
      } else if (nextStepId == steps['goToUse1']) {
        // debugPrint('TTS handler goToUse1, call handleGoToUse1, newStatus: $newStatus, nextStepId: $nextStepId');
        await handleGoToUse1(newStatus);
      } else if (nextStepId == steps['goToUse2']) {
        // debugPrint('TTS handler goToUse2, call updateWordStatus, newStatus: $newStatus, nextStepId: 0');
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
    debugPrint(
        'initState end, nextStepId: $nextStepId, wordExist: $wordExist, svgFileExist: $svgFileExist');
  }

  Future<void> handleGoToUse1(WordStatus newStatus) async {
    // debugPrint('handleGoToUse1. vocab #: $vocabCnt, newStatus: $newStatus, nextStepId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
    if (vocabCnt == 1) {
      await updateWordStatus(newStatus, learned: true, nextStepId: 0);
    } else {
      incrementNextStepId();
    }
  }

  Future<void> updateWordStatus(WordStatus newStatus,
      {required bool learned, required int nextStepId}) async {
    debugPrint(
        'updateWordStatus. mounted: $mounted, learned: $learned, nextStepId: $nextStepId');
    if (!mounted) return;
    setState(() {
      // setState 3 do we need this?
      newStatus.learned = learned;
      this.nextStepId = nextStepId;
    });

    ref.read(learnedWordCountProvider.notifier).state += 1;
    await WordStatusProvider.updateWordStatus(status: newStatus);
  }

  void checkWordExistence() {
    if (!wordExist) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('',
            '「${widget.wordsStatus[widget.wordIndex].word}」不在SQL。請截圖回報。謝謝！');
      });
    } else {
      readJsonAndProcess(); // setState() is called here
    }
  }

  Future<void> readJsonAndProcess() async {
    // setState() is called here
    try {
      final result = await readJson();
      debugPrint(
          'readJsonAndProcess: ${widget.wordsStatus[widget.wordIndex].word} ${svgFileExist ? "有筆順" : "沒有筆順"}');
      if (result.isNotEmpty) {
        setState(() {
          // setState 4 do we need this?
          _strokeOrderAnimationControllers = StrokeOrderAnimationController(
              result, this,
              onQuizCompleteCallback: handleQuizCompletion);
          // svgFileExist is set in readJson(). Should not be set in other places.
        });
      } else {
        setState(() {
          // setState 5 do we need this?
          _strokeOrderAnimationControllers = null;
          // svgFileExist is set in readJson(). Should not be set in other places.
        });
      }
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('',
            '「${widget.wordsStatus[widget.wordIndex].word}」沒有筆順1。請截圖回報。謝謝！');
      });
      setState(() {
        // setState 6 do we need this?
        _strokeOrderAnimationControllers = null;
        // svgFileExist is set in readJson(). Should not be set here.
        debugPrint(
            'readJsonAndProcess error: ${widget.wordsStatus[widget.wordIndex].word} 沒有筆順, svgFileExist: $svgFileExist'); // Came here. What's next?
      });
    }
  }

  Future<String> readJson() async {
    // Define the noSvgList. This list needs to be updated every new shcool semester
    // List<String> noSvgList = ['上', '右']; // For testing only
    List<String> noSvgList = [
      '吔',
      '姍',
      '媼',
      '嬤',
      '履',
      '搧',
      '枴',
      '椏',
      '欓',
      '汙',
      '溼',
      '漥',
      '痠',
      '礫',
      '粄',
      '粿',
      '綰',
      '蓆',
      '襬',
      '譟',
      '踖',
      '踧',
      '鎚',
      '鏗',
      '鏘',
      '陳',
      '颺',
      '齒'
    ];

    String word = widget.wordsStatus[widget.wordIndex].word;

    // If the word is in the noSvgList, use '學' as the word to avoid null checking
    if (noSvgList.contains(word)) {
      word =
          '學'; // Set the word to "學" to avoid null checking in the rest of code
      svgFileExist = false;
    } else {
      svgFileExist = true;
    }
    // debugPrint('readJson() word: $word, svgFileExist: $svgFileExist');

    // Proceed with loading the SVG file
    try {
      final String response =
          await rootBundle.loadString('lib/assets/svg/$word.json');
      return response.replaceAll("\"", "'");
    } catch (e) {
      // Handle error if the SVG file does not exist or cannot be loaded
      svgFileExist = false;
      debugPrint('readJson() error: $e, svgFileExist: $svgFileExist');
      return ''; // Return an empty string
    }
  }

  void handleQuizCompletion(QuizSummary summary) {
    if (nextStepId >= steps['practiceWithBorder1']! &&
        nextStepId <= steps['turnBorderOff']!) {
      setState(() {
        // setState 7 do we need this?
        practiceTimeLeft -= 1;
        nextStepId += 1;
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
          // setState 8 do we need this?
          practiceTimeLeft -= 1;
          nextStepId += 1;
          // widget.wordsStatus[widget.wordIndex].learned = true; // 強迫設這標籤
          // debugPrint('handleQuizCompletion 要進入用一用,learned flag: ${widget.wordsStatus[widget.wordIndex].learned}');
        });
      }
      Fluttertoast.showToast(
        msg: ["恭喜筆畫正確！"].join(),
        fontSize: fontSize * 1.2,
      );
    }
  }

  void showErrorDialog(String message, String title) {
    if (!mounted) return;

    showDialog(
      context: context,
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

  void showErrorDialog2(String message, String title) {
    if (!mounted) return;

    showDialog(
      context: context,
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
                '上一頁',
                style: TextStyle(
                  color: Colors.black, // Set text color to black
                  fontSize: fontSize * 1.2, // Set font size
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                nextStepId = steps['goToListen']!;
                // var result = await ftts.speak(word); // Did not speak the word. TBF
                currentTabIndex.value--;
                return _tabController.animateTo(_tabController.index - 1);
              },
            ),
            TextButton(
              child: Text(
                '下一頁',
                style: TextStyle(
                  color: Colors.black, // Set text color to black
                  fontSize: fontSize * 1.2, // Set font size
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                nextStepId = steps['goToUse1']!; // try to skip 寫一寫 sjf
                handleGoToUseStep();
                currentTabIndex.value++;
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

  int vocabIndex = 0;

  Map<String, int> steps = {
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
    // bool wordIsLearned = widget.wordsStatus[widget.wordIndex].learned;

    ScreenInfo screenInfo = getScreenInfo(context);
    fontSize = screenInfo.fontSize;
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    double availableWidth = deviceWidth - 20; // 10 padding on each side
    double availableHeight =
        deviceHeight - 20; // example padding top and bottom
    double nonConsumedHeight = deviceHeight * 0.15; // was 0.20;
    var gray85Color = '#D9D9D9'.toColor();

    String word = widget.wordsStatus[widget.wordIndex].word;
    int unitId = widget.unitId;
    String unitTitle = widget.unitTitle;
    // debugPrint('\nbuild word: $word, nextStepId: $nextStepId, wordExist: $wordExist, svgFileExist: $svgFileExist, wordIsLearned: $wordIsLearned');

    // 不知道為何每一個字都會出現 _strokeOrderAnimationControllers is null 一次。
    // 若出現第二次，則有問題。
    if (_strokeOrderAnimationControllers == null) {
      // debugPrint('build _strokeOrderAnimationControllers is null, _firstNullStroke: $_firstNullStroke, nextStepId: $nextStepId');
      if (_firstNullStroke) {
        _firstNullStroke = false;
        return Container();
      } else {
        _showErrorDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_showErrorDialog) {
            showErrorDialog('',
                '「${widget.wordsStatus[widget.wordIndex].word}」沒有筆順2。請截圖回報。謝謝！');
            _firstNullStroke = true; // Reset the flag
            _showErrorDialog = false; // Reset the flag
          }
        });
        // Return a fallback widget to avoid returning null
        return Container(); // or any other placeholder widget
      }
    }

    // debugPrint('build _strokeOrder is not null, word: $word,  wordExist: $wordExist, svgFileExist: $svgFileExist, nextStepId: $nextStepId, wordIsLearned: $wordIsLearned, vocabCnt: $vocabCnt, vocabIndex: $vocabIndex');
    List<Widget> useTabView = [
      TeachWordTabBarView(
        // 用一用 - 例句1
        content: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            availableWidth * 0.90, // 90% of the available width
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          LeftRightSwitch(
                            // LeftRightSwitch for 用一用
                            iconsColor: gray85Color,
                            iconsSize: fontSize * 2.0, // was 35
                            rightBorder: nextStepId == steps['goToUse2'],
                            middleWidget: TeachWordCardTitle(
                                sectionName: '用一用', iconsColor: gray85Color),
                            isFirst: false,
                            isLast: (vocabCnt == 1),
                            onLeftClicked: wordIsLearned
                                ? () {
                                    prevTab();
                                    return _tabController
                                        .animateTo(_tabController.index - 1);
                                  }
                                : null,
                            onRightClicked: (nextStepId == steps['goToUse2'] ||
                                    wordIsLearned)
                                ? () async {
                                    setState(() {
                                      vocabIndex = 1;
                                    });
                                    if (nextStepId == steps['goToUse2']) {
                                      var result = await ftts.speak(
                                          "${wordObj['vocab2']}。${wordObj['sentence2']}");
                                      // debugPrint('用一用 vocab2: ${wordObj['vocab2']}');
                                      WordStatus newStatus =
                                          widget.wordsStatus[widget.wordIndex];
                                      setState(() {
                                        // setState 100 do we need this?
                                        newStatus.learned =
                                            true; // I never saw this flag set. Why?
                                        // debugPrint('build 用一用 newStatus: $newStatus');
                                        // nextStepId = 100; temp disabled for testing sjf
                                      });
                                      ref
                                          .read(
                                              learnedWordCountProvider.notifier)
                                          .state += 1;
                                      await WordStatusProvider.updateWordStatus(
                                          status: newStatus);
                                    }
                                    setState(() {
                                      // setState 11 do we need this?
                                      vocabIndex = 1;
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
                                  // alternativePhrases: alternativePhrases, // Pass the fetched phrases here
                                ),
                          Flexible(
                            // Make the Row flexible to avoid overflow
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                (img1Exist && !isBpmf)
                                    ? Image(
                                        height: fontSize *
                                            3.0, // deviceHeight * 0.15, no difference wy?
                                        image: AssetImage(
                                            'lib/assets/img/vocabulary/${wordObj['vocab1']}.webp'), // changed png to webp
                                      )
                                    : SizedBox(
                                        height: fontSize *
                                            0.5), // was deviceHeight * 0.08
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
            Positioned(
              // Position the text at the bottom right
              right: fontSize, // Adjust the value as needed for proper spacing
              bottom: fontSize, // Adjust the value as needed for proper spacing
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
      (vocabCnt == 2)
          ? TeachWordTabBarView(
              // 用一用 - 例句2
              content: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                        child: Center(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: availableWidth *
                                      0.90, // 90% of the available width
                                  // maxHeight is removed because Expanded will handle the available space
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize
                                      .max, // Use maximum space available
                                  children: <Widget>[
                                    LeftRightSwitch(
                                      iconsColor: gray85Color,
                                      iconsSize: fontSize * 2.0,
                                      rightBorder: false,
                                      middleWidget: TeachWordCardTitle(
                                          sectionName: '用一用',
                                          iconsColor: gray85Color),
                                      isFirst: false,
                                      isLast: true,
                                      onLeftClicked: wordIsLearned
                                          ? () {
                                              prevTab();
                                              setState(() {
                                                vocabIndex = 0;
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
                                            sentence:
                                                "${wordObj['sentence2']}\n",
                                            vocab2: wordObj['vocab1'],
                                            // alternativePhrases: alternativePhrases, // Pass the fetched phrases here
                                          ),
                                    Flexible(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          (img2Exist && !isBpmf)
                                              ? Image(
                                                  height: fontSize * 3.0,
                                                  image: AssetImage(
                                                      'lib/assets/img/vocabulary/${wordObj['vocab2']}.webp'), // changed png to webp
                                                )
                                              : SizedBox(
                                                  height: fontSize * 0.5,
                                                ),
                                        ], // children
                                      ),
                                    ),
                                  ],
                                )))),
                  ],
                ),
                Positioned(
                  // Position the text at the bottom right
                  right:
                      fontSize, // Adjust the value as needed for proper spacing
                  bottom:
                      fontSize, // Adjust the value as needed for proper spacing
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
          : Container()
    ];

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
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
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
              TeachWordTabBarView(
                // 看一看 （不在 steps 裡）
                content: Column(
                  children: [
                    Expanded(
                      // This will fill the vertical space available after accounting for the space used by other widgets
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: availableWidth *
                                0.90, // 90% of the available width
                            // maxHeight is removed because Expanded will handle the available space
                          ),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.max, // Use maximum space available
                            children: <Widget>[
                              LeftRightSwitch(
                                // 看一看及左右按鈕
                                iconsColor: gray85Color,
                                iconsSize: max(fontSize * 2.0,
                                    48.0), // Ensure a minimum tap target size
                                rightBorder: nextStepId == steps['goToListen'],
                                middleWidget: TeachWordCardTitle(
                                    sectionName: '看一看',
                                    iconsColor: gray85Color),
                                isFirst: true,
                                isLast: false,
                                onRightClicked: (nextStepId ==
                                            steps['goToListen']! ||
                                        wordIsLearned)
                                    ? () async {
                                        nextTab();
                                        // var result = await player.play(AssetSource('bopomo/$word.mp3'));
                                        if (isBpmf) {
                                          await player.play(
                                              AssetSource('bopomo/$word.mp3'));
                                        } else {
                                          var result = await ftts.speak(word);
                                        }
                                        return _tabController.animateTo(
                                            _tabController.index + 1);
                                      }
                                    : null,
                              ),
                              SizedBox(
                                  height: fontSize *
                                      0.3), // Some small space between widgets
                              Expanded(
                                // This will take the remaining space after the switch and the SizedBox
                                child: Stack(
                                  // Use Stack to overlay the icon on the bottom right corner
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF28231D)),
                                      child: Center(
                                        // Center the text within the container
                                        child: Image(
                                          width: max(17.6 * fontSize,
                                              300.0), // was 300,
                                          image: isBpmf
                                              ? AssetImage(
                                                  'lib/assets/img/bopomo/$word.png')
                                              : AssetImage(
                                                  'lib/assets/img/oldWords/$word.webp'), // change png to webp
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            // Log the error
                                            debugPrint(
                                                'Error loading image: $exception');

                                            // Return the Text widget as a fallback
                                            return Center(
                                              child: Text(
                                                word,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: fontSize *
                                                      8.0, // Adjust font size to be reasonable
                                                  color:
                                                      backgroundColor, // Ensure backgroundColor is defined or use a default color
                                                  fontWeight: FontWeight.w100,
                                                  fontFamily: isBpmf
                                                      ? "BpmfOnly"
                                                      : "BpmfIansui",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
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
              TeachWordTabBarView(
                // 聽一聽
                content: Column(
                  children: [
                    Expanded(
                      // This will fill the vertical space available after accounting for the space used by other widgets
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: availableWidth *
                                0.90, // 90% of the available width
                            // maxHeight is removed because Expanded will handle the available space
                          ),
                          child: Column(
                            mainAxisSize:
                                MainAxisSize.max, // Use maximum space available
                            children: <Widget>[
                              LeftRightSwitch(
                                // 聽一聽及左右按鈕
                                iconsColor: gray85Color,
                                iconsSize: max(fontSize * 2.0,
                                    48.0), // Ensure a minimum tap target size
                                rightBorder: nextStepId == steps['goToWrite'],
                                middleWidget: TeachWordCardTitle(
                                    sectionName: '聽一聽',
                                    iconsColor: gray85Color),
                                isFirst: false,
                                isLast: false,
                                onLeftClicked: (wordIsLearned)
                                    ? () {
                                        prevTab();
                                        // currentTabIndex.value--; this is done in prevTab()
                                        return _tabController.animateTo(
                                            _tabController.index - 1);
                                      }
                                    : null,
                                onRightClicked:
                                    (nextStepId == steps['goToWrite'] ||
                                            wordIsLearned)
                                        ? () {
                                            nextTab();
                                            return _tabController.animateTo(
                                                _tabController.index + 1);
                                          }
                                        : null,
                              ),
                              SizedBox(
                                  height: fontSize *
                                      0.3), // Some small space between widgets
                              Expanded(
                                // This will take the remaining space after the switch and the SizedBox
                                child: Stack(
                                  // Use Stack to overlay the icon on the bottom right corner
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF28231D)),
                                      child: Center(
                                        // Center the text within the container
                                        child: Text(
                                          word,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: fontSize *
                                                8.0, // Adjust font size to be reasonable
                                            color: backgroundColor,
                                            fontWeight: FontWeight.w100,
                                            fontFamily: isBpmf
                                                ? "BpmfOnly"
                                                : "BpmfIansui",
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      // Position the icon at the bottom right
                                      bottom:
                                          8.0, // Adjust the positioning as needed
                                      right:
                                          8.0, // Adjust the positioning as needed
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .end, // Align the text to the right
                                        children: [
                                          IconButton(
                                            iconSize: fontSize * 1.2,
                                            color: backgroundColor,
                                            onPressed: () async {
                                              // var result = await player.play(AssetSource('bopomo/$word.mp3'));
                                              // debugPrint('聽一聽 $word');  // 移到前面，因為 await 會有延遲
                                              if (isBpmf) {
                                                await player.play(AssetSource(
                                                    'bopomo/$word.mp3'));
                                              } else {
                                                var result =
                                                    await ftts.speak(word);
                                              }
                                              // debugPrint('聽一聽 $word');
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
                      ),
                    ),
                  ],
                ),
              ),
              TeachWordTabBarView(
                // 寫一寫
                content: ChangeNotifierProvider<
                    StrokeOrderAnimationController>.value(
                  value: _strokeOrderAnimationControllers!,
                  child: Consumer<StrokeOrderAnimationController>(
                      builder: (context, controller, child) {
                    double availableWidth =
                        deviceWidth - 20; // 10 padding on each side
                    double availableHeight =
                        deviceHeight - 20; // example padding top and bottom
                    double nonConsumedHeight = deviceHeight * 0.2; // was 0.15;

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: availableWidth * 0.90,
                          maxHeight: availableHeight - nonConsumedHeight,
                        ),
                        child: Column(
                          mainAxisSize:
                              MainAxisSize.max, // Use maximum space available
                          children: <Widget>[
                            LeftRightSwitch(
                              // 寫一寫及左右按鈕
                              iconsColor: gray85Color,
                              iconsSize: max(fontSize * 2.0,
                                  48.0), // Ensure a minimum tap target size
                              rightBorder: nextStepId == steps['goToUse1'],
                              middleWidget: TeachWordCardTitle(
                                  sectionName: '寫一寫', iconsColor: gray85Color),
                              isFirst: false,
                              isLast: false,
                              onLeftClicked: wordIsLearned
                                  ? () {
                                      prevTab();
                                      // currentTabIndex.value--; this is done inside prevTab()
                                      return _tabController
                                          .animateTo(_tabController.index - 1);
                                    }
                                  : null,
                              onRightClicked: (nextStepId ==
                                          steps['goToUse1'] ||
                                      wordIsLearned)
                                  ? () {
                                      nextTab();
                                      return _tabController
                                          .animateTo(_tabController.index + 1);
                                    }
                                  : null,
                            ),
                            SizedBox(height: fontSize * 0.2), // was 0.3
                            SizedBox(
                              width: availableWidth *
                                  1.0, // or any other appropriate width
                              height: (availableHeight - nonConsumedHeight) *
                                  0.5, // Allocate 50% of the available height
                              child: Container(
                                decoration: !isBpmf
                                    ? const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "lib/assets/img/box.png"),
                                          fit: BoxFit.fitWidth,
                                        ),
                                      )
                                    : BoxDecoration(color: '#28231D'.toColor()),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // check mark for completetion
                                    Positioned(
                                      left: 10,
                                      top: 5,
                                      child: Column(children: [
                                        Icon(
                                          (practiceTimeLeft >=
                                                      4 &&
                                                  !wordIsLearned)
                                              ? Icons
                                                  .check_circle_outline_outlined
                                              : Icons.check_circle,
                                          color: (practiceTimeLeft >= 4 &&
                                                  !wordIsLearned)
                                              ? '#999999'.toColor()
                                              : '#F8A339'.toColor(),
                                          size: fontSize * 1.5,
                                        ),
                                        Icon(
                                          (practiceTimeLeft >=
                                                      3 &&
                                                  !wordIsLearned)
                                              ? Icons
                                                  .check_circle_outline_outlined
                                              : Icons.check_circle,
                                          color: (practiceTimeLeft >= 3 &&
                                                  !wordIsLearned)
                                              ? '#999999'.toColor()
                                              : '#F8A339'.toColor(),
                                          size: fontSize * 1.5,
                                        ),
                                        Icon(
                                          (practiceTimeLeft >=
                                                      2 &&
                                                  !wordIsLearned)
                                              ? Icons
                                                  .check_circle_outline_outlined
                                              : Icons.check_circle,
                                          color: (practiceTimeLeft >= 2 &&
                                                  !wordIsLearned)
                                              ? '#999999'.toColor()
                                              : '#F8A339'.toColor(),
                                          size: fontSize * 1.5, // was 25
                                        ),
                                        SizedBox(
                                          height: fontSize * 0.9,
                                        ), // was 15
                                        Icon(
                                          (practiceTimeLeft >=
                                                      1 &&
                                                  !wordIsLearned)
                                              ? Icons
                                                  .check_circle_outline_outlined
                                              : Icons.check_circle,
                                          color: (practiceTimeLeft >= 1 &&
                                                  !wordIsLearned)
                                              ? '#999999'.toColor()
                                              : '#F8A3A9'.toColor(),
                                          size: fontSize * 1.5, // was 25
                                        ),
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
                              ),
                            ),
                            // SizedBox(height: fontSize * 0.3,),

                            // GridView for icons and labels 筆順、寫字、邊框
                            // Since GridView is already wrapped in a Flexible, it will take the remaining space
                            Flexible(
                              child: GridView.count(
                                crossAxisCount: 3,
                                childAspectRatio: 1.0,
                                mainAxisSpacing: 2,
                                crossAxisSpacing: 3,
                                shrinkWrap:
                                    true, // Use only the space needed by children
                                physics:
                                    const NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                                children: <Widget>[
                                  // IconButton for 筆順
                                  buildIconButtonWithLabel(
                                      context: context,
                                      border:
                                          nextStepId == steps['seeAnimation'],
                                      iconData: [Icons.pause, Icons.play_arrow],
                                      label: '筆順',
                                      isSelected: controller.isAnimating,
                                      onPressed: !controller.isQuizzing
                                          ? () async {
                                              if (!controller.isAnimating) {
                                                controller.startAnimation();
                                                // var result = await player.play(AssetSource('bopomo/$word.mp3'));
                                                if (isBpmf) {
                                                  await player.play(AssetSource(
                                                      'bopomo/$word.mp3'));
                                                } else {
                                                  var result =
                                                      await ftts.speak(word);
                                                }
                                                // debugPrint('筆順 $word');
                                                if (nextStepId ==
                                                    steps['seeAnimation']) {
                                                  setState(() {
                                                    // setState 13 do we need this?
                                                    nextStepId += 1;
                                                  });
                                                }
                                              } else {
                                                controller.stopAnimation();
                                                // debugPrint("stop animation // nextStepId update time");
                                              }
                                            }
                                          : null,
                                      fontSize: fontSize),
                                  // border
                                  // IconButton for 寫字
                                  buildIconButtonWithLabel(
                                      context: context,
                                      border: (!controller.isQuizzing &&
                                          (nextStepId ==
                                                  steps[
                                                      'practiceWithBorder1'] ||
                                              nextStepId ==
                                                  steps[
                                                      'practiceWithBorder2'] ||
                                              nextStepId ==
                                                  steps[
                                                      'practiceWithBorder3'] ||
                                              nextStepId ==
                                                  steps[
                                                      'practiceWithoutBorder1'])),
                                      iconData: [Icons.edit_off, Icons.edit],
                                      label: '寫字',
                                      isSelected: controller.isQuizzing,
                                      onPressed: (nextStepId ==
                                                  steps[
                                                      'practiceWithBorder1'] ||
                                              nextStepId ==
                                                  steps[
                                                      'practiceWithBorder2'] ||
                                              nextStepId ==
                                                  steps[
                                                      'practiceWithBorder3'] ||
                                              nextStepId ==
                                                  steps[
                                                      'practiceWithoutBorder1'] ||
                                              wordIsLearned)
                                          ? () async {
                                              controller.startQuiz();
                                              // var result = await player.play(AssetSource('bopomo/$word.mp3'));
                                              if (isBpmf) {
                                                await player.play(AssetSource(
                                                    'bopomo/$word.mp3'));
                                              } else {
                                                var result =
                                                    await ftts.speak(word);
                                              }
                                              // debugPrint('寫字 $word');
                                            }
                                          : null,
                                      fontSize: fontSize),

                                  // IconButton for 邊框
                                  buildIconButtonWithLabel(
                                      context: context,
                                      border: (nextStepId ==
                                          steps['turnBorderOff']),
                                      iconData: [
                                        Icons.remove_red_eye,
                                        Icons.remove_red_eye_outlined
                                      ],
                                      label: '邊框',
                                      isSelected: controller.showOutline,
                                      onPressed: (nextStepId ==
                                                  steps['turnBorderOff'] ||
                                              wordIsLearned)
                                          ? () {
                                              if (nextStepId ==
                                                  steps['turnBorderOff']) {
                                                setState(() {
                                                  // setState 14 do we need this?
                                                  nextStepId += 1;
                                                });
                                              }
                                              controller.setShowOutline(
                                                  !controller.showOutline);
                                            }
                                          : null,
                                      fontSize: fontSize),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
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
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TeachWordView(
                            unitId: widget.unitId,
                            unitTitle: widget.unitTitle,
                            wordsStatus: widget.wordsStatus,
                            wordsPhrase: widget.wordsPhrase,
                            wordIndex: widget.wordIndex - 1,
                          )));
                },
                onRightClicked: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TeachWordView(
                            unitId: widget.unitId,
                            unitTitle: widget.unitTitle,
                            wordsStatus: widget.wordsStatus,
                            wordsPhrase: widget.wordsPhrase,
                            wordIndex: widget.wordIndex + 1,
                          )));
                })),
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
        Container(
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
        ),
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
}
