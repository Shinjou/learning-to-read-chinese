import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/data/providers/word_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:provider/provider.dart';

class TeachBopomoView extends StatefulWidget {
  final String char;
  final int unitId;
  final String unitTitle;
  final bool isBpmf;

  const TeachBopomoView({
    super.key,
    required this.char,
    required this.unitId,
    required this.unitTitle,
    required this.isBpmf,
  });

  @override
  State<TeachBopomoView> createState() => _TeachBopomoViewState();
}

class _TeachBopomoViewState extends State<TeachBopomoView>
    with TickerProviderStateMixin {
  late StrokeOrderAnimationController _strokeOrderAnimationControllers;
  late TabController _tabController;
  FlutterTts ftts = FlutterTts();
  late Word wordd;

  Future<String> readJson() async {
    final String response =
        await rootBundle.loadString('lib/assets/svg/${widget.char}.json');

    return response.replaceAll("\"", "\'");
  }

  // void getWord() async {
  //   Word word_ = await WordProvider.getWord(inputWord: "山");
  //   // await WordProvider.getWord(inputWord: widget.char);
  //   setState(() {
  //     wordd = word_;
  //   });
  // }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);
    // getWord();
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
    String word = widget.char;
    int unitId = widget.unitId;
    String unitTitle = widget.unitTitle;
    bool isBpmf = widget.isBpmf;

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
              fontSize: 34,
              fontWeight: FontWeight.w900,
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
                    isBpmf: isBpmf,
                    sectionName: '看一看',
                    word: word,
                    content: Image(
                      width: 300,
                      image: AssetImage('lib/assets/img/bopomo/$word.png'),
                    )),
                TeachWordTabBarView(
                    isBpmf: isBpmf,
                    word: word,
                    sectionName: '聽一聽',
                    content: Column(
                      children: [
                        Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: Text(word,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 150,
                                  color: Color.fromRGBO(245, 245, 220, 100),
                                  fontFamily: 'BpmfOnly',
                                  fontWeight: FontWeight.w100)),
                        ),
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 1),
                            child: Column(
                              children: [
                                IconButton(
                                    iconSize: 35,
                                    color: Color.fromRGBO(245, 245, 220, 100),
                                    onPressed: () async {
                                      var result = await ftts.speak(word);
                                      if (result == 1) {
                                      } else {}
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
                  isBpmf: isBpmf,
                  sectionName: '寫一寫',
                  word: word,
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
                              Flexible(
                                child: GridView(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 2,
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 6,
                                  ),
                                  primary: false,
                                  children: <Widget>[
                                    IconButton(
                                      iconSize: 35,
                                      color: Color.fromRGBO(245, 245, 220, 100),
                                      isSelected: controller.isAnimating,
                                      icon: const Icon(Icons.play_arrow),
                                      selectedIcon: const Icon(Icons.pause),
                                      onPressed: !controller.isQuizzing
                                          ? () async {
                                              if (!controller.isAnimating) {
                                                controller.startAnimation();
                                                var result =
                                                    await ftts.speak(word);
                                                if (result == 1) {
                                                } else {}
                                              } else {
                                                controller.stopAnimation();
                                              }
                                            }
                                          : null,
                                    ),
                                    IconButton(
                                      iconSize: 35,
                                      color: Color.fromRGBO(245, 245, 220, 100),
                                      isSelected: controller.isQuizzing,
                                      icon: const Icon(Icons.edit),
                                      selectedIcon: const Icon(Icons.edit_off),
                                      onPressed: () async {
                                        if (!controller.isQuizzing) {
                                          controller.startQuiz();
                                          var result = await ftts.speak(word);
                                          if (result == 1) {
                                          } else {}
                                        } else {
                                          controller.stopQuiz();
                                        }
                                      },
                                    ),
                                    IconButton(
                                      iconSize: 35,
                                      color: Color.fromRGBO(245, 245, 220, 100),
                                      isSelected: controller.showOutline,
                                      icon: const Icon(
                                          Icons.remove_red_eye_outlined),
                                      selectedIcon:
                                          const Icon(Icons.remove_red_eye),
                                      onPressed: () {
                                        controller.setShowOutline(
                                            !controller.showOutline);
                                      },
                                    ),
                                    IconButton(
                                      iconSize: 35,
                                      color: Color.fromRGBO(245, 245, 220, 100),
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
                                          color: Color.fromRGBO(
                                              245, 245, 220, 100),
                                        )),
                                    const Text('邊框',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 17.5,
                                          color: Color.fromRGBO(
                                              245, 245, 220, 100),
                                        )),
                                    const Text('重新',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 17.5,
                                            color: Color.fromRGBO(
                                                55, 55, 24, 0.612))),
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
                TeachWordTabBarView(
                    isBpmf: isBpmf,
                    sectionName: '用一用',
                    word: word,
                    content: Column(
                      children: [
                        Container(
                          // height: 300,
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              const Text('水杯',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 55,
                                    color: Color.fromRGBO(245, 245, 220, 100),
                                    fontFamily: 'BpmfOnly',
                                  )),
                              Image(
                                height: 140,
                                image: AssetImage(
                                    'lib/assets/img/bopomo/$word.png'),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(
                                      textAlign: TextAlign.center,
                                      TextSpan(
                                          text: '媽媽拿起',
                                          style: TextStyle(
                                            height: 1.1,
                                            fontSize: 48,
                                            color: Color.fromRGBO(
                                                245, 245, 220, 100),
                                            fontFamily: "BpmfOnly",
                                          ),
                                          children: <InlineSpan>[
                                            TextSpan(
                                              text: '水杯',
                                              style: TextStyle(
                                                // fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    228, 219, 124, 1),
                                              ),
                                            ),
                                            TextSpan(
                                              text: '，將水全部喝完。',
                                              // style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              // color: Color.fromRGBO(228, 219, 124, 1),
                                              // ),
                                            ),
                                          ])),
                                  Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Column(
                                      children: [
                                        IconButton(
                                            iconSize: 35,
                                            color: const Color.fromRGBO(
                                                245, 245, 220, 100),
                                            onPressed: () async {
                                              var result = await ftts
                                                  .speak('水杯。媽媽拿起水杯，將水全部喝完。');
                                              if (result == 1) {
                                                //speaking
                                              } else {
                                                //not speaking
                                              }
                                            },
                                            icon: const Icon(Icons.volume_up)),
                                        const Text('讀音',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 17.5,
                                              color: Color.fromRGBO(
                                                  245, 245, 220, 100),
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ])),
    );
  }
}
