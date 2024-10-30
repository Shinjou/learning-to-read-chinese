// tabs/use_tab_integration.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/teach_word/bpmf_vocab_content.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/word_vocab_content.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

class UseTab extends StatefulWidget {
  final TeachWordState state;
  final Map<String, dynamic> wordsPhrase;
  final TeachWordControllers controllers;
  final ScreenInfo screenInfo;

  const UseTab({
    super.key,
    required this.state,
    required this.wordsPhrase,
    required this.controllers,
    required this.screenInfo,
  });

  @override
  UseTabState createState() => UseTabState();
}

class UseTabState extends State<UseTab> {
  late final VocabContentController _contentController;
  late final AudioController _audioController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _contentController = VocabContentController(
      onVocabComplete: _handleVocabComplete,
      onVocabRetry: _handleVocabRetry,
    );
    
    _audioController = AudioController(
      onPlayComplete: _handleAudioComplete,
      onPlayError: _handleAudioError,
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TeachWordTabBarView(
      content: _UseTabContent(
        state: widget.state,
        wordsPhrase: widget.wordsPhrase,
        contentController: _contentController,
        audioController: _audioController,
        screenInfo: widget.screenInfo,
        onNavigatePrevious: _handlePrevious,
        onNavigateNext: _handleNext,
      ),
    );
  }

  // Event Handlers
  void _handleVocabComplete() {
    debugPrint('Vocabulary completed');
    widget.controllers.handleNextInUseTab(widget.state, context.read); // Notify next step in the controllers
  }

  void _handleVocabRetry() {
    debugPrint('Retrying vocabulary');
  }

  void _handleAudioComplete() {
    debugPrint('Audio playback completed');
  }

  void _handleAudioError(String error) {
    debugPrint('Audio playback error: $error');
  }

  void _handlePrevious() {
    debugPrint('Navigating to previous vocab');
    widget.controllers.handlePreviousInUseTab(widget.state, context.read); // Passing WidgetRef context
  }

  void _handleNext() {
    debugPrint('Navigating to next vocab');
    widget.controllers.handleNextInUseTab(widget.state, context.read); // Passing WidgetRef context
  }
}

// Controllers for managing content and audio state
class VocabContentController extends ChangeNotifier {
  final VoidCallback onVocabComplete;
  final VoidCallback onVocabRetry;
  
  bool _isAnswerCorrect = false;
  String _selectedWord = '';
  String _message = '';

  bool get isAnswerCorrect => _isAnswerCorrect;
  String get selectedWord => _selectedWord;
  String get message => _message;

  VocabContentController({
    required this.onVocabComplete,
    required this.onVocabRetry,
  });

  void setAnswer(bool isCorrect, String word) {
    debugPrint('Setting answer: $word is correct? $isCorrect');
    _isAnswerCorrect = isCorrect;
    _selectedWord = word;
    _message = isCorrect ? '答對了！' : '再試試！';
    notifyListeners();

    if (isCorrect) {
      onVocabComplete();
    } else {
      onVocabRetry();
    }
  }

  void reset() {
    debugPrint('Resetting vocab content controller');
    _isAnswerCorrect = false;
    _selectedWord = '';
    _message = '';
    notifyListeners();
  }
}

class AudioController {
  final VoidCallback onPlayComplete;
  final Function(String) onPlayError;
  
  final FlutterTts _tts = FlutterTts();
  bool _isPlaying = false;

  AudioController({
    required this.onPlayComplete,
    required this.onPlayError,
  }) {
    _initializeTts();
  }

  void _initializeTts() {
    _tts.setLanguage("zh-tw");
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      debugPrint('Audio playback complete');
      _isPlaying = false;
      onPlayComplete();
    });
    _tts.setErrorHandler((msg) {
      debugPrint('Audio playback error: $msg');
      _isPlaying = false;
      onPlayError(msg.toString());
    });
  }

  Future<void> speak(String text) async {
    debugPrint('TTS speaking: $text');
    if (_isPlaying) {
      await _tts.stop();
      debugPrint('Stopped current TTS playback');
    }
    _isPlaying = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    debugPrint('Stopping audio playback');
    if (_isPlaying) {
      await _tts.stop();
      _isPlaying = false;
    }
  }

  void dispose() {
    debugPrint('Disposing TTS controller');
    _tts.stop();
  }
}

// Content Widget
class _UseTabContent extends StatelessWidget {
  final TeachWordState state;
  final Map wordsPhrase;
  final VocabContentController contentController;
  final AudioController audioController;
  final ScreenInfo screenInfo;
  final VoidCallback onNavigatePrevious;
  final VoidCallback onNavigateNext;

  const _UseTabContent({
    required this.state,
    required this.wordsPhrase,
    required this.contentController,
    required this.audioController,
    required this.screenInfo,
    required this.onNavigatePrevious,
    required this.onNavigateNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildContent(),
            ],
          ),
        ),
        Positioned(
          right: screenInfo.fontSize,
          bottom: screenInfo.fontSize,
          child: _buildPageIndicator(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return state.isBpmf
        ? BopomofoVocabContent(
            word: state.word,
            vocab: _getCurrentVocab(),
            sentence: _getCurrentSentence(),
            audioController: audioController,
            onComplete: contentController.onVocabComplete, // Link the vocab completion here
          )
        : WordVocabContent(
            vocab: _getCurrentVocab(),
            meaning: _getCurrentMeaning(),
            sentence: _getCurrentSentence(),
            vocab2: _getNextVocab(),
            contentController: contentController,
            audioController: audioController,
            onComplete: contentController.onVocabComplete, // Link completion callback here
          );
  }

  Widget _buildPageIndicator() {
    return Text(
      "${state.vocabIndex + 1} / ${state.vocabCnt}",
      style: TextStyle(
        fontSize: screenInfo.fontSize * 0.75,
        color: Colors.black,
      ),
    );
  }

  // Helper methods for accessing vocabulary data
  String _getCurrentVocab() => wordsPhrase['vocab${state.vocabIndex + 1}'] ?? '';
  String _getCurrentMeaning() => wordsPhrase['meaning${state.vocabIndex + 1}'] ?? '';
  String _getCurrentSentence() => wordsPhrase['sentence${state.vocabIndex + 1}'] ?? '';
  String _getNextVocab() {
    int nextIndex = (state.vocabIndex + 1) % state.vocabCnt + 1;
    return wordsPhrase['vocab$nextIndex'] ?? '';
  }
}
