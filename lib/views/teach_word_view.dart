// ignore_for_file: unused_local_variable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  // bool _isControllerInitialized = false;
  late TabController _tabController;
  FlutterTts ftts = FlutterTts();
  late Map wordsPhrase;
  late Map wordObj;
  int vocabCnt = 0;
  bool img1Exist = false;
  bool img2Exist = false;
  int practiceTimeLeft = 4;
  int nextStepId = 0;
  bool isBpmf = false;
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);
  // Define the color used for the background
  static const Color backgroundColor = Color.fromRGBO(245, 245, 220, 100);
  bool get wordIsLearned =>
      widget.wordsStatus[widget.wordIndex].learned; // 這才是正確的方法

  void nextTab() async {
    currentTabIndex.value++;
    // bool wordIsLearned = widget.wordsStatus[widget.wordIndex].learned;
    if (!wordIsLearned) {
      // debugPrint('nextTab nextStepId: $nextStepId');
      if (nextStepId == steps['goToSection2']) {
        setState(() {
          nextStepId += 1;
        });
        // todo
      } else if (nextStepId == steps['goToSection3']) {
        setState(() {
          nextStepId += 1;
        });
        // todo
      } else if (nextStepId == steps['goToSection4']) {
        // todo
        var result =
            await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        if (vocabCnt == 1) {
          WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
          setState(() {
            newStatus.learned = true; // I never saw this flag set. Why?
            // debugPrint('initState learned: $newStatus');
          });
          setState(() {
            nextStepId = 100;
          });
          ref.read(learnedWordCountProvider.notifier).state += 1;
          await WordStatusProvider.updateWordStatus(status: newStatus);
        } else {
          setState(() {
            nextStepId += 1;
          });
        }
      }
    }
  }

  Future<String> readJson() async {
    final String response = await rootBundle.loadString(
        'lib/assets/svg/${widget.wordsStatus[widget.wordIndex].word}.json');

    return response.replaceAll("\"", "'");
  }

  Future myLoadAsset(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  void getWord() async {
    setState(() {
      wordObj = widget.wordsPhrase[widget.wordIndex];
    });
    // debugPrint('getWord wordObj: $wordObj'); // this code was not executed. Why?
    if (wordObj['vocab1'] != "") {
      vocabCnt += 1;
      var imgAsset = await myLoadAsset(
          'lib/assets/img/vocabulary/${wordObj['vocab1']}.png');
      if (imgAsset == null) {
        img1Exist = false;
      } else {
        img1Exist = true;
      }
    }
    if (wordObj['vocab2'] != "") {
      vocabCnt += 1;
      var imgAsset = await myLoadAsset(
          'lib/assets/img/vocabulary/${wordObj['vocab2']}.png');
      if (imgAsset == null) {
        img2Exist = false;
      } else {
        img2Exist = true;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);
    ftts.setCompletionHandler(() async {
      // 不知道為甚麼line 84 `await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");` 完進不來（沒有換tab的話會進來）
      // debugPrint('initState nextStepId: $nextStepId');
      if (!wordIsLearned) {
        if (nextStepId == steps['goToSection2']) {
          setState(() {
            nextStepId += 1;
          });
        } else if (nextStepId == steps['goToSection4']) {
          // debugPrint('initState vocabCnt: $vocabCnt');
          if (vocabCnt == 1) {
            WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
            setState(() {
              newStatus.learned = true; // I never saw this flag set. Why?
              // debugPrint('initState learned: $newStatus');
            });
            setState(() {
              nextStepId = 100;
            });
            ref.read(learnedWordCountProvider.notifier).state += 1;
            await WordStatusProvider.updateWordStatus(status: newStatus);
          } else {
            setState(() {
              nextStepId += 1;
            });
          }
        } else if (nextStepId == steps['goToPhrase2']) {
          WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
          setState(() {
            newStatus.learned = true; // I never saw this flag set. Why?
            // debugPrint('initState learned: $newStatus.learned');
          });
          setState(() {
            nextStepId = 100;
          });
          ref.read(learnedWordCountProvider.notifier).state += 1;
          await WordStatusProvider.updateWordStatus(status: newStatus);
        }
      }
      // debugPrint("initState: Speech has completed");
    });
    if (wordIsLearned) {
      nextStepId = 100; // replaced widget.wordsStatus[widget.wordIndex].learned
    }
    isBpmf = (initials.contains(widget.wordsStatus[widget.wordIndex].word) ||
        prenuclear.contains(widget.wordsStatus[widget.wordIndex].word) ||
        finals.contains(widget.wordsStatus[widget.wordIndex].word));
    getWord();
    _tabController =
        TabController(length: 4, vsync: this, animationDuration: Duration.zero);
    readJson().then((result) {
      setState(() {
        debugPrint('initState. Has a result. Set up the controller.');
        _strokeOrderAnimationControllers = StrokeOrderAnimationController(
          result,
          this,
          onQuizCompleteCallback: (summary) {
            if (nextStepId >= steps['practiceWithBorder1']! &&
                nextStepId <= steps['turnBorderOff']!) {
              setState(() {
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
                  practiceTimeLeft -= 1;
                  nextStepId += 1;
                  // widget.wordsStatus[widget.wordIndex].learned = true; // 強迫設這標籤
                  debugPrint(
                      'initState 要進入用一用，set learned flag: ${widget.wordsStatus[widget.wordIndex].learned}');
                });
              }
              Fluttertoast.showToast(
                msg: ["恭喜筆畫正確！"].join(),
                fontSize: 30,
              );
            }
          },
        );
      });
    }).catchError((error) {
      debugPrint(
          'Failed to initialize _strokeOrderAnimationControllers: $error');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  int vocabIndex = 0;

  Map<String, int> steps = {
    'goToSection2': 0, // 聽一聽
    'goToSection3': 1, // 寫一寫
    'seeAnimation': 2, // 寫一寫-筆順
    'practiceWithBorder1': 3, // 寫一寫-寫字-有邊框
    'practiceWithBorder2': 4, // 寫一寫-寫字-有邊框
    'practiceWithBorder3': 5, // 寫一寫-寫字-有邊框
    'turnBorderOff': 6, // 寫一寫-關掉邊框
    'practiceWithoutBorder1': 7, // 寫一寫-寫字-無邊框
    'goToSection4': 8, // 用一用-例句1
    'goToPhrase2': 9, // 用一用-例句2
  };

  @override
  Widget build(BuildContext context) {
    // bool wordIsLearned = widget.wordsStatus[widget.wordIndex].learned;

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    double fontSize =
        getFontSize(context, 16); // 16 is the base font size for 360dp width
    double availableWidth = deviceWidth - 20; // 10 padding on each side
    double availableHeight =
        deviceHeight - 20; // example padding top and bottom
    double nonConsumedHeight = deviceHeight * 0.15; // was 0.20;
    var gray85Color = '#D9D9D9'.toColor();

    String word = widget.wordsStatus[widget.wordIndex].word;
    int unitId = widget.unitId;
    String unitTitle = widget.unitTitle;

    // Make sure to check if _strokeOrderAnimationControllers is initialized before using it
    if (_strokeOrderAnimationControllers == null) {
      debugPrint('_strokeOrderAnimationControllers is null');
      // Handle the case where the controller is not yet initialized
      return const CircularProgressIndicator(); // Or some other placeholder
    }
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
                          // LeftRightSwitch for 用一用
                          LeftRightSwitch(
                            iconsColor: gray85Color,
                            iconsSize: fontSize * 2.0, // was 35
                            rightBorder: nextStepId == steps['goToPhrase2'],
                            middleWidget: TeachWordCardTitle(
                                sectionName: '用一用', iconsColor: gray85Color),
                            isFirst: false,
                            isLast: (vocabCnt == 1),
                            onLeftClicked: wordIsLearned
                                ? () {
                                    currentTabIndex.value--;
                                    return _tabController
                                        .animateTo(_tabController.index - 1);
                                  }
                                : null,
                            onRightClicked: (nextStepId ==
                                        steps['goToPhrase2'] ||
                                    wordIsLearned)
                                ? () async {
                                    if (nextStepId == steps['goToPhrase2']) {
                                      var result = await ftts.speak(
                                          "${wordObj['vocab2']}。${wordObj['sentence2']}");
                                      // debugPrint('用一用 vocab2: ${wordObj['vocab2']}');
                                      WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
                                      setState(() {
                                        newStatus.learned = true; // I never saw this flag set. Why?
                                        // debugPrint('initState learned: $newStatus.learned');
                                      });
                                      setState(() {
                                        nextStepId = 100;
                                      });
                                      ref.read(learnedWordCountProvider.notifier).state += 1;
                                      await WordStatusProvider.updateWordStatus(status: newStatus);
                                    }
                                    setState(() {
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
                              children: [
                                (img1Exist && !isBpmf)
                                    ? Image(
                                        height: deviceHeight * 0.15,
                                        image: AssetImage(
                                            'lib/assets/img/vocabulary/${wordObj['vocab1']}.png'),
                                      )
                                    : SizedBox(
                                        height: deviceHeight *
                                            0.08), // Use SizedBox for consistency
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
                  fontSize: fontSize * 1.0,
                  fontWeight: FontWeight.bold,
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
                                        children: [
                                          (img2Exist && !isBpmf)
                                              ? Image(
                                                  height: deviceHeight *
                                                      0.15, // was 150
                                                  image: AssetImage(
                                                      'lib/assets/img/vocabulary/${wordObj['vocab2']}.png'),
                                                )
                                              : SizedBox(
                                                  height: isBpmf
                                                      ? 0
                                                      : deviceHeight * 0.15,
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
                      fontSize: fontSize * 1.0,
                      fontWeight: FontWeight.bold,
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
            icon: Icon(Icons.chevron_left, size: fontSize),
            onPressed: () => Navigator.pop(context),
          ),
          title: (unitId == -1)
              ? Text(unitTitle, style: TextStyle(fontSize: fontSize))
              : Text(("${unitId.toString().padLeft(2, '0')} | $unitTitle"),
                  style: TextStyle(fontSize: fontSize)),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
              icon: Icon(Icons.home_filled, size: fontSize),
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
                // 看一看
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
                                rightBorder:
                                    nextStepId == steps['goToSection2'],
                                middleWidget: TeachWordCardTitle(
                                    sectionName: '看一看',
                                    iconsColor: gray85Color),
                                isFirst: true,
                                isLast: false,
                                onRightClicked:
                                    (nextStepId == steps['goToSection2']! ||
                                            wordIsLearned)
                                        ? () async {
                                            nextTab();
                                            var result = await ftts.speak(word);
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
                                                  'lib/assets/img/oldWords/$word.png'),
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
                                rightBorder:
                                    nextStepId == steps['goToSection3'],
                                middleWidget: TeachWordCardTitle(
                                    sectionName: '聽一聽',
                                    iconsColor: gray85Color),
                                isFirst: false,
                                isLast: false,
                                onLeftClicked: wordIsLearned
                                    ? () {
                                        currentTabIndex.value--;
                                        _tabController.animateTo(
                                            _tabController.index - 1);
                                      }
                                    : null,
                                onRightClicked:
                                    (nextStepId == steps['goToSection3'] ||
                                            wordIsLearned)
                                        ? () {
                                            nextTab();
                                            _tabController.animateTo(
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
                                                10.0, // Adjust font size to be reasonable
                                            color: backgroundColor,
                                            fontWeight: FontWeight.w100,
                                            fontFamily:
                                                isBpmf ? "BpmfOnly" : "Serif",
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
                                              var result =
                                                  await ftts.speak(word);
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
                              rightBorder: nextStepId == steps['goToSection4'],
                              middleWidget: TeachWordCardTitle(
                                  sectionName: '寫一寫', iconsColor: gray85Color),
                              isFirst: false,
                              isLast: false,
                              onLeftClicked: wordIsLearned
                                  ? () {
                                      currentTabIndex.value--;
                                      return _tabController
                                          .animateTo(_tabController.index - 1);
                                    }
                                  : null,
                              onRightClicked: (nextStepId ==
                                          steps['goToSection4'] ||
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
                                      border: nextStepId == steps['seeAnimation'],
                                      iconData: [Icons.pause, Icons.play_arrow],
                                      label: '筆順',
                                      isSelected: controller.isAnimating,
                                      onPressed: !controller.isQuizzing
                                          ? () {
                                              if (!controller.isAnimating) {
                                                controller.startAnimation();
                                                ftts.speak(word).then((result) {
                                                  if (nextStepId ==
                                                      steps['seeAnimation']) {
                                                    setState(() {
                                                      nextStepId += 1;
                                                    });
                                                  }
                                                });
                                              } else {
                                                controller.stopAnimation();
                                                debugPrint(
                                                    "stop animation // nextStepId update time");
                                              }
                                            }
                                          : null,
                                      fontSize: fontSize),
                                  // border
                                  // IconButton for 寫字
                                  buildIconButtonWithLabel(
                                      context: context,
                                      border: (!controller.isQuizzing && (nextStepId == steps['practiceWithBorder1'] || nextStepId == steps['practiceWithBorder2'] || nextStepId == steps['practiceWithBorder3'] || nextStepId == steps['practiceWithoutBorder1'])),
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
                                              var result =
                                                  await ftts.speak(word);
                                            }
                                          : null,
                                      fontSize: fontSize),

                                  // IconButton for 邊框
                                  buildIconButtonWithLabel(
                                      context: context,
                                      border: (nextStepId == steps['turnBorderOff']),
                                      iconData: [Icons.remove_red_eye, Icons.remove_red_eye_outlined],
                                      label: '邊框',
                                      isSelected: controller.showOutline,
                                      onPressed: (nextStepId ==
                                                  steps['turnBorderOff'] ||
                                              wordIsLearned)
                                          ? () {
                                              if (nextStepId ==
                                                  steps['turnBorderOff']) {
                                                setState(() {
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
                  } // builder
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
                    sizedBoxWidth: 7.5 * fontSize, // was 125, 5.5
                    sizedBoxHeight: 4.0 * fontSize, // was 88
                    fontSize: fontSize * 2.0,
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
            border: border ? Border.all(color: '#FFFF93'.toColor(), width: 1.5) : null,
          ),
          child: IconButton(
            icon: Icon(
              isSelected ? iconData[0] : iconData[1],
              size: fontSize,
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
