import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/contants/bopomo_spelling_problem.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/bopomo_spelling_model.dart';
import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/providers/word_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import '../widgets/bopomo/bopomo_container.dart';
import 'package:ltrc/views/view_utils.dart';

class BopomoQuizView extends StatefulWidget {
  const BopomoQuizView({super.key});

  @override
  State<BopomoQuizView> createState() => _BopomoQuizState();
}

class _BopomoQuizState extends State<BopomoQuizView> {
  final vowels = List.from(prenuclear)..addAll(finals);
  int problemId = 0;
  FlutterTts ftts = FlutterTts();
  Color answerBoxBorderColor = '#F5F5DC'.toColor();
  BopomoSpelling caught = BopomoSpelling();
  BopomoSpelling answer = BopomoSpelling();

  Future<void> _getAnswer() async {
    if (answer.initial.isEmpty &&
        answer.prenuclear.isEmpty &&
        answer.finals.isEmpty) {
      Word answerWord =
          await WordProvider.getWord(inputWord: bopomoSpellingWords[problemId]);
      String answerSpelling = answerWord.phonetic;
      List<String> spellingList = answerSpelling.split('');
      switch (spellingList.length) {
        case (1):
          if (initials.contains(spellingList[0])) {
            answer.initial = spellingList[0];
          } else if (prenuclear.contains(spellingList[0])) {
            answer.prenuclear = spellingList[0];
          } else {
            answer.finals = spellingList[0];
          }
          break;
        case (2):
          if (initials.contains(spellingList[0])) {
            answer.initial = spellingList[0];
            if (prenuclear.contains(spellingList[1])) {
              answer.prenuclear = spellingList[1];
            } else {
              answer.finals = spellingList[1];
            }
          } else if (prenuclear.contains(spellingList[0])) {
            answer.prenuclear = spellingList[0];
            answer.finals = spellingList[1];
          }
          break;
        case (3):
          answer.initial = spellingList[0];
          answer.prenuclear = spellingList[1];
          answer.finals = spellingList[2];
          break;
        default:
          break;
      }
      answer.tone = answerWord.tone;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fontSize =
        getFontSize(context, 16); // 16 is the base font size for 360dp width

    return Scaffold(
        appBar: AppBar(
          // 拼拼看
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.0),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "拼拼看",
            style: TextStyle(
                fontSize: fontSize * 1.0), // Set the font size for the title
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.home,
                size: fontSize * 1.0,
              ),
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
            )
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              // 第${problemId+1}題\n請拼出「${bopomoSpellingWords[problemId]}」的注音
              child: Container(
                  height: fontSize * 1.7,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: '#013E6D'.toColor(),
                  ),
                  child: RichText(
                    // 第${problemId+1}題\n請拼出「${bopomoSpellingWords[problemId]}」的注音
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: '第${problemId + 1}題：請拼出「',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'Serif',
                          color: "#F5F5DC".toColor(),
                        ),
                        children: [
                          TextSpan(
                              text: bopomoSpellingWords[problemId],
                              style: TextStyle(
                                fontSize: fontSize,
                                fontFamily: 'Iceberg',
                                color: "#F5F5DC".toColor(),
                              )),
                          TextSpan(
                              text: '」的注音',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontFamily: 'Serif',
                                color: "#F5F5DC".toColor(),
                              )),
                        ]),
                  )),
            ),
            SliverPadding(
                // 讀音、提示、答案、清除、確認
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image(
                        height: fontSize * 8.0,
                        image: AssetImage(
                            'lib/assets/img/bopomo_spelling/${bopomoSpellingWords[problemId]}.png'),
                      ),
                      Column(
                        // 讀音、提示
                        children: [
                          Consumer(builder: (context, ref, child) {
                            return IconButton(
                              icon: Icon(
                                Icons.volume_up,
                                color: "#F5F5DC".toColor(),
                                size: 1.2 * fontSize,
                              ),
                              onPressed: () {
                                debugPrint(
                                    ref.watch(soundSpeedProvider).toString());
                                ftts.setLanguage("zh-tw");
                                ftts.setSpeechRate(
                                    ref.watch(soundSpeedProvider));
                                ftts.setVolume(1.0);
                                ftts.speak(bopomoSpellingWords[problemId]);
                              },
                            );
                          }),
                          Text(
                            '讀\n音',
                            style: TextStyle(
                                color: "#F5F5DC".toColor(),
                                fontSize: fontSize * 0.75),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.lightbulb,
                              color: "#F5F5DC".toColor(),
                              size: 1.2 * fontSize,
                            ),
                            onPressed: () async {
                              await _getAnswer();
                              if (answer.initial != caught.initial) {
                                setState(() {
                                  caught.initial = answer.initial;
                                });
                              } else if (answer.prenuclear !=
                                  caught.prenuclear) {
                                setState(() {
                                  caught.prenuclear = answer.prenuclear;
                                });
                              } else if (answer.finals != caught.finals) {
                                setState(() {
                                  caught.finals = answer.finals;
                                });
                              } else if (answer.tone != caught.tone) {
                                setState(() {
                                  caught.tone = answer.tone;
                                });
                              }
                            },
                          ),
                          Text(
                            '提\n示',
                            style: TextStyle(
                                color: "#F5F5DC".toColor(),
                                fontSize: fontSize * 0.75),
                          ),
                        ],
                      ),
                      SizedBox(
                        // 答案
                        width: 8.2 * fontSize,
                        height: 10.6 * fontSize,
                        child: Container(
                          decoration: BoxDecoration(
                            color: '023E6E'.toColor(),
                            border: Border.all(
                              width: 0.1 * fontSize,
                              color: answerBoxBorderColor,
                            ),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    BopomoContainer(
                                      character: (caught.initial.isNotEmpty &&
                                              caught.tone == 5)
                                          ? null
                                          : (caught.tone == 5)
                                              ? "˙"
                                              : caught.initial,
                                      innerWidget: (caught.initial.isNotEmpty &&
                                              caught.tone == 5)
                                          ? Column(
                                              children: [
                                                Text(
                                                  "˙",
                                                  style: TextStyle(
                                                      fontSize: fontSize),
                                                ),
                                                Text(
                                                  caught.initial,
                                                  style: TextStyle(
                                                      fontSize: fontSize),
                                                )
                                              ],
                                            )
                                          : null,
                                      color: "#48742C".toColor(),
                                      onPressed: () => setState(() {
                                        caught.initial = '';
                                        if (caught.tone == 5) {
                                          caught.tone = 1;
                                        }
                                      }),
                                    ),
                                    BopomoContainer(
                                      character: caught.prenuclear,
                                      innerWidget: Text(
                                        caught.prenuclear,
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                                      color: "#D19131".toColor(),
                                      onPressed: () => setState(() {
                                        caught.prenuclear = '';
                                      }),
                                    ),
                                    BopomoContainer(
                                      character: caught.finals,
                                      innerWidget: Text(
                                        caught.finals,
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                                      color: "#D19131".toColor(),
                                      onPressed: () => setState(() {
                                        caught.finals = '';
                                      }),
                                    ),
                                  ],
                                ),
                                BopomoContainer(
                                  character:
                                      (caught.tone == 5 || caught.tone == 1)
                                          ? ""
                                          : tones[caught.tone - 2],
                                  color: "#B65454".toColor(),
                                  onPressed: () => setState(() {
                                    caught.tone = 1;
                                  }),
                                ),
                              ]),
                        ),
                      ),
                      Column(
                        // 清除、確認
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.replay,
                              color: "#F5F5DC".toColor(),
                              size: 1.2 * fontSize,
                            ),
                            onPressed: () {
                              setState(() {
                                caught = BopomoSpelling();
                              });
                            },
                          ),
                          Text(
                            '清\n除',
                            style: TextStyle(
                                color: "#F5F5DC".toColor(),
                                fontSize: fontSize * 0.75),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.done_outline,
                              color: "#F5F5DC".toColor(),
                              size: 1.2 * fontSize,
                            ),
                            onPressed: () async {
                              if (problemId < bopomoSpellingWords.length - 1) {
                                await _getAnswer();
                                if (answer == caught) {
                                  setState(() {
                                    answerBoxBorderColor = Colors.green;
                                  });
                                  Timer(const Duration(seconds: 1), () {
                                    setState(() {
                                      problemId += 1;
                                      caught = BopomoSpelling();
                                      answer = BopomoSpelling();
                                      answerBoxBorderColor =
                                          '#F5F5DC'.toColor();
                                    });
                                  });
                                } else {
                                  setState(() {
                                    answerBoxBorderColor = Colors.red;
                                  });
                                  Timer(const Duration(seconds: 1), () {
                                    setState(() {
                                      answerBoxBorderColor =
                                          '#F5F5DC'.toColor();
                                    });
                                  });
                                }
                              } else {
                                Navigator.pushNamed(
                                    context, '/bopomoQuizFinish');
                              }
                            },
                          ),
                          Text(
                            '確\n認',
                            style: TextStyle(
                                color: "#F5F5DC".toColor(),
                                fontSize: fontSize * 0.75),
                          ),
                        ],
                      ),
                    ], // children
                  ),
                )),
            // SizedBox(height: fontSize * 0.2),
            SliverPadding(
              // 四聲
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: fontSize * 1.75, // was 40
                  mainAxisSpacing: fontSize * 0.75, // was 8.0,
                  crossAxisSpacing: fontSize * 0.75, // was 8.0
                  childAspectRatio: 1 / 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return (index == caught.tone - 2)
                        ? BopomoContainer(
                            // The top right hand box
                            character: tones[index],
                            color: "#404040".toColor(),
                            onPressed: () => setState(() {
                              caught.tone = 1;
                            }),
                          )
                        : BopomoContainer(
                            character: tones[index],
                            color: "#B65454".toColor(),
                            onPressed: () => setState(() {
                              caught.tone = index + 2;
                            }),
                          );
                  },
                  childCount: tones.length,
                ),
              ),
            ),
            SliverPadding(
              // ㄅㄆㄇㄈ
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: fontSize * 1.75, // was 40
                  mainAxisSpacing: fontSize * 0.75, // was 8.0,
                  crossAxisSpacing: fontSize * 0.75, // was 8.0
                  childAspectRatio: 1 / 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return initials[index] == caught.initial
                        ? BopomoContainer(
                            character: initials[index],
                            color: "#404040".toColor(),
                            onPressed: () => setState(() {
                              caught.initial = '';
                            }),
                          )
                        : BopomoContainer(
                            character: initials[index],
                            color: "#48742C".toColor(),
                            onPressed: () => setState(() {
                              caught.initial = initials[index];
                            }),
                          );
                  },
                  childCount: initials.length,
                ),
              ),
            ),
            SliverPadding(
              // ㄧㄨㄩ
              padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: fontSize * 1.75, // was 40
                  mainAxisSpacing: fontSize * 0.75, // was 8.0,
                  crossAxisSpacing: fontSize * 0.75, // was 8.0
                  childAspectRatio: 1 / 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index < 3) {
                      return prenuclear[index] == caught.prenuclear
                          ? BopomoContainer(
                              character: prenuclear[index],
                              color: "#404040".toColor(),
                              onPressed: () => setState(() {
                                caught.prenuclear = '';
                              }),
                            )
                          : BopomoContainer(
                              character: prenuclear[index],
                              color: "#D19131".toColor(),
                              onPressed: () => setState(() {
                                caught.prenuclear = prenuclear[index];
                              }),
                            );
                    } else {
                      return finals[index - 3] == caught.finals
                          ? BopomoContainer(
                              character: finals[index - 3],
                              color: "#404040".toColor(),
                              onPressed: () => setState(() {
                                caught.finals = '';
                              }),
                            )
                          : BopomoContainer(
                              character: finals[index - 3],
                              color: "#D19131".toColor(),
                              onPressed: () => setState(() {
                                caught.finals = finals[index - 3];
                              }),
                            );
                    }
                  },
                  childCount: vowels.length,
                ),
              ),
            ),
          ],
        ));
  }
}
