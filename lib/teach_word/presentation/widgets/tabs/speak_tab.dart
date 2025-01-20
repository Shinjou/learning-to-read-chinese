// lib/teach_word/presentation/widgets/tabs/speak_tab.dart

import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';
import 'package:ltrc/teach_word/models/speech_state.dart';
import 'package:ltrc/teach_word/presentation/teach_word_utils.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';
import 'package:ltrc/teach_word/notifiers/speech_state_notifier.dart';

class ComparisonResult {
  final InlineSpan highlightedSpan;
  final double accuracy;
  ComparisonResult(this.highlightedSpan, this.accuracy);
}

class AlignmentPair {
  final String originalChar; 
  final String recognizedChar;
  AlignmentPair(this.originalChar, this.recognizedChar);
}

// Normalize text by removing punctuation and spaces for accuracy calculation
String normalizeForAccuracy(String text) {
  // Remove punctuation, spaces, invisible chars
  final punctuationMarks = ['，','。','！','？','、',' ', '\n','\r','\t'];
  StringBuffer sb = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    String ch = text[i];
    if (!punctuationMarks.contains(ch)) {
      sb.write(ch);
    }
  }
  return sb.toString();
}

// Compare normalized texts and compute accuracy
ComparisonResult compareTexts(String originalText, String recognizedText) {
  final alignment = _computeAlignment(originalText, recognizedText);

  int matched = 0;
  int originalLen = originalText.length;
  int recognizedLen = recognizedText.length;

  List<InlineSpan> spans = [];

  int i = 0;
  while (i < alignment.length) {
    if (alignment[i].originalChar.isNotEmpty &&
        alignment[i].recognizedChar.isNotEmpty &&
        alignment[i].originalChar == alignment[i].recognizedChar) {
      // Match
      spans.add(TextSpan(text: alignment[i].originalChar));
      matched++;
      i++;
    } else {
      int start = i;
      while (i < alignment.length &&
          !(alignment[i].originalChar.isNotEmpty &&
              alignment[i].recognizedChar.isNotEmpty &&
              alignment[i].originalChar == alignment[i].recognizedChar)) {
        i++;
      }
      var diffRun = alignment.getRange(start, i).toList();

      String originalSegment =
          diffRun.where((p) => p.originalChar.isNotEmpty).map((p) => p.originalChar).join();
      String recognizedSegment =
          diffRun.where((p) => p.recognizedChar.isNotEmpty).map((p) => p.recognizedChar).join();

      // Find longest common prefix
      int prefixLen = _commonPrefixLength(originalSegment, recognizedSegment);
      String commonPrefix = originalSegment.substring(0, prefixLen);
      String oMid = originalSegment.substring(prefixLen);
      String rMid = recognizedSegment.substring(prefixLen);

      // Find longest common suffix of the remainder
      int suffixLen = _commonSuffixLength(oMid, rMid);
      String commonSuffix = "";
      if (suffixLen > 0) {
        commonSuffix = oMid.substring(oMid.length - suffixLen);
        oMid = oMid.substring(0, oMid.length - suffixLen);
        rMid = rMid.substring(0, rMid.length - suffixLen);
      }

      // Add common prefix as normal matched text
      if (commonPrefix.isNotEmpty) {
        spans.add(TextSpan(text: commonPrefix));
        matched += commonPrefix.length;
      }

      // Handle differing middle parts
      if (oMid.isNotEmpty) {
        spans.add(TextSpan(
          text: oMid,
          style: const TextStyle(decoration: TextDecoration.underline, color: Colors.black),
        ));
      }
      if (rMid.isNotEmpty) {
        spans.add(TextSpan(
          text: rMid,
          style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black),
        ));
      }

      // Add common suffix
      if (commonSuffix.isNotEmpty) {
        spans.add(TextSpan(text: commonSuffix));
        matched += commonSuffix.length;
      }
    }
  }

  // Calculate accuracy
  int extraChars = recognizedLen - matched; // Characters in recognizedText that are unmatched
  double accuracy = 1.0;
  if ((originalLen + extraChars) > 0) {
    accuracy = matched / (originalLen + extraChars);
  }

  debugPrint('${formattedActualTime()} compareTexts: originalLen=$originalLen, recognizedLen=$recognizedLen, matched=$matched, extraChars=$extraChars, accuracy=$accuracy');

  return ComparisonResult(
    TextSpan(children: spans, style: const TextStyle(color: Colors.black)),
    accuracy,
  );
}


