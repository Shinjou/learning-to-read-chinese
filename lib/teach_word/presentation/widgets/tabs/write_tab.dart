// lib/teach_word/presentation/widgets/tabs/write_tab.dart

import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:provider/provider.dart';


class WriteTab extends ConsumerStatefulWidget {
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
  final String svgData;
  final bool wordIsLearned;
  final StrokeOrderAnimationController? strokeController;

  const WriteTab({
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
    required this.svgData,
    required this.wordIsLearned,
    required this.strokeController,
  });

  @override
  WriteTabState createState() => WriteTabState();
}

class WriteTabState extends ConsumerState<WriteTab> with TickerProviderStateMixin {
  String word = '';
  bool isBpmf = false;
  bool svgFileExist = false;
  String svgData = '';
  bool wordIsLearned = false;
  late TabController tabController;
  int vocabCnt = 0;
  Map wordObj = {};
  late FlutterTts ftts;
  late AudioPlayer player;
  double fontSize = 16.0;
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);  
  StrokeOrderAnimationController? strokeController;

  // Local state
  late int nextStepId;
  late int practiceTimeLeft;
  // bool get wordIsLearned => widget.wordsStatus[widget.wordIndex].learned;
  bool _showErrorDialog = false;
  bool _firstNullStroke = true;  

  @override
  void initState() {
    super.initState();
    word = widget.wordsStatus[widget.wordIndex].word;     
    ftts = ref.read(ttsProvider);
    player = ref.read(audioPlayerProvider);
    isBpmf = widget.isBpmf;
    svgFileExist = widget.svgFileExist;
    svgData = widget.svgData;
    wordIsLearned = widget.wordIsLearned; 
    tabController = widget.tabController;
    strokeController = widget.strokeController;
    nextStepId = TeachWordSteps.steps['seeAnimation']!;
    practiceTimeLeft = 4;

    strokeController = StrokeOrderAnimationController(
      svgData,
      this,
      onQuizCompleteCallback: handleQuizCompletion,  // Set up the callback here
    );
  }

  @override
  void dispose() {
    // these controllers are not initialized in initState in this class.
    // tabController.dispose();
    // strokeController?.dispose();
    super.dispose();
  }

  void handleQuizCompletion(QuizSummary summary) {
    debugPrint('handleQuizCompletion: summary: $summary, nextStepId: $nextStepId');
    if (nextStepId >= TeachWordSteps.steps['practiceWithBorder1']! &&
        nextStepId <= TeachWordSteps.steps['turnBorderOff']!) {
      setState(() {
        practiceTimeLeft -= 1;
        nextStepId += 1;
        debugPrint('setState handleQuizCompletion: practiceTimeLeft: $practiceTimeLeft, nextId: $nextStepId');
      });
      Fluttertoast.showToast(
        msg: [
          nextStepId == TeachWordSteps.steps['turnBorderOff']
              ? "恭喜筆畫正確！讓我們 去掉邊框 再練習 $practiceTimeLeft 遍哦！"
              : "恭喜筆畫正確！讓我們再練習 $practiceTimeLeft 次哦！"
        ].join(),
        fontSize: fontSize * 1.2,
      );
    } else {
      if (nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']) {
        setState(() {
          practiceTimeLeft -= 1;
          nextStepId += 1;
          // 在用一用完後，才設定 learned = true
          // widget.wordsStatus[widget.wordIndex].learned = true; // 設成“已學”
          // _updateWordStatus(widget.wordsStatus[widget.wordIndex], learned: true);
          // updateWordStatus(context, ref, widget.wordsStatus[widget.wordIndex], true); 
          debugPrint('setState handleQuizCompletion 要進入用一用1, practiceTimeLeft: $practiceTimeLeft, nextId: $nextStepId, learned: true');
        });
      }
      Fluttertoast.showToast(
        msg: ["恭喜筆畫正確！"].join(),
        fontSize: fontSize * 1.2,
      );
    }
  }


  bool _canMoveToUse() {
    if ((wordIsLearned) || (practiceTimeLeft == 0)) {
      return true;
    } else {
      return false;
    }
  }

  bool _doStrokOrder() {
    debugPrint('_doStrokOrder: nextStepId: $nextStepId, wordIsLearned: $wordIsLearned');
    if (nextStepId == TeachWordSteps.steps['seeAnimation'] && !wordIsLearned) {
      return true;
    } else {
      return false;
    }
  }

  bool _doWrite() {
    debugPrint('_doWrite: nextStepId: $nextStepId, wordIsLearned: $wordIsLearned');
    if (((nextStepId > TeachWordSteps.steps['seeAnimation']!) && 
      (nextStepId < TeachWordSteps.steps['turnBorderOff']!) && 
      (!wordIsLearned && !strokeController!.isQuizzing)) || 
      (nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']!)) {
      return true;
    } else {
      return false;
    }
  } 

  _doLabel() {
    debugPrint('_doLabel: nextStepId: $nextStepId, wordIsLearned: $wordIsLearned');
    if ((nextStepId == TeachWordSteps.steps['turnBorderOff'] && !wordIsLearned)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (strokeController == null) {
      debugPrint("Error: strokeController is not initialized.");
      return _buildErrorWidget(word);
    }


    final ScreenInfo screenInfo = ref.watch(screenInfoProvider);
    final double fontSize = screenInfo.fontSize;
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    // double availableWidth = deviceWidth - 10;
    // double availableHeight = deviceHeight - 10;
    double nonConsumedHeight = deviceHeight * 0.15;
    // bool isTablet = screenInfo.isTablet;
    debugPrint("WriteTab: Building WriteTab with fontSize $fontSize and word $word");

    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildWriteTab(deviceWidth, deviceHeight, nonConsumedHeight, fontSize, word);
      },
    );
  }

  Widget _buildWriteTab(double deviceWidth, double deviceHeight, double nonConsumedHeight, double fontSize, String word) {
    return TeachWordTabBarView(
      content: ChangeNotifierProvider<StrokeOrderAnimationController>.value(
        value: strokeController!,
        child: Consumer<StrokeOrderAnimationController>(
          builder: (context, controller, child) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(                        
                  maxWidth: deviceWidth * 0.90,
                  maxHeight: deviceHeight - nonConsumedHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildWriteLeftRightSwitch(fontSize, word),
                    SizedBox(height: fontSize),
                    Flexible(
                      child: _buildWriteAnimator(deviceWidth, deviceHeight, nonConsumedHeight, fontSize, controller),
                    ),                    
                    _buildWriteIconGrid(fontSize, controller),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWriteLeftRightSwitch(double fontSize, String word) {
    return LeftRightSwitch(
      fontSize: fontSize,
      iconsColor: lightGray,
      iconsSize: max(fontSize * 1.5, 48.0),
      rightBorder: _canMoveToUse(),
      middleWidget: Text('寫一寫',
          style: TextStyle(
            color: lightGray,
            fontSize: fontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      isFirst: false,
      isLast: false,
      onLeftClicked: wordIsLearned
          ? () async {
              int savedNextStepId = nextStepId;
              int oldTabIndex = currentTabIndex.value;
              nextStepId = TeachWordSteps.steps['goToWrite']!;
              currentTabIndex.value = 2;
              debugPrint('回去 聽一聽 說：$word');
              speakWord(word, isBpmf, player, ftts,);
              debugPrint('寫一寫，上一頁2，savedId: $savedNextStepId，nextId: $nextStepId，oldTabIndex: $oldTabIndex, newTabIndex: ${currentTabIndex.value},叫 prevTab()');
              
              // prevTab();
              // return tabController.animateTo(tabController.index - 1);
              widget.onPreviousTab();
            }
          : null,
      onRightClicked: (nextStepId == TeachWordSteps.steps['goToUse1'] || wordIsLearned)
          ? () {
              // nextTab();
              // return tabController.animateTo(tabController.index + 1);
              widget.onNextTab();
            }
          : null,
    );
  }

  Widget _buildWriteAnimator(double availableWidth, double availableHeight, double nonConsumedHeight, double fontSize, StrokeOrderAnimationController controller) {
    return SizedBox(                            
      width: availableWidth,
      height: (availableHeight - nonConsumedHeight) * 0.6,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: !isBpmf
                ? const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("lib/assets/img/box.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  )
                : const BoxDecoration(color: darkBrown),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 10,
                  top: 5,
                  child: Column(children: [
                    _buildPracticeTimeIcon(practiceTimeLeft >= 4 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 3 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 2 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    SizedBox(height: fontSize * 0.9),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 1 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                  ]),
                ),
                FittedBox(
                  child: StrokeOrderAnimator(
                    strokeController!,
                    key: UniqueKey(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWriteIconGrid(double fontSize, StrokeOrderAnimationController controller) {
    return Flexible(
      fit: FlexFit.loose,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2,
        crossAxisSpacing: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          _buildIconButtonWithLabel(
            context: context,
            border: _doStrokOrder(),
            // border: (nextStepId == TeachWordSteps.steps['seeAnimation'] && !wordIsLearned),
            iconData: [Icons.pause, Icons.play_arrow],
            label: '筆順',
            isSelected: controller.isAnimating,
            onPressed: _buildStrokeOrderButtonOnPressed(controller),
            fontSize: fontSize,
          ),
          _buildIconButtonWithLabel(
            context: context,
            border: _doWrite(),
            // border: ((nextStepId > TeachWordSteps.steps['seeAnimation']! && nextStepId < TeachWordSteps.steps['turnBorderOff']!) && 
            //         !wordIsLearned && !controller.isQuizzing) || (nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']!),
            iconData: [Icons.edit_off, Icons.edit],
            label: '寫字',
            isSelected: controller.isQuizzing,
            onPressed: _buildWriteButtonOnPressed(controller),
            fontSize: fontSize,
          ),
          _buildIconButtonWithLabel(
            context: context,
            border: _doLabel(),
            // border: (nextStepId == TeachWordSteps.steps['turnBorderOff'] && !wordIsLearned),
            iconData: [Icons.remove_red_eye, Icons.remove_red_eye_outlined],
            label: '邊框',
            isSelected: controller.showOutline,
            onPressed: _buildOutlineButtonOnPressed(controller),
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }

  Function()? _buildStrokeOrderButtonOnPressed(StrokeOrderAnimationController controller) {
    return ((!controller.isQuizzing && (nextStepId == TeachWordSteps.steps['seeAnimation'])) || wordIsLearned)
        ? () async {
            if (!controller.isAnimating) {
              controller.startAnimation();
              speakWord(word, isBpmf, player, ftts);
              debugPrint('筆順 $word');
              if (nextStepId == TeachWordSteps.steps['seeAnimation']) {
                setState(() {
                  nextStepId += 1;
                  debugPrint('setState 筆順 $word, nextStepId: $nextStepId');
                });
              }
            } else {
              controller.stopAnimation();
              debugPrint("stop animation // nextStepId update time");
            }
          }
        : null;
  }

  Function()? _buildWriteButtonOnPressed(StrokeOrderAnimationController controller) {
    debugPrint('_buildWriteButtonOnPressed: $word, nextStepId: $nextStepId, wordIsLearned: $wordIsLearned');
    return ((nextStepId > TeachWordSteps.steps['seeAnimation']! && nextStepId < TeachWordSteps.steps['turnBorderOff']!) || wordIsLearned || (nextStepId == TeachWordSteps.steps['practiceWithoutBorder1']!))
        ? () async {
            controller.startQuiz();
            speakWord(word, isBpmf, player, ftts);
            debugPrint('WriteTab 寫字 $word');
          }
        : null;
  }

  Function()? _buildOutlineButtonOnPressed(StrokeOrderAnimationController controller) {
    debugPrint('_buildOutlineButtonOnPressed: $word, nextStepId: $nextStepId, wordIsLearned: $wordIsLearned');
    return (nextStepId == TeachWordSteps.steps['turnBorderOff'] || wordIsLearned)
        ? () {
            if (nextStepId == TeachWordSteps.steps['turnBorderOff']) {
              setState(() {
                nextStepId += 1;
                debugPrint('setState 邊框 $word, nextStepId: $nextStepId');
              });
            }
            controller.setShowOutline(!controller.showOutline);
          }
        : null;
  }

  Widget _buildErrorWidget(String word) {
    if (_firstNullStroke) {
      _firstNullStroke = false;
      return Container();
    } else {
      _showErrorDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_showErrorDialog) {
          showErrorDialog(context, '','「$word」沒有筆順2。請截圖回報。謝謝！', fontSize);
          _firstNullStroke = true;
          _showErrorDialog = false;
        }
      });
      return Container();
    }
  }


  Widget _buildIconButtonWithLabel({
    required BuildContext context,
    required bool border,
    required List<IconData> iconData,
    required String label,
    required bool isSelected,
    required Function()? onPressed,
    required double fontSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              border: border
                  ? Border.all(color: lightYellow, width: 1.5)
                  : null,
            ),
            child: IconButton(
              icon: Icon(
                isSelected ? iconData[0] : iconData[1],
                size: fontSize * 1.0,
              ),
              color: backgroundColor,
              onPressed: onPressed != null
                  ? () => onPressed()
                  : null,
            ),
          );
        }),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildPracticeTimeIcon(bool condition, double fontSize, Color defaultColor, Color activeColor) {
    return Icon(
      condition ? Icons.check_circle_outline_outlined : Icons.check_circle,
      color: condition ? defaultColor : activeColor,
      size: fontSize * 1.5,
    );
  }



}

