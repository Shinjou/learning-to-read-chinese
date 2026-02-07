// lib/teach_word/services/speech_service.dart
// Constructor signature matches providers.dart: speechToText, recorder, audioPlayer, onError
// Uses speech_to_text for STT and record >=5 (AudioRecorder) for fallback.

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

typedef StatusCallback = void Function(String status);
typedef ErrorCallback = void Function(Object error);
typedef ResultCallback = void Function(String text, bool finalResult);
typedef LevelCallback = void Function(double level);

class SpeechService {
  final stt.SpeechToText _stt;
  final AudioRecorder _recorder;
  final AudioPlayer _player; // reserved for future playback use
  final void Function(String message) _onUiError;

  bool _initialized = false;
  String _localeId = 'zh-TW';

  SpeechService({
    required stt.SpeechToText speechToText,
    required AudioRecorder recorder,
    required AudioPlayer audioPlayer,
    required void Function(String) onError,
  })  : _stt = speechToText,
        _recorder = recorder,
        _player = audioPlayer,
        _onUiError = onError;
  
  /*
  Future<bool> initialize({
    required StatusCallback onStatus,
    required ErrorCallback onError,
    required LevelCallback onLevel,
  }) async {
    try {
      final ok = await _stt.initialize(
        onStatus: (s) => onStatus(s),
        onError: (e) => onError(Exception(e.errorMsg)),
        debugLogging: false,
      );
      if (!ok) return false;

      final system = await _stt.systemLocale();
      final locales = await _stt.locales();
      debugPrint('SpeechService: Available locales: ${locales.map((l) => l.localeId).join(", ")}');
      String chosen = system?.localeId ?? 'zh-TW';
      if (locales.any((l) => l.localeId == chosen)) {
        debugPrint('SpeechService: Using system locale: $chosen');
      } else {
        debugPrint('SpeechService: System locale not available, falling back to zh-TW');
        chosen = 'zh-TW';
      }
      if (!locales.any((l) => l.localeId == chosen)) {
        final zh = locales.firstWhere(
          (l) => l.localeId.startsWith('zh'),
          orElse: () => locales.first,
        );
        chosen = zh.localeId;
      }
      _localeId = chosen;
      _initialized = true;
      return true;
    } catch (e) {
      _onUiError('$e');
      onError(e);
      return false;
    }
  }
  */

  Future<bool> initialize({
    required StatusCallback onStatus,
    required ErrorCallback onError,
    required LevelCallback onLevel,
    String? preferredLocaleId, // NEW
  }) async {
    try {
      final ok = await _stt.initialize(
        onStatus: (s) => onStatus(s),
        onError: (e) => onError(Exception(e.errorMsg)),
        debugLogging: false,
      );
      if (!ok) return false;

      final locales = await _stt.locales();
      final system = await _stt.systemLocale();

      String? exact(String id) {
        final t = id.toLowerCase();
        for (final l in locales) {
          if (l.localeId.toLowerCase() == t) return l.localeId;
        }
        return null;
      }

      String? startsWith(String prefix) {
        final p = prefix.toLowerCase();
        for (final l in locales) {
          if (l.localeId.toLowerCase().startsWith(p)) return l.localeId;
        }
        return null;
      }

      // Selection order:
      // 1) preferredLocaleId (exact / normalized)
      // 2) zh-TW (or zh_TW)
      // 3) any zh*
      // 4) system locale
      // 5) first available
      String? chosen;
      if (preferredLocaleId != null && preferredLocaleId.isNotEmpty) {
        chosen = exact(preferredLocaleId)
          ?? exact(preferredLocaleId.replaceAll('_', '-'))
          ?? exact(preferredLocaleId.replaceAll('-', '_'))
          ?? startsWith(preferredLocaleId);
      }
      chosen = chosen
        ?? exact('zh-TW')
        ?? exact('zh_TW')
        ?? startsWith('zh')
        ?? system?.localeId
        ?? (locales.isNotEmpty ? locales.first.localeId : 'zh-TW');

      _localeId = chosen;
      _initialized = true;

      // Helpful when debugging
      // ignore: avoid_print
      print('SpeechService.initialize => selected locale: $_localeId');

      return true;
    } catch (e) {
      _onUiError('$e');
      onError(e);
      return false;
    }
  }


