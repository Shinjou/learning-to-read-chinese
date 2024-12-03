// lib.provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';

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
  // main.dart has initialized ftts. So no need to do it here.
  return ftts;
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

final recorderProvider = Provider<AudioRecorder>((ref) {
  throw UnimplementedError('Recorder must be initialized first');
});

final speechToTextProvider = Provider<SpeechToText>((ref) {
  throw UnimplementedError('SpeechToText must be initialized first');
});

Future<FlutterTts> initializeTts() async {
  final ftts = FlutterTts();

  ftts.setStartHandler(() { // Need more processing
    debugPrint("Main: TTS Started");  // we only saw "TTS Start", but no "TTS Complete". Why?
  });

  ftts.setCompletionHandler(() { // No "TTS Complete" message. Why?
    debugPrint("Main: TTS Completed");
  });

  ftts.setErrorHandler((msg) { // 
    debugPrint("Main: TTS Error: $msg");
  });

  await ftts.setLanguage("zh-tw");
  await ftts.setSpeechRate(0.5);
  await ftts.setVolume(1.0);
  debugPrint('Main: TTS initialized.');
  return ftts;
}

Future<AudioPlayer> initializeAudioPlayer() async {
  final player = AudioPlayer();
  debugPrint('Main: Audio player initialized.');
  return player;
}

Future<AudioRecorder> initializeRecorder() async {
  final recorder = AudioRecorder();
  debugPrint('Main: Audio recorder initialized.');
  return recorder;
}

/*
Future<stt.SpeechToText> initializeSpeechToText() async {
  final speech = stt.SpeechToText();
  final available = await speech.initialize(
    onError: (error) => debugPrint('Speech recognition error: $error'),
    debugLogging: true,
  );
  
  if (!available) {
    debugPrint('Speech recognition initialization failed');
  } else {
    debugPrint('Speech recognition initialized successfully');
  }
  
  return speech;
}
*/
/*
Future<SpeechToText> initializeSpeechToText() async {
  SpeechToText stt = SpeechToText();
  final sttAvailable = await stt.initialize(
    onError: (error) => debugPrint('Speech recognition error: $error'),
    debugLogging: true,
  );
  
  if (!sttAvailable) {
    debugPrint('Speech recognition initialization failed');
  } else {
    debugPrint('Speech recognition initialized successfully');
  }
  
  return stt;
}
*/

Future<SpeechToText> initializeSpeechToText() async {
  final speech = SpeechToText();
  
  try {
    debugPrint('Initializing speech to text...');
    // Ensure we're on the platform thread when calling initialize
    final available = await speech.initialize(
      onError: (errorNotification) => debugPrint('Speech recognition error: $errorNotification'),
      debugLogging: true,
    );
    
    if (available) {
      debugPrint('Speech recognition initialized successfully');
      
      // Test if we can get available locales
      final locales = await speech.locales();
      debugPrint('Available locales: ${locales.map((loc) => loc.localeId).join(", ")}');
      
      // Check if Traditional Chinese is available
      final hasZhTW = locales.any((locale) => locale.localeId.toLowerCase().contains('zh_tw'));
      if (hasZhTW) {
        debugPrint('Traditional Chinese (zh_TW) is available');
      } else {
        debugPrint('Warning: Traditional Chinese (zh_TW) not found in available locales');
      }
    } else {
      debugPrint('Speech recognition initialization failed');
    }
  } catch (e) {
    debugPrint('Error initializing speech recognition: $e');
    // Re-throw the error so main.dart can handle it
    rethrow;
  }
  
  return speech;
}

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
