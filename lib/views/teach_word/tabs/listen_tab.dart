// ./lib/views/teach_word/tabs/listen_tab.dart


// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';

class ListenTab extends ConsumerWidget {
  final TeachWordControllers controllers;
  final TeachWordState state;
  final ScreenInfo screenInfo;

  const ListenTab({
    super.key,
    required this.controllers,
    required this.state,
    required this.screenInfo,
  });

  String get word => state.word;
  bool get isBpmf => state.isBpmf;  

  @override  
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('ListenTab build - nextStepId: ${state.nextStepId}, isLearned: ${state.isLearned}');
        
    return TeachWordTabBarView(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenInfo.screenHeight * 0.9,
                maxWidth: screenInfo.screenWidth * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildListenHeader(ref),
                  SizedBox(height: screenInfo.fontSize * 0.3),
                  _buildListenWord(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListenHeader(WidgetRef ref) {
    final canNavigatePrevious = _canNavigatePrevious;
    final canNavigateNext = _canNavigateNext;
    
    debugPrint('ListenTab header - canNavigatePrevious: $canNavigatePrevious, canNavigateNext: $canNavigateNext');
    debugPrint('Current nextStepId: ${state.nextStepId}, Write step: ${TeachWordConstants.steps['goToWrite']}');

    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: screenInfo.fontSize * 2.0,
      rightBorder: state.nextStepId == TeachWordConstants.steps['goToWrite'],
      middleWidget: const TeachWordCardTitle(
        sectionName: '聽一聽',
        iconsColor: lightGray,
      ),
      isFirst: false,
      isLast: false,
      onLeftClicked: canNavigatePrevious ? () => _handlePrevious(ref) : null,
      onRightClicked: canNavigateNext ? () => _handleNext(ref) : null,
    );
  }

  Widget _buildListenWord(WidgetRef ref) {
    return SizedBox(
      height: (screenInfo.screenHeight * 0.4),
      width: screenInfo.screenWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(color: darkBrown),
            child: Center(
              child: GestureDetector(
                onTap: () {    // Changed to a closure
                  _playWordSound(ref);  // Don't await here
                },                
                child: Text(
                  state.word,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenInfo.fontSize * 8.0,
                    color: backgroundColor,
                    fontWeight: FontWeight.w100,
                    fontFamily: state.isBpmf ? "BpmfOnly" : "BpmfIansui",
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: screenInfo.fontSize,
            child: IconButton(
              icon: Icon(
                Icons.volume_up,
                size: screenInfo.fontSize * 2.0,
                color: backgroundColor,
              ),
              onPressed: () {    // Changed to a closure
                _playWordSound(ref);  // Don't await here
              },                          
            ),
          ),
        ],
      ),
    );
  }

  bool get _canNavigatePrevious {
    final bool canNavigate = state.nextStepId >= TeachWordConstants.steps['goToWrite']! || 
                            state.isLearned;
    debugPrint('_canNavigatePrevious: $canNavigate (nextStepId: ${state.nextStepId}, isLearned: ${state.isLearned})');
    return canNavigate;
  }

  bool get _canNavigateNext {
    final bool canNavigate = state.nextStepId >= TeachWordConstants.steps['goToWrite']! || 
                            state.isLearned;
    debugPrint('_canNavigateNext: $canNavigate (nextStepId: ${state.nextStepId}, isLearned: ${state.isLearned})');
    return canNavigate;
  }

  Future<void> _playWordSound(WidgetRef ref) async {
    final audioService = ref.read(audioServiceProvider);
    audioService.playWordSound(word, isBpmf);
    debugPrint('_playWordSound: ${state.word}');
  }

  Future<void> _handlePrevious(WidgetRef ref) async {
    debugPrint('ListenTab _handlePrevious called');
    controllers.navigateToPreviousTab();
  }

  Future<void> _handleNext(WidgetRef ref) async {
    debugPrint('ListenTab _handleNext called - nextStepId: ${state.nextStepId}');
    // Increment step before navigation
    ref.read(teachWordStateProvider.notifier).incrementNextStepId();
    
    await _playWordSound(ref);
    controllers.navigateToNextTab();
  }
}

