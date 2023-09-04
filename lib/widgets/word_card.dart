import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/teach_word_view.dart';
import 'package:ltrc/views/teach_bpmf_view.dart';

class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.word,
    required this.sizedBoxWidth,
    required this.sizedBoxHeight,
    required this.fontSize,
    required this.isBpmf,
  });

  final int unitId;
  final String unitTitle;
  final String word;
  final double sizedBoxWidth;
  final double sizedBoxHeight;
  final double fontSize;
  final bool isBpmf;
  // late String svg;

  @override
  Widget build(BuildContext context) {
    Future<String> readJson() async {
      final String response =
        await rootBundle.loadString('lib/assets/svg/$word.json');

      return response.replaceAll("\"", "\'");
    }

    return InkWell(
      onTap: () {
        // readJson().then((result) {
        //   svg = result;
        // });
        if (isBpmf) {
          // Navigator.of(context).pushNamed(
          //   '/teachWord', 
          //   arguments: {
          //     'svg': svg,
          //     'isBpmf': isBpmf,
          //     'char': word,
          //     'unitId': unitId,
          //     'unitTitle': unitTitle,
          //   },
          // );
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TeachBopomoView(
              isBpmf: isBpmf,
              char: word,
              unitId: unitId,
              unitTitle: unitTitle,
            )));
        } else {
          // Navigator.of(context).pushNamed(
          //   '/teachWord', 
          //   arguments: {
          //     'svg': svg,
          //     'isBpmf': isBpmf,
          //     'char': word,
          //     'unitId': unitId,
          //     'unitTitle': unitTitle,
          //   },
          // );
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TeachWordView(
              isBpmf: isBpmf,
              char: word,
              unitId: unitId,
              unitTitle: unitTitle,
          )));
        }
      },
      child: Container(
        width: sizedBoxWidth,
        height: sizedBoxHeight,
        decoration: BoxDecoration(
          color: "#F5F5DC".toColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              word,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                fontFamily: isBpmf ? "BpmfOnly" : "Serif",
              ),
            ),
          ],
        )));
  }
}
