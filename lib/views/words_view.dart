import 'package:flutter/material.dart';
import '../widgets/word_card.dart';

class WordsView extends StatelessWidget {
  const WordsView({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> newWords;
    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    newWords = obj["newWords"];

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("01|拍拍手"),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => {},
            )
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: CustomScrollView(
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 125.0,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 10.0,
                    childAspectRatio: 113 / 160,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return WordCard(
                        word: newWords[index],
                        sizedBoxWidth: 30,
                        sizedBoxHeight: 155,
                        fontSize: 48,
                      );
                    },
                    childCount: newWords.length,
                  ),
                ),
              ],
            )));
  }
}
