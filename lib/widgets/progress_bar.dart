import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.maxCount, required this.value});
  final double value;
  final int maxCount;
  final iconSize = 58.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 298,
          height: 58,
          child: Stack(clipBehavior: Clip.none, children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 240,
                height: 24,
                decoration: BoxDecoration(
                    border: Border.all(color: '#F5F5DC'.toColor(), width: 3),
                    borderRadius: BorderRadius.circular(10)),
                child: LinearProgressIndicator(
                  backgroundColor: '#D9D9D9'.toColor(),
                  value: value,
                  valueColor:
                      AlwaysStoppedAnimation<Color>('#F8A23A'.toColor()),
                ),
              ),
            ),
            Builder(builder: (context) {
              double leftPadding = iconSize / 2 + 240 * value - iconSize / 2;
              double topPadding = 58 / 2 - iconSize / 2;
              return Padding(
                  padding: EdgeInsets.only(left: leftPadding, top: topPadding),
                  child: Icon(Icons.star,
                      size: iconSize, color: '#F5F5DC'.toColor()));
            })
          ]),
        ),
        Container(
          width: 298,
          height: 25,
          padding: const EdgeInsetsDirectional.only(start: 21, end: 11),
          child: Row(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('0',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Iceberg'
                  )
                )
              ),
              Expanded(child: Container()),
              Text(
                maxCount.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'Iceberg'
                )
              )
            ]
          ),
        )
      ],
    );
  }
}
