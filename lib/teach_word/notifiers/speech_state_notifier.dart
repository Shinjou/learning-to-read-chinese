// lib/teach_word/notifiers/speech_state_notifier.dart
// Matches providers.dart constructor and implements pre-start STT during countdown.

import 'dart:async';
// import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/models/speech_state.dart';
import 'package:ltrc/teach_word/services/speech_service.dart';

class SpeechStateNotifier extends StateNotifier<SpeechState> {
  final SpeechService _speech;
  final AudioPlayer _player;
  final void Function(String message) _uiError;

  Timer? _countdownTimer;
  DateTime? _listenStart;

  // pre-start state
  bool _preStarted = false;
  bool _listenStarted = false;
  int _msRemaining = 0;

  // Self-tuning lead time before T==0 to start STT early.
  // Shared across instances so it improves after first run.
  static int _leadMs = 900; // phone baseline
  DateTime? _listenCallAt;  // when we invoked listen()
  final bool isTablet = true; // will be set during countdown

  SpeechStateNotifier(
    this._speech,
    this._player, {
    required void Function(String) onError,
    required String initialLocaleId,
  })  : _uiError = onError,
        super(SpeechState(localeId: initialLocaleId));

  String _ts() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Future<void> ensureInitialized() async {
    if (state.isInitialized) return;
    final ok = await _speech.initialize(
      onStatus: (s) {
        debugPrint('Speech recognition status: $s');

        if (s == 'listening') {
          // measure device startup latency (from listen() call to 'listening')
          if (_listenCallAt != null) {
            final latencyMs = DateTime.now().difference(_listenCallAt!).inMilliseconds;
            debugPrint('${_ts()} STT listening after ${latencyMs}ms since listen()');

            // If latency is bigger than our current lead, increase it (cap 2000ms)
            final target = (latencyMs + 200).clamp(600, 2000);
            if (target > _leadMs) {
              _leadMs = target;
              debugPrint('${_ts()} Adjusted STT lead to ${_leadMs}ms for next runs');
            }
          }
          state = state.copyWith(isListening: true);
        } else if (s == 'notListening' || s == 'done') {
          state = state.copyWith(isListening: false);
        }
      },


      onError: (e) {
        debugPrint('Speech recognition error: $e');
        _uiError('$e');
      },
      onLevel: (lvl) {
        state = state.copyWith(audioLevel: lvl);
      },
      preferredLocaleId: state.localeId, // <-- force zh-TW (comes from providers)
    );

    state = state.copyWith(isInitialized: ok, localeId: _speech.localeId);
  }

