// lib/teach_word/notifiers/speech_state_notifier.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ltrc/teach_word/models/speech_state.dart';
import 'package:ltrc/teach_word/services/speech_service.dart';

class SpeechStateNotifier extends StateNotifier<SpeechState> {
  final SpeechService _speechService;
  final AudioPlayer _audioPlayer;
  final Function(String) _onError;
  Timer? _countdownTimer;
  Timer? _elapsedTimer;
  StreamSubscription? _playerCompleteSubscription;
  int _elapsedSeconds = 0;

  void setLocale(String newLocaleId) {
    state = state.copyWith(localeId: newLocaleId);
  }

  SpeechStateNotifier(
    this._speechService,
    this._audioPlayer, {
    required Function(String) onError,
    required initialLocaleId,
  })  : _onError = onError,
        super(SpeechState()) {
    _setupPlayerListener();
  }

  void _setupPlayerListener() {
    _playerCompleteSubscription?.cancel();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        state = state.copyWith(isPlaying: false, localeId: 'zh-TW');
      }
    });
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;
    final success = await _speechService.initialize();
    state = state.copyWith(
      isInitialized: success,
      error: success ? null : 'Failed to initialize STT', localeId: 'zh-TW',
    );
  }

  void startCountdown() {
    if (!state.isInitialized) {
      initialize();
    }

    // Define the initial countdown value
    const int initialCountdownValue = 3;

    // Initialize the countdown state
    state = state.copyWith(
      state: RecordingState.countdown,
      countdownValue: initialCountdownValue,
      transcribedText: '',
      recordingSeconds: 0,
      error: null,
      localeId: 'zh-TW',
    );

    _countdownTimer?.cancel(); // Ensure any previous timer is canceled

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Update the countdown value
      final currentCount = state.countdownValue - 1;
      if (currentCount > 0) {
        debugPrint('Countdown tick: $currentCount');
        state = state.copyWith(countdownValue: currentCount, localeId: 'zh-TW');
      } else {
        // Countdown complete
        debugPrint('Countdown reached 0. Starting listening flow.');
        timer.cancel();
        state = state.copyWith(countdownValue: 0, localeId: 'zh-TW');
        _startListeningFlow();
      }
    });
  }


  Future<void> _startListeningFlow() async {
    // Start recording audio if desired
    await _speechService.startRecording();
    // Retrieve localeId from state
    final String currentLocaleId = state.localeId;
   
    // Start listening
    _speechService.startListening(
      localeId: currentLocaleId,
      onResult: (text, finalResult) {
        if (!mounted) return;
        // Update text as partial results come in
        state = state.copyWith(transcribedText: text, localeId: 'zh-TW');
      },
      onAudioLevel: (level) {
        // If you want to handle audio level
      },
    );

    _elapsedSeconds = 0;
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      // Don't update UI with elapsed time now, only after stop
    });

    state = state.copyWith(
      state: RecordingState.listening,
      isListening: true, localeId: 'zh-TW',
    );
  }

  Future<void> stopListening() async {
    // Stop STT
    await _speechService.stopListening();
    // Stop recording
    final path = await _speechService.stopRecording();

    _elapsedTimer?.cancel();
    // Now we can show elapsed time
    if (!mounted) return;
    state = state.copyWith(
      state: RecordingState.finished,
      isListening: false,
      recordingPath: path,
      recordingSeconds: _elapsedSeconds, localeId: 'zh-TW',
    );
  }

  Future<void> playRecording() async {
    if (state.recordingPath == null || state.isPlaying) return;
    state = state.copyWith(isPlaying: true, localeId: 'zh-TW');
    try {
      await _speechService.playRecording(state.recordingPath!);
    } catch (e) {
      handleError('Failed to play: $e');
      state = state.copyWith(isPlaying: false, localeId: 'zh-TW');
    }
  }

  void retry() {
    state = SpeechState();
  }

  void resetPractice() {
    state = SpeechState(); // or whatever the initial SpeechState is
  }

  void complete() {
    // Move on to next lesson or next step
  }

  void handleError(String error) {
    _onError(error);
    if (!mounted) return;
    state = state.copyWith(error: error, state: RecordingState.idle, isListening: false, localeId: 'zh-TW');
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _elapsedTimer?.cancel();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }
}


