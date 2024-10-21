// teach_word_view.dart 
// refactored to improve readability, maintainability and performance
import 'dart:math';
import 'package:flutter/foundation.dart';
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
  // Original state variables
  StrokeOrderAnimationController? _strokeOrderAnimationController;
  late TabController _tabController;
  FlutterTts ftts = FlutterTts();
  final player = AudioPlayer();
  late Map wordsPhrase;
  late Map wordObj;
  String word = '';
  int vocabCnt = 0;
  bool img1Exist = false;
  bool img2Exist = false;
  bool wordExist = false; // 字存在，但是 json 可能不存在 (svgFileExist = false)
  bool svgFileExist = false; // 字存在，json 也存在
  double fontSize = 0;
  int practiceTimeLeft = 4;
  int nextStepId = 0;
  bool isBpmf = false;
  int vocabIndex = 0;
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);

  bool get wordIsLearned =>
      widget.wordsStatus[widget.wordIndex].learned;
  bool _showErrorDialog = false;
  bool _firstNullStroke = true;

  // REFACTOR: Extract steps into a constant map
  static const Map<String, int> steps = {
    'goToListen': 0,
    'goToWrite': 1,
    'seeAnimation': 2,
    'practiceWithBorder1': 3,
    'practiceWithBorder2': 4,
    'practiceWithBorder3': 5,
    'turnBorderOff': 6,
    'practiceWithoutBorder1': 7,
    'goToUse1': 8,
    'goToUse2': 9,
  };

  @override
  void initState() {
    super.initState();
    word = widget.wordsStatus[widget.wordIndex].word;      
    _initializeComponents();
  }

  // REFACTOR: New method to encapsulate initialization logic
  void _initializeComponents() {
    _initializeTts();
    _initializeTabController();
    _checkIfBpmf();
    getWord();
    checkWordExistence();
  }

  // REFACTOR: New method for TTS initialization
  void _initializeTts() {
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);
    ftts.setCompletionHandler(_onTtsComplete);
  }

  // REFACTOR: New method for TabController initialization
  void _initializeTabController() {
    _tabController = TabController(length: 4, vsync: this);
  }

  // REFACTOR: New method to check if the word is BPMF
  void _checkIfBpmf() {
    isBpmf = initials.contains(word) ||
        prenuclear.contains(word) ||
        finals.contains(word);
  }

  // REFACTOR: New method for TTS completion handler
  void _onTtsComplete() {
    debugPrint("Speech has completed");
    if (!context.mounted) return;

    if (nextStepId == steps['goToListen']) {
      incrementNextStepId();
    } else if (nextStepId == steps['goToUse1']) {
      handleGoToUse();
    } else if (nextStepId == steps['goToUse2']) {
      // No action needed here, as per original code
    }
  }

  List<Widget> get useTabView {
    final screenInfo = ref.read(screenInfoProvider);
    final fontSize = screenInfo.fontSize;
    final deviceWidth = screenInfo.screenWidth;
    final availableWidth = deviceWidth - 10;

    Widget buildPage(int pageIndex) {
      bool isLastPage = pageIndex == vocabCnt - 1;
      String vocab = wordObj['vocab${pageIndex + 1}'];
      String sentence = wordObj['sentence${pageIndex + 1}'];
      String meaning = wordObj['meaning${pageIndex + 1}'];
      bool imgExist = pageIndex == 0 ? img1Exist : img2Exist;

      return TeachWordTabBarView(
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
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        LeftRightSwitch(
                          iconsColor: lightGray,
                          iconsSize: fontSize * 2.0,
                          rightBorder: pageIndex == 0 ? nextStepId == steps['goToUse2'] : false,
                          middleWidget: const TeachWordCardTitle(
                            sectionName: '用一用',
                            iconsColor: lightGray
                          ),
                          isFirst: false,
                          isLast: isLastPage,
                          onLeftClicked: wordIsLearned
                            ? () {
                                if (pageIndex == 0) {
                                  int savedNextStepId = nextStepId;
                                  int oldTabIndex = currentTabIndex.value;
                                  nextStepId = steps['goToUse1']!;
                                  currentTabIndex.value = 3;
                                  debugPrint('用一用1，上一頁，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');
                                  prevTab();
                                  return _tabController.animateTo(_tabController.index - 1);
                                } else {
                                  debugPrint('用一用2，上一頁，nextId: $nextStepId，叫 prevTab()');
                                  prevTab();
                                  ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
                                  setState(() {
                                    vocabIndex = 0;
                                    debugPrint('setState 用一用2，上一頁， vocabIndex: $vocabIndex');
                                  });
                                }
                              }
                            : null,
                          onRightClicked: (nextStepId == steps['goToUse${pageIndex + 2}'] || wordIsLearned) && !isLastPage
                            ? () async {
                                if (nextStepId == steps['goToUse${pageIndex + 2}']) {
                                  await ftts.speak("${wordObj['vocab${pageIndex + 2}']}。${wordObj['sentence${pageIndex + 2}']}");
                                  debugPrint('用一用${pageIndex + 1}，下一頁 vocab${pageIndex + 2}: ${wordObj['vocab${pageIndex + 2}']}, ${wordObj['sentence${pageIndex + 2}']}');
                                  setState(() {
                                    debugPrint('setState 用一用${pageIndex + 1}，下一頁， newStatus.learned: true');
                                  });                                    
                                }
                                setState(() {
                                  vocabIndex = pageIndex + 1;
                                  debugPrint('setState 用一用${pageIndex + 1}，下一頁， vocabIndex: $vocabIndex');
                                });
                              }
                            : null,
                        ),
                        isBpmf
                          ? BopomofoVocabContent(
                              word: word,
                              vocab: vocab,
                              sentence: sentence,
                            )
                          : WordVocabContent(
                              vocab: vocab,
                              meaning: meaning,
                              sentence: "$sentence\n",
                              vocab2: wordObj['vocab${(pageIndex + 1) % vocabCnt + 1}'],
                            ),
                        SizedBox(height: fontSize * 0.2),
                        SizedBox(
                          height: fontSize * 3.0,
                          child: (imgExist && !isBpmf)
                            ? Image(
                                height: fontSize * 3.0,
                                image: AssetImage('lib/assets/img/vocabulary/$vocab.webp'),
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
                "${pageIndex + 1} / $vocabCnt",
                style: TextStyle(
                  fontSize: fontSize * 0.75,
                  fontWeight: FontWeight.normal,
                  color: backgroundColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Return all pages
    return List.generate(vocabCnt, (index) => buildPage(index));
  }

  @override
  void dispose() {
    _tabController.dispose();
    ftts.stop();
    player.dispose();    
    super.dispose();
  }

  void nextTab() async {
    if (kDebugMode) {
      final stackTrace = StackTrace.current.toString().split('\n');
      final relevantStackTrace = '\n${stackTrace[0]}\n${stackTrace[1]}';
      debugPrint('nextTab invoked for $word, at nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}, stack: $relevantStackTrace');
    }

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
          debugPrint('nextTab $word, 字已學，要從"寫一寫"中的任一步驟，跳到"用一用"，savedId: $savedNextStepId，nextId: $nextStepId');
        } else { // 0, 8, 9
          debugPrint('nextTab $word,字已學，savedId: $savedNextStepId，nextId: $nextStepId');
        }
      } else { // 字未學，一步一步來  
        debugPrint('nextTab $word,字未學，savedId: $savedNextStepId，nextId: $nextStepId');
      }
    } else { // no SVG
      if (nextStepId > steps['goToListen']! && nextStepId < steps['goToUse1']!) {
        debugPrint('nextTab $word,no SVG1. 從 "聽一聽"到"寫一寫". Show error message.');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showNoSvgDialog('','抱歉，「$word」還沒有筆順。請繼續。謝謝！');
        });
        return; // Exit early to avoid updating `nextStepId`
      }
    }
    nextStepId = min(steps['goToUse2']!, nextStepId);
    debugPrint('nextTab $word,svgFileExist $svgFileExist, savedId: $savedNextStepId, nextId: $nextStepId');

    if (nextStepId == steps['goToListen']) {
      // 0      
      incrementNextStepId();
    } else if (nextStepId == steps['goToWrite'] || nextStepId == (steps['goToWrite']! + 1)) { // 1 & 2 sjf 9/8/24
      // 1、2
      incrementNextStepId();
      await _speakWord();
    } else if (nextStepId == steps['goToUse1'] || nextStepId == steps['goToUse2']) {
      await handleGoToUse();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('', '「$word」程序問題。請截圖回報。謝謝！');
      });
    }

    debugPrint('nextTab completed, nextStepId: $nextStepId, currentTabIndex: ${currentTabIndex.value}');
  }

  // REFACTOR: New method for speaking the word
  Future<void> _speakWord() async {
    if (isBpmf) {
      await player.play(AssetSource('bopomo/$word.mp3'));
    } else {
      await ftts.speak(word);
    }
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
          nextStepId = steps['goToListen']!;
          debugPrint('prevTab 字已學，要從"寫一寫"中的任一步驟，退回到"聽一聽" nextId: $nextStepId');
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
      // Check if we're at 'goToUse2', step back to 'goToUse1'
      if (nextStepId == steps['goToUse2']) {
        nextStepId -= 1;
        debugPrint('prevTab no svg0. 從 "用一用2"退回到"用一用1". nextId = $nextStepId.');
        return;
      }

      // Check if we're at 'goToUse1', step back to 'goToWrite' and show error dialog
      if (nextStepId == steps['goToUse1']) {
        debugPrint('prevTab no svg1. 從 "用一用1"退回到"寫一寫". Show error message.');
        
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await showNoSvgDialog(
            '', 
            '抱歉，「$word」還沒有筆順。請繼續。謝謝！'
          );
        });
        
        nextStepId = steps['practiceWithoutBorder1']!;
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
          nextStepId = steps['goToUse2']!;
          debugPrint('setState handleGoToUse: newStatus.learned = true');
        });
        break;

      case 2:
        switch (nextStepId) {
          case int stepId when stepId == steps['goToUse1']:
            debugPrint('handleGoToUse vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, sentence1: ${wordObj['sentence1']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
            await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
            setState(() {
              nextStepId += 1;
              debugPrint('setState handleGoToUse: nextStepId: $nextStepId');
            });
            break;

          case int stepId when stepId == steps['goToUse2']:
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

  Future myLoadAsset(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  void getWord() {
    // getWord() is called in initState(), NO setState() is called
    int tempIndex = widget.wordIndex;
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
      // Process vocab1 and vocab2
      if (wordObj['vocab1'] != "") {
        vocabCnt += 1;
      }
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

  // late List<Widget> useTabView;

  Future<void> _updateWordStatus(WordStatus newStatus, {required bool learned}) async {
    debugPrint('_updateWordStatus. mounted: ${context.mounted}, learned: $learned, nextStepId: $nextStepId');
    if (!context.mounted) return;

    try {
      newStatus.learned = learned;
      
      ref.read(learnedWordCountProvider.notifier).state += learned ? 1 : 0;
      
      await WordStatusProvider.updateWordStatus(status: newStatus);
      
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
    
  void checkWordExistence() {
    if (!wordExist) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('','「$word」不在SQL。請截圖回報。謝謝！');
      });
    } else {
      readJsonAndProcess(); // setState() is called here
    }
  }

  Future<void> readJsonAndProcess() async {
    // setState() is called in this function
    try {
      final result = await readJson();
      debugPrint('readJsonAndProcess: $word ${svgFileExist ? "有筆順" : "沒有筆順"}');
      if (result.isNotEmpty) {
        setState(() {
          _strokeOrderAnimationController = StrokeOrderAnimationController(
              result, this,
              onQuizCompleteCallback: handleQuizCompletion);
          if (svgFileExist) {
            debugPrint('setState readJsonAndProcess: $word 筆順檔下載成功');
          } else {
            debugPrint('setState readJsonAndProcess: 用"寫"替代，筆順��下載成功');
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog('','「$word」的筆順檔無法下載。請截圖回報。謝謝！');
          debugPrint('readJsonAndProcess error: $word 的筆順檔無法下載, svgFileExist: $svgFileExist');
          _firstNullStroke = true;
          _showErrorDialog = false;
        });        
        setState(() {
          _strokeOrderAnimationController = null;
          debugPrint('setState readJsonAndProcess error: $word 的筆順檔無法下載, svgFileExist: $svgFileExist');
        });
      }
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog('','「$word」筆順檔問題，請截圖回報。svgFileExist: $svgFileExist。謝謝！');
        _firstNullStroke = true;
        _showErrorDialog = false;
      });
      setState(() {
        _strokeOrderAnimationController = null;
        debugPrint('setState readJsonAndProcess error: $word 筆順檔問題, svgFileExist: $svgFileExist');
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

    // String word = widget.wordsStatus[widget.wordIndex].word;
    String tempWord = word;

    // If the word is in the noSvgList, set svgFileExist to false and use '學' as a fallback
    if (noSvgList.contains(word)) {
      tempWord = '學';
      svgFileExist = false;
    } else {
      svgFileExist = true;
    }

    debugPrint('readJson() word: $tempWord, svgFileExist: $svgFileExist');

    // Proceed with loading the SVG file. If svgFileExist is false, 
    // load “學” so that 看一看、聽一聽、用一用 still work.  
    try {
      final String response = await rootBundle.loadString('lib/assets/svg/$tempWord.json');
      return response.replaceAll("\"", "'");
    } catch (e) {
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
          _updateWordStatus(widget.wordsStatus[widget.wordIndex], learned: true);
          debugPrint('setState handleQuizCompletion 要進入用一用1, practiceTimeLeft: $practiceTimeLeft, nextId: $nextStepId, learned: true');
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
                nextStepId = steps['goToUse1']!; // Force to goToUse1
                debugPrint('寫一寫，下一頁，savedId: $savedNextStepId,  nextId: $nextStepId，呼叫 handleGoToUse()');                   
                handleGoToUse();
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
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    double availableWidth = deviceWidth - 10;
    double availableHeight = deviceHeight - 10;
    double nonConsumedHeight = deviceHeight * 0.15;

    word = widget.wordsStatus[widget.wordIndex].word;
    int unitId = widget.unitId;
    String unitTitle = widget.unitTitle;

    if (_strokeOrderAnimationController == null) {
      return _buildErrorWidget(word);
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: _buildAppBar(deviceWidth, fontSize, unitId, unitTitle),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            _buildLookTab(deviceWidth, fontSize, word),
            _buildListenTab(deviceHeight, deviceWidth, fontSize, word),
            _buildWriteTab(availableWidth, availableHeight, nonConsumedHeight, fontSize, word),
            _buildUseTab(availableWidth, fontSize),
          ],
        ),
        bottomNavigationBar: _buildBottomAppBar(deviceWidth, fontSize, unitId, unitTitle),
      ),
    );
  }

  PreferredSize _buildAppBar(double deviceWidth, double fontSize, int unitId, String unitTitle) {
    return PreferredSize(
      preferredSize: Size(deviceWidth, kToolbarHeight * 2),
      child: Center(
        child: SizedBox(
          width: deviceWidth,
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBarTop(fontSize, unitId, unitTitle),
                _buildTabBar(fontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTop(double fontSize, int unitId, String unitTitle) {
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: beige, size: fontSize * 1.5),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: _buildUnitTitle(fontSize, unitId, unitTitle),
          ),
          IconButton(
            onPressed: () => navigateWithProvider(context, '/mainPage', ref),
            icon: Icon(Icons.home_filled, color: beige, size: fontSize * 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTitle(double fontSize, int unitId, String unitTitle) {
    return (unitId == -1)
        ? Text(unitTitle, 
            style: TextStyle(fontSize: fontSize * 1.2),
            textAlign: TextAlign.center)
        : Text("${unitId.toString().padLeft(2, '0')} | $unitTitle",
            style: TextStyle(fontSize: fontSize * 1.2),
            textAlign: TextAlign.center);
  }

  Widget _buildTabBar(double fontSize) {
    return SizedBox(
      height: kToolbarHeight,
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
        labelColor: darkBrown,
        dividerColor: mediumGray,
        unselectedLabelColor: mediumGray,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
          color: mediumGray,
        ),
      ),
    );
  }

  Widget _buildLookTab(double deviceWidth, double fontSize, String word) {
    return TeachWordTabBarView(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: deviceWidth * 0.90,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildLookLeftRightSwitch(fontSize),
                      SizedBox(height: fontSize * 0.3),
                      _buildLookImage(fontSize, word),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookLeftRightSwitch(double fontSize) {
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: max(fontSize * 2.0, 48.0),
      rightBorder: true,
      middleWidget: const TeachWordCardTitle(
        sectionName: '看一看',
        iconsColor: lightGray,
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
    );
  }

  Widget _buildLookImage(double fontSize, String word) {
    return Flexible(
      fit: FlexFit.loose,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: const BoxDecoration(
                  color: darkBrown,
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
    );
  }

  Widget _buildListenTab(double deviceHeight, double deviceWidth, double fontSize, String word) {
    return TeachWordTabBarView(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: deviceHeight * 0.9,
                maxWidth: deviceWidth * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildListenLeftRightSwitch(fontSize),
                  SizedBox(height: fontSize * 0.3),
                  _buildListenWord(deviceHeight, deviceWidth, fontSize, word),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListenLeftRightSwitch(double fontSize) {
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: max(fontSize * 2.0, 48.0),
      rightBorder: nextStepId == steps['goToWrite'],
      middleWidget: const TeachWordCardTitle(
        sectionName: '聽一聽',
        iconsColor: lightGray,
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
    );
  }

  Widget _buildListenWord(double deviceHeight, double deviceWidth, double fontSize, String word) {
    return SizedBox(
      height: (deviceHeight * 0.4),
      width: deviceWidth * 1.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return Container(
              decoration: const BoxDecoration(
                color: darkBrown,
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
    );
  }

  Widget _buildWriteTab(double availableWidth, double availableHeight, double nonConsumedHeight, double fontSize, String word) {
    return TeachWordTabBarView(
      content: ChangeNotifierProvider<StrokeOrderAnimationController>.value(
        value: _strokeOrderAnimationController!,
        child: Consumer<StrokeOrderAnimationController>(
          builder: (context, controller, child) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(                        
                  maxWidth: availableWidth * 0.90,
                  maxHeight: availableHeight - nonConsumedHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildWriteLeftRightSwitch(fontSize, word),
                    SizedBox(height: fontSize * 0.2),
                    Flexible(
                      child: _buildWriteAnimator(availableWidth, availableHeight, nonConsumedHeight, fontSize, controller),
                    ),                    
                    _buildWriteIconGrid(fontSize, controller),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWriteLeftRightSwitch(double fontSize, String word) {
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: max(fontSize * 2.0, 48.0),
      rightBorder: nextStepId == steps['goToUse1'],
      middleWidget: const TeachWordCardTitle(
        sectionName: '寫一寫',
        iconsColor: lightGray,
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

              debugPrint('寫一寫，上一頁2，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');
              
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
    );
  }

  Widget _buildWriteAnimator(double availableWidth, double availableHeight, double nonConsumedHeight, double fontSize, StrokeOrderAnimationController controller) {
    return SizedBox(                            
      width: availableWidth,
      height: (availableHeight - nonConsumedHeight) * 0.5,
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
                : const BoxDecoration(color: darkBrown),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 10,
                  top: 5,
                  child: Column(children: [
                    _buildPracticeTimeIcon(practiceTimeLeft >= 4 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 3 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 2 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    SizedBox(height: fontSize * 0.9),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 1 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                  ]),
                ),
                FittedBox(
                  child: StrokeOrderAnimator(
                    _strokeOrderAnimationController!,
                    key: UniqueKey(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWriteIconGrid(double fontSize, StrokeOrderAnimationController controller) {
    return Flexible(
      fit: FlexFit.loose,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2,
        crossAxisSpacing: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _buildIconButtonWithLabel(
            context: context,
            border: (nextStepId == steps['seeAnimation'] && !wordIsLearned),
            iconData: [Icons.pause, Icons.play_arrow],
            label: '筆順',
            isSelected: controller.isAnimating,
            onPressed: _buildStrokeOrderButtonOnPressed(controller),
            fontSize: fontSize,
          ),
          _buildIconButtonWithLabel(
            context: context,
            border: ((nextStepId > steps['seeAnimation']! && nextStepId < steps['turnBorderOff']!) && 
                    !wordIsLearned && !controller.isQuizzing) || (nextStepId == steps['practiceWithoutBorder1']!),
            iconData: [Icons.edit_off, Icons.edit],
            label: '寫字',
            isSelected: controller.isQuizzing,
            onPressed: _buildWriteButtonOnPressed(controller),
            fontSize: fontSize,
          ),
          _buildIconButtonWithLabel(
            context: context,
            border: (nextStepId == steps['turnBorderOff'] && !wordIsLearned),
            iconData: [Icons.remove_red_eye, Icons.remove_red_eye_outlined],
            label: '邊框',
            isSelected: controller.showOutline,
            onPressed: _buildOutlineButtonOnPressed(controller),
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }

  Function()? _buildStrokeOrderButtonOnPressed(StrokeOrderAnimationController controller) {
    return ((!controller.isQuizzing && (nextStepId == steps['seeAnimation'])) || wordIsLearned)
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
        : null;
  }

  Function()? _buildWriteButtonOnPressed(StrokeOrderAnimationController controller) {
    return ((nextStepId > steps['seeAnimation']! && nextStepId < steps['turnBorderOff']!) || wordIsLearned || (nextStepId == steps['practiceWithoutBorder1']!))
        ? () async {
            controller.startQuiz();
            if (isBpmf) {
              await player.play(AssetSource('bopomo/$word.mp3'));
            } else {
              await ftts.speak(word);
            }
            debugPrint('寫字 $word');
          }
        : null;
  }

  Function()? _buildOutlineButtonOnPressed(StrokeOrderAnimationController controller) {
    return (nextStepId == steps['turnBorderOff'] || wordIsLearned)
        ? () {
            if (nextStepId == steps['turnBorderOff']) {
              setState(() {
                nextStepId += 1;
                debugPrint('setState 邊框 $word, nextStepId: $nextStepId');
              });
            }
            controller.setShowOutline(!controller.showOutline);
          }
        : null;
  }

  Widget _buildUseTab(double availableWidth, double fontSize) {
    return useTabView[vocabIndex];
  }

  Widget _buildBottomAppBar(double deviceWidth, double fontSize, int unitId, String unitTitle) {
    return BottomAppBar(
      height: 4.0 * fontSize,
      elevation: 0,
      color: darkBrown,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: deviceWidth,
        ),
        child: LeftRightSwitch(
          iconsColor: beige,
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
    );
  }

  Widget _buildErrorWidget(String word) {
    if (_firstNullStroke) {
      _firstNullStroke = false;
      return Container();
    } else {
      _showErrorDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_showErrorDialog) {
          showErrorDialog('','「$word」沒有筆順2。請截圖回報。謝謝！');
          _firstNullStroke = true;
          _showErrorDialog = false;
        }
      });
      return Container();
    }
  }

  Widget _buildIconButtonWithLabel({
    required BuildContext context,
    required bool border,
    required List<IconData> iconData,
    required String label,
    required bool isSelected,
    required Function()? onPressed,
    required double fontSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              border: border
                  ? Border.all(color: lightYellow, width: 1.5)
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
                  : null,
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
  
  Widget _buildPracticeTimeIcon(bool condition, double fontSize, Color defaultColor, Color activeColor) {
    return Icon(
      condition ? Icons.check_circle_outline_outlined : Icons.check_circle,
      color: condition ? defaultColor : activeColor,
      size: fontSize * 1.5,
    );
  }

}


