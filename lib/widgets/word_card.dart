import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/extensions.dart';
// import 'package:ltrc/providers.dart';
// import 'package:ltrc/views/teach_word_view.dart';
import 'package:ltrc/views/view_utils.dart';  // Make sure this import is correct

class WordCard extends ConsumerStatefulWidget {
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

class WordCardState extends ConsumerState<WordCard> {
  
  bool liked = false;

  @override void initState() {
    liked = widget.wordsStatus[widget.wordIndex].liked;
    super.initState();
  }

  void _toggleLiked() {
    setState(() {
      liked = !liked;
    });
    WordStatus newStatus = widget.wordsStatus[widget.wordIndex];
    newStatus.liked = liked;
    // Use WidgetsBinding to schedule the update after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WordStatusProvider.updateWordStatus(status: newStatus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.disable ? null : () {
        debugPrint('WordCard tapped. Attempting to navigate to teachWord page');
        navigateWithProvider(
          context,
          '/teachWord',
          ref,
          arguments: {
            'unitId': widget.unitId,
            'unitTitle': widget.unitTitle,
            'wordsStatus': widget.wordsStatus,
            'wordsPhrase': widget.wordsPhrase,
            'wordIndex': widget.wordIndex,
          },
        );
        debugPrint('Navigation to teachWord page initiated');
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
              alignment: widget.isVertical ? Alignment.topRight : Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, widget.fontSize * 0.25, 0),
                child: 
                  Wrap(
                    direction: !widget.isVertical ? Axis.vertical : Axis.horizontal,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children:[
                      IconButton(
                        icon: liked ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
                        iconSize: widget.fontSize * 0.5,
                        color: liked ? "#FF0303".toColor() : "#999999".toColor(),
                        onPressed: _toggleLiked,
                      ),
                      Icon(
                        widget.wordsStatus[widget.wordIndex].learned ? Icons.check_circle : Icons.circle_outlined,
                        size: widget.fontSize * 0.5,
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