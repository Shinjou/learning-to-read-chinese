// lib/teach_word/presentation/widgets/tabs/speak_tab.dart

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
// Modify only compareTexts and related logic
ComparisonResult compareTexts(String originalText, String recognizedText) {
  final alignment = _computeAlignment(originalText, recognizedText);

  int matched = 0;
  int originalLen = originalText.length;
  int recognizedLen = recognizedText.length;

  List<InlineSpan> spans = [];

  int i = 0;
  while (i < alignment.length) {
    if (alignment[i].originalChar.isNotEmpty && alignment[i].recognizedChar.isNotEmpty &&
        alignment[i].originalChar == alignment[i].recognizedChar) {
      // Match
      spans.add(TextSpan(text: alignment[i].originalChar));
      matched++;
      i++;
    } else {
      int start = i;
      while (i < alignment.length &&
             !(alignment[i].originalChar.isNotEmpty && alignment[i].recognizedChar.isNotEmpty
               && alignment[i].originalChar == alignment[i].recognizedChar)) {
        i++;
      }
      var diffRun = alignment.getRange(start, i).toList();

      String originalSegment = diffRun.where((p) => p.originalChar.isNotEmpty).map((p) => p.originalChar).join();
      String recognizedSegment = diffRun.where((p) => p.recognizedChar.isNotEmpty).map((p) => p.recognizedChar).join();

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
        // Count matched chars in prefix
        matched += commonPrefix.length;
      }

      // Now handle the differing middle parts
      // oMid: missing original chars → underline
      // rMid: extra recognized chars → strikethrough
      if (oMid.isNotEmpty) {
        // These original chars were not recognized, need to be added back → underline
        spans.add(TextSpan(
          text: oMid,
          style: TextStyle(decoration: TextDecoration.underline, color: Colors.black),
        ));
      }
      if (rMid.isNotEmpty) {
        // These recognized chars are extra → strikethrough
        spans.add(TextSpan(
          text: rMid,
          style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.black),
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
  double accuracy = 1.0;
  if ((originalLen + recognizedLen) > 0) {
    accuracy = (matched * 2.0) / (originalLen + recognizedLen);
  }

  return ComparisonResult(
    TextSpan(children: spans, style: TextStyle(color: Colors.black)),
    accuracy
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
  // Core state variables
  late FlutterTts ftts;
  late double fontSize;
  late double deviceWidth;

  // Navigation state
  int vocabIndex = 0;
  int nextStepId = 0;
  bool isLastVocab = false;
  bool hasSpoken = false;

  // Word-specific state
  late String vocab;
  late String vocab2;
  late String sentence;
  bool isAnswerCorrect = false;
  late int pageIndex;
  static const accuracyThreshold = 0.6;

  @override
  void initState() {
    super.initState(); 
    _initializeComponents();
    debugPrint('SpeakTabState.initState called for widgetId: ${widget.widgetId}');    
  }
  
  void _initializeComponents() {
    ftts = ref.read(ttsProvider);
    pageIndex = 0;
    _initVariables(pageIndex); // Start with first page
  }  

  void _initVariables(int pageIndex) {
    final notifier = ref.read(speechStateProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.resetPractice();
    });

    vocabIndex = pageIndex.clamp(0, widget.vocabCnt - 1);
    vocab = widget.wordObj['vocab${pageIndex + 1}'] ?? ''; // Add default value
    vocab2 = widget.wordObj['vocab${(pageIndex + 1) % widget.vocabCnt + 1}'] ?? ''; // Add default value
    sentence = widget.wordObj['sentence${pageIndex + 1}'] ?? ''; // Add default value
    isAnswerCorrect = false;
    isLastVocab = (pageIndex == widget.vocabCnt - 1);

    if (!mounted) return; // Ensure context is valid
    setState(() {
      nextStepId = pageIndex == 0
          ? TeachWordSteps.steps['goToSpeak1']!
          : TeachWordSteps.steps['goToSpeak2']!;
      hasSpoken = false;
    });
  }

  Future<void> _handleGoToSpeak() async {
    debugPrint('_handleGoToSpeak hasSpoken=$hasSpoken, vocabCnt=${widget.vocabCnt}, vocabIndex=$vocabIndex, nextStepId=$nextStepId');
    if (hasSpoken) return; // Prevent multiple calls
    hasSpoken = true;    
    await handleGoToSpeak(widget.vocabCnt, vocabIndex, nextStepId, widget.wordObj, ftts);
  }

  Future<void> _speak(String text) async {
    await ftts.speak(text);
  }

  Widget _buildNavigationSwitch() {
    return LeftRightSwitch(
      fontSize: fontSize,
      iconsColor: lightGray,
      iconsSize: fontSize * 1.5,
      // rightBorder: isAnswerCorrect && vocabIndex == 0,
      rightBorder: isAnswerCorrect,
      middleWidget: ZhuyinProcessing(
        textParam: '說一說',
        color: lightGray,
        fontSize: fontSize * 1.2,        
        fontWeight: FontWeight.bold,  // Optional font weight
        centered: true,  // Optional centering
      ),            
      isFirst: false,
      // isLast: isLastVocab,
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
        if (!isAnswerCorrect) {
          debugPrint('說一說-第${vocabIndex + 1}句，$vocab, 需再試！');
          return; // 需再試，do nothing
        } else if (isLastVocab) {
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
    setState(() {
      vocabIndex++;
      hasSpoken = false; // Reset for the next page
      _initVariables(vocabIndex);
    });
  }

  void _onPreviousVocab() {
    if (vocabIndex > 0) {
      setState(() {
        vocabIndex--;
        _initVariables(vocabIndex);
      });
    }
  }

  Widget _buildSentenceSection() {
    return Padding(
      // More symmetric padding so there's space on both left and right
      padding: EdgeInsets.symmetric(horizontal: fontSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "例句：",
                style: TextStyle(
                  fontSize: fontSize,
                  color: explanationColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                iconSize: fontSize,
                color: explanationColor,
                onPressed: () => _speak(sentence),
              ),
            ],
          ),
          ZhuyinProcessing(
            textParam: sentence,
            fontSize: fontSize,
            color: whiteColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeControls() {
    final speechState = ref.watch(speechStateProvider);
    final notifier = ref.read(speechStateProvider.notifier);

    // Common decorations and constraints
    final commonBoxDecoration = BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8),
    );

    final containerPadding = EdgeInsets.all(fontSize * 0.5);
    final containerMargin = EdgeInsets.symmetric(horizontal: fontSize, vertical: fontSize * 0.5);

    switch (speechState.state) {
      case RecordingState.idle:
        return ElevatedButton(
          onPressed: () => notifier.startCountdown(),
          child: Text("開始朗讀", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
        );

      case RecordingState.countdown:
        return SizedBox(
          width: fontSize * 10, // fixed size
          height: fontSize * 10,
          child: CountdownDisplay(
            countdownValue: speechState.countdownValue,
            fontSize: fontSize,
          ),
        );

      /*
      case RecordingState.listening:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Large box for transcribed text (even though no subtitle needed here as per design)
            Container(
              margin: containerMargin,
              padding: containerPadding,
              decoration: commonBoxDecoration.copyWith(color: Colors.grey[200]),
              constraints: BoxConstraints(minHeight: fontSize * 3.0),
              width: deviceWidth * 0.9,
              child: Text(
                speechState.transcribedText,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => notifier.stopListening(),
              child: Text("停止", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
            ),
          ],
        );
      */

      case RecordingState.listening:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: containerMargin,
              padding: containerPadding,
              decoration: commonBoxDecoration.copyWith(color: Colors.grey[200]),
              constraints: BoxConstraints(minHeight: fontSize * 3.0),
              width: deviceWidth * 0.9,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Text(
                  speechState.transcribedText,
                  key: ValueKey<String>(speechState.transcribedText),
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => notifier.stopListening(),
              child: Text("停止", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
            ),
          ],
        );

      case RecordingState.finished:
        // Raw recognized text
        String rawText = speechState.transcribedText;

        String normOriginal = normalizeForAccuracy(sentence);
        String normRecognized = normalizeForAccuracy(rawText);

        final comparison = compareTexts(normOriginal, normRecognized);
        double accuracy = comparison.accuracy;
        int wpm = calculateWPM(normRecognized, speechState.recordingSeconds);
        String message = feedbackMessage(accuracy);
        if (accuracy >= accuracyThreshold) {
          setState(() {
            isAnswerCorrect = true;
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Subtitle for transcribed text line
            Padding(
              padding: EdgeInsets.symmetric(horizontal: fontSize),
              child: Align(
                alignment: Alignment.centerLeft,
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
              margin: containerMargin,
              padding: containerPadding,
              decoration: commonBoxDecoration.copyWith(color: Colors.grey[300]),
              constraints: BoxConstraints(minHeight: fontSize * 3.0),
              width: double.infinity,
              child: ZhuyinProcessing(
                textParam: rawText,
                fontSize: fontSize,
                color: Colors.black,
              ),              
            ),

            // If accuracy < 1.0, show diff line with subtitle
            if (accuracy < 1.0) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: fontSize),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "跟原文比對",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: explanationColor,
                    ),
                  ),
                ),
              ),

              Container(
                margin: containerMargin,
                padding: containerPadding,
                decoration: commonBoxDecoration,
                constraints: BoxConstraints(minHeight: fontSize * 3.0),
                width: double.infinity,
                child: ZhuyinProcessing.fromSpan(
                  spanParam: comparison.highlightedSpan,
                  fontSize: fontSize * 1.0,
                  color: Colors.black,
                ),
              ),
            ],

            Wrap(
              spacing: fontSize * 1.5,
              runSpacing: fontSize * 0.5,
              alignment: WrapAlignment.center,
              children: [
                Text("準確率: ${(accuracy * 100).toStringAsFixed(0)}%", style: TextStyle(fontSize: fontSize, color: Colors.white)),
                Text("語速: $wpm 字/分鐘", style: TextStyle(fontSize: fontSize, color: Colors.white)),
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
                  onPressed: () => notifier.retry(),
                  child: Text("重新練習", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
                ),
                if (speechState.recordingPath != null)
                  ElevatedButton(
                    onPressed: () => notifier.playRecording(),
                    child: Text("聽取錄音", style: TextStyle(fontSize: fontSize, color: Colors.grey[600])),
                  ),    
              ]
            )
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.read(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    deviceWidth = screenInfo.screenWidth;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildNavigationSwitch(),
          // SizedBox(height: fontSize * 0.5),          
          // _buildVocabularySection(),
          // SizedBox(height: fontSize),
          _buildSentenceSection(),
          SizedBox(height: fontSize * 1.5),
          _buildPracticeControls(),
        ],
      ),
    );
  }
}

