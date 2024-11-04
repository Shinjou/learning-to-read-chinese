
// lib/teach_word/controllers/audio_controller.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/teach_word/constants/assets.dart';
import '../states/audio_state.dart';

class AudioController extends StateNotifier<AudioState> {
  final FlutterTts tts;
  final AudioPlayer player;
  final void Function()? onPlayComplete;

  AudioController(
    this.tts, 
    this.player, {
    this.onPlayComplete,
  }) : super(const AudioState()) {
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    await tts.setLanguage("zh-tw");
    await tts.setSpeechRate(state.playbackSpeed);
    await tts.setVolume(state.volume);

    tts.setCompletionHandler(() {
      state = state.copyWith(isPlaying: false, isSpeaking: false);
      onPlayComplete?.call();
    });

    player.onPlayerComplete.listen((_) {
      state = state.copyWith(isPlaying: false);
      onPlayComplete?.call();
    });
  }

  Future<void> playWord(String word, bool isBpmf) async {
    try {
      state = state.copyWith(isPlaying: true);
      
      if (isBpmf) {
        await player.play(AssetSource(AssetPaths.getBpmfAudio(word)));
      } else {
        state = state.copyWith(isSpeaking: true);
        await tts.speak(word);
      }
    } catch (e) {
      debugPrint('Error playing word audio: $e');
      state = state.copyWith(isPlaying: false, isSpeaking: false);
    }
  }

  Future<void> playVocab(String vocab, String sentence) async {
    try {
      state = state.copyWith(isPlaying: true, isSpeaking: true);
      await tts.speak("$vocab。$sentence");
    } catch (e) {
      debugPrint('Error playing vocab audio: $e');
      state = state.copyWith(isPlaying: false, isSpeaking: false);
    }
  }

  Future<void> stop() async {
    if (state.isSpeaking) {
      await tts.stop();
    }
    await player.stop();
    state = state.copyWith(isPlaying: false, isSpeaking: false);
  }

  void setPlaybackSpeed(double speed) {
    tts.setSpeechRate(speed);
    state = state.copyWith(playbackSpeed: speed);
  }

  void setVolume(double volume) {
    tts.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  @override
  void dispose() {
    stop();
    player.dispose();
    super.dispose();
  }
}

