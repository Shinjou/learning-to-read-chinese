// lib/teach_word/services/speech_service.dart

import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ltrc/providers.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  })  : _speechToText = speechToText,
        _recorder = recorder,
        _audioPlayer = audioPlayer;

  bool get isInitialized => _isInitialized;
  String? get recordingPath => _recordingPath;

  Future<bool> initialize() async {
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
      onError('Device does not support required audio encoding');
      return false;
    }
    return true;
  }

  Future<void> startListening({
    required String localeId,
    required void Function(String text, bool finalResult) onResult,
    required void Function(double level) onAudioLevel,
  }) async {

    await _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenFor: Duration(seconds: 30),
      partialResults: true, // don't know how to upgrade
      onSoundLevelChange: onAudioLevel,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  Future<void> startRecording() async {
    _recordingPath = await _getRecordingPath();
    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 16 * 1024,
      ),
      path: _recordingPath!,
    );
  }

  Future<String?> stopRecording() async {
    await _recorder.stop();
    return _recordingPath;
  }

  Future<void> playRecording(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
  }

  Future<String> _getRecordingPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }
}

