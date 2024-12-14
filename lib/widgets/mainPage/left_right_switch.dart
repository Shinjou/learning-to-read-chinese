import 'package:flutter/material.dart';
import 'package:ltrc/views/view_utils.dart';

class LeftRightSwitch extends StatelessWidget {
  final double fontSize;
  final Color iconsColor;
  final double iconsSize;
  final bool rightBorder;
  final Widget middleWidget;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onLeftClicked;
  final VoidCallback? onRightClicked;

  const LeftRightSwitch({
    super.key,
    required this.fontSize,
    required this.iconsColor,
    required this.iconsSize,
    required this.rightBorder,
    required this.middleWidget,
    required this.isFirst,
    required this.isLast,
    this.onLeftClicked,
    this.onRightClicked,
  });

  @override
  Widget build(BuildContext context) {  
    final fontSize = this.fontSize;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        (!isFirst) ? IconButton(
          icon: Icon(
            Icons.chevron_left,
            shadows: const [
              Shadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 4)
            ],
            color: iconsColor,
          ),
          iconSize: iconsSize,
          onPressed: onLeftClicked ?? ()=>{},
        ) : Container(width: fontSize * 2.5,),
        middleWidget,
        (!isLast) ? Container(
          decoration: BoxDecoration(
            border: rightBorder ? Border.all(color: lightYellow, width: 1.2) : null,
          ),
          child: IconButton(
            icon: Icon(
              Icons.chevron_right,
              shadows: const [
                Shadow(color: Colors.black, offset: Offset(0, 6), blurRadius: 4)
              ],
              color: iconsColor,
            ),
            iconSize: iconsSize,
            onPressed: onRightClicked ?? ()=>{},
          )
        )
         : Container(width: fontSize * 2.5,),
      ],
    );
  }
}