int _commonPrefixLength(String a, String b) {
  int minLen = a.length < b.length ? a.length : b.length;
  int idx = 0;
  while (idx < minLen && a[idx] == b[idx]) {
    idx++;
  }
  return idx;
}

int _commonSuffixLength(String a, String b) {
  int minLen = min(a.length, b.length);
  int idx = 0;
  while (idx < minLen && a[a.length - 1 - idx] == b[b.length - 1 - idx]) {
    idx++;
  }
  return idx;
}


int calculateWPM(String recognizedText, int elapsedSeconds) {
  if (elapsedSeconds == 0) return 0;
  // recognizedText is normalized for accuracy; it contains only meaningful chars
  int wordCount = recognizedText.length; // each char as a word
  double wpm = (wordCount / elapsedSeconds) * 60.0;
  debugPrint('${formattedActualTime()} calculateWPM: recognizedText=$recognizedText, elapsedSeconds=$elapsedSeconds, wordCount=$wordCount, wpm=$wpm');
  return wpm.round();
}

String feedbackMessage(double accuracy) {
  if (accuracy == 1.00) {
    return "超群絕倫，完全正確！";
  } else if (accuracy >= 0.90) {
    return "才華出眾，幾乎全對！";
  } else if (accuracy >= 0.8) {
    return "不同凡響，只差一點！";
  } else if (accuracy >= 0.7) {
    return "與眾不同，繼續努力！";
  } else if (accuracy >= 0.6) {
    return "孜孜不倦，可以更好！";    
  } else {
    return "再來一次，永不放棄！";
  }
}

// Compute alignment using Levenshtein DP
List<AlignmentPair> _computeAlignment(String original, String recognized) {
  int m = original.length;
  int n = recognized.length;

  List<List<int>> dp = List.generate(m+1, (_) => List.filled(n+1, 0));
  for (int i = 1; i <= m; i++) {
    dp[i][0] = i;
  }
  for (int j = 1; j <= n; j++) {
    dp[0][j] = j;
  }

  for (int i = 1; i <= m; i++) {
    for (int j = 1; j <= n; j++) {
      int cost = (original[i-1] == recognized[j-1]) ? 0 : 1;
      dp[i][j] = _min3(
        dp[i-1][j] + 1,
        dp[i][j-1] + 1,
        dp[i-1][j-1] + cost
      );
    }
  }

  List<AlignmentPair> alignment = [];
  int i = m, j = n;
  while (i > 0 || j > 0) {
    if (i > 0 && j > 0 && dp[i][j] == dp[i-1][j-1] + ((original[i-1] == recognized[j-1])?0:1)) {
      alignment.insert(0, AlignmentPair(original[i-1], recognized[j-1]));
      i--;
      j--;
    } else if (i > 0 && dp[i][j] == dp[i-1][j] + 1) {
      alignment.insert(0, AlignmentPair(original[i-1], ''));
      i--;
    } else {
      alignment.insert(0, AlignmentPair('', recognized[j-1]));
      j--;
    }
  }

  return alignment;
}

int _min3(int a, int b, int c) {
  if (a <= b && a <= c) return a;
  if (b <= a && b <= c) return b;
  return c;
}

class SpeakTab extends ConsumerStatefulWidget {
  final int widgetId;
  final int unitId;
  final String unitTitle;
  final List<dynamic> wordsStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;
  final VoidCallback onNextTab;
  final VoidCallback onPreviousTab;
  final TabController tabController;
  final bool isBpmf;
  final Map wordObj;
  final int vocabCnt;

  const SpeakTab({
    super.key,
    required this.widgetId,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
    required this.onNextTab,
    required this.onPreviousTab,
    required this.tabController,
    required this.isBpmf,
    required this.wordObj,
    required this.vocabCnt,
  });

  @override
  SpeakTabState createState() => SpeakTabState();
}

class SpeakTabState extends ConsumerState<SpeakTab> {
  late FlutterTts ftts;
  late double fontSize;
  late double deviceWidth;
  late SpeechState speechState;

