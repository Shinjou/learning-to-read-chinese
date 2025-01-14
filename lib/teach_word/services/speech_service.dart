// lib/teach_word/services/speech_service.dart

import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText;
  final AudioRecorder _recorder;
  final AudioPlayer _audioPlayer;
  final void Function(String) onError;
  final void Function(String)? onStatusChange;

  bool _isInitialized = false;
  String? _recordingPath;

  SpeechService({
    required SpeechToText speechToText,
    required AudioRecorder recorder,
    required AudioPlayer audioPlayer,
    required this.onError,
    this.onStatusChange,
  }) : _speechToText = speechToText,
      _recorder = recorder,
      _audioPlayer = audioPlayer {

    // Hook up the global status listener

    _speechToText.initialize(
      onError: (error) {
        onError('STT Error: ${error.errorMsg}');
      },
      onStatus: (status) {
        _handleStatusChange(status);
      },
    );
  }

  void _handleStatusChange(String status) {
    // If the plugin says 'done', we can auto-stop
    if (status == 'done') {
      debugPrint('Auto-stopping STT');
      stopListening();
    }
    onStatusChange?.call(status);
  }

  bool get isInitialized => _isInitialized;
  String? get recordingPath => _recordingPath;

  /// Re-initialize STT if needed.
  /// For Android, we often want to re-init every new session (force=true).
  /// For iOS, a single init can remain valid (force=false) if you prefer.
  Future<bool> initialize({bool force = false}) async {
    // If we’re already initialized and not forcing, skip
    if (_isInitialized && !force) {
      return true;
    }
    // If forcing (Android) or never done before, do a fresh init
    _isInitialized = false; // ensure a fresh attempt

    if (!await _checkPermissions()) return false;
    if (!await _checkDeviceCapabilities()) return false;

    final available = await _speechToText.initialize(
      onError: (error) {
        onError('STT Error: ${error.errorMsg}');
      },
      onStatus: (status) {
        onStatusChange?.call(status);
      },
      debugLogging: false,
    );
    if (!available) {
      onError('Speech recognition not available');
      return false;
    }

    _isInitialized = true;
    return true;
  }

  Future<bool> _checkPermissions() async {
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        onError('需要麥克風權限');
        return false;
      }
    }
    return true;
  }

  Future<bool> _checkDeviceCapabilities() async {
    final hasSupport = await _recorder.hasPermission();
    final isSupported = await _recorder.isEncoderSupported(AudioEncoder.aacLc);

    if (!hasSupport) {
      onError('Recording permission not granted');
      return false;
    }
    if (!isSupported) {
      onError('Device does not support required audio encoding (AAC).');
      return false;
    }
    return true;
  }

  /// Start STT listening with a given locale, passing partial/final results
  Future<void> startListening({
    required String localeId,
    required void Function(String text, bool finalResult) onResult,
    required void Function(double level) onAudioLevel,
  }) async {
    // We assume the caller has called initialize(...) as needed
    await _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        final recognizedText = result.recognizedWords.trim();
        final isFinal = result.finalResult;

        // If your code needs partial text for live display:
        if (!isFinal) {
          // Update a UI field or variable with partial text
          debugPrint('Partial result: $recognizedText');
          // Maybe store recognizedText in some state for immediate feedback
        } else {
          // Final result
          debugPrint('Final result: $recognizedText');

          // If the final recognized text is not empty, do something with it:
          if (recognizedText.isNotEmpty) {
            // For example, pass it to a method that processes the completed text
            onResult(recognizedText, true);
          } else {
            // Possibly handle an empty final result (user didn't say anything, or got cut off)
            debugPrint('No speech recognized in final result.');
            onResult('', true);
          }
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 5),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),      
      onSoundLevelChange: onAudioLevel,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> startRecording() async {
    _recordingPath = await _getRecordingPath();

    if (Platform.isAndroid) {
      // WAV for older Android to avoid timestamp issues
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
          bitRate: 16 * 1024,
        ),
        path: _recordingPath!,
      );
    } else {
      // iOS => keep AAC
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          numChannels: 1,
          bitRate: 16 * 1024,
        ),
        path: _recordingPath!,
      );
    }
  }

  Future<String?> stopRecording() async {
    await _recorder.stop();
    return _recordingPath;
  }

  Future<void> playRecording(String path, {double volume = 0.7}) async {
    // If something is already playing, stop it first
    await _audioPlayer.stop();

    // Set the volume (range: 0.0 to 1.0)
    await _audioPlayer.setVolume(volume);

    // Now play the recording from local file source
    await _audioPlayer.play(DeviceFileSource(path));
  }

  Future<String> _getRecordingPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }
}
