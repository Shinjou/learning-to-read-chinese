// lib/teach_word/presentation/widgets/tabs/use_tab.dart

// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
// import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';
// import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
// import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
// import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';


class UseTab extends ConsumerStatefulWidget {
  final int widgetId; // Debug identifier
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;
  final VoidCallback onNextTab;
  final VoidCallback onPreviousTab;
  final VoidCallback onPlayAudio;
  final TabController tabController;
  final bool isBpmf;
  final bool svgFileExist;
  final bool wordIsLearned;
  final bool img1Exist;
  final bool img2Exist;
  final int vocabCnt;
  final Map wordObj;

  const UseTab({
    super.key,
    required this.widgetId,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
    required this.onNextTab,
    required this.onPreviousTab,
    required this.onPlayAudio,
    required this.tabController,
    required this.isBpmf,
    required this.svgFileExist,
    required this.wordIsLearned,
    required this.img1Exist,
    required this.img2Exist,
    required this.vocabCnt,
    required this.wordObj,
  });

  @override
  UseTabState createState() => UseTabState();
}

class UseTabState extends ConsumerState<UseTab> {
  // Core state variables
  late FlutterTts ftts;
  late double fontSize;
  late double deviceWidth;
  bool _isInitialized = false;

  // Navigation state
  int vocabIndex = 0;
  int nextStepId = 0;
  bool isLastPage = false;
  bool hasSpoken = false;

