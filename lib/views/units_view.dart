import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/models/word_phrase_sentence_model.dart';
import 'package:ltrc/data/providers/word_phrase_sentence_provider.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
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
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    bool isTablet = screenInfo.screenWidth > 600;
    if (isTablet) fontSize = fontSize * 1.5;

    // Extract the arguments safely
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null || args['units'] == null) {
      return Center(
        child: Text(
          'No units available',
          style: TextStyle(fontSize: fontSize),
        ),
      );
    }

    // Now that we've checked, it's safe to cast    
    List<Unit> units = args["units"]; // Assuming 'units' is a list of 'Unit'

    Future<List<Map>> getWordsPhraseSentence(List<WordStatus> wordsStatus) async {
      List<Map> wordsPhrase = [];
      WordPhraseSentence? wordPhraseSentence;

      if (wordsStatus.isEmpty) return wordsPhrase;
      try {
        for (var wordStatus in wordsStatus) {
          // Attempt to fetch the WordPhraseSentence for the provided wordStatus
          // debugPrint('wordStatus.word: ${wordStatus.word}'); // debug
          wordPhraseSentence = await WordPhraseSentenceProvider.getWordPhraseSentenceByWord(inputWord: wordStatus.word);
          if (wordPhraseSentence.id == -1) {
            wordsPhrase.add(
              {
                "word": "",
                "vocab1": "",
                "meaning1": "",
                "sentence1": "",
                "vocab2": "",
                "meaning2": "",
                "sentence2": "",
              }
            );
          } else {
            wordsPhrase.add(
              {
                "word": wordPhraseSentence.word,
                "vocab1": wordPhraseSentence.phrase,
                "meaning1": wordPhraseSentence.definition,
                "sentence1": wordPhraseSentence.sentence,
                "vocab2": wordPhraseSentence.phrase2,
                "meaning2": wordPhraseSentence.definition2,
                "sentence2": wordPhraseSentence.sentence2,
              }
            );
          }
        }
        return wordsPhrase;
      } catch (e) {
        debugPrint('Error in getWordsPhraseSentence: $e');
        wordsPhrase = [];
        return wordsPhrase;
      }
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
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isTablet
                      ? fontSize * 8.0
                      : fontSize * 8.0, // This is most important
                  mainAxisSpacing: fontSize * 0.5, // was 10,
                  crossAxisSpacing: fontSize * 0.5, // was 10,
                  childAspectRatio: isTablet ? 4 / 3 : 4 / 4,
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
                        List<Map> bpmfWordsPhrase = await getWordsPhraseSentence(wordsStatus);
                        if (!context.mounted) return;
                        /*
                        Navigator.of(context).pushNamed(
                          '/bopomos', 
                          arguments: {
                            'wordStatus' : wordsStatus,
                            'wordsPhrase' : bpmfWordsPhrase
                          }
                        );
                        */
                        navigateWithProvider(
                          context, 
                          '/bopomos', 
                          ref, 
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
                        List<Map> likedWordsPhrase = await getWordsPhraseSentence(likedWords);
                        if (!context.mounted) return;
                        /*
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
                        */
                        navigateWithProvider(
                          context, 
                          '/words', 
                          ref, 
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
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isTablet
                      ? fontSize * 8.0
                      : fontSize * 8.0, // This is most important
                  mainAxisSpacing: fontSize * 0.5, // was 10,
                  crossAxisSpacing: fontSize * 0.5, // was 10,
                  childAspectRatio: isTablet ? 4 / 3 : 4 / 4,
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
                      List<Map> newWordsPhrase = await getWordsPhraseSentence(newWordsStatus);
                      List<Map> extraWordsPhrase = await getWordsPhraseSentence(extraWordsStatus);
                      if (!context.mounted) return;
                      /*
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
                      */
                      navigateWithProvider(
                        context,
                        '/words', 
                        ref,
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
