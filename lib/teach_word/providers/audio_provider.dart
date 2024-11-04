// lib/teach_word/providers/audio_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import '../states/audio_state.dart';
import '../controllers/audio_controller.dart';

final audioControllerProvider = StateNotifierProvider<AudioController, AudioState>((ref) {
  return AudioController(
    ref.watch(ttsProvider),
    ref.watch(audioPlayerProvider),
  );
});