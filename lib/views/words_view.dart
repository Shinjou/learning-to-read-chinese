import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/widgets/word_card.dart';

class WordsView extends ConsumerWidget {
  const WordsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    Unit unit = obj["unit"];
    List<WordStatus> newWordsStatus = obj["newWordsStatus"];
    List<WordStatus> extraWordsStatus = obj["extraWordsStatus"] ?? [];
    List<Map> newWordsPhrase = obj["newWordsPhrase"];
    List<Map> extraWordsPhrase = obj["extraWordsPhrase"] ?? [];

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
          title: (unit.id == -1) ? Text(unit.unitTitle) : Text("${unit.unitId.toString().padLeft(2,'0')} | ${unit.unitTitle}"),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
            )
          ],
        ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 125.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 113 / 160,
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
                    sizedBoxWidth: 30,
                    sizedBoxHeight: 155,
                    fontSize: 48,
                    isVertical: true,
                    disable: false,
                  );
                },
                childCount: newWordsStatus.length,
              ),
            ),
          ),
          (extraWordsStatus.isEmpty) ? const SliverToBoxAdapter(child: Text('')) : 
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                  "唸唸看",
                  style: TextStyle(
                    fontSize: 24,
                  )
              ))
                  ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 125.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 113 / 160,
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
                    sizedBoxWidth: 30,
                    sizedBoxHeight: 155,
                    fontSize: 48,
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
