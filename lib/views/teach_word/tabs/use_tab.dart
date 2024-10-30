// lib/views/teach_word/tabs/use_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/views/teach_word/widgets/bpmf_vocal_content.dart';
import 'package:ltrc/views/teach_word/widgets/word_vocal_content.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';

class UseTab extends ConsumerStatefulWidget {
  final TeachWordControllers controllers;
  final TeachWordState state;
  final ScreenInfo screenInfo;
  final Map<String, dynamic> wordsPhrase;

  const UseTab({
    super.key,
    required this.controllers,
    required this.state,
    required this.screenInfo,
    required this.wordsPhrase,
  });

  @override
  UseTabState createState() => UseTabState();
}

class UseTabState extends ConsumerState<UseTab> {
  late final ValueNotifier<String> _userMessage;
  late final ValueNotifier<bool> _showContinueButton;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    debugPrint('UseTab initialized');
  }

  void _initializeControllers() {
    _userMessage = ValueNotifier('');
    _showContinueButton = ValueNotifier(false);
  }

  @override
  void dispose() {
    debugPrint('UseTab disposing');
    _userMessage.dispose();
    _showContinueButton.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building UseTab - nextStepId: ${widget.state.nextStepId}, vocabIndex: ${widget.state.vocabIndex}');
    
    return TeachWordTabBarView(
      content: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildContent(),
              ],
            ),
          ),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: widget.screenInfo.screenWidth * 0.95,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildHeader(),
          SizedBox(height: widget.screenInfo.fontSize * 0.2),
          _buildVocabContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {    
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: widget.screenInfo.fontSize * 2.0,
      rightBorder: _shouldShowRightBorder,
      middleWidget: const TeachWordCardTitle(
        sectionName: '用一用',
        iconsColor: lightGray,
      ),
      isFirst: false,
      isLast: _isLastVocabPage,
      onLeftClicked: _canNavigatePrevious ? () => _handlePrevious() : null,
      onRightClicked: _canNavigateNext ? () => _handleNext() : null,
    );
  }

  Widget _buildVocabContent() {
    if (widget.state.isBpmf) {
      return BopomofoVocabContent(
        word: widget.state.word,
        vocab: _getCurrentVocab(),
        sentence: _getCurrentSentence(),
      );
    } else {
      return Column(
        children: [
          WordVocabContent(
            vocab: _getCurrentVocab(),
            meaning: _getCurrentMeaning(),
            sentence: _getCurrentSentence(),
            vocab2: _getNextVocab(),
          ),
          _buildVocabImage(),
          ValueListenableBuilder<String>(
            valueListenable: _userMessage,
            builder: (context, message, child) {
              return _buildMessageAndContinueButton(message);
            },
          ),
        ],
      );
    }
  }

  Widget _buildVocabImage() {
    if (!widget.state.isBpmf && _imageExistsForCurrentVocab) {
      return SizedBox(
        height: widget.screenInfo.fontSize * 3.0,
        child: Image(
          height: widget.screenInfo.fontSize * 3.0,
          image: AssetImage('lib/assets/img/vocabulary/${_getCurrentVocab()}.webp'),
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading vocab image: $error');
            return const SizedBox.shrink();
          },          
        ),
      );
    }
    return SizedBox(height: widget.screenInfo.fontSize * 0.5);
  }

  Widget _buildMessageAndContinueButton(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.screenInfo.fontSize * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: TextStyle(
              color: explanationColor,
              fontSize: widget.screenInfo.fontSize,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showContinueButton,
            builder: (context, show, child) {
              return show ? _buildContinueButton() : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return TextButton(
      onPressed: _handleContinue,
      child: Text(
        '繼續',
        style: TextStyle(
          fontSize: widget.screenInfo.fontSize,
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      right: widget.screenInfo.fontSize,
      bottom: widget.screenInfo.fontSize,
      child: Text(
        "${widget.state.vocabIndex + 1} / ${widget.state.vocabCount}",
        style: TextStyle(
          fontSize: widget.screenInfo.fontSize * 0.75,
          fontWeight: FontWeight.normal,
          color: backgroundColor,
        ),
      ),
    );
  }

  // Helper methods
  String _getCurrentVocab() => widget.wordsPhrase['vocab${widget.state.vocabIndex + 1}'] ?? '';
  String _getCurrentMeaning() => widget.wordsPhrase['meaning${widget.state.vocabIndex + 1}'] ?? '';
  String _getCurrentSentence() => widget.wordsPhrase['sentence${widget.state.vocabIndex + 1}'] ?? '';
  String _getNextVocab() {
    int nextIndex = (widget.state.vocabIndex + 1) % widget.state.vocabCount + 1;
    return widget.wordsPhrase['vocab$nextIndex'] ?? '';
  }

  bool get _imageExistsForCurrentVocab => 
    widget.state.vocabIndex == 0 ? widget.state.img1Exists : widget.state.img2Exists;

  bool get _isLastVocabPage => 
    widget.state.vocabIndex == widget.state.vocabCount - 1;

  bool get _shouldShowRightBorder =>
    widget.state.vocabIndex == 0 && 
    widget.state.nextStepId == TeachWordConstants.steps['goToUse2'];

  bool get _canNavigatePrevious =>
    widget.state.isLearned || 
    (widget.state.vocabIndex == 0 
      ? widget.state.nextStepId == TeachWordConstants.steps['goToUse2'] 
      : true);

  bool get _canNavigateNext =>
    !_isLastVocabPage && 
    (widget.state.nextStepId == TeachWordConstants.steps['goToUse${widget.state.vocabIndex + 2}'] || 
     widget.state.isLearned);

  // Event handlers
  Future<void> _handlePrevious() async {
    debugPrint('UseTab handlePrevious called - vocabIndex: ${widget.state.vocabIndex}');
    if (widget.state.vocabIndex == 0) {
      widget.controllers.navigateToPreviousTab();
    } else {
      await _speakPreviousVocab();
      ref.read(teachWordStateProvider.notifier).updateVocabIndex(
        widget.state.vocabIndex - 1
      );
    }
  }

  Future<void> _handleNext() async {
    debugPrint('UseTab handleNext called - vocabIndex: ${widget.state.vocabIndex}');

    if (!_isLastVocabPage) {
      await _speakNextVocab();
      if (widget.state.nextStepId == TeachWordConstants.steps['goToUse${widget.state.vocabIndex + 2}']) {
        widget.controllers.navigateToNextTab();
      }
      ref.read(teachWordStateProvider.notifier).updateVocabIndex(
        widget.state.vocabIndex + 1
      );
    }
  }

  void _handleContinue() {
    debugPrint('UseTab handleContinue called');
    setState(() {
      _userMessage.value = '';
      _showContinueButton.value = false;
    });
  }

  Future<void> _speakPreviousVocab() async {
    String prevVocab = widget.wordsPhrase['vocab${widget.state.vocabIndex}'];
    String prevSentence = widget.wordsPhrase['sentence${widget.state.vocabIndex}'];
    final tts = ref.read(ttsProvider);
    await tts.speak("$prevVocab。$prevSentence");
  }

  Future<void> _speakNextVocab() async {
    String nextVocab = widget.wordsPhrase['vocab${widget.state.vocabIndex + 2}'];
    String nextSentence = widget.wordsPhrase['sentence${widget.state.vocabIndex + 2}'];
    final tts = ref.read(ttsProvider);
    await tts.speak("$nextVocab。$nextSentence");
  }
}

