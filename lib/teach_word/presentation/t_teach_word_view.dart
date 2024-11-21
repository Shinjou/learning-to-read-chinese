// lib/teach_word/presentation/teach_word_view.dart


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
  final int widgetId;

  const TeachWordView({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
    required this.widgetId,
  });

  @override
  TeachWordViewState createState() => TeachWordViewState();
}

class TeachWordViewState extends ConsumerState<TeachWordView> with TickerProviderStateMixin {
  bool _isInitialized = false;
  late TabController _tabController;
  late FlutterTts ftts;
  late AudioPlayer player;
  String word = '';
  bool firstNullStrokeFlag = true;
  bool showErrorFlag = false;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    debugPrint('TeachWordView: Initializing components. widgetId: ${widget.widgetId}');    
  }

  void _initializeComponents() async {
    word = widget.wordsStatus[widget.wordIndex].word;
    _initializeTts();
    _initializeTabController();
    await _initializeWordState();
  }

  void _initializeTts() {
    ftts = ref.read(ttsProvider);
    player = ref.read(audioPlayerProvider);
  }

  void _initializeTabController() {
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    debugPrint('TeachWordView: TabController initialized.');    
  }

  Future<void> _initializeWordState() async {
    final isBpmf = initials.contains(word) ||
        prenuclear.contains(word) ||
        finals.contains(word);

    // Process word data
    final Map wordObj = await _processWordData();
    final int vocabCnt = _calculateVocabCount(wordObj);
    final String svgData = await _loadSvgData(word);
    final bool svgFileExist = svgData.isNotEmpty;

    // Initialize state
    ref.read(wordStateProvider.notifier).initialize(
      word: word,
      unitId: widget.unitId,
      unitTitle: widget.unitTitle,
      isBpmf: isBpmf,
      svgFileExist: svgFileExist,
      svgData: svgData,
      wordObj: wordObj,
      vocabCnt: vocabCnt,
      isLearned: widget.wordsStatus[widget.wordIndex].learned,
      wordStatus: widget.wordsStatus[widget.wordIndex],
    );

    // Initialize write state if SVG exists
    if (svgFileExist) {
      final strokeController = StrokeOrderAnimationController(
        svgData,
        this,
        onQuizCompleteCallback: _handleQuizCompletion,
      );

      final writeState = WriteState(
        strokeController: strokeController,
      );

      ref.read(wordStateProvider.notifier).setWriteState(writeState);
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<Map> _processWordData() async {
    if (widget.wordsPhrase.isEmpty || widget.wordIndex >= widget.wordsPhrase.length) {
      debugPrint('getWord error: wordsPhrase is empty or index out of range');
      return {};
    }
    return widget.wordsPhrase[widget.wordIndex];
  }

  int _calculateVocabCount(Map wordObj) {
    int count = 0;
    if (wordObj['vocab1']?.isNotEmpty ?? false) count++;
    if (wordObj['vocab2']?.isNotEmpty ?? false) count++;
    return count;
  }

  Future<String> _loadSvgData(String word) async {
    try {
      final String response = await rootBundle.loadString('lib/assets/svg/$word.json');
      return response.replaceAll("\"", "'");
    } catch (e) {
      debugPrint('Error loading SVG data: $e');
      return '';
    }
  }

  void _handleTabChange() {
    final wordState = ref.read(wordStateProvider);
    if (wordState == null) return;

    ref.read(wordStateProvider.notifier).updateTabIndex(_tabController.index);
    ref.read(navigationStateProvider.notifier).state = NavigationState(
      currentTab: _tabController.index,
      canNavigateNext: _tabController.index < 3 && !wordState.isLearned,
      canNavigatePrev: _tabController.index > 0,
    );
    debugPrint('_handleTabChange: Tab changed to index ${_tabController.index}.');
  }

  void _handleQuizCompletion(QuizSummary summary) {
    final wordState = ref.read(wordStateProvider);
    if (wordState?.writeState == null) return;

    ref.read(wordStateProvider.notifier).updateWriteState((writeState) {
      final newTimeLeft = writeState.practiceTimeLeft - 1;
      final newStepId = writeState.nextStepId + 1;

      if (newTimeLeft == 0) {
        ref.read(wordStateProvider.notifier).updateLearnedStatus(true);
      }

      return writeState.copyWith(
        practiceTimeLeft: newTimeLeft,
        nextStepId: newStepId,
      );
    });
  }

  void onPlayAudio() {
    final wordState = ref.read(wordStateProvider);
    if (wordState == null) return;

    if (wordState.config.isBpmf) {
      player.play(AssetSource('bopomo/${wordState.config.word}.mp3'));
    } else {
      ftts.speak(wordState.config.word);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
    debugPrint("TeachWordView: TabController and other resources disposed.");
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    final wordState = ref.watch(wordStateProvider);
    
    if (!_isInitialized || wordState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(screenInfo.screenWidth, screenInfo.fontSize),
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
            isBpmf: wordState.config.isBpmf,
            svgFileExist: wordState.config.svgFileExist,
            wordIsLearned: wordState.isLearned,
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
            isBpmf: wordState.config.isBpmf,
            svgFileExist: wordState.config.svgFileExist,
            wordIsLearned: wordState.isLearned,
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
            isBpmf: wordState.config.isBpmf,
            svgFileExist: wordState.config.svgFileExist,
            svgData: wordState.config.svgData,
            wordIsLearned: wordState.isLearned,
            strokeController: wordState.writeState?.strokeController,
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
            isBpmf: wordState.config.isBpmf,
            svgFileExist: wordState.config.svgFileExist,
            wordIsLearned: wordState.isLearned,
            img1Exist: wordState.config.img1Exist,
            img2Exist: wordState.config.img2Exist,
            vocabCnt: wordState.config.vocabCnt,
            wordObj: wordState.config.wordObj,
            widgetId: widget.widgetId,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(screenInfo),
    );
  }

  // ... rest of your existing build methods (_buildAppBar, _buildBottomBar, etc.)
  // These methods remain largely unchanged, just updated to use wordState
}



// additional error handling

// lib/teach_word/presentation/teach_word_view.dart

class TeachWordViewState extends ConsumerStatefulWidget {
  // ... existing code ...

  Future<void> _initializeComponents() async {
    try {
      word = widget.wordsStatus[widget.wordIndex].word;
      _initializeTts();
      _initializeTabController();
      await _initializeWordState();
    } catch (e, stackTrace) {
      debugPrint('Error initializing components: $e\n$stackTrace');
      _showErrorDialog('Initialization Error', 
        'Failed to initialize components. Please restart the app.');
    }
  }

  Future<void> _initializeWordState() async {
    try {
      // Input validation
      if (widget.wordIndex >= widget.wordsStatus.length) {
        throw Exception('Word index out of range');
      }
      if (word.isEmpty) {
        throw Exception('Word cannot be empty');
      }

      final isBpmf = initials.contains(word) ||
          prenuclear.contains(word) ||
          finals.contains(word);

      // Process word data with error handling
      final Map wordObj = await _processWordData();
      if (wordObj.isEmpty) {
        throw Exception('Invalid word data');
      }

      final int vocabCnt = _calculateVocabCount(wordObj);
      final String svgData = await _loadSvgData(word);
      final bool svgFileExist = svgData.isNotEmpty;

      // Initialize state
      ref.read(wordStateProvider.notifier).initialize(
        word: word,
        unitId: widget.unitId,
        unitTitle: widget.unitTitle,
        isBpmf: isBpmf,
        svgFileExist: svgFileExist,
        svgData: svgData,
        wordObj: wordObj,
        vocabCnt: vocabCnt,
        isLearned: widget.wordsStatus[widget.wordIndex].learned,
        wordStatus: widget.wordsStatus[widget.wordIndex],
      );

      // Initialize write state if SVG exists
      if (svgFileExist) {
        await _initializeWriteState(svgData);
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e, stackTrace) {
      debugPrint('Error initializing word state: $e\n$stackTrace');
      _showErrorDialog('初始化錯誤', 
        '無法初始化「$word」。錯誤：${_getLocalizedError(e)}');
    }
  }

  Future<void> _initializeWriteState(String svgData) async {
    try {
      if (!mounted) return;

      final strokeController = StrokeOrderAnimationController(
        svgData,
        this,
        onQuizCompleteCallback: _handleQuizCompletion,
      );

      final writeState = WriteState(
        strokeController: strokeController,
      );

      ref.read(wordStateProvider.notifier).setWriteState(writeState);
    } catch (e, stackTrace) {
      debugPrint('Error initializing write state: $e\n$stackTrace');
      throw Exception('Failed to initialize write functionality');
    }
  }

  Future<Map> _processWordData() async {
    try {
      if (widget.wordsPhrase.isEmpty) {
        throw Exception('Words phrase list is empty');
      }
      if (widget.wordIndex >= widget.wordsPhrase.length) {
        throw Exception('Word index out of range');
      }

      final wordData = widget.wordsPhrase[widget.wordIndex];
      if (wordData == null) {
        throw Exception('Word data is null');
      }

      return wordData;
    } catch (e, stackTrace) {
      debugPrint('Error processing word data: $e\n$stackTrace');
      return {};
    }
  }

  Future<String> _loadSvgData(String word) async {
    try {
      if (word.isEmpty) {
        throw Exception('Word cannot be empty');
      }

      final String response = await rootBundle.loadString(
        'lib/assets/svg/$word.json',
      );
      
      if (response.isEmpty) {
        throw Exception('SVG data is empty');
      }

      return response.replaceAll("\"", "'");
    } catch (e, stackTrace) {
      debugPrint('Error loading SVG data for $word: $e\n$stackTrace');
      // Check if the error is due to missing file
      if (e is FlutterError && e.toString().contains('Unable to load asset')) {
        _handleMissingSvg(word);
        return '';
      }
      // For other errors
      _showErrorDialog('SVG 錯誤', 
        '無法載入「$word」的筆順資料。請確認檔案存在且格式正確。');
      return '';
    }
  }

  void _handleMissingSvg(String word) {
    // Check if it's a known case of missing SVG
    if (_isKnownMissingSvg(word)) {
      debugPrint('Known word without SVG: $word');
      return;
    }
    _showErrorDialog('檔案遺失', 
      '「$word」的筆順檔案遺失。請截圖回報。謝謝！');
  }

  bool _isKnownMissingSvg(String word) {
    const knownMissingSvgs = [
      '吔', '姍', '媼', '嬤', '履', '搧', '枴', '椏', '欓', '汙',
      '溼', '漥', '痠', '礫', '粄', '粿', '綰', '蓆', '襬', '譟',
      '踖', '踧', '鎚', '鏗', '鏘', '陳', '颺', '齒'
    ];
    return knownMissingSvgs.contains(word);
  }

  void _handleQuizCompletion(QuizSummary summary) {
    try {
      final wordState = ref.read(wordStateProvider);
      if (wordState?.writeState == null) {
        throw Exception('Write state is not initialized');
      }

      ref.read(wordStateProvider.notifier).updateWriteState((writeState) {
        final newTimeLeft = writeState.practiceTimeLeft - 1;
        if (newTimeLeft < 0) {
          throw Exception('Practice time cannot be negative');
        }

        final newStepId = writeState.nextStepId + 1;
        
        if (newTimeLeft == 0) {
          ref.read(wordStateProvider.notifier).updateLearnedStatus(true);
        }

        return writeState.copyWith(
          practiceTimeLeft: newTimeLeft,
          nextStepId: newStepId,
        );
      });
    } catch (e, stackTrace) {
      debugPrint('Error handling quiz completion: $e\n$stackTrace');
      _showErrorDialog('練習錯誤', 
        '處理練習結果時發生錯誤。請重試。');
    }
  }

  void _showErrorDialog(String title, String message) {
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
          TextButton(
            child: const Text('重試'),
            onPressed: () {
              Navigator.of(context).pop();
              _initializeComponents();
            },
          ),
        ],
      ),
    );
  }

  String _getLocalizedError(dynamic error) {
    // Convert common errors to user-friendly Chinese messages
    if (error.toString().contains('Word index out of range')) {
      return '字索引超出範圍';
    }
    if (error.toString().contains('Word cannot be empty')) {
      return '字不能為空';
    }
    // Add more error translations as needed
    return error.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Add error boundary widget
    return ErrorBoundary(
      onError: (error, stackTrace) {
        debugPrint('Caught error in build: $error\n$stackTrace');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('發生錯誤'),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/mainPage'),
                child: const Text('回首頁'),
              ),
            ],
          ),
        );
      },
      child: // ... rest of your build method
    );
  }
}

// Add ErrorBoundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace) onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    required this.onError,
  }) : super(key: key);

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();
}

class ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void componentDidCatch(Object error, StackTrace? stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.onError(_error!, _stackTrace);
    }
    return widget.child;
  }
}

// Additional performance improvements

