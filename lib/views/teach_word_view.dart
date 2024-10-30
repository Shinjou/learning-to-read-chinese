/* File Structure:
lib/
  providers.dart // State management and audio providers
  views/
    teach_word_view.dart         // Main view
    teach_word/
      state/
         teach_word_provider.dart // State management
         teach_word_state.dart   // State 
      teach_word_controllers.dart  // Logic and control
      teach_word_constants.dart    // Constants and steps
      widgets/
        teach_word_app_bar.dart
        teach_word_bottom_bar.dar
        bpmf_vocal_content.dart
        word_vocal_content.dart
      tabs/
        look_tab.dart
        listen_tab.dart
        write_tab.dart
        use_tab.dart
Remember to maintain proper separation of concerns:
- Controller handles business logic
- View provides necessary callbacks and context
- State management remains in providers
- Error handling remains consistent
*/

// lib/views/teach_word_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
import 'package:ltrc/views/teach_word/tabs/look_tab.dart';
import 'package:ltrc/views/teach_word/tabs/listen_tab.dart';
import 'package:ltrc/views/teach_word/tabs/write_tab.dart';
import 'package:ltrc/views/teach_word/tabs/use_tab.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/views/teach_word/widgets/teach_word_app_bar.dart';
import 'package:ltrc/views/teach_word/widgets/teach_word_bottom_bar.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';

class TeachWordView extends ConsumerStatefulWidget {
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
  final List<Map<String, dynamic>> wordsPhrase;
  final int wordIndex;

  const TeachWordView({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
  });

  @override
  TeachWordViewState createState() => TeachWordViewState();
}

class TeachWordViewState extends ConsumerState<TeachWordView> with TickerProviderStateMixin {
  // Word state from the original code. Some of them should be replaced by the state provider
  late Map wordsPhrase;
  late Map<String, dynamic> wordData;
  String word = '';
  int vocabCnt = 0;
  bool img1Exist = false;
  bool img2Exist = false;
  bool wordExist = false; // 字存在，但是 json 可能不存在 (svgFileExist = false)
  bool svgFileExist = false; // 字存在，json 也存在
  double fontSize = 0;
  int practiceTimeLeft = 4;
  int nextStepId = 0;
  bool isBpmf = false;
  int vocabIndex = 0;
  bool get isLearned =>   // use getter, don't use variable
    widget.wordsStatus[widget.wordIndex].learned; 
  bool _showErrorDialog = false;
  bool _firstNullStroke = true;

  // Controllers
  late final TeachWordControllers controllers;

  @override
  void initState() {
    super.initState();
    word = widget.wordsStatus[widget.wordIndex].word;
    debugPrint('TeachWordView initState for word: $word, learned: $isLearned');
    
    _initializeTabController();
    // tts is initialized in the main.dart
    _checkIfBpmf();
    _getWord();
    _initializeView();
  }

  @override
  void dispose() {
    controllers.dispose();
    super.dispose();
  }

  void _initializeTabController() {
    // Initialize controllers with the current TickerProvider
    controllers = TeachWordControllers(
      ref,
      TabController(
        length: TeachWordConstants.tabCount,
        vsync: this,
      ),
      onNoSvgError: (String word) {
        showNoSvgDialog(
          '',
          '抱歉，「$word」還沒有筆順。請繼續。謝謝！'
        );
      },
    );
  }

  void _checkIfBpmf() { // use controllers instead of 
    isBpmf = initials.contains(word) ||
        prenuclear.contains(word) ||
        finals.contains(word);
  }

