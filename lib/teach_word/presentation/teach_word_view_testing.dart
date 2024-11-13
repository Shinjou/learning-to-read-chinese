// lib/teach_word/presentation/teach_word_view.dart
// ChatGPT generated code based on the original code.


import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:ltrc/contants/bopomos.dart';
// import 'package:ltrc/data/providers/word_status_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/data/models/word_status_model.dart';
// import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/teach_word/providers/teach_word_providers.dart';
import 'package:ltrc/teach_word/states/navigation_state.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/look_tab.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/listen_tab.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/write_tab.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/use_tab.dart';
import 'package:ltrc/teach_word/states/word_state.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/widgets/word_card.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';


class TeachWordView extends ConsumerStatefulWidget {
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
  final List<Map> wordsPhrase;
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
  // new variables
  bool _isInitialized = false;

  // duplicate variable from the original code
  StrokeOrderAnimationController? strokeController;
  late TabController _tabController;
  FlutterTts ftts = FlutterTts();
  final player = AudioPlayer();
  late Map wordsPhrase;
  late Map wordObj;
  String word = '';
  int vocabCnt = 0;
  bool img1Exist = false;
  bool img2Exist = false;
  bool wordExist = false; // wordExist true 時，字存在，但是 json 可能不存在 (svgFileExist = false)
  bool svgFileExist = false; // if wordExist true, and svgFileExist true, then json exists
  String svgData = '';
  double fontSize = 0;
  int practiceTimeLeft = 4;
  int nextStepId = 0;
  bool isBpmf = false;
  int vocabIndex = 0;
  ValueNotifier<int> currentTabIndex = ValueNotifier(0);

  bool get wordIsLearned => widget.wordsStatus[widget.wordIndex].learned;

  bool firstNullStrokeFlag = true;
  bool showErrorFlag = false;
  // end of duplicate variable


