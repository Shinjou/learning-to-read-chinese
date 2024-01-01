import 'package:flutter/material.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/extensions.dart';
import '../widgets/word_card.dart';
import '../views/view_utils.dart';

class BopomosView extends StatelessWidget {
  const BopomosView({super.key});

  @override
  Widget build(BuildContext context) {
    double fontSize = getFontSize(context, 16); // 16 is the base font size for 360dp width

    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    List<WordStatus> wordsStatus = obj['wordStatus']; 
    List<Map> wordsPhrase = obj['wordsPhrase']; 

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: fontSize * 0.75),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "00 | 學注音",
          style: TextStyle(fontSize: fontSize * 0.75), // Set the font size for the title
        ),        
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
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isTablet(context) ? fontSize * 3.0 : fontSize * 6.0, // This is most important
                mainAxisSpacing: fontSize * 0.5, // Reduced spacing
                crossAxisSpacing: fontSize * 0.5, // Reduced spacing
                childAspectRatio: 1 / 1.5, // Adjusted for a tighter fit (you might need to experiment with this value)
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
                    sizedBoxWidth: fontSize * 1.0, // 1.8 This may need to be adjusted if the cards are still too wide
                    sizedBoxHeight: fontSize * 1.0, // 9.1 This may need to be adjusted if the cards are still too tall
                    fontSize: fontSize * 2.0, // Ensure this is appropriate for the size of the cards
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
                      width: fontSize * 17.5,
                      height: fontSize * 4.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                          const BorderRadius.all(Radius.circular(14)),
                        color: "#F5F5DC".toColor(),
                      ),
                      child: Text(
                        "拼拼看",
                        style: TextStyle(
                          fontSize: fontSize * 2.0,
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