  Future<void> _initializeView() async {
    // Cast the Map to the correct type
    final wordData = Map<String, dynamic>.from(widget.wordsPhrase[widget.wordIndex]);

    // Initialize the state first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teachWordStateProvider.notifier).initializeWord(
        word,
        wordData,
        isLearned,
        isBpmf,
      );
    });

    // Initialize word and stroke data
    await controllers.initializeWordAndStroke(
      context,
      this,
      _handleQuizCompletion,
      readJson,
    );
  }

  void _getWord() {
    int tempIndex = widget.wordIndex;
    bool phraseEmpty = widget.wordsPhrase.isEmpty;
    debugPrint('getWord begin: phraseEmpty: $phraseEmpty, tempIndex: $tempIndex');

    // Update state through provider
    ref.read(teachWordStateProvider.notifier).processWordData(
      phraseEmpty ? null : widget.wordsPhrase[tempIndex],
      tempIndex,
      widget.wordsPhrase.length,
    );

    // Access the updated state if needed
    final state = ref.read(teachWordStateProvider);
    wordExist = state.wordExists;  // If you still need local tracking
    vocabCnt = state.vocabCount;   // If you still need local tracking
  }

  void _handleNextNavigation() {
    if (!controllers.navigateToNextTab()) {
      // Navigation was blocked due to NoSvg
      showNoSvgDialog('', '抱歉，「${state.word}」還沒有筆順。請繼續。謝謝！');
    }
  }

  void _handlePreviousNavigation() {
    if (!controllers.navigateToPreviousTab()) {
      // Navigation was blocked due to NoSvg
      showNoSvgDialog('', '抱歉，「${state.word}」還沒有筆順。請繼續。謝謝！');
    }
  }
  /*
  Future<void> _updateWordStatus(WordStatus newStatus, {required bool learned}) async {
    debugPrint('_updateWordStatus. mounted: ${context.mounted}, learned: $learned, nextStepId: $nextStepId');
    if (!context.mounted) return;

    try {
      newStatus.learned = learned;
      
      ref.read(learnedWordCountProvider.notifier).state += learned ? 1 : 0;
      
      await WordStatusProvider().updateWordStatus(status: newStatus);
      
      if (mounted) {
        setState(() {
          debugPrint('setState _updateWordStatus: newStatus.learned: $learned, nextStepId: $nextStepId');
        });
      }
    } catch (e) {
      debugPrint('Error in _updateWordStatus: $e');
      // Handle error (e.g., show a snackbar to the user)      
    }
  }  
    
  void checkWordExistence() {
    if (!wordExist) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controllers.showErrorDialog('','「$word」不在SQL。請截圖回報。謝謝！');
      });
    } else {
      readJsonAndProcess(); // setState() is called here
    }
  }

  Future<void> readJsonAndProcess() async {
    // setState() is called in this function
    try {
      final result = await readJson();
      debugPrint('readJsonAndProcess: $word ${svgFileExist ? "有筆順" : "沒有筆順"}');
      if (result.isNotEmpty) {
        setState(() {
          _strokeOrderAnimationController = StrokeOrderAnimationController(
              result, this,
              onQuizCompleteCallback: handleQuizCompletion);
          if (svgFileExist) {
            debugPrint('setState readJsonAndProcess: $word 筆順檔下載成功');
          } else {
            debugPrint('setState readJsonAndProcess: 用"寫"替代，筆順��下載成功');
          }
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controllers.showErrorDialog('','「$word」的筆順檔無法下載。請截圖回報。謝謝！');
          debugPrint('readJsonAndProcess error: $word 的筆順檔無法下載, svgFileExist: $svgFileExist');
          _firstNullStroke = true;
          _showErrorDialog = false;
        });        
        setState(() {
          _strokeOrderAnimationController = null;
          debugPrint('setState readJsonAndProcess error: $word 的筆順檔無法下載, svgFileExist: $svgFileExist');
        });
      }
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controllers.showErrorDialog('','「$word」筆順檔問題，請截圖回報。svgFileExist: $svgFileExist。謝謝！');
        _firstNullStroke = true;
        _showErrorDialog = false;
      });
      setState(() {
        _strokeOrderAnimationController = null;
        debugPrint('setState readJsonAndProcess error: $word 筆順檔問題, svgFileExist: $svgFileExist');
      });
    }
  }
  */

  Future<String> readJson(String word) async {
    // Define the noSvgList. This list needs to be updated every new school semester
    List<String> noSvgList = [
      '吔', '姍', '媼', '嬤', '履', '搧', '枴', '椏', '欓', '汙',
      '溼', '漥', '痠', '礫', '粄', '粿', '綰', '蓆', '襬', '譟',
      '踖', '踧', '鎚', '鏗', '鏘', '陳', '颺', '齒'
    ];

    String tempWord = word;

    // If the word is in the noSvgList, set svgFileExist to false and use '學' as a fallback
    if (noSvgList.contains(word)) {
      tempWord = '學';
      svgFileExist = false;
    } else {
      svgFileExist = true;
    }

    debugPrint('readJson() word: $tempWord, svgFileExist: $svgFileExist');

    // Proceed with loading the SVG file. If svgFileExist is false, 
    // load “學” so that 看一看、聽一聽、用一用 still work.  
    try {
      final String response = await rootBundle.loadString('lib/assets/svg/$tempWord.json');
      return response.replaceAll("\"", "'");
    } catch (e) {
      svgFileExist = false;
      debugPrint('readJson() error: $e, svgFileExist: $svgFileExist');
      return ''; // Return an empty string in case of error
    }
  }

