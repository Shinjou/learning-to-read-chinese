import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';


class AudioService {
  final FlutterTts _tts;
  final AudioPlayer _player;
  final Function(String) onError;
  bool _isDisposed = false;
  bool _isTtsPaused = false;

  AudioService({
    required this.onError,
    FlutterTts? tts,
    AudioPlayer? player,
  }) : _tts = tts ?? FlutterTts(),
       _player = player ?? AudioPlayer() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _tts.setLanguage("zh-tw");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);

      _tts.setStartHandler(() {
        debugPrint("TTS Started");
      });

      _tts.setCompletionHandler(() {
        debugPrint("TTS Completed");
      });

      _tts.setErrorHandler((msg) {
        debugPrint("TTS Error: $msg");
        onError("TTS Error: $msg");
      });

      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
      onError('Failed to initialize audio service: $e');
    }
  }

  Future<void> speak(String text) async {
    if (_isDisposed) return;
    try {
      await _tts.speak(text);
    } catch (e) {
      onError('Failed to speak text: $e');
    }
  }

  Future<void> playAudio(String path) async {
    if (_isDisposed) return;
    try {
      await _player.play(DeviceFileSource(path));
    } catch (e) {
      onError('Failed to play audio: $e');
    }
  }

  Future<void> stopAudio() async {
    if (_isDisposed) return;
    try {
      await _player.stop();
      await _tts.stop();
    } catch (e) {
      onError('Failed to stop audio: $e');
    }
  }

  Future<void> pause() async {
    if (_isDisposed) return;
    try {
      await _player.pause();
      if (!_isTtsPaused) {
        await _tts.stop();  // TTS can only be stopped, not paused
        _isTtsPaused = true;
      }
    } catch (e) {
      onError('Failed to pause audio: $e');
    }
  }

  Future<void> resume() async {
    if (_isDisposed) return;
    try {
      await _player.resume();
      if (_isTtsPaused) {
        // For TTS, we might want to store the last spoken text to resume
        // But since TTS doesn't support resume, we'll just reset the flag
        _isTtsPaused = false;
      }
    } catch (e) {
      onError('Failed to resume audio: $e');
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    try {
      await _player.dispose();
      await _tts.stop();
    } catch (e) {
      debugPrint('Error disposing audio service: $e');
    }
  }

  Future<void> cleanupTempFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final audioDir = '${appDir.path}/audio_cache';
      final directory = Directory(audioDir);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}