// lib/teach_word/notifiers/speech_state_notifier.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ltrc/teach_word/models/speech_state.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
import 'package:ltrc/teach_word/services/speech_service.dart';

class SpeechStateNotifier extends StateNotifier<SpeechState> {
  final SpeechService _speechService;
  final AudioPlayer _audioPlayer;
  final Function(String) _onError;
  Timer? _countdownTimer;
  Timer? _elapsedTimer;
  final Completer<void> longBeepCompleter = Completer<void>();
  int _elapsedSeconds = 0;
  // static int? _lastBeepedValue; // Prevent duplicate beeps
  StreamSubscription? _playerCompleteSubscription;

  SpeechStateNotifier(
    this._speechService,
    this._audioPlayer, {
    required Function(String) onError,
    required String initialLocaleId,
  })  : _onError = onError,
        super(SpeechState(localeId: initialLocaleId)) {
    _setupPlayerListener();
  }

  void _setupPlayerListener() {
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        state = state.copyWith(isPlaying: false);
      }
    });
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;
    final success = await _speechService.initialize();
    state = state.copyWith(
      isInitialized: success,
      error: success ? null : 'Failed to initialize STT',
    );
  }

  Future<void> preloadAllBeeps() async {
    try {
      await _audioPlayer.setSource(AssetSource('sounds/short_beep.mp3'));
      await _audioPlayer.setSource(AssetSource('sounds/long_beep.mp3'));
      debugPrint('${formattedActualTime()} Preloaded all beep files.');
    } catch (e) {
      debugPrint('${formattedActualTime()} Error preloading beep files: $e');
    }
  }

  void startCountdown() {
    debugPrint('${formattedActualTime()} Starting countdown...');

    if (!state.isInitialized) {
      initialize();
    }

    const int initialCountdownValue = 3;
    state = state.copyWith(
      state: RecordingState.countdown,
      countdownValue: initialCountdownValue,
    );

    _countdownTimer?.cancel();

    // Play the first short beep immediately
    debugPrint('${formattedActualTime()} Countdown tick: $initialCountdownValue. Play first short beep.');
    _playBeep('short').then((_) {
      debugPrint('${formattedActualTime()} First short beep completed.');

      // Start periodic countdown
      _countdownTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final currentCount = state.countdownValue;
        if (currentCount > 1) {
          state = state.copyWith(countdownValue: currentCount - 1);
          await _playBeep('short');
        } else {
          timer.cancel();
          state = state.copyWith(countdownValue: 0);
          await _playBeep('long');
          _startListeningFlow();
        }
      });

    });
  }

  Future<void> _playBeep(String type) async {
    final startTime = DateTime.now();
    final isLongBeep = type == 'long';

    try {
      final source = type == 'short'
          ? AssetSource('sounds/short_beep.mp3')
          : AssetSource('sounds/long_beep.mp3');

      await _audioPlayer.stop();
      debugPrint('${formattedActualTime()} Previous playback stopped.');

      debugPrint('${formattedActualTime()} Initiating $type beep playback.');
      await _audioPlayer.setSource(source);
      await _audioPlayer.resume();

      // Adjust buffer based on file type
      final durationBuffer = isLongBeep ? Duration(milliseconds: 500) : Duration(milliseconds: 150);
      // final durationBuffer = isLongBeep ? Duration(milliseconds: 200) : Duration(milliseconds: 100);
      await Future.delayed(durationBuffer);

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('${formattedActualTime()} $type beep played in $elapsed ms.');
    } catch (e) {
      debugPrint('${formattedActualTime()} Error playing $type beep: $e');
    }
  }

  Future<void> _startListeningFlow() async {
    debugPrint('${formattedActualTime()} Starting listening flow...');

    if (state.state == RecordingState.listening) {
      debugPrint('${formattedActualTime()} Already in listening state. Skipping start.');
      return;
    }

    try {
      // Start both recording and listening in parallel
      final recordingFuture = _speechService.startRecording();
      final listeningFuture = _speechService.startListening(
        localeId: state.localeId,
        onResult: (text, finalResult) {
          if (!mounted) return;
          state = state.copyWith(transcribedText: text);
        },
        onAudioLevel: (level) {},
      );

      // Wait for both to complete
      await recordingFuture;
      final recordingElapsed = DateTime.now().difference(DateTime.now()).inMilliseconds;
      debugPrint('${formattedActualTime()} startRecording completed in $recordingElapsed ms.');

      await listeningFuture;
      final listeningElapsed = DateTime.now().difference(DateTime.now()).inMilliseconds;
      debugPrint('${formattedActualTime()} startListening completed in $listeningElapsed ms.');

      _elapsedSeconds = 0;
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) => _elapsedSeconds++);

      state = state.copyWith(state: RecordingState.listening, isListening: true);
      debugPrint('${formattedActualTime()} Listening started.');
    } catch (e) {
      debugPrint('${formattedActualTime()} Error starting listening flow: $e');
      state = state.copyWith(error: e.toString());
    }
  }  

  Future<void> stopListening() async {
    await _speechService.stopListening();
    final path = await _speechService.stopRecording();

    _elapsedTimer?.cancel();
    if (!mounted) return;
    state = state.copyWith(
      state: RecordingState.finished,
      isListening: false,
      recordingPath: path,
      recordingSeconds: _elapsedSeconds,
    );
  }

  Future<void> playRecording() async {
    if (state.recordingPath == null || state.isPlaying) return;
    state = state.copyWith(isPlaying: true);
    try {
      await _audioPlayer.play(DeviceFileSource(state.recordingPath!));
    } catch (e) {
      handleError('Failed to play recording: $e');
      state = state.copyWith(isPlaying: false);
    }
  }

  void retry() {
    state = SpeechState(localeId: state.localeId);
  }

  void resetPractice() {
    state = SpeechState(localeId: state.localeId);
  }

  void handleError(String error) {
    _onError(error);
    if (!mounted) return;
    state = state.copyWith(
      error: error,
      state: RecordingState.idle,
      isListening: false,
    );
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel(); // Ensure listener is cleaned up
    _countdownTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }  
}