// Quiz completion handler
  void _handleQuizCompletion(QuizSummary summary) {
    final notifier = ref.read(teachWordStateProvider.notifier);
    final state = ref.read(teachWordStateProvider);
    final screenInfo = ref.read(screenInfoProvider);  // Get current screenInfo

    if (state.nextStepId >= TeachWordConstants.steps['practiceWithBorder1']! &&
        state.nextStepId <= TeachWordConstants.steps['turnBorderOff']!) {
      notifier.decrementPracticeTimeLeft();
      notifier.incrementNextStepId();
      
      controllers.showPracticeCompletionToast(
        state.practiceTimeLeft,
        state.nextStepId == TeachWordConstants.steps['turnBorderOff'],
        screenInfo.fontSize,  // Pass current fontSize
      );
    } else if (state.nextStepId == TeachWordConstants.steps['practiceWithoutBorder1']) {
      notifier.decrementPracticeTimeLeft();
      notifier.incrementNextStepId();
      notifier.markWordAsLearned(); // Note: 未來要改成用一用結束後，才標記為已學習。
      _updateWordStatusInDatabase();
      controllers.showCompletionToast(screenInfo.fontSize);  // Pass current fontSize
    }
  }
  
  Future<void> _updateWordStatusInDatabase() async {
    final status = widget.wordsStatus[widget.wordIndex];
    status.learned = true;
    await WordStatusProvider().updateWordStatus(status: status);
  }

  Widget _buildErrorWidget(String word) {
    if (_numberOfNullStroke < _maxNumberOfNullStroke) {
      _numberOfNullStroke++;
      debugPrint('buildErrorWidget() word: $word, numberOfNullStroke: $_numberOfNullStroke');      
      return Container();
    } else {
      _showErrorDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_showErrorDialog) {
          controllers.showErrorDialog(
            context,
            '',
            '「$word」沒有筆順2。請截圖回報。謝謝！',
            ref.read(screenInfoProvider).fontSize,
          );
          _numberOfNullStroke = 0;
          _showErrorDialog = false;
        }
      });
      return Container();
    }
  }

  /*
  Future<void> showNoSvgDialog(String title, String message) async {
    if (!context.mounted) return;
    
    final screenInfo = ref.read(screenInfoProvider);
    // final state = ref.read(teachWordStateProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenInfo.fontSize * 1.2,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenInfo.fontSize * 1.2,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                '聽一聽',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenInfo.fontSize * 1.2,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                final audioService = ref.read(audioServiceProvider);
                await audioService.playWordSound(word, isBpmf);
                ref.read(teachWordStateProvider.notifier).setCurrentTabIndex(1);
                controllers.tabController.animateTo(1);
              },
            ),
            TextButton(
              child: Text(
                '用一用',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: screenInfo.fontSize * 1.2,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // Update state
                widget.wordsStatus[widget.wordIndex].learned = true;
                _updateWordStatusInDatabase();
                ref.read(teachWordStateProvider.notifier)
                  ..setCurrentTabIndex(3)
                  ..markWordAsLearned();
                controllers.tabController.animateTo(3);
              },
            ),
          ],
        );
      },
    );
  }  
  */

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teachWordStateProvider);
    Map<String, dynamic> wordData = state.wordData;    
    final screenInfo = ref.watch(screenInfoProvider);
    final strokeController = ref.watch(strokeOrderControllerProvider);        
    debugPrint('TeachWordView build - word: ${state.word}, fontSize: ${screenInfo.fontSize}, controller: ${strokeController != null}');
    
    if (state.word.isEmpty || screenInfo.fontSize == 0) {
      debugPrint('Still initializing - waiting for word or fontSize');
      return Container();
    } 
    
    if (strokeController == null) {
      debugPrint('No stroke controller - showing error widget');
      return _buildErrorWidget(state.word);
    }

    return DefaultTabController(
      length: TeachWordConstants.tabCount,
      child: Scaffold(
        appBar: TeachWordAppBar(
          screenInfo: screenInfo,
          controllers: controllers,
          state: state,
          unitId: widget.unitId,
          unitTitle: widget.unitTitle,
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: controllers.tabController,
          children: [
            LookTab(
              controllers: controllers,
              screenInfo: screenInfo,
              state: state,
            ),
            ListenTab(
              controllers: controllers,
              screenInfo: screenInfo,
              state: state,
            ),
            WriteTab(
              controllers: controllers,
              screenInfo: screenInfo,
              state: state,
            ),            
            UseTab(
              controllers: controllers,
              screenInfo: screenInfo,
              state: state,
              wordsPhrase: wordData,
            ),
          ],
        ),
        bottomNavigationBar: TeachWordBottomBar(
          screenInfo: screenInfo,
          controllers: controllers,
          state: state,
          unitId: widget.unitId,
          unitTitle: widget.unitTitle,
          wordsStatus: widget.wordsStatus,
          wordsPhrase: widget.wordsPhrase,
          wordIndex: widget.wordIndex,
        ),
      ),
    );
  }

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}


