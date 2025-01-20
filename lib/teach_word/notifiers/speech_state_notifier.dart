// lib/teach_word/notifiers/speech_state_notifier.dart

import 'dart:async';
import 'dart:io';
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

  /// iOS or first-time usage => just call .initialize(force=false)
  /// But if you want each new session on iOS to be fresh, you could force too.
  Future<void> initialize({bool force = false}) async {
    if (state.isInitialized && !force) {
      // already good
      return;
    }
    final success = await _speechService.initialize(force: force);
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

  // -------------------------------------------------------------------------
  // The main entry point for user tapping "開始朗讀"
  // -------------------------------------------------------------------------
  void startCountdown({bool isSttMode = true}) {
    debugPrint('${formattedActualTime()} Starting countdown...');

    // Always attempt to initialize. Android might 'force' re-init each session
    // iOS can skip if already initialized.
    if (!state.isInitialized) {
      initialize(force: Platform.isAndroid ? false : false); 
      // or you can do something more explicit
    }

    const int initialCountdownValue = 1;
    state = state.copyWith(
      state: RecordingState.countdown,
      countdownValue: initialCountdownValue,
    );

    _countdownTimer?.cancel();
    // Originally, I played a short beep before listening. But it caused problems
    // in the Android. Even though iOS works well, To keep the same UI, I took it out.
    // _playBeep('short');

    // Now start the correct flow
    if (Platform.isIOS) {
      // iOS => concurrency => run re-init if you want a fresh session each time
      _startIosListeningFlow();
    } else {
      // Android => re-init STT each time if isSttMode
      if (isSttMode) {
        _startAndroidSttFlow();
      } else {
        _startAndroidRecordFlow();
      }
    }
  }


  /* Android can not play beep before listening. So I took it out for both Android and iOS.
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
      final durationBuffer = isLongBeep ? const Duration(milliseconds: 500) : const Duration(milliseconds: 150);
      // final durationBuffer = isLongBeep ? Duration(milliseconds: 200) : Duration(milliseconds: 100);
      await Future.delayed(durationBuffer);

      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('${formattedActualTime()} $type beep played in $elapsed ms.');
    } catch (e) {
      debugPrint('${formattedActualTime()} Error playing $type beep: $e');
    }
  }
  */

  // iOS concurrency
  Future<void> _startIosListeningFlow() async {
    debugPrint('${formattedActualTime()} Starting iOS concurrency flow...');

    if (state.state == RecordingState.listening) {
      debugPrint('${formattedActualTime()} Already in listening state. Skipping start.');
      return;
    }

    try {
      // Possibly re-init STT for iOS if you want each session fresh
      await initialize(force: false);

      // Start both
      final recordingFuture = _speechService.startRecording();
      final listeningFuture = _speechService.startListening(
        localeId: state.localeId,
        onResult: (text, finalResult) {
          if (!mounted) return;
          state = state.copyWith(transcribedText: text);
        },
        onAudioLevel: (level) {},
      );

      // Wait for both
      await recordingFuture;
      debugPrint('${formattedActualTime()} startRecording (iOS) done.');

      await listeningFuture;
      debugPrint('${formattedActualTime()} startListening (iOS) done.');

      // Start timer
      _elapsedSeconds = 0;
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) => _elapsedSeconds++);

      state = state.copyWith(
        state: RecordingState.listening,
        isListening: true,
      );
      debugPrint('${formattedActualTime()} iOS concurrency listening started.');
    } catch (e) {
      debugPrint('${formattedActualTime()} Error in iOS concurrency: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Android STT only
  Future<void> _startAndroidSttFlow() async {
    debugPrint('${formattedActualTime()} Starting Android STT flow...');

    if (state.state == RecordingState.listening) {
      debugPrint('${formattedActualTime()} Already in listening. Skipping start.');
      return;
    }

    try {
      // Force re-init for each STT session on Android
      await initialize(force: true);

      final listeningFuture = _speechService.startListening(
        localeId: state.localeId,
        onResult: (text, finalResult) {
          if (!mounted) return;
          state = state.copyWith(transcribedText: text);
        },
        onAudioLevel: (level) {},
      );

      await listeningFuture;
      debugPrint('${formattedActualTime()} startListening (Android STT) done.');

      _elapsedSeconds = 0;
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) => _elapsedSeconds++);

      state = state.copyWith(
        state: RecordingState.listening,
        isListening: true,
      );
      debugPrint('${formattedActualTime()} Android STT listening started.');
    } catch (e) {
      debugPrint('${formattedActualTime()} Error in Android STT flow: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Android record-only
  Future<void> _startAndroidRecordFlow() async {
    debugPrint('${formattedActualTime()} Starting Android RECORD flow...');

    if (state.state == RecordingState.listening) {
      debugPrint('${formattedActualTime()} Already in listening. Skipping.');
      return;
    }

    try {
      // No need for STT re-init if we’re just recording
      final recordingFuture = _speechService.startRecording();

      await recordingFuture;
      debugPrint('${formattedActualTime()} startRecording (Android) done.');

      _elapsedSeconds = 0;
      _elapsedTimer?.cancel();
      _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) => _elapsedSeconds++);

      state = state.copyWith(
        state: RecordingState.listening,
        isListening: true,
      );
      debugPrint('${formattedActualTime()} Android record-only listening started.');
    } catch (e) {
      debugPrint('${formattedActualTime()} Error in Android record flow: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // If you still want the old concurrency for both iOS/Android, you can keep _startListeningFlow,
  // but you seem to have replaced it with specialized flows.

  Future<void> stopListening({bool isSttMode = true}) async {
    debugPrint('notifier stopListening() called...');
    try {
      _elapsedTimer?.cancel();
      state = state.copyWith(
        state: RecordingState.finished,
        isListening: false,
        // recordingPath: path,
        recordingSeconds: _elapsedSeconds,
      );      
      if (Platform.isAndroid) {
        if (isSttMode) {
          await _speechService.stopListening();
          debugPrint('stopListening() => STT stopped. state = $state');
        } else {
          final path = await _speechService.stopRecording();
          debugPrint('stopListening() => recorder stopped at $path. state = $state');
          state = state.copyWith(
            recordingPath: path,
          );                
        }
      } else { // iOS
        await _speechService.stopListening();
        debugPrint('stopListening() => STT stopped');
        final path = await _speechService.stopRecording();
        debugPrint('stopListening() => recorder stopped at $path. state = $state');
        state = state.copyWith(
          recordingPath: path,
        );                        
      }
    } catch (e) {
      debugPrint('stopListening() => error: $e');
      handleError('Error stopping listening/recording: $e');
    }
  }

  Future<void> playRecording(volume) async {
    if (state.recordingPath == null || state.isPlaying) return;
    state = state.copyWith(isPlaying: true);
    try {
      await _audioPlayer.play(DeviceFileSource(state.recordingPath!), volume: volume);
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      handleError('Failed to play recording: $e');
      state = state.copyWith(isPlaying: false);
    }
  }

  void reset() {
    state = SpeechState(localeId: state.localeId);
  }

  void updateAnswerCorrectness(bool isCorrect) {
    state = state.copyWith(isAnswerCorrect: isCorrect);
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
    _playerCompleteSubscription?.cancel();
    _countdownTimer?.cancel();
    _elapsedTimer?.cancel();
    super.dispose();
  }
}


