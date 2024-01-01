import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/widgets/word_card.dart';
import 'package:ltrc/views/view_utils.dart';

class WordsView extends ConsumerWidget {
  const WordsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double fontSize = getFontSize(context, 16); // 16 is the base font size for 360dp width

    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    Unit unit = obj["unit"];
    List<WordStatus> newWordsStatus = obj["newWordsStatus"];
    List<WordStatus> extraWordsStatus = obj["extraWordsStatus"] ?? [];
    List<Map> newWordsPhrase = obj["newWordsPhrase"];
    List<Map> extraWordsPhrase = obj["extraWordsPhrase"] ?? [];

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 0.75),
            onPressed: () => Navigator.pop(context),
          ),
          title: (unit.id == -1) ? Text(unit.unitTitle, style: TextStyle(fontSize: fontSize * 0.75,)) : 
            Text("${unit.unitId.toString().padLeft(2,'0')} | ${unit.unitTitle}", style: TextStyle(fontSize: fontSize * 0.75,)),
          actions: [
            IconButton(
              icon: Icon(Icons.home, size: fontSize * 0.75),
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
            )
          ],
        ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isTablet(context) ? fontSize * 8.0 : fontSize * 8.0, // This is most important
                mainAxisSpacing: fontSize * 0.5, // was 10,
                crossAxisSpacing: fontSize * 0.5, // was 10,
                childAspectRatio: isTablet(context) ? 4 / 3 : 4 / 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return WordCard(
                    isBpmf: (initials.contains(newWordsStatus[index].word) || prenuclear.contains(newWordsStatus[index].word) || finals.contains(newWordsStatus[index].word)),
                    unitId: unit.unitId,
                    unitTitle: unit.unitTitle,
                    wordsStatus: newWordsStatus,
                    wordsPhrase: newWordsPhrase,
                    wordIndex: index,
                    sizedBoxWidth: fontSize * 2.0,
                    sizedBoxHeight: fontSize * 3.0, // was 3.0
                    fontSize: fontSize * 2.5,
                    isVertical: true,
                    disable: false,
                  );
                },
                childCount: newWordsStatus.length,
              ),
            ),
          ),
          (extraWordsStatus.isEmpty) ? const SliverToBoxAdapter(child: Text('')) : 
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                  "唸唸看",
                  style: TextStyle(
                    fontSize: fontSize * 1.5,
                  )
              ))
                  ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: fontSize * 15.0, // 250.0,
                mainAxisSpacing: fontSize * 0.5, // was 15,
                crossAxisSpacing: fontSize * 0.5, // was 15,                
                childAspectRatio: 3 / 4,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return WordCard(
                    isBpmf: false,
                    unitId: unit.unitId,
                    unitTitle: unit.unitTitle,
                    wordsStatus: extraWordsStatus,
                    wordsPhrase: extraWordsPhrase,
                    wordIndex: index,
                    sizedBoxWidth: fontSize * 1.8,
                    sizedBoxHeight: fontSize * 9.1,
                    fontSize: fontSize * 2.0,
                    isVertical: true,
                    disable: false
                  );
                },
                childCount: extraWordsStatus.length,
              ),
            ),
          )],
        ));
  }
}
