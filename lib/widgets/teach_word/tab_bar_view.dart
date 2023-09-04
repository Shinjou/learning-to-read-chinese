import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/word_card.dart';

import '../mainPage/left_right_switch.dart';
import 'card_title.dart';

class TeachWordTabBarView extends ConsumerWidget {
  final Widget content;
  final String word;
  final String sectionName;
  final bool isBpmf;
  const TeachWordTabBarView({
    Key? key,
    required this.sectionName,
    required this.word,
    required this.content,
    required this.isBpmf,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.68,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: '#28231D'.toColor(),
            border: Border.all(color: '#999999'.toColor(), width: 6),
          ),
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
                  sectionName: sectionName, iconsColor: '#D9D9D9'.toColor()),
              ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    ]);
  }
}
