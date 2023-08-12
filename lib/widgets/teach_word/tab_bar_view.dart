import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

import '../mainPage/left_right_switch.dart';
import 'card_title.dart';

class TeachWordTabBarView extends StatelessWidget {
  final Widget content;
  final String sectionName;
  const TeachWordTabBarView({
    Key? key,
    required this.sectionName,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width,
          child: Container(
            decoration: BoxDecoration(
                color: '#28231D'.toColor(),
                border: Border(
                  top: BorderSide(
                    width: 6,
                    color: '#999999'.toColor(),
                  ),
                  left: BorderSide(
                    width: 6,
                    color: '#999999'.toColor(),
                  ),
                  right: BorderSide(
                    width: 6,
                    color: '#999999'.toColor(),
                  ),
                  bottom: BorderSide(
                    width: 6,
                    color: '#999999'.toColor(),
                  ),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                LeftRightSwitch(
                  iconsColor: '#D9D9D9'.toColor(),
                  iconsSize: 35,
                  middleWidget: TeachWordCardTitle(
                      sectionName: sectionName,
                      iconsColor: '#D9D9D9'.toColor()),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 45,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_left,
              color: '#F5F5DC'.toColor(),
              size: 48,
            ),
            // IconButton(
            //   icon: const Icon(Icons.chevron_left),
            //   color: '#F5F5DC'.toColor(),
            //   iconSize: 48,
            //   onPressed: () =>
            //       _tabController.animateTo((_tabController.index - 1) % 4),
            // ),
            Image(
              height: 88,
              image:
                  AssetImage('lib/assets/img/char_view/' + demoChar + '.png'),
            ),
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
