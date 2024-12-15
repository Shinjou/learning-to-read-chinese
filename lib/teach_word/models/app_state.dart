import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

@immutable
class AppState {
  final AudioPlaybackState audioState;
  final SpeechRecognitionState speechState;
  final UserPreferences preferences;

  const AppState({
    this.audioState = const AudioPlaybackState(),
    this.speechState = const SpeechRecognitionState(),
    this.preferences = const UserPreferences(),
  });

  AppState copyWith({
    AudioPlaybackState? audioState,
    SpeechRecognitionState? speechState,
    // ScreenInfo? screenInfo,
    UserPreferences? preferences,
  }) {
    return AppState(
      audioState: audioState ?? this.audioState,
      speechState: speechState ?? this.speechState,
      // screenInfo: screenInfo ?? this.screenInfo,
      preferences: preferences ?? this.preferences,
    );
  }
}

@immutable
class AudioPlaybackState {
  final bool isPlaying;
  final bool isSpeaking;
  final String? currentAudioPath;
  final Duration? position;
  final Duration? duration;
  final double volume;
  final double speed;

  const AudioPlaybackState({
    this.isPlaying = false,
    this.isSpeaking = false,
    this.currentAudioPath,
    this.position,
    this.duration,
    this.volume = 1.0,
    this.speed = 1.0,
  });

  AudioPlaybackState copyWith({
    bool? isPlaying,
    bool? isSpeaking,
    String? currentAudioPath,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
  }) {
    return AudioPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      currentAudioPath: currentAudioPath ?? this.currentAudioPath,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioPlaybackState &&
        other.isPlaying == isPlaying &&
        other.isSpeaking == isSpeaking &&
        other.currentAudioPath == currentAudioPath &&
        other.position == position &&
        other.duration == duration &&
        other.volume == volume &&
        other.speed == speed;
  }

  @override
  int get hashCode => Object.hash(
        isPlaying,
        isSpeaking,
        currentAudioPath,
        position,
        duration,
        volume,
        speed,
      );
}

@immutable
class SpeechRecognitionState {
  final bool isListening;
  final bool isInitialized;
  final String transcribedText;
  final double? confidence;
  final String? selectedLocale;
  final List<LocaleName> availableLocales;
  final double? audioLevel;
  final SpeechRecognitionError? lastError;
  final List<SpeechRecognitionResult> interimResults;
  final bool isProcessing;

  const SpeechRecognitionState({
    this.isListening = false,
    this.isInitialized = false,
    this.transcribedText = '',
    this.confidence,
    this.selectedLocale,
    this.availableLocales = const [],
    this.audioLevel,
    this.lastError,
    this.interimResults = const [],
    this.isProcessing = false,
  });

  SpeechRecognitionState copyWith({
    bool? isListening,
    bool? isInitialized,
    String? transcribedText,
    double? confidence,
    String? selectedLocale,
    List<LocaleName>? availableLocales,
    double? audioLevel,
    SpeechRecognitionError? lastError,
    List<SpeechRecognitionResult>? interimResults,
    bool? isProcessing,
  }) {
    return SpeechRecognitionState(
      isListening: isListening ?? this.isListening,
      isInitialized: isInitialized ?? this.isInitialized,
      transcribedText: transcribedText ?? this.transcribedText,
      confidence: confidence ?? this.confidence,
      selectedLocale: selectedLocale ?? this.selectedLocale,
      availableLocales: availableLocales ?? this.availableLocales,
      audioLevel: audioLevel ?? this.audioLevel,
      lastError: lastError ?? this.lastError,
      interimResults: interimResults ?? this.interimResults,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpeechRecognitionState &&
        other.isListening == isListening &&
        other.isInitialized == isInitialized &&
        other.transcribedText == transcribedText &&
        other.confidence == confidence &&
        other.selectedLocale == selectedLocale &&
        listEquals(other.availableLocales, availableLocales) &&
        other.audioLevel == audioLevel &&
        other.lastError == lastError &&
        listEquals(other.interimResults, interimResults) &&
        other.isProcessing == isProcessing;
  }

  @override
  int get hashCode => Object.hash(
        isListening,
        isInitialized,
        transcribedText,
        confidence,
        selectedLocale,
        Object.hashAll(availableLocales),
        audioLevel,
        lastError,
        Object.hashAll(interimResults),
        isProcessing,
      );
}

@immutable
class UserPreferences {
  final bool zhuyinOn;
  final double soundSpeed;
  final int grade;
  final String locale;
  final bool darkMode;

  const UserPreferences({
    this.zhuyinOn = true,
    this.soundSpeed = 0.5,
    this.grade = 1,
    this.locale = 'zh_TW',
    this.darkMode = false,
  });

  UserPreferences copyWith({
    bool? zhuyinOn,
    double? soundSpeed,
    int? grade,
    String? locale,
    bool? darkMode,
  }) {
    return UserPreferences(
      zhuyinOn: zhuyinOn ?? this.zhuyinOn,
      soundSpeed: soundSpeed ?? this.soundSpeed,
      grade: grade ?? this.grade,
      locale: locale ?? this.locale,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPreferences &&
        other.zhuyinOn == zhuyinOn &&
        other.soundSpeed == soundSpeed &&
        other.grade == grade &&
        other.locale == locale &&
        other.darkMode == darkMode;
  }

  @override
  int get hashCode => Object.hash(
        zhuyinOn,
        soundSpeed,
        grade,
        locale,
        darkMode,
      );
}