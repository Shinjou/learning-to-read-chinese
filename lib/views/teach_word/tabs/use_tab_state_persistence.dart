// tabs/use_tab_state_persistence.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences.dart';

// State persistence manager
class UseTabStateManager {
  static const String _keyPrefix = 'use_tab_state_';
  final String _wordId;
  
  UseTabStateManager(this._wordId);

  // Keys for different state aspects
  String get _vocabIndexKey => '${_keyPrefix}vocab_index_$_wordId';
  String get _completedVocabsKey => '${_keyPrefix}completed_vocabs_$_wordId';
  String get _currentProgressKey => '${_keyPrefix}current_progress_$_wordId';

  // Save state
  Future<void> saveState({
    required int vocabIndex,
    required List<String> completedVocabs,
    required Map<String, dynamic> currentProgress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_vocabIndexKey, vocabIndex);
    await prefs.setStringList(_completedVocabsKey, completedVocabs);
    await prefs.setString(_currentProgressKey, json.encode(currentProgress));
  }

  // Restore state
  Future<UseTabRestoredState?> restoreState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (!prefs.containsKey(_vocabIndexKey)) {
        return null;
      }

      return UseTabRestoredState(
        vocabIndex: prefs.getInt(_vocabIndexKey) ?? 0,
        completedVocabs: prefs.getStringList(_completedVocabsKey) ?? [],
        currentProgress: json.decode(prefs.getString(_currentProgressKey) ?? '{}'),
      );
    } catch (e) {
      debugPrint('Error restoring state: $e');
      return null;
    }
  }

  // Clear state
  Future<void> clearState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vocabIndexKey);
    await prefs.remove(_completedVocabsKey);
    await prefs.remove(_currentProgressKey);
  }
}

// Enhanced UseTab with state persistence and edge case handling
class UseTab extends StatefulWidget {
  // ... existing properties ...

  @override
  UseTabState createState() => UseTabState();
}

class UseTabState extends State<UseTab> with WidgetsBindingObserver {
  late final UseTabStateManager _stateManager;
  late final TabFocusHandler _focusHandler;
  late final AudioStateManager _audioManager;
  late final ErrorHandler _errorHandler;
  Timer? _autoSaveTimer;
  bool _isRestoringState = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeManagers();
    _setupAutoSave();
    _restoreState();
  }

  void _initializeManagers() {
    _stateManager = UseTabStateManager(widget.state.word);
    _focusHandler = TabFocusHandler(
      onFocusGained: _handleTabFocused,
      onFocusLost: _handleTabUnfocused,
    );
    _audioManager = AudioStateManager(
      onInterruption: _handleAudioInterruption,
      onError: _handleAudioError,
    );
    _errorHandler = ErrorHandler(
      onError: _handleError,
      onRecovery: _handleErrorRecovery,
    );
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveCurrentState(),
    );
  }

  Future<void> _restoreState() async {
    setState(() => _isRestoringState = true);
    
    try {
      final restoredState = await _stateManager.restoreState();
      if (restoredState != null) {
        _applyRestoredState(restoredState);
      }
    } catch (e) {
      _errorHandler.handleError(
        ErrorType.stateRestoration,
        error: e,
        context: context,
      );
    } finally {
      setState(() => _isRestoringState = false);
    }
  }

  void _applyRestoredState(UseTabRestoredState state) {
    setState(() {
      widget.state.vocabIndex = state.vocabIndex;
      // Apply other restored state properties
    });
  }

  Future<void> _saveCurrentState() async {
    if (_isRestoringState) return;

    try {
      await _stateManager.saveState(
        vocabIndex: widget.state.vocabIndex,
        completedVocabs: _getCompletedVocabs(),
        currentProgress: _getCurrentProgress(),
      );
    } catch (e) {
      _errorHandler.handleError(
        ErrorType.stateSaving,
        error: e,
        context: context,
      );
    }
  }

  // Edge case handling
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      default:
        break;
    }
  }

  void _handleAppPaused() {
    _audioManager.pauseAudio();
    _saveCurrentState();
  }

  void _handleAppResumed() {
    _restoreState();
  }

  void _handleTabFocused() {
    _audioManager.resumeAudio();
    _restoreState();
  }

  void _handleTabUnfocused() {
    _audioManager.pauseAudio();
    _saveCurrentState();
  }

  void _handleAudioInterruption() {
    _audioManager.handleInterruption();
  }

  void _handleAudioError(AudioError error) {
    _errorHandler.handleError(
      ErrorType.audio,
      error: error,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoringState) {
      return _buildLoadingState();
    }

    return ErrorBoundary(
      onError: _handleError,
      child: TabFocusWrapper(
        handler: _focusHandler,
        child: _UseTabContent(
          state: widget.state,
          wordsPhrase: widget.wordsPhrase,
          audioManager: _audioManager,
          errorHandler: _errorHandler,
          onStateChange: _handleStateChange,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _handleStateChange() {
    _saveCurrentState();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _audioManager.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

// Error handling
class ErrorHandler {
  final Function(ErrorType, {dynamic error, BuildContext? context}) onError;
  final Function()? onRecovery;

  ErrorHandler({
    required this.onError,
    this.onRecovery,
  });

  void handleError(ErrorType type, {dynamic error, BuildContext? context}) {
    debugPrint('Error of type $type: $error');
    onError(type, error: error, context: context);
  }

  Future<void> attemptRecovery() async {
    try {
      await onRecovery?.call();
    } catch (e) {
      handleError(ErrorType.recovery, error: e);
    }
  }
}

// Audio state management
class AudioStateManager {
  final VoidCallback onInterruption;
  final Function(AudioError) onError;
  
  bool _isPlaying = false;
  final FlutterTts _tts = FlutterTts();
  AudioFocus? _audioFocus;

  AudioStateManager({
    required this.onInterruption,
    required this.onError,
  }) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      await _tts.setLanguage("zh-tw");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      
      _tts.setCompletionHandler(() {
        _isPlaying = false;
      });

      _tts.setErrorHandler((msg) {
        _isPlaying = false;
        onError(AudioError(msg.toString()));
      });

      _initializeAudioFocus();
    } catch (e) {
      onError(AudioError(e.toString()));
    }
  }

  Future<void> _initializeAudioFocus() async {
    _audioFocus = await AudioFocus.requestFocus(
      onFocusChange: (focus) {
        if (focus == AudioFocusState.loss) {
          pauseAudio();
          onInterruption();
        }
      },
    );
  }

  Future<void> playAudio(String text) async {
    if (!_isPlaying) {
      try {
        final focusResult = await _audioFocus?.requestFocus();
        if (focusResult == AudioFocusRequest.granted) {
          _isPlaying = true;
          await _tts.speak(text);
        }
      } catch (e) {
        onError(AudioError(e.toString()));
      }
    }
  }

  Future<void> pauseAudio() async {
    if (_isPlaying) {
      try {
        await _tts.stop();
        _isPlaying = false;
        await _audioFocus?.abandonFocus();
      } catch (e) {
        onError(AudioError(e.toString()));
      }
    }
  }

  void dispose() {
    _tts.stop();
    _audioFocus?.abandonFocus();
  }
}

// Tab focus management
class TabFocusHandler {
  final VoidCallback onFocusGained;
  final VoidCallback onFocusLost;
  bool _hasFocus = false;

  TabFocusHandler({
    required this.onFocusGained,
    required this.onFocusLost,
  });

  void handleFocusChange(bool focused) {
    if (focused != _hasFocus) {
      _hasFocus = focused;
      if (focused) {
        onFocusGained();
      } else {
        onFocusLost();
      }
    }
  }
}
