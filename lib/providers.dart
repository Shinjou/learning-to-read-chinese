// lib/providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/teach_word/models/speech_state.dart';
import 'package:ltrc/teach_word/notifiers/speech_state_notifier.dart';
import 'package:ltrc/teach_word/services/speech_service.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';


// Core app state providers
final soundSpeedProvider = StateProvider<double>((ref) => 0.5);
final zhuyinOnProvider = StateProvider<bool>((ref) => true);

final gradeProvider = StateProvider<int>((ref) => 1);
final publisherCodeProvider = StateProvider<int>((ref) => 0);
final semesterCodeProvider = StateProvider<int>((ref) => 0);
final accountProvider = StateProvider<String>((ref) => "");
final pwdProvider = StateProvider<String>((ref) => "");
final teachWordViewProvider = StateProvider<int>((ref) => 0);
final userNameProvider = StateProvider<String>((ref) => "");
final totalWordCountProvider = StateProvider<int>((ref) => 186);
final learnedWordCountProvider = StateProvider<int>((ref) => 0);

// Base service providers
final ttsProvider = Provider<FlutterTts>((ref) {
  final ftts = FlutterTts();
  return ftts;
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() => player.dispose());
  return player;
});

// Base providers for speech services
final speechToTextProvider = Provider<SpeechToText>((ref) {
  final stt = SpeechToText();
  ref.onDispose(() {
    stt.stop();
  });
  return stt;
});

final recorderProvider = Provider<AudioRecorder>((ref) {
  final recorder = AudioRecorder();
  ref.onDispose(() {
    recorder.stop();
  });
  return recorder;
});

// Initialization functions
Future<FlutterTts> initializeTts() async {
  final ftts = FlutterTts();
  ftts.setStartHandler(() {
    debugPrint("Main: setStartHandler(()");
  });
  ftts.setCompletionHandler(() {
    debugPrint("Main: setCompletionHandler(()");
  });
  ftts.setErrorHandler((msg) {
    debugPrint("Main: setErrorHandler: $msg");
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

Future<SpeechToText> initializeSpeechToText() async {
  final speech = SpeechToText();
  try {
    debugPrint('Initializing speech to text...');
    final available = await speech.initialize(
      onError: (error) {
        debugPrint('Speech recognition error: ${error.errorMsg}');
      },
      onStatus: (status) {
        debugPrint('Speech recognition status: $status');
      },
    );

    if (available) {
      debugPrint('Speech recognition initialized successfully');
      final locales = await speech.locales();
      debugPrint('Available locales: ${locales.map((loc) => loc.localeId).join(", ")}');

      const zhTWFormats = ['zh-tw', 'zh_tw', 'zh-TW', 'zh_TW'];
      final hasZhTW = locales.any((locale) {
        final localeId = locale.localeId.toLowerCase();
        return zhTWFormats.contains(localeId);
      });

      if (hasZhTW) {
        debugPrint('Traditional Chinese (zh-TW/zh_TW) is available');
        final zhTWLocale = locales.firstWhere(
          (locale) => zhTWFormats.contains(locale.localeId.toLowerCase()),
        );
        final zhTWLocaleId = zhTWLocale.localeId;
        debugPrint('Found Traditional Chinese locale: $zhTWLocaleId');
      } else {
        debugPrint('Warning: No Traditional Chinese locale not found, available Chinese locales:');
        final chineseLocales = locales.where(
          (locale) => locale.localeId.toLowerCase().startsWith('zh')
        );
        for (var locale in chineseLocales) {
          debugPrint('- ${locale.localeId} (${locale.name})');
        }
      }      
    } else {
      debugPrint('Speech recognition initialization failed');
    }
  } catch (e, stack) {
    debugPrint('Error initializing speech recognition: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
  return speech;
}

// Service initializers
class AudioServiceInitializer {
  Future<List<Override>> initialize() async {
    final tts = await initializeTts();
    final player = await initializeAudioPlayer();
    return [
      ttsProvider.overrideWithValue(tts),
      audioPlayerProvider.overrideWithValue(player),
    ];
  }
}

// Screen info provider
final screenInfoProvider = StateNotifierProvider<ScreenInfoNotifier, ScreenInfo>((ref) {
  return ScreenInfoNotifier();
});

// Error handler
final speechErrorStateProvider = StateProvider<String?>((ref) => null);
final speechErrorHandlerProvider = Provider<Function(String)>((ref) {
  return (String error) {
    ref.read(speechErrorStateProvider.notifier).state = error;
  };
});

final speechServiceProvider = Provider<SpeechService>((ref) {
  final stt = ref.watch(speechToTextProvider);
  final recorder = ref.watch(recorderProvider);
  final player = ref.watch(audioPlayerProvider);
  final errorHandler = ref.watch(speechErrorHandlerProvider);
  // final initialLocaleId = ref.watch(initialLocaleProvider);
  return SpeechService(
    speechToText: stt,
    recorder: recorder,
    audioPlayer: player,
    onError: errorHandler,
    // initialLocaleId: initialLocaleId,
  );
});

final initialLocaleProvider = Provider<String>((ref) => 'zh-TW');

final speechStateProvider = StateNotifierProvider<SpeechStateNotifier, SpeechState>((ref) {
  final service = ref.watch(speechServiceProvider);
  final player = ref.watch(audioPlayerProvider);
  final errorHandler = ref.watch(speechErrorHandlerProvider);
  // final initialLocaleId = ref.watch(initialLocaleProvider);

  return SpeechStateNotifier(
    service, 
    player, 
    onError: errorHandler, 
    initialLocaleId: 'zh-TW',
  );
});



