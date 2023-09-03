import 'package:flutter/material.dart';
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/extensions.dart';
import '../widgets/word_card.dart';

class WordsView extends StatelessWidget {
  const WordsView({super.key});

  @override
  Widget build(BuildContext context) {
    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    Unit unit = obj["unit"];
    unit.newWords.removeWhere((item) => unit.extraWords.contains(item));

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
              "${unit.unitId.toString().padLeft(2, '0')} | ${unit.unitTitle}"),
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
                      isBpmf: false,
                      unitId: unit.unitId,
                      unitTitle: unit.unitTitle,
                      word: unit.newWords[index],
                      sizedBoxWidth: 30,
                      sizedBoxHeight: 155,
                      fontSize: 48,
                    );
                  },
                  childCount: unit.newWords.length,
                ),
              ),
            ),
            (unit.extraWords.isEmpty)
                ? const SliverToBoxAdapter(child: Text(''))
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 0, 0),
                    sliver: SliverToBoxAdapter(
                        child: Text(
                      "唸唸看",
                      style: TextStyle(
                        color: "#F5F5DC".toColor(),
                        fontSize: 24,
                      ),
                    )),
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
                      word: unit.extraWords[index],
                      sizedBoxWidth: 30,
                      sizedBoxHeight: 155,
                      fontSize: 48,
                    );
                  },
                  childCount: unit.extraWords.length,
                ),
              ),
            ),
          ],
        ));
  }
}
