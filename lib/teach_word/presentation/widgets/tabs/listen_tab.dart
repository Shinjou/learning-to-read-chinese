// lib/teach_word/presentation/widgets/tabs/listen_tab.dart

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
// import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';

class ListenTab extends ConsumerStatefulWidget {
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

  const ListenTab({
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

class LookTabState extends ConsumerState<ListenTab> with TickerProviderStateMixin {
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
  double deviceWidth = 0.0;
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
    final ScreenInfo screenInfo = ref.read(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    deviceWidth = screenInfo.screenWidth;
    debugPrint("ListenTab: Building ListenTab with fontSize $fontSize and word $word");

    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildListenTab(deviceWidth, deviceWidth, fontSize, word);
      },
    );
  }

  Widget _buildListenTab(double deviceHeight, double deviceWidth, double fontSize, String word) {
    return TeachWordTabBarView(
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: deviceHeight * 0.9,
                maxWidth: deviceWidth * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildListenLeftRightSwitch(fontSize),
                  SizedBox(height: fontSize * 0.3),
                  _buildListenWord(deviceHeight, deviceWidth, fontSize, word),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListenLeftRightSwitch(double fontSize) {
    return LeftRightSwitch(
      fontSize: fontSize,
      iconsColor: lightGray,
      iconsSize: max(fontSize * 1.5, 48.0),
      rightBorder: true, // always true for 看一看 and 聽一聽
      /*
      middleWidget: Text('聽一聽',
          style: TextStyle(
            color: lightGray,
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),      
      */  
      middleWidget: ZhuyinProcessing(
        text: '聽一聽',
        color: lightGray,
        fontSize: fontSize * 1.2,        
        fontWeight: FontWeight.bold,  // Optional font weight
        centered: true,  // Optional centering
      ),      
      isFirst: false,
      isLast: false,
      onLeftClicked: () async {
        speakWord(word, isBpmf, player, ftts);
        widget.onPreviousTab(); 
      },            
      onRightClicked: () async {
        speakWord(word, isBpmf, player, ftts);
        widget.onNextTab(); 
      },      

    );
  }

  Widget _buildListenWord(double deviceHeight, double deviceWidth, double fontSize, String word) {
    return SizedBox(
      height: (deviceHeight * 0.4),
      width: deviceWidth * 1.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            return Container(
              decoration: const BoxDecoration(
                color: darkBrown,
              ),
              child: Center(
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
              ),
            );
          }),
        ],
      ),
    );
  }


}