  String get localeId => _localeId;
  bool get isInitialized => _initialized;
  /*
  Future<void> startListening({
    required ResultCallback onResult,
    required ErrorCallback onError,
    LevelCallback? onLevel,
    // NEW: allow caller to tune these per device / screen
    Duration? listenForDur,
    Duration? pauseForDur,
  }) async {
    if (!_initialized) {
      throw StateError('STT not initialized');
    }
    try {
      // Clean slate in case the plugin still thinks it's active
      try {
        await _stt.stop();
      } catch (_) {}

      final listenFor = listenForDur ?? const Duration(seconds: 60);     // longer so it won’t auto-expire
      final pauseFor  = pauseForDur  ?? const Duration(milliseconds: 2800); // phones default

      debugPrint('SpeechService.startListening => using locale: $_localeId '
          '(listenFor=$listenFor, pauseFor=$pauseFor)');

      await _stt.listen(
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        localeId: _localeId,
        listenFor: listenFor,
        pauseFor:  pauseFor,
        onSoundLevelChange: (level) {
          if (onLevel != null) onLevel(level);
        },
        // Use SpeechListenOptions (your current approach)
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.dictation,  // <- important on iOS/iPad
          // enableHapticFeedback: false,
          // autoPunctuation: true,
        ),
      );
    } catch (e) {
      _onUiError('$e');
      onError(e);
      // IMPORTANT: do not bubble up; avoid triggering fallback recording
      return;
    }
  }
  */
  /* The following code did not work
  Future<void> startListening({
    required ResultCallback onResult,
    required ErrorCallback onError,
    LevelCallback? onLevel,
  }) async {
    if (!_initialized) {
      throw StateError('STT not initialized');
    }

    try {
      debugPrint(
        'SpeechService.startListening => using locale: $_localeId (listenFor=60s, pauseFor=4.2s)',
      );

      // --- IMPORTANT: fully reset any prior session before starting a new one ---
      // (iOS can return error_listen_failed if the previous session hasn't
      // fully torn down its audio session.)
      try {
        await _stt.stop();
      } catch (_) {}
      try {
        await _stt.cancel();
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 120));

      // Start fresh
      await _stt.listen(
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        localeId: _localeId,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(milliseconds: 5000),
        onSoundLevelChange: (level) {
          if (onLevel != null) onLevel(level);
        },
        // Use the new options object
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
          // Force network mode; zh-TW on-device can be unavailable or flaky in the Simulator.
          onDevice: false,
          // Keep the engine alive if there’s a transient error.
          cancelOnError: false,
        ),
      );
    } catch (e) {
      _onUiError('$e');
      onError(e);
      rethrow;
    }
  }
  */
  /* One of the test versions that did not work
  Future<void> startListening({
    required ResultCallback onResult,
    required ErrorCallback onError,
    LevelCallback? onLevel,
  }) async {
    if (!_initialized) {
      throw StateError('STT not initialized');
    }

    // Local helpers so we keep logging consistent
    void logStatus(String s) => debugPrint('Speech recognition status: $s');
    void logError(Object e) => debugPrint('Speech recognition error: $e');

    Future<bool> reinit() async {
      try {
        // Fully tear down anything stale
        try { await _stt.stop(); } catch (_) {}
        try { await _stt.cancel(); } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 150));

        // Re-initialize (some iOS versions require this right before listen)
        final ok = await _stt.initialize(
          onError: (err) => logError(err.errorMsg),
          onStatus: logStatus,
        );
        debugPrint('SpeechService: reinitialize before listen => $ok');

        // Small guard delay to let AVAudioSession settle
        await Future.delayed(const Duration(milliseconds: 120));
        return ok;
      } catch (e) {
        logError(e);
        return false;
      }
    }

    // One-time reinit (always do it on iOS before a fresh listen)
    final ready = await reinit();
    if (!ready) {
      const msg = 'STT initialize failed just before listen()';
      _onUiError(msg);
      onError(msg);
      return;
    }

    Future<void> doListen() {
      debugPrint(
        'SpeechService.startListening => using locale: $_localeId (listenFor=60s, pauseFor=4.2s)',
      );

      return _stt.listen(
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        localeId: _localeId,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(milliseconds: 4200),
        onSoundLevelChange: (level) {
          if (onLevel != null) onLevel(level);
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
          // Force network recognition; zh-TW on-device can be flaky in Simulator.
          onDevice: false,
          // Don’t auto-cancel the whole session on a transient engine error.
          cancelOnError: false,
        ),
      );
    }

    // Attempt + single retry if we hit the iOS "listen failed" race
    try {
      await doListen();
    } catch (e) {
      final text = e.toString();
      _onUiError(text);
      logError(e);

      // Retry path only for the start failure case
      final looksLikeStartFailure =
          text.contains('listen_failed') || text.contains('listen failed');

      if (looksLikeStartFailure) {
        debugPrint('SpeechService: listen() failed; retrying after reinit…');
        final ok = await reinit();
        if (ok) {
          try {
            await doListen();
            return;
          } catch (e2) {
            _onUiError(e2.toString());
            onError(e2);
            return;
          }
        }
      }

      onError(e);
    }
  }
  */

