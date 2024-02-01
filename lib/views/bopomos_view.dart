import 'package:flutter/material.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/extensions.dart';
import '../widgets/word_card.dart';

class BopomosView extends StatelessWidget {
  const BopomosView({super.key});

  @override
  Widget build(BuildContext context) {
    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    List<WordStatus> wordsStatus = obj['wordStatus']; 
    List<Map> wordsPhrase = obj['wordsPhrase']; 

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("00 | 學注音"),
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
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 125.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 113 / 166,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return WordCard(
                    disable: false,
                    isBpmf: true,
                    unitId: 0,
                    unitTitle: "學注音",
                    wordsStatus: wordsStatus,
                    wordsPhrase: wordsPhrase,
                    wordIndex: index,
                    sizedBoxWidth: 30,
                    sizedBoxHeight: 155,
                    fontSize: 48,
                    isVertical: true,
                  );
                },
                childCount: wordsStatus.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(46, 16, 46, 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int idx) {
                  return InkWell(
                    onTap: () => Navigator.of(context).pushNamed('/bopomoQuiz'),
                    child: Container(
                      width: 297,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                          const BorderRadius.all(Radius.circular(14)),
                        color: "#F5F5DC".toColor(),
                      ),
                      child: Text(
                        "拼拼看",
                        style: TextStyle(
                          fontSize: 32,
                          color: "#28231D".toColor(),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
                childCount: 1,
              )),
          ),
        ],
      ));
  }
}
