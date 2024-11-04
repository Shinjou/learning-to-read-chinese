// lib/teach_word/states/audio_state.dart

class AudioState {
  final bool isPlaying;
  final double playbackSpeed;
  final double volume;
  final bool isSpeaking;

  const AudioState({
    this.isPlaying = false,
    this.playbackSpeed = 0.5,
    this.volume = 1.0,
    this.isSpeaking = false,
  });

  AudioState copyWith({
    bool? isPlaying,
    double? playbackSpeed,
    double? volume,
    bool? isSpeaking,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