  // Navigation state
  int vocabIndex = 0;
  int nextStepId = 0;
  bool isLastVocab = false;
  bool hasSpoken = false;

  // Word-specific state
  late String vocab;
  late String vocab2;
  late String sentence;
  late int pageIndex;
  static const accuracyThreshold = 0.6;

  /// For Android only: user picks either STT or record mode
  bool _isSttMode = true; // default "語音轉文字"

  double volume = 0.9; // Volume for playback. fixed because volume controller requires sdk 35

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    debugPrint('${formattedActualTime()} SpeakTabState.initState called for widgetId: ${widget.widgetId}');
  }

  void _initializeComponents() {
    ftts = ref.read(ttsProvider);
    pageIndex = 0;
    _initVariables(pageIndex); // Start with first page
  }

  void _initVariables(int pageIndex) {
    final notifier = ref.read(speechStateProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.reset();
    });

    vocabIndex = pageIndex.clamp(0, widget.vocabCnt - 1);
    vocab = widget.wordObj['vocab${pageIndex + 1}'] ?? ''; // Add default value
    vocab2 = widget.wordObj['vocab${(pageIndex + 1) % widget.vocabCnt + 1}'] ?? ''; // Add default value
    sentence = widget.wordObj['sentence${pageIndex + 1}'] ?? ''; // Add default value
    isLastVocab = (pageIndex == widget.vocabCnt - 1);

    if (!mounted) return;
    setState(() {
      nextStepId = pageIndex == 0
          ? TeachWordSteps.steps['goToSpeak1']!
          : TeachWordSteps.steps['goToSpeak2']!;
      hasSpoken = false;
    });
    debugPrint('${formattedActualTime()} _initVariables called. pageIndex=$pageIndex, vocab=$vocab, vocab2=$vocab2, nextStepId=$nextStepId');
  }

  Future<void> _handleGoToSpeak() async {
    debugPrint('${formattedActualTime()} _handleGoToSpeak hasSpoken=$hasSpoken, vocabCnt=${widget.vocabCnt}, vocabIndex=$vocabIndex, nextStepId=$nextStepId');
    if (hasSpoken) return;
    hasSpoken = true;
    await handleGoToSpeak(widget.vocabCnt, vocabIndex, nextStepId, widget.wordObj, ftts);
  }

  Widget _buildNavigationSwitch() {
    debugPrint('${formattedActualTime()} _buildNavigationSwitch called.');

    return LeftRightSwitch(
      fontSize: fontSize,
      iconsColor: lightGray,
      iconsSize: fontSize * 1.5,
      rightBorder: speechState.isAnswerCorrect, // Directly bound to SpeechState,
      middleWidget: ZhuyinProcessing(
        textParam: '說一說',
        color: lightGray,
        fontSize: fontSize * 1.2,
        fontWeight: FontWeight.bold,
        centered: true,
      ),
      isFirst: false,
      isLast: false,

      onLeftClicked: () {
        if (vocabIndex == 0) {
          widget.onPreviousTab();
        } else {
          _onPreviousVocab();
          _handleGoToSpeak();
        }
      },
      onRightClicked: () {
        debugPrint('${formattedActualTime()} Right navigation clicked. isAnswerCorrect=${speechState.isAnswerCorrect}');

        // 1) If iOS, must pass accuracy.
        // 2) If Android + STT mode, must pass accuracy.
        // 3) If Android + record mode, can skip accuracy check.
        bool mustPassAccuracy = false;
        if (Platform.isIOS) {
          mustPassAccuracy = true;
        } else if (Platform.isAndroid && _isSttMode) {
          mustPassAccuracy = true;
        }

        if (mustPassAccuracy && !speechState.isAnswerCorrect) {
          debugPrint('${formattedActualTime()} 說一說-第${vocabIndex + 1}句，$vocab, 需再試！');
          return;
        }

        if (isLastVocab) {
          goToNextCharacter(
            context: context,
            ref: ref,
            currentWordIndex: widget.wordIndex,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            widgetId: widget.widgetId
          );
        } else {
          _onNextVocab();
          _handleGoToSpeak();
        }
      },
    );
  }

  void _onNextVocab() {
    debugPrint('${formattedActualTime()} _onNextVocab called. Moving to next vocab.');
    vocabIndex++;
    _initVariables(vocabIndex);
  }

  void _onPreviousVocab() {
    debugPrint('${formattedActualTime()} _onPreviousVocab called. Moving to previous vocab.'); 
    if (vocabIndex > 0) {
      vocabIndex--;
      _initVariables(vocabIndex);
    }
  }

  Widget _buildSentenceSection() {
    debugPrint('${formattedActualTime()} _buildSentenceSection called.');    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "例句：",
                  style: TextStyle(
                    fontSize: fontSize,
                    color: explanationColor,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                iconSize: fontSize,
                color: explanationColor,
                onPressed: () => ftts.speak(sentence),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ZhuyinProcessing(
              textParam: sentence,
              fontSize: fontSize,
              color: whiteColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Show transcription if iOS concurrency or Android STT mode
  Widget _buildTranscriptionSection() {
    debugPrint('${formattedActualTime()} _buildTranscriptionSection called.');

    final showTranscription = Platform.isIOS || (Platform.isAndroid && _isSttMode);

    if (!showTranscription) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Ensure alignment to the left
      children: [
        SizedBox(height: fontSize),
        // Subtitle for transcribed text line
        Padding(
          padding: EdgeInsets.symmetric(horizontal: fontSize),
          child: Align(
            alignment: Alignment.centerLeft, // Align the subtitle to the left
            child: Text(
              "轉錄文字",
              style: TextStyle(
                fontSize: fontSize,
                color: explanationColor,
              ),
            ),
          ),
        ),

        // Transcribed line container
        Container(
          margin: EdgeInsets.symmetric(horizontal: fontSize, vertical: fontSize * 0.5),
          padding: EdgeInsets.all(fontSize * 0.5),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: BoxConstraints(minHeight: fontSize * 3.0),
          width: double.infinity,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                speechState.transcribedText,
                key: ValueKey<String>(speechState.transcribedText),
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The practice controls (start, stop, feedback). We handle iOS concurrency as before,
  /// but on Android we only do STT or record, not both at the same time.
  Widget _buildPracticeControls() {
    final notifier = ref.read(speechStateProvider.notifier);

    // debugPrint('${formattedActualTime()} _buildPracticeControls called. RecordingState: ${speechState.state}');

    switch (speechState.state) {
      case RecordingState.idle:
        return ElevatedButton(
          onPressed: () {
            debugPrint('${formattedActualTime()} Start button pressed. Starting countdown...');
            notifier.startCountdown(isSttMode: _isSttMode);
          },
          child: Text("開始朗讀", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
        );

      case RecordingState.countdown:
        debugPrint('${formattedActualTime()} Rendering CountdownDisplay. countdownValue: ${speechState.countdownValue}');
        return SizedBox(height: fontSize);

      case RecordingState.listening:
        debugPrint('${formattedActualTime()} Listening state. Rendering stop button.');
        return ElevatedButton(
          onPressed: () async {
            debugPrint('User tapped Stop.');
            await notifier.stopListening(isSttMode: _isSttMode); 
          },
          child: Text("停止", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
        );

      case RecordingState.finished:
        return _buildFeedback(notifier, speechState);
    }
  }

  /// Decide how to show feedback:
  /// - iOS => concurrency => show STT diff plus “聽取錄音” if any
  /// - Android STT => show diff, no “聽取錄音”
  /// - Android record => no diff, show “聽取錄音”
  Widget _buildFeedback(SpeechStateNotifier notifier, SpeechState speechState) {
    debugPrint('${formattedActualTime()} _buildFeedback called.');

    if (Platform.isIOS) {
      return _buildFeedbackiOS(notifier, speechState);
    } else {
      // Android => choose based on _isSttMode
      if (_isSttMode) {
        // STT => show transcript/diff, no "聽取錄音"
        return _buildFeedbackStt(notifier, speechState);
      } else {
        // Record => no transcript, only "聽取錄音"
        return _buildFeedbackRecord(notifier, speechState);
      }
    }
  }

  /// iOS concurrency => show transcript/diff + "聽取錄音" if path != null
  Widget _buildFeedbackiOS(SpeechStateNotifier notifier, SpeechState speechState) {
    final rawText = speechState.transcribedText;
    final normOriginal = normalizeForAccuracy(sentence);
    final normRecognized = normalizeForAccuracy(rawText);
    final comparison = compareTexts(normOriginal, normRecognized);
    final accuracy = comparison.accuracy;
    final wpm = calculateWPM(normRecognized, speechState.recordingSeconds);
    final message = feedbackMessage(accuracy);

    bool newIsAnswerCorrect = accuracy >= accuracyThreshold;
    if (speechState.isAnswerCorrect != newIsAnswerCorrect) {
      Future.microtask(() {
        notifier.updateAnswerCorrectness(newIsAnswerCorrect);
      });
    }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        // If accuracy < 1.0, show diff
        if (accuracy < 1.0) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: fontSize),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "比對結果",
                style: TextStyle(
                  fontSize: fontSize,
                  color: explanationColor,
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: fontSize, vertical: fontSize * 0.5),
            padding: EdgeInsets.all(fontSize * 0.5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(minHeight: fontSize * 3.0),
            width: double.infinity,
            child: ZhuyinProcessing.fromSpan(
              spanParam: comparison.highlightedSpan,
              fontSize: fontSize,
              color: Colors.black,
            ),
          ),
        ],
        Wrap(
          spacing: fontSize * 1.5,
          runSpacing: fontSize * 0.5,
          alignment: WrapAlignment.center,
          children: [
            Text(
              "準確率: ${(accuracy * 100).toStringAsFixed(0)}%",
              style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              "語速: $wpm 字/分鐘",
              style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: fontSize),
        Text(message, style: TextStyle(fontSize: fontSize, color: explanationColor)),
        SizedBox(height: fontSize * 0.5),
        Wrap(
          spacing: fontSize,
          runSpacing: fontSize * 0.5,
          children: [
            ElevatedButton(
              onPressed:() => _initVariables(vocabIndex),
              child: Text("重新練習", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
            ),
            if (speechState.recordingPath != null)
              ElevatedButton(
                onPressed: () => notifier.playRecording(volume),
                child: Text("聽取錄音", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
              ),
          ],
        ),
      ],
    );
  }

  /// Android STT => transcript/diff, no "聽取錄音"
  Widget _buildFeedbackStt(SpeechStateNotifier notifier, SpeechState speechState) {
    final rawText = speechState.transcribedText;
    final normOriginal = normalizeForAccuracy(sentence);
    final normRecognized = normalizeForAccuracy(rawText);
    final comparison = compareTexts(normOriginal, normRecognized);
    final accuracy = comparison.accuracy;
    final wpm = calculateWPM(normRecognized, speechState.recordingSeconds);
    final message = feedbackMessage(accuracy);

    bool newIsAnswerCorrect = accuracy >= accuracyThreshold;
    // Update correctness outside of widget rebuild if necessary
    if (speechState.isAnswerCorrect != newIsAnswerCorrect) {
      Future.microtask(() {
        notifier.updateAnswerCorrectness(newIsAnswerCorrect);
      });
    }

    debugPrint('${formattedActualTime()} Feedback calculated. Accuracy: ${(accuracy * 100).toStringAsFixed(2)}%, WPM: $wpm.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // If accuracy < 1.0, show diff line with subtitle
        if (accuracy < 1.0) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: fontSize),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "比對結果",
                style: TextStyle(
                  fontSize: fontSize,
                  color: explanationColor,
                ),
              ),
            ),
          ),

          Container(
            margin: EdgeInsets.symmetric(horizontal: fontSize, vertical: fontSize * 0.5),
            padding: EdgeInsets.all(fontSize * 0.5),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            constraints: BoxConstraints(minHeight: fontSize * 3.0),
            width: double.infinity,
            child: ZhuyinProcessing.fromSpan(
              spanParam: comparison.highlightedSpan,
              fontSize: fontSize,
              color: Colors.black,
            ),
          ),
        ],

        Wrap(
          spacing: fontSize * 1.5,
          runSpacing: fontSize * 0.5,
          alignment: WrapAlignment.center,
          children: [
            Text(
              "準確率: ${(accuracy * 100).toStringAsFixed(0)}%",
              style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              "語速: $wpm 字/分鐘",
              style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        SizedBox(height: fontSize),
        Text(message, style: TextStyle(fontSize: fontSize, color: explanationColor)),
        SizedBox(height: fontSize * 0.5),
        ElevatedButton(
          onPressed: () => notifier.reset(),
          child: Text("重新練習", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
        ),
      ],
    );
  }

  /// Android Record => "聽取錄音" only, no transcript/diff
  Widget _buildFeedbackRecord(SpeechStateNotifier notifier, SpeechState speechState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: fontSize,
          runSpacing: fontSize * 0.5,
          children: [
            ElevatedButton(
              onPressed: () => notifier.reset(),
              child: Text("重新練習", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
            ),
            if (speechState.recordingPath != null)
              ElevatedButton(
                onPressed: () => notifier.playRecording(volume),
                child: Text("聽取錄音", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
              ),
          ],
        ),
      ],
    );
  }

  /// Mode selector at bottom (Android only); iOS hides it
  Widget _buildModeSelector() {
    
    if (Platform.isIOS) {
      // iOS => concurrency => no special toggle
      return const SizedBox.shrink();
    }

    // CHANGED: Hide the checkboxes if we are not in the idle state
    if (speechState.state != RecordingState.idle) {
      // We’re in the middle of recording => remove them entirely
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: fontSize * 1.5, bottom: fontSize),
      padding: EdgeInsets.symmetric(horizontal: fontSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title, if you want it
          Text(
            '選擇模式',
            style: TextStyle(fontSize: fontSize, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: fontSize),

          // 語音轉文字 Checkbox
          Row(
            children: [
              Checkbox(
                value: _isSttMode,
                onChanged: (bool? newVal) {
                  if (newVal == null) return;
                  // If user checks this, we set STT mode = true
                  setState(() {
                    _isSttMode = true;
                    ref.read(speechStateProvider.notifier).reset();
                  });
                },
              ),
              Text(
                "語音轉文字",
                style: TextStyle(
                  fontSize: fontSize,
                  color: _isSttMode ? Colors.lightBlue : Colors.white,
                ),
              ),
            ],
          ),

          // 錄音 Checkbox
          Row(
            children: [
              Checkbox(
                value: !_isSttMode,
                onChanged: (bool? newVal) {
                  if (newVal == null) return;
                  // If user checks this, we set STT mode = false
                  setState(() {
                    _isSttMode = !newVal; // Because newVal means “check for the other mode”
                    ref.read(speechStateProvider.notifier).reset();
                  });
                },
              ),
              Text(
                "錄音",
                style: TextStyle(
                  fontSize: fontSize,
                  color: !_isSttMode ? Colors.lightBlue : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // 1) Watch your synchronous providers:
    speechState = ref.watch(speechStateProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    deviceWidth = screenInfo.screenWidth;

    /* volume_controller.dart requires sdk 35. Could not make it work. commented out for now.
    // 2) (Optional) Watch an AsyncValue from Riverpod:
    //    e.g., an async provider that fetches volume or something else
    final volumeAsync = ref.watch(volumeStateProvider);
    */

    debugPrint('${formattedActualTime()} SpeakTabState.build called. fontSize: $fontSize, state=${speechState.state}');

    /* volume_controller.dart requires sdk 35. Could not make it work. commented out for now.
    // 3) Decide how to handle the async data. 
    //    (If you have no async providers, you can skip the "when" block.)
    return volumeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return Center(child: Text('Error: $error'));
      },
      data: (volume) {
        // 4) Use the data from the async provider plus your normal UI.
        debugPrint('Fetched volume: $volume');
    */
        return SingleChildScrollView(
          child: Column(
            children: [
              // 1) Navigation Switch (top)
              _buildNavigationSwitch(),

              // 2) Sentence
              _buildSentenceSection(),

              // 3) Transcription (if concurrency on iOS or STT mode on Android)
              _buildTranscriptionSection(),
              SizedBox(height: fontSize * 1.5),

              // 4) Practice Controls
              _buildPracticeControls(),

              // 5) Mode selector at the bottom (Android only)
              _buildModeSelector(),
            ],
          ),
        );
    /* commented out volumeAsync.when block for now.
      }
    );
    */
  }
}

