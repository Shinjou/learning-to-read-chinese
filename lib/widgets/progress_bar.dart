import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/view_utils.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.maxCount, required this.value});
  final int value;
  final int maxCount;
  // final iconSize = 58.0;

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double fontSize = getFontSize(context, 16); // Base font size
    double iconSize = fontSize * 2.0;
    return Column(
      children: [
        SizedBox(
          width: 0.87 * deviceWidth,
          height: iconSize, // 58,
          child: Stack(clipBehavior: Clip.none, children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 0.66 * deviceWidth,
                height: fontSize, // 24,
                decoration: BoxDecoration(
                    border: Border.all(color: '#F5F5DC'.toColor(), width: 3),
                    borderRadius: BorderRadius.circular(10)),
                child: LinearProgressIndicator(
                  backgroundColor: '#D9D9D9'.toColor(),
                  value: value/maxCount,
                  valueColor:
                      AlwaysStoppedAnimation<Color>('#F8A23A'.toColor()),
                ),
              ),
            ),
            Builder(builder: (context) {
              // double leftPadding = iconSize / 2 + 240 * value - iconSize / 2;
              double leftPadding = fontSize * 2 + 0.66 * deviceWidth * value / maxCount; // - iconSize / 2;
              double topPadding = iconSize / 2 - iconSize / 2;
              return Padding(
                  padding: EdgeInsets.only(left: leftPadding, top: topPadding),
                  child: Icon(Icons.star,
                      size: iconSize, color: '#F5F5DC'.toColor()));
            })
          ]),
        ),
        Container(
          width: 0.87 * deviceWidth,
          padding: const EdgeInsetsDirectional.only(start: 21, end: 11),
          child: Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(value.toString(),
                  style: TextStyle(
                    fontSize: fontSize, // 24,
                  )
                )
              ),
              Expanded(child: Container()),
              Text(
                maxCount.toString(),
                style: TextStyle(
                  fontSize: fontSize, // 24,
                )
              )
            ]
          ),
        )
      ],
    );
  }
}
