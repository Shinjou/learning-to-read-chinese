import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class LeftRightSwitch extends StatelessWidget {
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
        ) : Container(width: 40,),
        middleWidget,
        (!isLast) ? Container(
          decoration: BoxDecoration(
            border: rightBorder ? Border.all(color: '#FFFF93'.toColor(), width: 1.5) : null,
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
         : Container(width: 40,),
      ],
    );
  }
}
