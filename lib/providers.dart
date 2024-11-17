// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

final screenInfoProvider = StateNotifierProvider<ScreenInfoNotifier, ScreenInfo>((ref) {
  return ScreenInfoNotifier();
});



final ttsProvider = Provider<FlutterTts>((ref) {
  final ftts = FlutterTts();

  // Set up the TTS engine  Is this necessary given that main.dart already did this?
  ftts.setLanguage("zh-TW");
  ftts.setSpeechRate(0.5);
  ftts.setVolume(1.0);

  // Add debug logging
  ftts.setStartHandler(() {
    debugPrint('TTS: Speech started');  // These are not showing up. Why?
  });
  ftts.setCompletionHandler(() {
    debugPrint('TTS: Speech completed'); // These are not showing up. Why?
  });
  ftts.setErrorHandler((msg) {
    debugPrint('TTS Error: $msg');
  });

  return ftts;
});



final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

class AudioPlaybackState {
  final bool isPlaying;
  final bool isSpeaking;

  const AudioPlaybackState({
    this.isPlaying = false,
    this.isSpeaking = false,
  });

  AudioPlaybackState copyWith({
    bool? isPlaying,
    bool? isSpeaking,
  }) {
    return AudioPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

final audioStateProvider = StateProvider<AudioPlaybackState>((ref) {
  return const AudioPlaybackState();
});
