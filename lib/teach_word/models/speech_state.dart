// lib/teach_word/models/speech_state.dart

enum RecordingState {
  idle,
  countdown,
  listening,
  finished,
}

class SpeechState {
  final bool isInitialized;
  final RecordingState state;
  final String transcribedText; // partial or final recognized text
  final int countdownValue;
  final int recordingSeconds; // elapsed time shown after stopping
  final String? recordingPath; // if you record audio in parallel
  final bool isPlaying; // if playing recorded audio
  final int remainingTrials;
  final String? error;
  final bool isListening; // indicate if currently listening
  final double? audioLevel; // if you want to show audio level if needed
  String localeId;

  SpeechState({
    this.isInitialized = false,
    this.state = RecordingState.idle,
    this.transcribedText = '',
    this.countdownValue = 0,
    this.recordingSeconds = 0,
    this.recordingPath,
    this.isPlaying = false,
    this.remainingTrials = 3,
    this.error,
    this.isListening = false,
    this.audioLevel,
    this.localeId = 'zh-TW',
  });

  SpeechState copyWith({
    bool? isInitialized,
    RecordingState? state,
    String? transcribedText,
    int? countdownValue,
    int? recordingSeconds,
    String? recordingPath,
    bool? isPlaying,
    int? remainingTrials,
    String? error,
    bool? isListening,
    double? audioLevel,
    required String localeId,
  }) {
    return SpeechState(
      isInitialized: isInitialized ?? this.isInitialized,
      state: state ?? this.state,
      transcribedText: transcribedText ?? this.transcribedText,
      countdownValue: countdownValue ?? this.countdownValue,
      recordingSeconds: recordingSeconds ?? this.recordingSeconds,
      recordingPath: recordingPath ?? this.recordingPath,
      isPlaying: isPlaying ?? this.isPlaying,
      remainingTrials: remainingTrials ?? this.remainingTrials,
      error: error,
      isListening: isListening ?? this.isListening,
      audioLevel: audioLevel ?? this.audioLevel,
      localeId: localeId,
    );
  }
}