  Future<void> startListening({
    required ResultCallback onResult,
    required ErrorCallback onError,
    LevelCallback? onLevel,
  }) async {
    if (!_initialized) {
      throw StateError('STT not initialized');
    }

    // ignore: no_leading_underscores_for_local_identifiers
    void _logStatus(String s) => debugPrint('Speech recognition status: $s');
    // ignore: no_leading_underscores_for_local_identifiers
    void _logError(Object e) => debugPrint('Speech recognition error: $e');

    // ignore: no_leading_underscores_for_local_identifiers
    Future<bool> _reinit() async {
      try {
        // Ensure any stale session is gone
        try { await _stt.stop(); } catch (_) {}
        try { await _stt.cancel(); } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 200));

        final ok = await _stt.initialize(
          onError: (err) => _logError(err.errorMsg),
          onStatus: _logStatus,
        );
        debugPrint('SpeechService: reinitialize before listen => $ok');

        // Let AVAudioSession settle
        await Future.delayed(const Duration(milliseconds: 300));
        return ok;
      } catch (e) {
        _logError(e);
        return false;
      }
    }

    // Always re-init right before listen on iOS to avoid the race.
    final ready = await _reinit();
    if (!ready) {
      const msg = 'STT initialize failed just before listen()';
      _onUiError(msg);
      onError(msg);
      return;
    }

    // ignore: no_leading_underscores_for_local_identifiers
    Future<void> _doListen() {
      debugPrint(
        'SpeechService.startListening => using locale: $_localeId (listenFor=60s, pauseFor=4.2s)',
      );

      // IMPORTANT: use the classic parameter list only (no listenOptions).
      // Some iOS/Simulator builds fail to start when listenOptions is used with zh-TW.
      return _stt.listen(
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        localeId: _localeId,
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(milliseconds: 4200),
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        sampleRate: 44100,
        // NOTE: Do NOT pass onDevice or listenOptions here; leaving them off is more reliable.
        onSoundLevelChange: (level) {
          if (onLevel != null) onLevel(level);
        },
      );
    }

    try {
      await _doListen();
    } catch (e) {
      final errText = e.toString();
      _onUiError(errText);
      _logError(e);

      // One retry for the 'listen failed' startup race
      if (errText.contains('listen_failed') || errText.contains('listen failed')) {
        debugPrint('SpeechService: listen() failed; retrying after reinit…');
        if (await _reinit()) {
          try {
            await _doListen();
            return;
          } catch (e2) {
            _onUiError(e2.toString());
            onError(e2);
            return;
          }
        }
      }

      onError(e);
    }
  }


  Future<void> stopListening() async {
    if (_stt.isListening) {
      await _stt.stop();
    }
  }

  // ---- optional fallback recording ----
  Future<void> startRecording() async {
    if (await _recorder.isRecording()) return;
    if (!await _recorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/ltrc_speak_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
  }

  Future<String?> stopRecording() async {
    if (!await _recorder.isRecording()) return null;
    final path = await _recorder.stop();
    return path;
  }
}
