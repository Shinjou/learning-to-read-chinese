import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:provider/provider.dart';

import '../contants/arabic_numerals_to_chinese.dart';
import '../data/models/unit_model.dart';

class UnitsView extends ConsumerStatefulWidget {
  
  const UnitsView({super.key});

  @override
  UnitsViewState createState() => UnitsViewState();
}
class UnitsViewState extends ConsumerState<UnitsView> {
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
    List<Unit> units = obj["units"];
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
        title: const Text("課程單元"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.of(context).pushNamed('/setting'),)
        ],
      ),

      body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(23, 20, 23, 14),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children:[
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

                        List<WordStatus> wordStatus = await WordStatusProvider.getWordsStatus(
                          account: ref.read(accountProvider.notifier).state,
                          words: bopomos, 
                        );

                        Navigator.of(context).pushNamed(
                          '/bopomos', 
                          arguments: {
                            'wordStatus' : wordStatus,
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
                        child: Text(
                          "學注音", 
                          style: TextStyle(
                            fontSize: 32,
                            color: "#F5F5DC".toColor(),
                          ), 
                          textAlign: TextAlign.center,),
                      ),
                    ),
                    const SizedBox(
                      width:16
                    ),
                    InkWell( 
                      onTap: () async {
                        List<WordStatus> wordStatus = await WordStatusProvider.getWordsStatus(
                          account: ref.read(accountProvider.notifier).state,
                          words: [""], 
                        );

                        Navigator.of(context).pushNamed(
                          '/bopomos', 
                          arguments: {
                            'wordStatus' : wordStatus,
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
                        child: Text(
                          "最愛", 
                          style: TextStyle(
                            fontSize: 24,
                            color: "#F5F5DC".toColor(),
                          ), 
                          textAlign: TextAlign.center,),
                      ),
                    ),
                  ]
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

                        Navigator.of(context).pushNamed(
                          '/words', 
                          arguments: {
                            'unit' : unit,
                            'newWordsStatus' : newWordsStatus,
                            'extraWordsStatus' : extraWordsStatus
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
                              style: TextStyle(
                                fontSize: 16,
                                color: "#F5F5DC".toColor(),
                              )
                            ),
                            Text(
                              units[index].unitTitle, 
                              style: TextStyle(
                                fontSize: 24,
                                color: "#F5F5DC".toColor(),
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