  @override
  void initState() {
    super.initState();
    word = widget.wordsStatus[widget.wordIndex].word; 
    _initializeComponents();
    debugPrint('TeachWordView: Initializing components.');    

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStrokeController();
    });
  }

  void _initializeComponents() {
    // _initializeTts(); // Removed because it is done in main.dart
    _initializeTabController();
    _checkIfBpmf();
    getWord();
    checkWordExistence();
  }

  void _initializeTabController() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    debugPrint('TeachWordView: TabController initialized.');    
  }

  void _checkIfBpmf() {
    isBpmf = initials.contains(word) ||
        prenuclear.contains(word) ||
        finals.contains(word);
  }

  /* where do we set up TTS completion handler???
  void _onTtsComplete() {
    debugPrint("Speech has completed");
    if (!context.mounted) return;

    if (nextStepId == steps['goToListen']) {
      incrementNextStepId();
    } else if (nextStepId == steps['goToUse1']) {
      handleGoToUse();
    } else if (nextStepId == steps['goToUse2']) {
      // No action needed here, as per original code
    }
  }
  */

  void getWord() {
    // getWord() is called in initState(), NO setState() is called
    int tempIndex = widget.wordIndex;
    bool phraseEmpty = widget.wordsPhrase.isEmpty;
    debugPrint('getWord begin: phraseEmpty: $phraseEmpty, tempIndex: $tempIndex');
    if (phraseEmpty) {
      debugPrint('getWord error: wordsPhrase is empty');
      wordObj = {};
      wordExist = false;
      return;
    } else {
      debugPrint('getWord index: $tempIndex, length: ${widget.wordsPhrase.length}');
      if (!(tempIndex < widget.wordsPhrase.length)) {
        debugPrint('getWord error: wordIndex is out of range');
        wordObj = {};
        wordExist = false;
        return;
      }
    }

    wordObj = widget.wordsPhrase[tempIndex];
    try {
      // Process vocab1 and vocab2
      if (wordObj['vocab1'] != "") {
        vocabCnt += 1;
      }
      if (wordObj['vocab2'] != "") {
        vocabCnt += 1;
      }

      wordExist = true; // 字存在，要檢查 json 是否也存在 (svgFileExist ？)
      debugPrint('getWord end: wordExist: $wordExist, vocabCnt: $vocabCnt, ${wordObj['vocab1']}, ${wordObj['vocab2']}');
    } catch (error) {
      wordExist = false;
      debugPrint('getWord error: : $error。wordExist: $wordExist,${wordObj['vocab1']}');
    }
  }
  /*
  // Where is _updateWordStatus() called???
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
  */
    
  void checkWordExistence() {
    if (!wordExist) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(context, '','「$word」不在SQL。請截圖回報。謝謝！', fontSize);
      });
    } else {
      readJsonAndProcess(); // setState() is called here
    }
  }

  Future<void> readJsonAndProcess() async {
    // setState() is called in this function
    try {
      final result = await readJson(); // readJson() will set svgFileExist
      debugPrint('readJsonAndProcess: $word ${svgFileExist ? "有筆順" : "沒有筆順"}');
      if (result.isNotEmpty) {
        debugPrint('readJsonAndProcess: $word ${svgFileExist ? "有筆順" : "沒筆順，用“學”代替；"}, 筆順檔下載成功');
        setState(() {
          strokeController = StrokeOrderAnimationController(
              result, this);  // let WriteTab to set up onQuizCompleteCallback
              // onQuizCompleteCallback: handleQuizCompletion;

        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorDialog(context, '','「$word」的筆順檔無法下載。請截圖回報。謝謝！', fontSize);
          debugPrint('readJsonAndProcess error: $word 的筆順檔無法下載, svgFileExist: $svgFileExist');
          firstNullStrokeFlag = true;
          showErrorFlag = false;
        });        
        setState(() {
          strokeController = null;
          debugPrint('readJsonAndProcess setState error: $word 的筆順檔無法下載, svgFileExist: $svgFileExist');
        });
      }
    } catch (error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorDialog(context, '','「$word」筆順檔問題，請截圖回報。svgFileExist: $svgFileExist。謝謝！', fontSize);
        firstNullStrokeFlag = true;
        showErrorFlag = false;
      });
      setState(() {
        strokeController = null;
        debugPrint('setState readJsonAndProcess error: $word 筆順檔問題, svgFileExist: $svgFileExist');
      });
    }
  }

  Future<String> readJson() async {
    // Define the noSvgList. This list needs to be updated every new school semester
    List<String> noSvgList = [
      '吔', '姍', '媼', '嬤', '履', '搧', '枴', '椏', '欓', '汙',
      '溼', '漥', '痠', '礫', '粄', '粿', '綰', '蓆', '襬', '譟',
      '踖', '踧', '鎚', '鏗', '鏘', '陳', '颺', '齒'
    ];

    // String word = widget.wordsStatus[widget.wordIndex].word;
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

  // Need to review the following methods carefully
  void _handleTabChange() {
    Future(() {
      final WordState wordState = ref.read(wordControllerProvider);
      ref.read(navigationStateProvider.notifier).state = NavigationState(
        currentTab: _tabController.index,
        canNavigateNext: _tabController.index < 3 && !wordState.isLearned,
        canNavigatePrev: _tabController.index > 0,
      );
      debugPrint('_handleTabChange: Tab changed to index ${_tabController.index}.');
    });
  }

  Future<void> _initializeStrokeController() async {
    final String word = widget.wordsStatus[widget.wordIndex].word;
    debugPrint("TeachWordView: Initializing stroke controller for word $word.");
    try {
      final wordController = ref.read(wordControllerProvider.notifier);
      svgData = await wordController.loadSvgData(word);      
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      if (mounted) {
        // Create a new StrokeOrderAnimationController instance with svgData
        strokeController = StrokeOrderAnimationController(svgData, this);
        
        // Set the stroke controller in the provider
        ref.read(wordControllerProvider.notifier).
          setStrokeController(strokeController!, context, ref, widget, fontSize);
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing stroke controller: $e\n$stackTrace');
      showErrorDialog(context, 
        'Initialization Error',
        'Failed to load the stroke order for the word. Please try again.', fontSize
      );
    }
  }

  /* duplicate???
  void showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('回首頁'),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/mainPage');
            },
          ),
        ],
      ),
    );
  }
  */

  void onPlayAudio() {
    final WordState wordState = ref.read(wordControllerProvider);
    final FlutterTts tts = ref.read(ttsProvider);
    final AudioPlayer audioPlayer = ref.read(audioPlayerProvider);
    final String word = wordState.currentWord;
    debugPrint('TeachWordView: Playing audio for word $word.');
    
    if (wordState.isBpmf) {
      audioPlayer.play(AssetSource('bopomo/$word.mp3'));
    } else {
      tts.speak(word);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    strokeController?.dispose();
    super.dispose();
    debugPrint("TeachWordView: TabController and other resources disposed.");
  }

  void prevTab() async {
    final WordState wordState = ref.read(wordControllerProvider);
    final NavigationState navigationState = ref.read(navigationStateProvider);
    final int currentTab = navigationState.currentTab;
    final int nextTab = math.max(currentTab - 1, 0);
    debugPrint('TeachWordView: Navigating to previous tab $nextTab.');
    ref.read(navigationStateProvider.notifier).state = navigationState.copyWith(
      currentTab: nextTab,
      canNavigateNext: nextTab < 3 && !wordState.isLearned,
      canNavigatePrev: nextTab > 0,
    );
    _tabController.animateTo(nextTab);
  }

  void nextTab() async {
    final WordState wordState = ref.read(wordControllerProvider);
    final NavigationState navigationState = ref.read(navigationStateProvider);
    final int currentTab = navigationState.currentTab;
    final int nextTab = math.min(currentTab + 1, 3);
    debugPrint('TeachWordView: Navigating to next tab $nextTab.');
    ref.read(navigationStateProvider.notifier).state = navigationState.copyWith(
      currentTab: nextTab,
      canNavigateNext: nextTab < 3 && !wordState.isLearned,
      canNavigatePrev: nextTab > 0,
    );
    _tabController.animateTo(nextTab);
  }

  void handleGoToUse() {
    final WordState wordState = ref.read(wordControllerProvider);
    final NavigationState navigationState = ref.read(navigationStateProvider);
    final int currentTab = navigationState.currentTab;
    final int nextTab = 3;
    debugPrint('TeachWordView: Navigating to Use from tab $currentTab to tab $nextTab.');
    ref.read(navigationStateProvider.notifier).state = navigationState.copyWith(
      currentTab: nextTab,
      canNavigateNext: nextTab < 3 && !wordState.isLearned,
      canNavigatePrev: nextTab > 0,
    );
    _tabController.animateTo(nextTab);
  }
  


  @override
  Widget build(BuildContext context) {
    final ScreenInfo screenInfo = ref.watch(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    debugPrint('TeachWordView: Building with fontSize ${screenInfo.fontSize}');
    
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      // appBar: _buildAppBar(screenInfo),
      appBar: _buildAppBar(screenInfo.screenWidth, fontSize, widget.unitId, widget.unitTitle),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LookTab(
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            wordIndex: widget.wordIndex,
            onNextTab: () => navigateNextTab(_tabController), 
            onPreviousTab: () => navigatePreviousTab(_tabController),             
            onPlayAudio: onPlayAudio, 
            tabController: _tabController,
            isBpmf: isBpmf,
            svgFileExist: svgFileExist,
            wordIsLearned: wordIsLearned,
            ),
          ListenTab(
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            wordIndex: widget.wordIndex,
            onNextTab: () => navigateNextTab(_tabController), 
            onPreviousTab: () => navigatePreviousTab(_tabController),   
            onPlayAudio: onPlayAudio, 
            tabController: _tabController,
            isBpmf: isBpmf,
            svgFileExist: svgFileExist,
            wordIsLearned: wordIsLearned,
            ),
          WriteTab(
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            wordIndex: widget.wordIndex,            
            onNextTab: () => navigateNextTab(_tabController), 
            onPreviousTab: () => navigatePreviousTab(_tabController),   
            onPlayAudio: onPlayAudio,
            tabController: _tabController,
            isBpmf: isBpmf,
            svgFileExist: svgFileExist,
            svgData: svgData,
            wordIsLearned: wordIsLearned,          
            strokeController: strokeController,            
            ),
          UseTab(
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            wordIndex: widget.wordIndex,          
            onNextTab: () => navigateNextTab(_tabController), 
            onPreviousTab: () => navigatePreviousTab(_tabController),   
            onPlayAudio: onPlayAudio,
            tabController: _tabController,
            isBpmf: isBpmf,
            svgFileExist: svgFileExist,
            wordIsLearned: wordIsLearned,   
            img1Exist: img1Exist,
            img2Exist: img2Exist,   
            vocabCnt: vocabCnt,      
            wordObj: wordObj,              
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(screenInfo),
    );
  }

  PreferredSize _buildAppBar(double deviceWidth, double fontSize, int unitId, String unitTitle) {
    return PreferredSize(
      preferredSize: Size(deviceWidth, kToolbarHeight * 2),
      child: Center(
        child: SizedBox(
          width: deviceWidth,
          child: AppBar(
            // backgroundColor: Colors.blueAccent,
            title: _buildUnitTitle(fontSize, unitId, unitTitle),
            leading: IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.white, size: fontSize * 1.5),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.home_filled, color: Colors.white, size: fontSize * 1.5),
                onPressed: () => navigateWithProvider(context, '/mainPage', ref),
              ),
            ],
            bottom: _buildTabBar(fontSize),
          ),
        ),
      )
    );
  }

  Widget _buildUnitTitle(double fontSize, int unitId, String unitTitle) {
    return Text(
      unitId == -1 ? unitTitle : "${unitId.toString().padLeft(2, '0')} | $unitTitle",
      style: TextStyle(fontSize: fontSize * 1.2, color: Colors.white),
      textAlign: TextAlign.center,
    );
  }

  TabBar _buildTabBar(double fontSize) {
    return TabBar(
      tabs: [
        Tab(icon: Icon(Icons.image, size: fontSize * 0.75)),
        Tab(icon: Icon(Icons.hearing, size: fontSize * 0.75)),
        Tab(icon: Icon(Icons.create, size: fontSize * 0.75)),
        Tab(icon: Icon(Icons.school, size: fontSize * 0.75)),
      ],
      controller: _tabController,
      onTap: (index) {
        _tabController.index = currentTabIndex.value;
      },
      labelColor: darkBrown,
      dividerColor: mediumGray,
      unselectedLabelColor: mediumGray,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),
      indicator: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        color: mediumGray,
      ),
    );
  }

  Widget _buildBottomBar(ScreenInfo screenInfo) {
    final WordState wordState = ref.watch(wordControllerProvider);
    return Container(
      height: 4.0 * screenInfo.fontSize,
      color: darkBrown,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenInfo.fontSize),
        child: LeftRightSwitch(
          fontSize: screenInfo.fontSize,
          iconsColor: whiteColor, // beige
          iconsSize: screenInfo.fontSize * 2.0,
          rightBorder: false,
          middleWidget: WordCard(
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            wordIndex: widget.wordIndex,
            sizedBoxWidth: 10 * screenInfo.fontSize,
            sizedBoxHeight: 4.0 * screenInfo.fontSize,
            fontSize: screenInfo.fontSize * 1.2,
            isBpmf: wordState.isBpmf,
            isVertical: false,
            disable: true,
          ),
          isFirst: (widget.wordIndex == 0),
          isLast: (widget.wordIndex == widget.wordsStatus.length - 1),
          onLeftClicked: widget.wordIndex > 0
              ? () => _navigateToWord(-1)
              : null,
          onRightClicked: widget.wordIndex < widget.wordsStatus.length - 1
              ? () => _navigateToWord(1)
              : null,
        ),
      ),
    );
  }

  void _navigateToWord(int offset) {
    navigateWithProvider(
      context,
      '/teachWord',
      ref,
      arguments: {
        'unitId': widget.unitId,
        'unitTitle': widget.unitTitle,
        'wordsStatus': widget.wordsStatus,
        'wordsPhrase': widget.wordsPhrase,
        'wordIndex': widget.wordIndex + offset,
      },
    );    
  }

}