  // Word-specific state
  late String vocab;
  late String vocab2;
  late String meaning;
  late String sentence;
  late String blankSentence;
  late String displayedSentence;
  late List<String> options;
  String message = '';
  bool isAnswerCorrect = false;
  late int pageIndex;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    debugPrint('UseTabState.initState called for widgetId: ${widget.widgetId}');
  }

  void _initializeComponents() {
    ftts = ref.read(ttsProvider);
    pageIndex = 0;
    _initVariables(pageIndex); // Start with first page

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!hasSpoken) _handleGoToUse();
      setState(() => _isInitialized = true);
    });
  }

  @override
  void dispose() {
    debugPrint('UseTabState.dispose called for widgetId: ${widget.widgetId}');
    super.dispose();
  }

  void _initVariables(int pageIndex) {


    vocabIndex = pageIndex.clamp(0, widget.vocabCnt - 1);
    vocab = widget.wordObj['vocab${pageIndex + 1}'] ?? '';
    vocab2 = widget.wordObj['vocab${(pageIndex + 1) % widget.vocabCnt + 1}'] ?? '';
    meaning = widget.wordObj['meaning${pageIndex + 1}'] ?? '';
    sentence = widget.wordObj['sentence${pageIndex + 1}'] ?? '';
    blankSentence = _createBlankSentence(sentence, vocab);
    displayedSentence = blankSentence;
    options = [vocab, vocab2]..shuffle();
    message = '';
    isAnswerCorrect = false;
    isLastPage = (pageIndex == widget.vocabCnt - 1);
    nextStepId = pageIndex == 0
        ? TeachWordSteps.steps['goToUse1']!
        : TeachWordSteps.steps['goToUse2']!;
    hasSpoken = false;

    debugPrint(
      'Initialized: pageIndex=$pageIndex, vocabIndex=$vocabIndex, vocabCnt=${widget.vocabCnt}, vocab=$vocab, '
      'meaning=$meaning, isLastPage=$isLastPage',
    );
  }

  String _createBlankSentence(String sentence, String vocab) {
    return sentence.replaceAll(vocab, "__" * vocab.length);
  }

  Future<void> _handleGoToUse() async {
    debugPrint('_handleGoToUse hasSpoken=$hasSpoken, vocabCnt=${widget.vocabCnt}, vocabIndex=$vocabIndex, nextStepId=$nextStepId');
    if (hasSpoken) return; // Prevent multiple calls
    hasSpoken = true;    
    await handleGoToUse(widget.vocabCnt, vocabIndex, nextStepId, widget.wordObj, ftts);
    /*
    try {
      switch (widget.vocabCnt) {
        case 1:
          await ftts.speak("${widget.wordObj['vocab1']}。${widget.wordObj['sentence1']}");
          break;
        case 2:
          final step = vocabIndex == 0 ? 'goToUse1' : 'goToUse2';
          debugPrint('nextId=${TeachWordSteps.steps[step]}, vocab1: ${widget.wordObj['vocab1']}, vocab2: ${widget.wordObj['vocab2']}');
          if (TeachWordSteps.steps[step] == 8) {
            await ftts.speak("${widget.wordObj['vocab1']}。${widget.wordObj['sentence1']}");
          } else {
            await ftts.speak("${widget.wordObj['vocab2']}。${widget.wordObj['sentence2']}");
          }
          break;
        default:
          debugPrint('Unexpected vocabCnt: ${widget.vocabCnt}');
      }
    } catch (e) {
      debugPrint('Error in _handleGoToUse: $e');
    }
    */
  }

  Future<void> _speak(String text) async {
    await ftts.speak(text);
  }

  void _selectWord(String word) {
    _speak(word);
    setState(() {
      if (word == vocab) {
        displayedSentence = sentence;
        message = '答對了！';
        isAnswerCorrect = true;
        updateWordStatus(context, ref, widget.wordsStatus[widget.wordIndex], true);
      } else {
        displayedSentence = blankSentence;
        message = '再試試！';
        isAnswerCorrect = false;
      }
    });
    _speak(message);
  }

  void _onContinuePressed() {
    if (isLastPage) {
      widget.onNextTab();
    } else {
      setState(() {
        vocabIndex++;
        hasSpoken = false; // Reset for the next page
        _initVariables(vocabIndex);
      });
      _handleGoToUse();
    }
  }

  Widget _buildVocabularySection() {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZhuyinProcessing(
            text: vocab,
            fontSize: fontSize * 1.2,
            color: explanationColor,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            iconSize: fontSize * 1.2,
            color: explanationColor,
            onPressed: () => _speak(vocab),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningSection() {
    return Padding(
      padding: EdgeInsets.only(left: fontSize * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "解釋：",
                style: TextStyle(
                  fontSize: fontSize,
                  color: explanationColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                iconSize: fontSize,
                color: explanationColor,
                onPressed: () => _speak(meaning),
              ),
            ],
          ),
          ZhuyinProcessing(
            text: meaning,
            fontSize: fontSize,
            color: whiteColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceSection() {
    return Padding(
      padding: EdgeInsets.only(left: fontSize * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "例句：",
                style: TextStyle(
                  fontSize: fontSize,
                  color: explanationColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                iconSize: fontSize,
                color: explanationColor,
                onPressed: () => _speak(sentence),
              ),
            ],
          ),
          ZhuyinProcessing(
            text: displayedSentence,
            fontSize: fontSize,
            color: whiteColor,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((option) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: fontSize * 0.25),
              child: ElevatedButton(
                onPressed: () => _selectWord(option),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: fontSize * 0.5),
                ),
                child: Text(
                  option,
                  style: TextStyle(fontSize: fontSize),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Padding(
      padding: EdgeInsets.only(top: fontSize * 0.5),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isAnswerCorrect ? Colors.green : Colors.red,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _goToNextCharacter() {

    int nextIndex;
    if (widget.wordIndex < widget.wordsStatus.length - 1) {
      // Not the last character, go to next character
      nextIndex = widget.wordIndex + 1;
    } else {
      // Last character, go back to first character
      nextIndex = 0;
    }

    // Navigate to TeachWordView with the new index
    navigateWithProvider(
      context,
      '/teachWord',
      ref,
      arguments: {
        'unitId': widget.unitId,
        'unitTitle': widget.unitTitle,
        'wordsStatus': widget.wordsStatus,
        'wordsPhrase': widget.wordsPhrase,
        'wordIndex': nextIndex,
        'widgetId': widget.widgetId,
      },
    );

    return Container();

  }
  

  Widget _buildUseTabPage() {
    return TeachWordTabBarView(
      content: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: deviceWidth * 0.9,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      _buildNavigationSwitch(),
                      SizedBox(height: fontSize),
                      _buildVocabularySection(),
                      _buildMeaningSection(),
                      SizedBox(height: fontSize * 0.5),
                      _buildSentenceSection(),
                      SizedBox(height: fontSize),
                      _buildOptionsSection(),
                      if (message.isNotEmpty) _buildFeedbackSection(),
                      if (isLastPage && isAnswerCorrect)
                        Padding(
                          padding: EdgeInsets.only(top: fontSize),
                          child: ElevatedButton(
                            onPressed: _goToNextCharacter,
                            child: Text("下一字", style: TextStyle(fontSize: fontSize)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildNavigationSwitch() {
    return LeftRightSwitch(
      fontSize: fontSize,
      iconsColor: lightGray,
      iconsSize: fontSize * 1.5,
      rightBorder: isAnswerCorrect && vocabIndex == 0,
      /*
      middleWidget: Text( 
        '用一用',
        style: TextStyle(
          color: lightGray,
          fontSize: fontSize * 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
      */  
      middleWidget: ZhuyinProcessing(
        text: '用一用',
        color: lightGray,
        fontSize: fontSize * 1.2,        
        fontWeight: FontWeight.bold,  // Optional font weight
        centered: true,  // Optional centering
      ),            
      isFirst: false,
      isLast: isLastPage,
      onLeftClicked: vocabIndex > 0
          ? () {
              setState(() {
                vocabIndex--;
                _initVariables(vocabIndex);
              });
              _handleGoToUse();
            }
          : null,
      onRightClicked: isAnswerCorrect && !isLastPage ? _onContinuePressed : null,
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      right: fontSize,
      bottom: fontSize,
      child: Text(
        "${vocabIndex + 1} / ${widget.vocabCnt}",
        style: TextStyle(
          fontSize: fontSize * 0.75,
          fontWeight: FontWeight.normal,
          color: backgroundColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.read(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    deviceWidth = screenInfo.screenWidth;    
    debugPrint('UseTab: Building with fontSize $fontSize, widgetId: ${widget.widgetId}, vocabCnt=${widget.vocabCnt}, vocabIndex=$vocabIndex');

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.vocabCnt <= 0) {
      return Center(
        child: Text(
          '沒有字詞資料',
          style: TextStyle(color: Colors.red, fontSize: fontSize),
        ),
      );
    }

    return _buildUseTabPage();
  }
}

