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
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/acknowledge.dart';

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
    
    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    
    setState(() {
      units = obj["units"];
    });

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
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
        title: const Text("課程單元"),
      ),

      body: CustomScrollView(
          slivers: [
             SliverPadding(
              padding: const EdgeInsets.fromLTRB(23, 14, 23, 20),
                sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180.0,
                  mainAxisSpacing: 13.0,
                  crossAxisSpacing: 13.0,
                  childAspectRatio: 2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return index == 0 ?
                    InkWell( 
                      onTap: () async {
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

                        Navigator.of(context).pushNamed(
                          '/bopomos', 
                          arguments: {
                            'wordStatus' : wordsStatus,
                            'wordsPhrase' : bpmfWordsPhrase
                          }
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(14)),
                          color: "#013E6D".toColor(),
                        ),
                        child: const Text(
                          "學注音", 
                          style: TextStyle(
                            fontSize: 24,
                          ), 
                          textAlign: TextAlign.center,),
                      ),
                    ) :
                    InkWell( 
                      onTap: () async {
                        List<WordStatus> likedWords = await WordStatusProvider.getLikedWordsStatus(
                          account: ref.watch(accountProvider), 
                        );
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
                          }
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(14)),
                          color: "#013E6D".toColor(),
                        ),
                        child: const Text(
                          "❤️最愛", 
                          style: TextStyle(
                            fontSize: 24,
                          ), 
                          textAlign: TextAlign.center,),
                      ),
                    );
                  },
                  childCount: resourceList.length,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(23, 14, 23, 20),
                sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180.0,
                  mainAxisSpacing: 13.0,
                  crossAxisSpacing: 13.0,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    String? classNum = numeralToChinese[index+1];
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
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(14)),
                          color: "#013E6D".toColor(),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "第$classNum課", 
                              style: const TextStyle(
                                fontSize: 16,
                              )
                            ),
                            Text(
                              units[index].unitTitle, 
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: units.length,
                ),
              ),
            )
          ],
        ),
    );
  }
}