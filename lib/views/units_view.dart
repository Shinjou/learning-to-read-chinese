import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/phrase_model.dart';
import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/phrase_provider.dart';
import 'package:ltrc/data/providers/word_phrase_provider.dart';
import 'package:ltrc/data/providers/word_provider.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
// import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

import '../contants/arabic_numerals_to_chinese.dart';
import '../data/models/unit_model.dart';

class UnitsView extends ConsumerStatefulWidget {
  
  const UnitsView({super.key});

  @override
  UnitsViewState createState() => UnitsViewState();
}
class UnitsViewState extends ConsumerState<UnitsView> {
  List<Unit> units = [];
  
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
    ScreenInfo screenInfo = getScreenInfo(context);
    double fontSize = screenInfo.fontSize;    

    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    List<Unit> units = obj["units"]; // Assuming 'units' is a list of 'Unit'

    Future<List<Map>> getWordsPhrase(List<WordStatus> wordsStatus) async {
      List<Map> wordsPhrase = [];
      for (var wordStatus in wordsStatus) {
        Word word = await WordProvider.getWord(inputWord: wordStatus.word);
        List<int> phraseId = await WordPhraseProvider.getPhrasesId(inputWordId: word.id);
        if (phraseId.isEmpty) {
          wordsPhrase.add(
            {
              "word": wordStatus.word,
              "vocab1": "",
              "meaning1": "",
              "sentence1": "",
              "vocab2": "",
              "meaning2": "",
              "sentence2": "",
            }
          );
        }
        else {
          Phrase phrase1 = await PhraseProvider.getPhraseById(inputPhraseId: phraseId[0]);
          Phrase phrase2 = phraseId.length > 1 ? await PhraseProvider.getPhraseById(inputPhraseId: phraseId[1]) : phrase1;
          wordsPhrase.add(
            {
              "word": wordStatus.word,
              "vocab1": phrase1.phrase,
              "meaning1": phrase1.definition,
              "sentence1": phrase1.sentence,
              "vocab2": phraseId.length == 1 ? "" : phrase2.phrase,
              "meaning2": phraseId.length == 1 ? "" : phrase2.definition,
              "sentence2": phraseId.length == 1 ? "" : phrase2.sentence,
            }
          );
        }
      }
      return wordsPhrase;
    }
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: fontSize * 1.5), 
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("課程單元", style: TextStyle(fontSize: fontSize * 1.5)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(23, 14, 23, 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // for 2 columns, adjust according to your design
                childAspectRatio: 6 / 2, // was 3 / 2
                crossAxisSpacing: fontSize * 0.66, // was 10,
                mainAxisSpacing: fontSize * 0.66 // was 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  String text = index == 0 ? "學注音" : "最愛❤️";
                  return InkWell(
                    onTap: () async {
                      if (index == 0 ) {  // 學注音
                        List<String> bopomos = List.from(initials)..addAll(prenuclear)..addAll(finals);
                        await WordStatusProvider.addWordsStatus(
                          statuses: bopomos.map((word) => 
                            WordStatus(
                              id: -1, 
                              userAccount: ref.read(accountProvider.notifier).state , 
                              word: word, 
                              learned: false, 
                              liked: false
                            )
                          ).toList()
                        );

                        List<WordStatus> wordsStatus = await WordStatusProvider.getWordsStatus(
                          account: ref.read(accountProvider.notifier).state,
                          words: bopomos, 
                        );
                        List<Map> bpmfWordsPhrase = await getWordsPhrase(wordsStatus);
                        if (!mounted) return;
                        Navigator.of(context).pushNamed(
                          '/bopomos', 
                          arguments: {
                            'wordStatus' : wordsStatus,
                            'wordsPhrase' : bpmfWordsPhrase
                          }
                        );
                      }
                      else {
                        List<WordStatus> likedWords = await WordStatusProvider.getLikedWordsStatus(
                          account: ref.watch(accountProvider), 
                        );
                        List<Map> likedWordsPhrase = await getWordsPhrase(likedWords);
                        Navigator.of(context).pushNamed(
                          '/words', 
                          arguments: {
                            'unit' : Unit(
                              id: -1, 
                              publisher: '', 
                              grade: 1, 
                              semester: '', 
                              unitId: -1, 
                              unitTitle: "❤️最愛",
                              newWords: [] ,
                              extraWords:[]
                            ),
                            'newWordsStatus' : likedWords,
                            'newWordsPhrase' : likedWordsPhrase
                          }
                        );
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Color(0xFF013E6D),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            text,
                            style: TextStyle(fontSize: fontSize),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: 2,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(23, 14, 23, 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // for three columns, adjust according to your design
                childAspectRatio: 6 / 3, // was 3 / 2
                crossAxisSpacing: fontSize * 0.66, // was 10,
                mainAxisSpacing: fontSize * 0.66, // was 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  // String? classNum = numeralToChinese[index + 1];
                  return InkWell(
                    onTap: () async {
                      Unit unit = units[index];
                      await WordStatusProvider.addWordsStatus(
                        statuses: unit.newWords.map((word) => 
                          WordStatus(
                            id: -1, 
                            userAccount: ref.read(accountProvider.notifier).state , 
                            word: word, 
                            learned: false, 
                            liked: false
                          )
                        ).toList()
                      );
                      unit.newWords.removeWhere((item) => unit.extraWords.contains(item));
                      
                      List<WordStatus> newWordsStatus = await WordStatusProvider.getWordsStatus(
                        account: ref.read(accountProvider.notifier).state,
                        words: unit.newWords, 
                      );
                      List<WordStatus> extraWordsStatus = await WordStatusProvider.getWordsStatus(
                        account: ref.read(accountProvider.notifier).state,
                        words: unit.extraWords, 
                      );
                      List<Map> newWordsPhrase = await getWordsPhrase(newWordsStatus);
                      List<Map> extraWordsPhrase = await getWordsPhrase(extraWordsStatus);
                      if (!mounted) return;
                      Navigator.of(context).pushNamed(
                        '/words', 
                        arguments: {
                          'unit' : unit,
                          'newWordsStatus' : newWordsStatus,
                          'extraWordsStatus' : extraWordsStatus,
                          'newWordsPhrase' : newWordsPhrase,
                          'extraWordsPhrase' : extraWordsPhrase
                        }
                      );
                    },            
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Color(0xFF013E6D),
                      ),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(2.0), // was 8.0
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "第${numeralToChinese[index + 1]}課",
                            style: TextStyle(
                              fontSize: fontSize, // Choose a font size that fits all boxes
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            units[index].unitTitle,
                            style: TextStyle(fontSize: fontSize), // Use the same font size for consistency
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: units.length,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
