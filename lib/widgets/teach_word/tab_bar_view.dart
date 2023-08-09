import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

import '../mainPage/left_right_switch.dart';

class TeachWordTabBarView extends StatelessWidget {
  const TeachWordTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height*0.6,
          width: MediaQuery.of(context).size.width,
          child: Container(
            decoration: BoxDecoration(
              color: '#F5F5DC'.toColor(),
              border: Border(
                top: BorderSide(width: 6, color: '#999999'.toColor(),),
                left: BorderSide(width: 6, color: '#999999'.toColor(),),
                right: BorderSide(width: 6, color: '#999999'.toColor(),),
                bottom: BorderSide(width: 6, color: '#999999'.toColor(),),
                )
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LeftRightSwitch(iconsColor: '#D9D9D9'.toColor(), iconsSize: 35)
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_left,
              color: '#F5F5DC'.toColor(),
              size: 48,
            ),
            // TODO: Box with image inside
            Icon(
              Icons.chevron_right,
              color: '#F5F5DC'.toColor(),
              size: 48,
            ),
          ],
        )
      ],
    );
  }
}