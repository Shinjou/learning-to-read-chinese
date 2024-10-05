import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/contants/bopomo_spelling_problem.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/bopomo_spelling_model.dart';
import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/providers/word_provider.dart';
// import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';
import '../widgets/bopomo/bopomo_container.dart';


class BopomoQuizView extends ConsumerStatefulWidget {
  const BopomoQuizView({super.key});

  @override
  ConsumerState<BopomoQuizView> createState() => _BopomoQuizState();
}

class _BopomoQuizState extends ConsumerState<BopomoQuizView> {
  final vowels = List.from(prenuclear)..addAll(finals);
  int problemId = 0;
  FlutterTts ftts = FlutterTts();
  Color answerBoxBorderColor = beige;
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
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;

    return Scaffold(
        appBar: AppBar(
          // 拼拼看
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
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
                size: fontSize * 1.5,
              ),
              // onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
              onPressed: () => navigateWithProvider(context, '/mainPage', ref),
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
                  decoration: const BoxDecoration(
                    color: deepBlue,
                  ),
                  child: RichText(
                    // 第${problemId+1}題\n請拼出「${bopomoSpellingWords[problemId]}」的注音
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: '第${problemId + 1}題：請拼出「',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'BpmfIansui',
                          color: beige,
                        ),
                        children: [
                          TextSpan(
                              text: bopomoSpellingWords[problemId],
                              style: TextStyle(
                                fontSize: fontSize,
                                fontFamily: 'Iansui',
                                color: beige,
                              )),
                          TextSpan(
                              text: '」的注音',
                              style: TextStyle(
                                fontSize: fontSize,
                                fontFamily: 'BpmfIansui',
                                color: beige,
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
                                color: beige,
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
                                color: beige,
                                fontSize: fontSize * 0.75),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.lightbulb,
                              color: beige,
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
                                color: beige,
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
                            color: darkCyan,
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
                                      color: darkOliveGreen,
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
                                      color: goldenOrange,
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
                                      color: goldenOrange,
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
                                  color: indianRed,
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
                              color: beige,
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
                                color: beige,
                                fontSize: fontSize * 0.75),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.done_outline,
                              color: beige,
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
                                          beige;
                                    });
                                  });
                                } else {
                                  setState(() {
                                    answerBoxBorderColor = Colors.red;
                                  });
                                  Timer(const Duration(seconds: 1), () {
                                    setState(() {
                                      answerBoxBorderColor =
                                          beige;
                                    });
                                  });
                                }
                              } else {
                                // Navigator.pushNamed(context, '/bopomoQuizFinish');
                                navigateWithProvider(context, '/bopomoQuizFinish', ref);
                              }
                            },
                          ),
                          Text(
                            '確\n認',
                            style: TextStyle(
                                color: beige,
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
                  maxCrossAxisExtent: fontSize * 2.0,
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
                            color: dimGray,
                            onPressed: () => setState(() {
                              caught.tone = 1;
                            }),
                          )
                        : BopomoContainer(
                            character: tones[index],
                            color: indianRed,
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
                  maxCrossAxisExtent: fontSize * 2.0,
                  mainAxisSpacing: fontSize * 0.75,
                  crossAxisSpacing: fontSize * 0.75,
                  childAspectRatio: 1 / 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return initials[index] == caught.initial
                        ? BopomoContainer(
                            character: initials[index],
                            color: dimGray,
                            onPressed: () => setState(() {
                              caught.initial = '';
                            }),
                          )
                        : BopomoContainer(
                            character: initials[index],
                            color: darkOliveGreen,
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
                  maxCrossAxisExtent: fontSize * 2.0,
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
                              color: dimGray,
                              onPressed: () => setState(() {
                                caught.prenuclear = '';
                              }),
                            )
                          : BopomoContainer(
                              character: prenuclear[index],
                              color: goldenOrange,
                              onPressed: () => setState(() {
                                caught.prenuclear = prenuclear[index];
                              }),
                            );
                    } else {
                      return finals[index - 3] == caught.finals
                          ? BopomoContainer(
                              character: finals[index - 3],
                              color: dimGray,
                              onPressed: () => setState(() {
                                caught.finals = '';
                              }),
                            )
                          : BopomoContainer(
                              character: finals[index - 3],
                              color: goldenOrange,
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
