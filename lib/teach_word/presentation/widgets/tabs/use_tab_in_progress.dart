// lib/teach_word/presentation/widgets/tabs/use_tab.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';


class UseTab extends ConsumerStatefulWidget {
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

class UseTabState extends ConsumerState<UseTab> with TickerProviderStateMixin {
  String word = '';
  bool isBpmf = false;
  bool svgFileExist = false;
  bool wordIsLearned = false;
  late TabController tabController;
  int nextStepId = 0;
  int vocabCnt = 0;
  Map wordObj = {};
  late FlutterTts ftts;
  late AudioPlayer player;
  double fontSize = 16.0;
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);  
  bool img1Exist = false;
  bool img2Exist = false;



  // Local state
  int practiceTimeLeft = 4; // ??? why here, not WriteTab?
  late String vocab;
  late String vocab2;
  late String meaning;
  late String sentence;
  late String displayedSentence;
  late List<String> options;
  late String message;
  late String blankSentence;
  int vocabIndex = 0;  
  bool isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    ftts = ref.read(ttsProvider);
    player = ref.read(audioPlayerProvider);    
    _initVariables(vocabIndex); // Initialize with the first vocabulary entry
  }

  void _initVariables(int pageIndex) {    
    word = widget.wordsStatus[widget.wordIndex].word;     
    isBpmf = widget.isBpmf;
    svgFileExist = widget.svgFileExist;
    wordIsLearned = widget.wordIsLearned; 
    tabController = widget.tabController;
    img1Exist = widget.img1Exist;
    img2Exist = widget.img2Exist;
    vocabCnt = widget.vocabCnt;
    wordObj = widget.wordObj;

    nextStepId = TeachWordSteps.steps['goToUse1']!;
    // new code needed to merge WordVocabContentState into UseTabState
    vocab = widget.wordObj['vocab${pageIndex + 1}'] ?? '';
    vocab2 = widget.wordObj['vocab${(pageIndex + 1) % widget.vocabCnt + 1}'] ?? '';
    meaning = widget.wordObj['meaning${pageIndex + 1}'] ?? '';
    sentence = widget.wordObj['sentence${pageIndex + 1}'] ?? '';
    blankSentence = _createBlankSentence(sentence, vocab);
    displayedSentence = blankSentence;
    options = [vocab, vocab2]..shuffle();
    message = '';
    isAnswerCorrect = false;
  }

  String _createBlankSentence(String sentence, String vocab) {
    int vocabLength = vocab.length;
    String underscoreString = "__" * vocabLength;
    return sentence.replaceAll(vocab, underscoreString);
  }

  Future<void> _speak(String text) async {
    int result = await ftts.speak(text);
    debugPrint(result == 1 ? 'TTS succeeded: $text' : 'TTS failed: $text');
  }

  void _selectWord(String word) {
    _speak(word);
    if (word == vocab) {
      setState(() {
        displayedSentence = sentence;
        message = '答對了！';
        isAnswerCorrect = true;
      });
    } else {
      setState(() {
        displayedSentence = blankSentence;
        message = '再試試！';
        isAnswerCorrect = false;
      });
    }
    _speak(message);
  }

  void _onContinuePressed() {
    setState(() {
      vocabIndex++;
      if (vocabIndex < widget.vocabCnt) {
        _initVariables(vocabIndex); // Move to the next vocabulary entry
      } else {
        // Reset or handle end of vocab list if needed
        vocabIndex = 0;
        _initVariables(vocabIndex);
      }
    });
  }

  PreferredSize _buildAppBar(double deviceWidth, double fontSize) {
    return PreferredSize(
      preferredSize: Size(deviceWidth, kToolbarHeight * 2),
      child: AppBar(
        title: Text(
          widget.unitId == -1 ? widget.unitTitle : "Unit ${widget.unitId} | ${widget.unitTitle}",
          style: TextStyle(fontSize: fontSize * 1.2, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: fontSize * 1.5),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => navigateWithProvider(context, '/mainPage', ref),
            icon: Icon(Icons.home_filled, color: Colors.white, size: fontSize * 1.5),
          ),
        ],
      ),
    );
  }
  
  /*
  Widget _buildTabPage(double fontSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LeftRightSwitch navigation component
        LeftRightSwitch(
          fontSize: fontSize,
          iconsColor: Colors.grey,
          iconsSize: fontSize * 1.5,
          isFirst: vocabIndex == 0,
          isLast: vocabIndex == widget.vocabCnt - 1,
          middleWidget: Text(
            '用一用',
            style: TextStyle(
              color: Colors.grey,
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          onLeftClicked: vocabIndex > 0
              ? () {
                  setState(() {
                    vocabIndex--;
                    _initVariables(vocabIndex); // Go to previous page
                  });
                }
              : null,
          onRightClicked: isAnswerCorrect && vocabIndex < widget.vocabCnt - 1
              ? () {
                  _onContinuePressed(); // Move to the next page only if the answer is correct
                }
              : null,
        ),
        // Vocabulary display with TTS button
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vocab,
              style: TextStyle(fontSize: fontSize * 1.2),
            ),
            IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () => _speak(vocab),
            ),
          ],
        ),
        // Meaning display with TTS button
        Padding(
          padding: EdgeInsets.only(left: fontSize * 0.5),
          child: Row(
            children: [
              Text(
                "解釋：$meaning",
                style: TextStyle(fontSize: fontSize),
              ),
              IconButton(
                icon: Icon(Icons.volume_up),
                onPressed: () => _speak(meaning),
              ),
            ],
          ),
        ),
        // Sentence with blank (underscore) where vocab should be
        Padding(
          padding: EdgeInsets.only(left: fontSize * 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("例句：", style: TextStyle(fontSize: fontSize)),
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () => _speak(sentence),
                  ),
                ],
              ),
              Text(
                displayedSentence,
                style: TextStyle(fontSize: fontSize * 1.1),
              ),
            ],
          ),
        ),
        // Display options (vocab and vocab2) as buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((word) {
            return ElevatedButton(
              onPressed: () => _selectWord(word),
              child: Text(
                word,
                style: TextStyle(fontSize: fontSize),
              ),
            );
          }).toList(),
        ),
        // Feedback message
        if (message.isNotEmpty)
          Text(
            message,
            style: TextStyle(
              color: isAnswerCorrect ? Colors.green : Colors.red,
              fontSize: fontSize,
            ),
          ),
        // Indicator for the page index
        Padding(
          padding: EdgeInsets.only(top: fontSize * 0.5),
          child: Text(
            "${vocabIndex + 1} / ${widget.vocabCnt}",
            style: TextStyle(fontSize: fontSize * 0.8, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  */

 Widget _buildTabPage(int pageIndex, double fontSize) {
    bool isLastPage = pageIndex == widget.vocabCnt - 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,      
      children: [
        LeftRightSwitch(
          fontSize: fontSize,
          iconsColor: Colors.grey,
          iconsSize: fontSize * 1.5,
          rightBorder: pageIndex == 0 ? nextStepId == TeachWordSteps.steps['goToUse2'] : false,
          isFirst: vocabIndex == 0,
          isLast: vocabIndex == widget.vocabCnt - 1,
          middleWidget: Text(
            '用一用',
            style: TextStyle(
              color: Colors.grey,
              fontSize: fontSize * 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          onLeftClicked: vocabIndex > 0
              ? () {
                  setState(() {
                    vocabIndex--;
                    _initVariables(vocabIndex); // Go to previous page
                  });
                }
              : null,
          onRightClicked: isAnswerCorrect && vocabIndex < widget.vocabCnt - 1
              ? () {
                  _onContinuePressed(); // Move to the next page only if the answer is correct
                }
              : null,

        // to be reviewed and edited
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vocab, style: TextStyle(fontSize: fontSize * 1.2)),
            IconButton(icon: Icon(Icons.volume_up), onPressed: () => _speak(vocab)),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: fontSize * 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("解釋：$meaning", style: TextStyle(fontSize: fontSize)),
              Text(displayedSentence, style: TextStyle(fontSize: fontSize * 1.1)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: options.map((word) {
            return ElevatedButton(
              onPressed: () => _selectWord(word),
              child: Text(word, style: TextStyle(fontSize: fontSize)),
            );
          }).toList(),
        ),
        if (message.isNotEmpty)
          Text(
            message,
            style: TextStyle(color: isAnswerCorrect ? Colors.green : Colors.red, fontSize: fontSize),
          ),
        if (isAnswerCorrect && !isLastPage)
          ElevatedButton(
            onPressed: () => _onContinuePressed(),
            child: Text("下一頁", style: TextStyle(fontSize: fontSize)),
          ),
      ],
    );
  }

  @override
  void dispose() {
    // these controllers are not initialized in initState in this class.
    // tabController.dispose();
    // strokeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;
    double deviceWidth = screenInfo.screenWidth;

    return Scaffold(
      appBar: _buildAppBar(deviceWidth, fontSize),
      body: TabBarView(
        children: List.generate(
          widget.vocabCnt,
          (index) => _buildTabPage(index, fontSize),
        ),
      ),
    );
  }

  /*
  Future<void> handleGoToUse() async {
    debugPrint('UseTab handleGoToUse invoked. vocabCnt: $vocabCnt, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');

    switch (vocabCnt) {
      case 1:
        debugPrint('handleGoToUse vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, sentence1: ${wordObj['sentence1']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
        await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
        /*
        setState(() {
          nextStepId = TeachWordSteps.steps['goToUse2']!;
          debugPrint('setState handleGoToUse: newStatus.learned = true');
        });
        */
        break;

      case 2:
        switch (nextStepId) {
          case int stepId when stepId == TeachWordSteps.steps['goToUse1']:
            debugPrint('handleGoToUse vocabCnt: $vocabCnt, vocab1: ${wordObj['vocab1']}, sentence1: ${wordObj['sentence1']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
            await ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
            /*
            setState(() {
              nextStepId += 1;
              debugPrint('setState handleGoToUse: nextStepId: $nextStepId');
            });
            */
            break;

          case int stepId when stepId == TeachWordSteps.steps['goToUse2']:
            debugPrint('handleGoToUse vocabCnt: $vocabCnt, vocab2: ${wordObj['vocab2']}, sentence2: ${wordObj['sentence2']}, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
            await ftts.speak("${wordObj['vocab2']}。${wordObj['sentence2']}");
            /*
            setState(() {
              debugPrint('setState handleGoToUse: nextStepId: $nextStepId');
            });
            */
            break;

          default:
            debugPrint('Unexpected nextStepId for vocabCnt 2: $nextStepId');
        }
        break;

      default:
        debugPrint('handleGoToUse Error! vocabCnt: $vocabCnt, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');
    }

    debugPrint('handleGoToUse completed, nextStepId: $nextStepId');
  }  

  @override
  Widget build(BuildContext context) {
    debugPrint('UseTab build invoked. vocabCnt: $vocabCnt, nextId: $nextStepId, wordIsLearned: $wordIsLearned, svgFileExist: $svgFileExist');

    return useTabView[vocabIndex];

  }

  List<Widget> get useTabView {
    final screenInfo = ref.read(screenInfoProvider);
    final fontSize = screenInfo.fontSize;
    final deviceWidth = screenInfo.screenWidth;
    final availableWidth = deviceWidth - 10;
    handleGoToUse(); // 
    debugPrint('useTabView vocabCnt: $vocabCnt, vocabIndex: $vocabIndex');

    Widget buildPage(int pageIndex) {
      bool isLastPage = pageIndex == vocabCnt - 1;
      String vocab = wordObj['vocab${pageIndex + 1}'];
      String sentence = wordObj['sentence${pageIndex + 1}'];
      String meaning = wordObj['meaning${pageIndex + 1}'];
      bool imgExist = pageIndex == 0 ? img1Exist : img2Exist;
      // handleGoToUse(); // Repeat twice. Move up one level to see if it works.
      debugPrint('buildPage vocabCnt: $vocabCnt, pageIndex: $pageIndex, vocab: $vocab, sentence: $sentence,');

      return TeachWordTabBarView(
        content: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: availableWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        LeftRightSwitch(
                          fontSize: fontSize,
                          iconsColor: lightGray,
                          iconsSize: fontSize * 1.5,
                          rightBorder: pageIndex == 0 ? nextStepId == TeachWordSteps.steps['goToUse2'] : false,
                          middleWidget: Text('用一用',
                              style: TextStyle(
                                color: lightGray,
                                fontSize: fontSize * 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          isFirst: false,
                          isLast: isLastPage,
                          onLeftClicked: wordIsLearned
                            ? () {
                                if (pageIndex == 0) {
                                  int savedNextStepId = nextStepId;
                                  int oldTabIndex = currentTabIndex.value;
                                  nextStepId = TeachWordSteps.steps['goToUse1']!;
                                  currentTabIndex.value = 3;
                                  debugPrint('用一用1，上一頁，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');
                                  // prevTab();
                                  // return _tabController.animateTo(_tabController.index - 1);
                                  widget.onPreviousTab();
                                } else {
                                  debugPrint('用一用2，上一頁，nextId: $nextStepId，叫 prevTab()');
                                  // prevTab();
                                  ftts.speak("${wordObj['vocab1']}。${wordObj['sentence1']}");
                                  setState(() {
                                    vocabIndex = 0;
                                    debugPrint('setState 用一用2，上一頁， vocabIndex: $vocabIndex');
                                  });
                                  widget.onPreviousTab();
                                }
                              }
                            : null,
                          onRightClicked: (nextStepId == TeachWordSteps.steps['goToUse${pageIndex + 2}'] || wordIsLearned) && !isLastPage
                            ? () async {
                                if (nextStepId == TeachWordSteps.steps['goToUse${pageIndex + 2}']) {
                                  await ftts.speak("${wordObj['vocab${pageIndex + 2}']}。${wordObj['sentence${pageIndex + 2}']}");
                                  debugPrint('用一用${pageIndex + 1}，下一頁 vocab${pageIndex + 2}: ${wordObj['vocab${pageIndex + 2}']}, ${wordObj['sentence${pageIndex + 2}']}');
                                  setState(() {
                                    debugPrint('setState 用一用${pageIndex + 1}，下一頁， newStatus.learned: true');
                                  });                                    
                                }
                                setState(() {
                                  vocabIndex = pageIndex + 1;
                                  debugPrint('setState 用一用${pageIndex + 1}，下一頁， vocabIndex: $vocabIndex');
                                });
                              }
                            : null,
                        ),
                        isBpmf
                          ? BopomofoVocabContent(
                              word: word,
                              vocab: vocab,
                              sentence: sentence,
                            )
                          : WordVocabContent(
                              vocab: vocab,
                              meaning: meaning,
                              sentence: "$sentence\n",
                              vocab2: wordObj['vocab${(pageIndex + 1) % vocabCnt + 1}'],
                            ),
                        SizedBox(height: fontSize * 0.2),
                        SizedBox(
                          height: fontSize * 3.0,
                          child: (imgExist && !isBpmf)
                            ? Image(
                                height: fontSize * 3.0,
                                image: AssetImage('lib/assets/img/vocabulary/$vocab.webp'),
                              )
                            : SizedBox(height: fontSize * 0.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: fontSize,
              bottom: fontSize,
              child: Text(
                "${pageIndex + 1} / $vocabCnt",
                style: TextStyle(
                  fontSize: fontSize * 0.75,
                  fontWeight: FontWeight.normal,
                  color: backgroundColor,
                ),
              ),
            ),
          ],
        ),
      );

    }
    // Return all pages
    return List.generate(vocabCnt, (index) => buildPage(index));
  }
  */

}

