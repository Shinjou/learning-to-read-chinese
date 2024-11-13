// lib/teach_word/presentation/widgets/tabs/look_tab.dart

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
// import 'package:ltrc/teach_word/providers/word_provider.dart';
// import 'package:ltrc/teach_word/states/word_state.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';

class LookTab extends ConsumerStatefulWidget {
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

  const LookTab({
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
  });

  @override
  LookTabState createState() => LookTabState();
}

class LookTabState extends ConsumerState<LookTab> with TickerProviderStateMixin {
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


  @override
  void initState() {
    super.initState();
    word = widget.wordsStatus[widget.wordIndex].word;     
    ftts = ref.read(ttsProvider);
    player = ref.read(audioPlayerProvider);
    tabController = widget.tabController;
    isBpmf = widget.isBpmf;
    svgFileExist = widget.svgFileExist;
    wordIsLearned = widget.wordIsLearned; 
  }

  @override
  Widget build(BuildContext context) {
    final ScreenInfo screenInfo = ref.watch(screenInfoProvider);
    final double fontSize = screenInfo.fontSize;
    // double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    // double availableWidth = deviceWidth - 10;
    // double availableHeight = deviceHeight - 10;
    // double nonConsumedHeight = deviceHeight * 0.15;
    // bool isTablet = screenInfo.isTablet;
    debugPrint("LookTab: Building LookTab with fontSize $fontSize and word $word");

    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildLookTab(deviceWidth, fontSize, word);
      },
    );
  }

  Widget _buildLookTab(double deviceWidth, double fontSize, String word) {
    return TeachWordTabBarView(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: deviceWidth * 0.90,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _buildLookLeftRightSwitch(fontSize),
                      SizedBox(height: fontSize * 0.3),
                      _buildLookImage(fontSize, word),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLookLeftRightSwitch(double fontSize) {
    // final WordState wordState = ref.watch(wordControllerProvider);
    // final FlutterTts ftts = ref.read(ttsProvider);
    // final AudioPlayer player = ref.read(audioPlayerProvider);    
    final nextStepId = 0;
    debugPrint("LookTab: Building word: $word, nextId: $nextStepId, learned: $wordIsLearned");

    return LeftRightSwitch(
      fontSize: fontSize,
      iconsColor: lightGray,
      iconsSize: max(fontSize * 1.5, 48.0),
      rightBorder: true, // always true for 看一看 and 聽一聽
      middleWidget: Text('看一看',
          style: TextStyle(
            color: lightGray,
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      isFirst: true,
      isLast: false,
      onRightClicked: () async {
        speakWord(word, isBpmf, player, ftts,);
        widget.onNextTab(); 
      },

    );
  }

  Widget _buildLookImage(double fontSize, String word) {
    return Flexible(
      fit: FlexFit.loose,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: const BoxDecoration(
                  color: darkBrown,
                ),
                child: Center(
                  child: Image(
                    width: max(17.6 * fontSize, 300.0),
                    image: isBpmf
                        ? AssetImage('lib/assets/img/bopomo/$word.png')
                        : AssetImage('lib/assets/img/oldWords/$word.webp'),
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      debugPrint('Error loading image: $exception');
                      return Center(
                        child: Text(
                          word,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize * 8.0,
                            color: backgroundColor,
                            fontWeight: FontWeight.w100,
                            fontFamily: isBpmf ? "BpmfOnly" : "BpmfIansui",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          ),
        ],
      ),
    );
  }

}


