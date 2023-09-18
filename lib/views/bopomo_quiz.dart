import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/contants/bopomo_spelling_problem.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/bopomo_spelling_model.dart';
import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/providers/word_provider.dart';
import 'package:ltrc/extensions.dart';
import '../widgets/bopomo/bopomo_container.dart';


class BopomoQuizView extends StatefulWidget {
  const BopomoQuizView({super.key});

  @override
  State<BopomoQuizView> createState() => _BopomoQuizState();
}

class _BopomoQuizState extends State<BopomoQuizView>{ 
  final vowels = List.from(prenuclear)..addAll(finals);
  int problemId = 0;
  FlutterTts ftts = FlutterTts();
  Color answerBoxBorderColor = '#F5F5DC'.toColor();
  BopomoSpelling caught = BopomoSpelling();
  BopomoSpelling answer = BopomoSpelling();

  void _getAnswer() async {
    if (answer.initial.isEmpty && answer.prenuclear.isEmpty && answer.finals.isEmpty){
      Word answerWord = await WordProvider.getWord(inputWord: bopomoSpellingWords[problemId]);
      String answerSpelling = answerWord.phonetic;
      List<String> spellingList = answerSpelling.split('');
      switch (spellingList.length){
        case(1):
          if (initials.contains(spellingList[0])){
            answer.initial = spellingList[0];
          } else if (prenuclear.contains(spellingList[0])){
            answer.prenuclear = spellingList[0];
          } else {
            answer.finals = spellingList[0];
          }
          break;
        case(2):
          if (initials.contains(spellingList[0])){
            answer.initial = spellingList[0];
            if (prenuclear.contains(spellingList[1])) {
              answer.prenuclear = spellingList[1];
            } else{
              answer.finals = spellingList[1];
            }
          } else if (prenuclear.contains(spellingList[0])){
            answer.prenuclear = spellingList[0];
            answer.finals = spellingList[1];
          }
          break;
        case(3):
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
        title: const Text("拼拼看"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
            ),
            onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: '#013E6D'.toColor(),
              ),
              child: Text(
                '第${problemId+1}題\n請拼出「${bopomoSpellingWords[problemId]}」的注音',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: "#F5F5DC".toColor(),
                )
              )
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    height: 180,
                    image: AssetImage('lib/assets/img/bopomo_spelling/${bopomoSpellingWords[problemId]}.png'),
                  ),
                  Container(
                    width: 15
                  ),
                  Container(
                    width: 30,
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: "#F8F88E".toColor(),
                    ),
                    child: const Text(
                      "?",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  )
                ]
              ),
            )
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            sliver: SliverToBoxAdapter( 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.volume_up,
                          color: "#F5F5DC".toColor(),
                        ),
                        onPressed: () {
                          ftts.setLanguage("zh-tw");
                          ftts.setSpeechRate(0.5);
                          ftts.setVolume(1.0);
                          ftts.speak(bopomoSpellingWords[problemId]);
                        },
                      ),
                      Text(
                        '讀音',
                        style: TextStyle(color: "#F5F5DC".toColor()),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.lightbulb,
                          color: "#F5F5DC".toColor(),
                        ), 
                        onPressed: (){
                          _getAnswer();
                          if (answer.initial != caught.initial){
                            setState(() {
                              caught.initial = answer.initial;
                            });
                          } else if (answer.prenuclear != caught.prenuclear){
                            setState(() {
                              caught.prenuclear = answer.prenuclear;
                            });
                          } else if (answer.finals != caught.finals){
                            setState(() {
                              caught.finals = answer.finals;
                            });
                          } else if (answer.tone != caught.tone){
                            setState(() {
                              caught.tone = answer.tone;
                            });
                          }
                        },),
                      Text(
                        '提示',
                        style: TextStyle(color: "#F5F5DC".toColor()),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Container(
                        decoration: BoxDecoration(
                          color: '023E6E'.toColor(),
                          border: Border.all(
                            width: 5,
                            color: answerBoxBorderColor,
                          ),
                        ),
                        child: Row (
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BopomoContainer( 
                                  character : (caught.initial.isNotEmpty && caught.tone == 5) ? null :
                                    (caught.tone == 5) ? "˙" : caught.initial,
                                  innerWidget: (caught.initial.isNotEmpty && caught.tone == 5) ? Column(
                                    children: [
                                      const Text(
                                        "˙",
                                        style: TextStyle(
                                          fontSize: 16
                                        ),
                                      ),
                                      Text(
                                        caught.initial,
                                        style: const TextStyle(
                                          fontSize: 16
                                        ),
                                      )
                                    ],
                                  ) : null,
                                  color : "#48742C".toColor(),
                                  onPressed: () => setState(() {
                                    caught.initial = '';
                                    if (caught.tone == 5){
                                      caught.tone = 1;
                                    }
                                  }),
                                ),
                                BopomoContainer( 
                                  character: (caught.prenuclear.isNotEmpty && caught.finals.isNotEmpty) ? null :
                                    (caught.prenuclear.isNotEmpty) ? caught.prenuclear : caught.finals, 
                                  innerWidget: (caught.prenuclear.isNotEmpty && caught.finals.isNotEmpty) ? Column(
                                    children: [
                                      Text(
                                        caught.prenuclear,
                                        style: const TextStyle(
                                          fontSize: 16
                                        ),
                                      ),
                                      Text(
                                        caught.finals,
                                        style: const TextStyle(
                                          fontSize: 16
                                        ),
                                      )
                                    ],
                                  ) : null,
                                  color : "#D19131".toColor(),
                                  onPressed: () => setState(() {
                                    caught.finals = '';
                                    caught.prenuclear = '';
                                  }),
                                ),
                              ],
                            ),
                            BopomoContainer( 
                              character : (caught.tone == 5 || caught.tone == 1) ? "" : tones[caught.tone-2], 
                              color : "#B65454".toColor(),
                              onPressed: () => setState(() {
                                caught.tone = 1;
                              }),
                            ),
                          ]
                        ),
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.replay,
                          color: "#F5F5DC".toColor(),
                        ),
                        onPressed: (){
                          setState(() {
                            caught = BopomoSpelling();
                          });
                        },
                      ),
                      Text(
                        '清除',
                        style: TextStyle(color: "#F5F5DC".toColor()),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.done_outline,
                          color: "#F5F5DC".toColor(),
                        ), 
                        onPressed: (){
                          _getAnswer();
                          debugPrint(answer.toString());
                          debugPrint(caught.toString());
                          if (answer == caught){
                            setState(() {
                              answerBoxBorderColor = Colors.green;
                            });
                            Timer(const Duration(seconds: 2), () {
                              setState(() {
                                problemId += 1;
                                caught = BopomoSpelling();
                                answer = BopomoSpelling();
                                answerBoxBorderColor = '#F5F5DC'.toColor();
                              });
                            });
                          } else {
                            setState(() {
                              answerBoxBorderColor = Colors.red;
                            });
                            Timer(const Duration(seconds: 2), () {
                              setState(() {
                                answerBoxBorderColor = '#F5F5DC'.toColor();
                              });
                            });
                          }
                        },
                      ),
                      Text(
                        '確認',
                        style: TextStyle(color: "#F5F5DC".toColor()),
                      ),
                    ],
                  ),
                ],
              )
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 40,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return (index == caught.tone-2) ? 
                    BopomoContainer(
                      character: tones[index], 
                      color: "#404040".toColor(),
                      onPressed: () => setState(() {
                        caught.tone = 1;
                      }),
                    ) : 
                    BopomoContainer(
                      character: tones[index], 
                      color: "#B65454".toColor(),
                      onPressed: () => setState(() {
                        caught.tone = index+2;
                      }),
                    );
                },
                childCount: tones.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 40,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return initials[index] == caught.initial ?
                  BopomoContainer(
                    character: initials[index], 
                    color: "#404040".toColor(),
                    onPressed: () => setState(() {
                      caught.initial = '';
                    }),  
                  ) :
                  BopomoContainer(
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
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 40,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index < 3){
                    return prenuclear[index] == caught.prenuclear?
                      BopomoContainer(
                        character: prenuclear[index], 
                        color: "#404040".toColor(),
                        onPressed: () => setState(() {
                          caught.prenuclear = '';
                        }),  
                      ):
                      BopomoContainer(
                        character: prenuclear[index], 
                        color: "#D19131".toColor(),
                        onPressed: () => setState(() {
                          caught.prenuclear = prenuclear[index];
                        }),
                      );
                  }
                  else {
                    return finals[index-3] == caught.finals?
                      BopomoContainer(
                        character: finals[index-3], 
                        color: "#404040".toColor(),
                        onPressed: () => setState(() {
                          caught.finals = '';
                        }),  
                      ):
                      BopomoContainer(
                        character: finals[index-3], 
                        color: "#D19131".toColor(),
                        onPressed: () => setState(() {
                          caught.finals = finals[index-3];
                        }),  
                      );
                  }
                },
                childCount: vowels.length,
              ),
            ),
          ),
        ],
      )
    );
  }
}