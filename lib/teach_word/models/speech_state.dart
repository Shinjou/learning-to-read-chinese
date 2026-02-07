// lib/teach_word/models/speech_state.dart
// Matches app expectations + adds isRecordingFallback

enum RecordingState { idle, countdown, listening, finished }

class SpeechState {
  final bool isInitialized;
  final RecordingState state;
  final String transcribedText;
  final int countdownValue;
  final int recordingSeconds;
  final String? recordingPath;
  final bool isPlaying;
  final int remainingTrials;
  final String? error;

  // runtime/ephemeral fields
  final bool isListening;
  final double audioLevel;
  final bool isAnswerCorrect;
  final String localeId;

  /// Fallback recording flag: true between startRecording() and stopRecording()
  final bool isRecordingFallback;

  const SpeechState({
    this.isInitialized = false,
    this.state = RecordingState.idle,
    this.transcribedText = '',
    this.countdownValue = 3,
    this.recordingSeconds = 0,
    this.recordingPath,
    this.isPlaying = false,
    this.remainingTrials = 3,
    this.error,
    this.isListening = false,
    this.audioLevel = 0.0,
    this.isAnswerCorrect = false, // <— non-nullable default
    this.localeId = 'zh-TW',
    this.isRecordingFallback = false,
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
    bool? isAnswerCorrect,
    String? localeId,
    bool? isRecordingFallback,
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
      isAnswerCorrect: isAnswerCorrect ?? this.isAnswerCorrect, // <— keep non-null
      localeId: localeId ?? this.localeId,
      isRecordingFallback: isRecordingFallback ?? this.isRecordingFallback,
    );
  }
}
