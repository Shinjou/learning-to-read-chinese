import 'package:flutter/material.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/teach_word_view.dart';

class WordCard extends StatefulWidget {
  const WordCard({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
    required this.sizedBoxWidth,
    required this.sizedBoxHeight,
    required this.fontSize,
    required this.isBpmf,
    required this.isVertical,
    required this.disable
  });

  final int unitId;
  final String unitTitle;
  final double sizedBoxWidth;
  final double sizedBoxHeight;
  final double fontSize;
  final bool isBpmf;
  final List<WordStatus> wordsStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;
  final bool isVertical;
  final bool disable;
  
  @override
  WordCardState createState() => WordCardState();
}

class WordCardState extends State<WordCard> {
  
  bool liked = false;

  @override void initState() {
    liked = widget.wordsStatus[widget.wordIndex].liked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.disable ? () {} : () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TeachWordView(
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            wordIndex: widget.wordIndex,
        )));
      },
      child: Container(
        width: widget.sizedBoxWidth,
        height: widget.sizedBoxHeight,
        decoration: BoxDecoration(
          color: widget.wordsStatus[widget.wordIndex].learned ? "#F8F88E".toColor():"#F5F5DC".toColor(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Wrap(
          direction: !widget.isVertical ? Axis.vertical : Axis.horizontal,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
             Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: 
                  Wrap(
                    direction: !widget.isVertical ? Axis.vertical : Axis.horizontal,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children:[
                      IconButton(
                        icon: liked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                        iconSize: widget.fontSize,
                        color: liked ? "#FF0303".toColor() : "#999999".toColor(),
                        onPressed: () async {
                          setState(() {
                            liked = !liked;
                          });
                          WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
                          newStatus.liked = liked;
                          await WordStatusProvider.updateWordStatus(
                            status: newStatus
                          );
                        },
                      ),
                      Icon(
                        widget.wordsStatus[widget.wordIndex].learned ? Icons.check_circle : Icons.circle_outlined,
                        size: widget.fontSize,
                        color: widget.wordsStatus[widget.wordIndex].learned ? "#F8A339".toColor() : "#999999".toColor(),
                      ),
                    ]
                  ),
              ),
            ),
            Text(
              widget.wordsStatus[widget.wordIndex].word, 
              style: TextStyle(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        )));
  }
}

