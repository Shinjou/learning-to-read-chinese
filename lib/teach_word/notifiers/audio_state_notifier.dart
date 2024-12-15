// lib/teach_word/notifiers/audio_state_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/models/app_state.dart';
import 'package:ltrc/teach_word/services/audio_service.dart';

class AudioStateNotifier extends StateNotifier<AudioPlaybackState> {
  final AudioService _audioService;

  AudioStateNotifier(this._audioService) : super(const AudioPlaybackState());

  Future<void> speak(String text) async {
    state = state.copyWith(isSpeaking: true);
    await _audioService.speak(text);
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> playAudio(String path) async {
    state = state.copyWith(
      isPlaying: true,
      currentAudioPath: path,
    );
    await _audioService.playAudio(path);
    state = state.copyWith(isPlaying: false);
  }

  Future<void> stopAudio() async {
    await _audioService.stopAudio();
    state = state.copyWith(
      isPlaying: false,
      isSpeaking: false,
    );
  }

  Future<void> pause() async {
    await _audioService.pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> resume() async {
    await _audioService.resume();
    state = state.copyWith(isPlaying: true);
  }
}

