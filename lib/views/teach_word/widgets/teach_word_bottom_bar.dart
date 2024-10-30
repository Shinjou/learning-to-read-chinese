// lib/views/teach_word/widgets/teach_word_bottom_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/word_card.dart';

class TeachWordBottomBar extends ConsumerWidget {
  final ScreenInfo screenInfo;
  final TeachWordControllers controllers;
  final TeachWordState state;
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;

  const TeachWordBottomBar({
    super.key,
    required this.screenInfo,
    required this.controllers,
    required this.state,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // Added WidgetRef parameter
    return BottomAppBar(
      height: screenInfo.fontSize * 4.0,
      elevation: 0,
      color: darkBrown,
      child: _buildBottomBarContent(context, ref),
    );
  }

  Widget _buildBottomBarContent(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenInfo.screenWidth,
      ),
      child: _buildNavigationBar(context, ref),
    );
  }

  Widget _buildNavigationBar(BuildContext context, WidgetRef ref) {
    return LeftRightSwitch(
      iconsColor: beige,
      iconsSize: screenInfo.fontSize * 2.0,
      rightBorder: false,
      middleWidget: _buildWordCard(),
      isFirst: (wordIndex == 0),
      isLast: (wordIndex == wordsStatus.length - 1),
      onLeftClicked: _buildLeftClickHandler(context, ref),
      onRightClicked: _buildRightClickHandler(context, ref),
    );
  }

  Widget _buildWordCard() {
    return WordCard(
      unitId: unitId,
      unitTitle: unitTitle,
      wordsStatus: wordsStatus,
      wordsPhrase: wordsPhrase,
      wordIndex: wordIndex,
      sizedBoxWidth: screenInfo.fontSize * 10,
      sizedBoxHeight: screenInfo.fontSize * 4.0,
      fontSize: screenInfo.fontSize * 1.2,
      isBpmf: state.isBpmf,
      isVertical: false,
      disable: true,
    );
  }

  VoidCallback? _buildLeftClickHandler(BuildContext context, WidgetRef ref) {
    if (wordIndex == 0) return null;

    return () => navigateWithProvider(
      context,
      '/teachWord',
      ref,
      arguments: {
        'unitId': unitId,
        'unitTitle': unitTitle,
        'wordsStatus': wordsStatus,
        'wordsPhrase': wordsPhrase,
        'wordIndex': wordIndex - 1,
      },
    );
  }

  VoidCallback? _buildRightClickHandler(BuildContext context, WidgetRef ref) {
    if (wordIndex == wordsStatus.length - 1) return null;

    return () => navigateWithProvider(
      context,
      '/teachWord',
      ref,
      arguments: {
        'unitId': unitId,
        'unitTitle': unitTitle,
        'wordsStatus': wordsStatus,
        'wordsPhrase': wordsPhrase,
        'wordIndex': wordIndex + 1,
      },
    );
  }
}