  void startCountdown({required bool isSttMode, int? preferredLeadMs, required bool isTablet}) {    
    debugPrint('${_ts()} Starting countdown... isSttMode: $isSttMode, leadMs: $preferredLeadMs, isTablet: $isTablet}');
    if (preferredLeadMs != null && preferredLeadMs > _leadMs) {
      _leadMs = preferredLeadMs;
      debugPrint('${_ts()} Using preferredLeadMs=$_leadMs');
    }

    _countdownTimer?.cancel();
    _preStarted = false;
    _listenStarted = false;
    state = state.copyWith(state: RecordingState.countdown, countdownValue: 3, error: null);

    // 200ms ticks so we can pre-start STT just before 0
    _msRemaining = state.countdownValue * 1000;
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 200), (t) async {
      _msRemaining -= 200;

      // PRE-START STT around _leadMs ms (was 600)
      if (!_preStarted && _msRemaining <= _leadMs) {
        _preStarted = true;
        debugPrint('${_ts()} PRE-START STT at T-${_msRemaining}ms (lead=$_leadMs)');
        await ensureInitialized();
        await Future.delayed(const Duration(milliseconds: 120));
        await _startSttInternal();
      }

      if (_msRemaining <= 0) {
        t.cancel();
        if (!_listenStarted) {
          await _startSttInternal();
        }
        state = state.copyWith(state: RecordingState.listening, isListening: true);
      } else {
        final secs = (_msRemaining / 1000).ceil();
        if (secs != state.countdownValue) {
          state = state.copyWith(countdownValue: secs);
        }
      }
    });
  }

  Future<void> _startSttInternal() async {
    if (_listenStarted) return;
    _listenStart = DateTime.now();
    _listenStarted = true;
    try {
      _listenCallAt = DateTime.now();

      await _speech.startListening(
        onResult: (text, isFinal) {
          if (text != state.transcribedText) {
            state = state.copyWith(transcribedText: text);
          }
          // Optional: if you want to stop as soon as the engine says it's final.
          // You can also comment this out and let the plugin end naturally.
          if (isFinal) {
            stopListening();
          }
        },
        onError: (e) {
          debugPrint('${_ts()} STT listen failed: $e');
          _uiError('STT: $e');
        },
        /* chat took out these two without explanation
        // >>> NEW: tolerate longer pauses, esp. on iPad
        listenForDur: const Duration(seconds: 60),
        pauseForDur: isTablet
            ? const Duration(milliseconds: 4200) // iPad: longer silence window
            : const Duration(milliseconds: 2800), // iPhone: default-ish
        */
      );
    /*
    } catch (e) {
      // Fallback recording if STT fails immediately
      try {
        await _speech.startRecording();
        state = state.copyWith(isRecordingFallback: true);
        debugPrint('${_ts()} startRecording (fallback) done.');
      } catch (_) {
        state = state.copyWith(state: RecordingState.finished, isListening: false, error: '無法啟動語音功能');
      }
    */  
    } catch (e) {
      // Do NOT start the fallback recorder here.
      debugPrint('${_ts()} STT threw: $e');
      _uiError('STT listen threw: $e');
      state = state.copyWith(state: RecordingState.finished, isListening: false, error: '無法啟動語音功能');
      return;
    }      
  }

  /// Keep the signature your UI calls: `stopListening(isSttMode: _isSttMode)`
  Future<void> stopListening({bool? isSttMode}) async {
    debugPrint('notifier stopListening() called...');
    final elapsed = _listenStart == null ? 0 : DateTime.now().difference(_listenStart!).inSeconds;
    await _speech.stopListening();
    debugPrint('stopListening() => STT stopped');

    String? recPath;
    if (state.isRecordingFallback) {
      recPath = await _speech.stopRecording();
      debugPrint('stopListening() => recorder stopped at $recPath');
    } else {
      debugPrint('stopListening() => no recording to stop (STT-only mode)');
    }

    state = state.copyWith(
      state: RecordingState.finished,
      isListening: false,
      recordingSeconds: elapsed,
      recordingPath: recPath ?? state.recordingPath,
      isRecordingFallback: false,
    );
  }

  /// Your UI toggles/sets correctness explicitly.
  void updateAnswerCorrectness(bool value) {
    state = state.copyWith(isAnswerCorrect: value);
  }

  /// Your UI invokes `playRecording(volume)`.
  Future<void> playRecording(double volume) async {
    final path = state.recordingPath;
    if (path == null || path.isEmpty) {
      _uiError('沒有可播放的錄音檔');
      return;
    }
    try {
      await _player.stop();
    } catch (_) {}
    // clamp volume 0.0 ~ 1.0
    final v = volume.clamp(0.0, 1.0);
    await _player.setVolume(v);
    await _player.play(DeviceFileSource(path));
  }

  void reset() {
    _countdownTimer?.cancel();
    state = state.copyWith(
      state: RecordingState.idle,
      transcribedText: '',
      countdownValue: 3,
      recordingSeconds: 0,
      recordingPath: null,
      error: null,
      isListening: false,
      audioLevel: 0.0,
      isRecordingFallback: false,
      isAnswerCorrect: false, // reset correctness
    );
  }
}
