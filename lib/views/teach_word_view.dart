// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';
import 'package:ltrc/widgets/word_card.dart';
import 'package:provider/provider.dart';

class TeachWordView extends StatefulWidget {
  final int unitId;
  final String unitTitle;
  final bool isBpmf;
  final List<WordStatus> wordStatus;
  final int wordIndex;

  const TeachWordView({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.isBpmf,
    required this.wordStatus,
    required this.wordIndex,
  });

  @override
  State<TeachWordView> createState() => _TeachWordViewState();
}

class _TeachWordViewState extends State<TeachWordView>
    with TickerProviderStateMixin {
  late StrokeOrderAnimationController _strokeOrderAnimationControllers;
  late TabController _tabController;
  FlutterTts ftts = FlutterTts();
  late Map wordObj;
  int vocabCnt = 0;
  bool img1Exist = false;
  bool img2Exist = false;

  Future<String> readJson() async {
    final String response =
        await rootBundle.loadString('lib/assets/svg/${widget.wordStatus[widget.wordIndex].word}.json');

    return response.replaceAll("\"", "\'");
  }

  // void getWord() async {
  //   Word word_ = await WordProvider.getWord(inputWord: "山");
  //   // await WordProvider.getWord(inputWord: widget.char);
  //   setState(() {
  //     wordd = word_;
  //   });
  // }

  Future myLoadAsset(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (_) {
      return null;
    }
  }

  void getWord() async {
    setState(() {
      wordObj = {
        "word": "日",
        "vocab1": "日記",
        "meaning1": "就是每天把自己做過的事情、心情寫下來的記錄。",
        "sentence1": "今天我開始養成寫日記的好習慣，把每天的所見所聞都記錄下來。",
        "vocab2": "日出",
        "meaning2": "描述凌晨太陽昇起。",
        "sentence2": "日出的时候，海上的景色特别美麗。",
      };
      // wordObj = {
      //   "word": "我",
      //   "vocab1": "我們",
      //   "meaning1": "包括自己在內的一組人。",
      //   "sentence1": "悲傷的電影，常常讓我們淚流滿面。",
      //   "vocab2": "",
      //   "meaning2": "",
      //   "sentence2": "",
      // };
    });
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
    getWord();
    _tabController = TabController(length: 4, vsync: this);
    readJson().then((result) {
      setState(() {
        _strokeOrderAnimationControllers = StrokeOrderAnimationController(
          result,
          this,
          onQuizCompleteCallback: (summary) {
            Fluttertoast.showToast(
              msg: [
                "Quiz finished. ",
                summary.nTotalMistakes.toString(),
                " mistakes"
              ].join()
            );
          },
        );
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  static const List<Tab> teachWordTabs = [
    Tab(icon: Icon(Icons.image)),
    Tab(icon: Icon(Icons.hearing)),
    Tab(icon: Icon(Icons.create)),
    Tab(icon: Icon(Icons.school)),
  ];

  @override
  Widget build(BuildContext context) {
    // double deviceHeight = MediaQuery.of(context).size.height;

    String word = widget.wordStatus[widget.wordIndex].word;
    int unitId = widget.unitId;
    String unitTitle = widget.unitTitle;
    bool isBpmf = widget.isBpmf;
    int vocabIndex = 0;
    List<Widget> useTabView = [
      TeachWordTabBarView(
        content: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            LeftRightSwitch(
              iconsColor: '#D9D9D9'.toColor(),
              iconsSize: 35,
              middleWidget: TeachWordCardTitle(
                sectionName: '用一用', iconsColor: '#D9D9D9'.toColor()),
              isFirst: false,
              isLast: (vocabCnt == 1),
              onLeftClicked: () => _tabController.animateTo(_tabController.index - 1),
              onRightClicked: () {
                setState(() {
                  vocabIndex = 1;
                });
              },
            ),
            isBpmf ? 
              BopomofoVocabContent(
                word: word,
                vocab: wordObj['vocab1'],
                sentence: "${wordObj['sentence1']}",
              )
              :
              WordVocabContent(
                vocab: wordObj['vocab1'],
                meaning: wordObj['meaning1'],
                sentence: "${wordObj['sentence1']}\n",
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Wrap(
                  direction: Axis.vertical, 
                  spacing: 0,
                  children: <Widget>[
                    IconButton(
                      iconSize: 30,
                      color: Color.fromRGBO(245, 245, 220, 100),
                      onPressed: () async {
                        var result = await ftts.speak(
                          "${wordObj['vocab1']}。${wordObj['sentence1']}");
                      },
                      icon: const Icon(Icons.volume_up)),
                    const Text('讀音',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.5,
                        color: Color.fromRGBO(245, 245, 220, 100),
                      )),
                  ],
                ),
                (img1Exist && !isBpmf)
                  ? Image(
                    height: 150,
                    image: AssetImage(
                      'lib/assets/img/vocabulary/${wordObj['vocab1']}.png'),
                  )
                  : Container(
                    height: isBpmf ? 80 : 150,
                  ),
                Text("1 / $vocabCnt",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(245, 245, 220, 100),
                )),
              ],
            ),
          ],
      )),
      (vocabCnt == 2)
        ? TeachWordTabBarView(
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              LeftRightSwitch(
                iconsColor: '#D9D9D9'.toColor(),
                iconsSize: 35,
                middleWidget: TeachWordCardTitle(
                  sectionName: '用一用', iconsColor: '#D9D9D9'.toColor()),
                isFirst: false,
                isLast: true,
                onLeftClicked: () {
                  setState(() {
                    vocabIndex = 0;
                  });
                },
              ),
              isBpmf ? 
                BopomofoVocabContent(
                  word: word,
                  vocab: wordObj['vocab2'],
                  sentence: "${wordObj['sentence2']}",
                )
                :
                WordVocabContent(
                  vocab: wordObj['vocab2'],
                  meaning: wordObj['meaning2'],
                  sentence: "${wordObj['sentence2']}\n",
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Wrap(
                  direction: Axis.vertical, 
                  spacing: 0,
                  children: <Widget>[
                    IconButton(
                      iconSize: 30,
                      color: Color.fromRGBO(245, 245, 220, 100),
                      onPressed: () async {
                        var result = await ftts.speak(
                          "${wordObj['vocab2']}。${wordObj['sentence2']}");
                      },
                      icon: const Icon(Icons.volume_up)),
                    const Text('讀音',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17.5,
                        color: Color.fromRGBO(245, 245, 220, 100),
                      )),
                  ],
                ),
                  (img2Exist && !isBpmf)
                    ? Image(
                        height: 150,
                        image: AssetImage(
                        'lib/assets/img/vocabulary/${wordObj['vocab2']}.png'),
                      )
                    : Container(
                        height: isBpmf ? 0 : 150,
                      ),
                  Text("2 / $vocabCnt",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(245, 245, 220, 100),
                  )),
                ],
              ),
            ],
          ))
        : Container()];

    return DefaultTabController(
      length: teachWordTabs.length,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text("${unitId.toString().padLeft(2, '0')} | $unitTitle"),
          titleTextStyle: TextStyle(
            color: "#F5F5DC".toColor(),
            fontSize: 30,
            fontWeight: FontWeight.w900,
            fontFamily: "Serif",
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
              icon: const Icon(Icons.home_filled)),
          ],
          bottom: TabBar(
            tabs: teachWordTabs,
            controller: _tabController,
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
              content: Column(
                children: [
                  LeftRightSwitch(
                    iconsColor: '#D9D9D9'.toColor(),
                    iconsSize: 35,
                    middleWidget: TeachWordCardTitle(
                      sectionName: '看一看', iconsColor: '#D9D9D9'.toColor()),
                    isFirst: true,
                    isLast: false,
                    onRightClicked: () => _tabController.animateTo(_tabController.index + 1),
                  ),
                  const SizedBox(height: 60,),
                  Image(
                    width: 300,
                    image: isBpmf ? 
                      AssetImage('lib/assets/img/bopomo/$word.png') : AssetImage('lib/assets/img/oldWords/$word.png'),
                  ),
                ],
              )),
            TeachWordTabBarView(
              content: Column(
                children: [
                  LeftRightSwitch(
                    iconsColor: '#D9D9D9'.toColor(),
                    iconsSize: 35,
                    middleWidget: TeachWordCardTitle(
                      sectionName: '聽一聽', iconsColor: '#D9D9D9'.toColor()),
                    isFirst: false,
                    isLast: false,
                    onLeftClicked: () => _tabController.animateTo(_tabController.index - 1),
                    onRightClicked: () => _tabController.animateTo(_tabController.index + 1),
                  ),
                  const SizedBox(height: 20,),
                  Padding(
                    padding: isBpmf ? const EdgeInsets.fromLTRB(0, 0, 0, 0) : const EdgeInsets.fromLTRB(50, 0, 0, 0),
                    child: Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: Text(word,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 150,
                          color: const Color.fromRGBO(245, 245, 220, 100),
                          fontWeight: FontWeight.w100,
                          fontFamily: isBpmf ? "BpmfOnly" : "Serif",
                        )),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 1),
                      child: Column(
                        children: [
                          IconButton(
                            iconSize: 35,
                            color: const Color.fromRGBO(245, 245, 220, 100),
                            onPressed: () async {
                              var result = await ftts.speak(word);
                            },
                            icon: const Icon(Icons.volume_up)),
                          const Text('讀音',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 17.5,
                              color: Color.fromRGBO(245, 245, 220, 100),
                            )),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
            TeachWordTabBarView(
              content: ChangeNotifierProvider<
                StrokeOrderAnimationController>.value(
                value: _strokeOrderAnimationControllers,
                child: Consumer<StrokeOrderAnimationController>(
                  builder: (context, controller, child) {
                    return Center(
                      child: SizedBox(
                        width: 300,
                        child: Column(
                          children: <Widget>[
                            LeftRightSwitch(
                              iconsColor: '#D9D9D9'.toColor(),
                              iconsSize: 35,
                              middleWidget: TeachWordCardTitle(
                                sectionName: '聽一聽', iconsColor: '#D9D9D9'.toColor()),
                              isFirst: false,
                              isLast: false,
                    onLeftClicked: () => _tabController.animateTo(_tabController.index - 1),
                    onRightClicked: () => _tabController.animateTo(_tabController.index + 1),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage("lib/assets/img/box.png"),
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              child: FittedBox(
                                child: StrokeOrderAnimator(
                                  _strokeOrderAnimationControllers,
                                  key: UniqueKey(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7.5,),
                            Flexible(
                              child: GridView(
                                gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 2,
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 6,
                                  ),
                                primary: false,
                                children: <Widget>[
                                  IconButton(
                                    iconSize: 35,
                                    color: const Color.fromRGBO(245, 245, 220, 100),
                                    isSelected: controller.isAnimating,
                                    icon: const Icon(Icons.play_arrow),
                                    selectedIcon: const Icon(Icons.pause),
                                    onPressed: !controller.isQuizzing
                                      ? () async {
                                        if (!controller.isAnimating) {
                                          controller.startAnimation();
                                          var result = await ftts.speak(word);
                                        } else {
                                          controller.stopAnimation();
                                        }
                                      }
                                    : null,
                                  ),
                                  IconButton(
                                    iconSize: 35,
                                    color: const Color.fromRGBO(245, 245, 220, 100),
                                    isSelected: controller.isQuizzing,
                                    icon: const Icon(Icons.edit),
                                    selectedIcon: const Icon(Icons.edit_off),
                                    onPressed: () async {
                                      if (!controller.isQuizzing) {
                                        controller.startQuiz();
                                        var result = await ftts.speak(word);
                                      } else {
                                        controller.stopQuiz();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    iconSize: 35,
                                    color: const Color.fromRGBO(245, 245, 220, 100),
                                    isSelected: controller.showOutline,
                                    icon: const Icon(
                                      Icons.remove_red_eye_outlined),
                                    selectedIcon:
                                      const Icon(Icons.remove_red_eye),
                                    onPressed: () {
                                      controller.setShowOutline(!controller.showOutline);
                                    },
                                  ),
                                IconButton(
                                  iconSize: 35,
                                  color: const Color.fromRGBO(245, 245, 220, 100),
                                  icon: const Icon(Icons.restart_alt),
                                  onPressed: () {
                                    controller.reset();
                                  },
                                ),
                                const Text('筆順',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Color.fromRGBO(
                                        245, 245, 220, 100),
                                )),
                                const Text('寫字',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Color.fromRGBO(245, 245, 220, 100),
                                )),
                                const Text('邊框',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Color.fromRGBO(245, 245, 220, 100),
                                )),
                                const Text('重新',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Color.fromRGBO(245, 245, 220, 100),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            useTabView[1],
          ]),
        bottomNavigationBar: BottomAppBar(
          height: 100,
          elevation: 0,
          color: '#28231D'.toColor(),
          child: LeftRightSwitch(
            iconsColor: '#F5F5DC'.toColor(),
            iconsSize: 48,
            middleWidget: WordCard(
              unitId: unitId,
              unitTitle: unitTitle,
              wordStatus: widget.wordStatus,
              wordIndex: widget.wordIndex,
              sizedBoxWidth: 125,
              sizedBoxHeight: 88,
              fontSize: 30,
              isBpmf: isBpmf,
              isVertical: false,
            ),
            isFirst: (widget.wordIndex == 0),
            isLast: (widget.wordIndex == widget.wordStatus.length - 1),
            onLeftClicked: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TeachWordView(
                  isBpmf: widget.isBpmf,
                  unitId: widget.unitId,
                  unitTitle: widget.unitTitle,
                  wordStatus: widget.wordStatus,
                  wordIndex: widget.wordIndex - 1,
              )));
            },
            onRightClicked: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TeachWordView(
                  isBpmf: widget.isBpmf,
                  unitId: widget.unitId,
                  unitTitle: widget.unitTitle,
                  wordStatus: widget.wordStatus,
                  wordIndex: widget.wordIndex + 1,
              )));
            }
          )
        ),
      ),
    );
  }
}
