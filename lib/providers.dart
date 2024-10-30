// lib/providers.dart global state providers

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/views/view_utils.dart';

final soundSpeedProvider = StateProvider<double>((ref) => 0.5);
final zhuyinOnProvider = StateProvider<bool>((ref) => true);

final gradeProvider = StateProvider<int>((ref) => 1);
final publisherCodeProvider = StateProvider<int>((ref) => 0);
final semesterCodeProvider = StateProvider<int>((ref) => 0); // was 上 0: 上, 1: 下
final accountProvider = StateProvider<String>((ref) => "");
final pwdProvider = StateProvider<String>((ref) => "");
final teachWordViewProvider = StateProvider<int>((ref) => 0);
final userNameProvider = StateProvider<String>((ref) => "");
final totalWordCountProvider = StateProvider<int>((ref) => 186);
final learnedWordCountProvider = StateProvider<int>((ref) => 0);

// Screen info provider
final screenInfoProvider = StateNotifierProvider<ScreenInfoNotifier, ScreenInfo>((ref) {
  return ScreenInfoNotifier();
});

// Global Audio Providers
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    debugPrint('Disposing AudioPlayer');
    player.dispose();
  });
  return player;
});

final ttsProvider = Provider<FlutterTts>((ref) {
  final tts = FlutterTts();
  tts.setLanguage("zh-tw");
  tts.setSpeechRate(0.5);
  tts.setVolume(1.0);
  ref.onDispose(() {
    debugPrint('Disposing FlutterTts');
    tts.stop();
  });
  return tts;
});

class AudioService {
  final Ref _ref;
  bool _disposed = false;
  
  AudioService(this._ref) {
    _ref.onDispose(() {
      debugPrint('AudioService onDispose called');
      _dispose();
    });
  }

  Future<void> playWordSound(String word, bool isBpmf) async {
    if (_disposed) {
      debugPrint('Attempted to play sound after disposal');
      return;
    }
    
    try {
      if (isBpmf) {
        await _ref.read(audioPlayerProvider).play(AssetSource('bopomo/$word.mp3'));
      } else {
        await _ref.read(ttsProvider).speak(word);
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _dispose() {
    debugPrint('Disposing AudioService');
    _disposed = true;
  }
}

final audioServiceProvider = Provider((ref) {
  debugPrint('Creating AudioService');
  return AudioService(ref);
});
