// teach_word/presentation/widgets/tabs/speak_tab.dart

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeakTab extends ConsumerStatefulWidget {
  final int widgetId;
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
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
  late AudioPlayer audioPlayer;
  late AudioRecorder recorder;
  late SpeechToText speechToText;  
  double fontSize = 20;  
  
  // Recording state
  bool isRecording = false;
  bool hasRecording = false;
  String? recordingPath;
  int remainingTrials = 3;
  Timer? recordingTimer;
  int recordingSeconds = 0;
  double? audioLevel;
  String transcribedText = '';
  bool isListening = false;  
  
  // Practice state
  PracticeMode mode = PracticeMode.listening;
  bool isPlaying = false;

  late String vocab;
  late String sentence;
  late double deviceWidth;
  bool isAnswerCorrect = false;
  int vocabIndex = 0;
  bool isLastPage = false;
  static const _interval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _initVariables(0); // Initialize with first vocab
  }

  void _initializeComponents() {
    ftts = ref.read(ttsProvider);
    audioPlayer = ref.read(audioPlayerProvider);
    recorder = ref.read(recorderProvider);
    speechToText = ref.read(speechToTextProvider);    
    
    // Check permission on component initialization
    _checkMicrophonePermission();
  }

  Future<void> _checkMicrophonePermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('需要麥克風權限才能進行錄音練習', style: TextStyle(fontSize: fontSize))),
        );
      }
    }
  }

  void _initVariables(int index) {
    vocabIndex = index.clamp(0, widget.vocabCnt - 1);
    vocab = widget.wordObj['vocab${index + 1}'] ?? '';
    sentence = widget.wordObj['sentence${index + 1}'] ?? '';
    isLastPage = (index == widget.vocabCnt - 1);
  }  

  Future<void> _startRecording() async {
    try {
      final path = await _getRecordingPath();
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      
      setState(() {
        isRecording = true;
        recordingPath = path;
        recordingSeconds = 0;
      });

      recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          recordingSeconds++;
          if (recordingSeconds >= 10) {
            _stopRecording();
          }
        });
      });

      recorder.onAmplitudeChanged(_interval).listen((amp) {
        if (mounted) {
          setState(() => audioLevel = amp.current);
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('錄音開始失敗: $e', style: TextStyle(fontSize: fontSize))),
        );
      }
    }
  }

  Future<String> _getRecordingPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
  }

  /*
  Future<void> _startListening() async {
    setState(() {
      transcribedText = '';
      isListening = true;
    });

    await speechToText.listen(
      localeId: 'zh_TW',
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          transcribedText = result.recognizedWords;
        });
      },
      SpeechListenOptions.partialResults : true,  // This replaces the options parameter
      listenFor: const Duration(seconds: 30),  // Optional: limit the listening time
      pauseFor: const Duration(seconds: 3),    // Optional: auto-stop after pause
    );

    // Start recording simultaneously
    _startRecording();
  }
  */

  Future<void> _startListening() async {
    setState(() {
      transcribedText = '';
      isListening = true;
    });

    await speechToText.listen(
      localeId: 'zh_TW',
      onResult: (SpeechRecognitionResult result) {
        setState(() {
          transcribedText = result.recognizedWords;
        });
      },
    );

    // Start recording simultaneously
    _startRecording();
  }


  Future<void> _stopListening() async {
    await speechToText.stop();
    await _stopRecording();
    
    setState(() {
      isListening = false;
    });
  }


  @override
  void dispose() {
    recordingTimer?.cancel();
    if (isRecording) {
      recorder.stop();
    }
    if (isListening) {
      speechToText.stop();
    }
    super.dispose();
  }

  Future<void> _stopRecording() async {
    recordingTimer?.cancel();
    await recorder.stop();
    
    setState(() {
      isRecording = false;
      hasRecording = true;
    });
  }

  Future<void> _playRecording() async {
    if (recordingPath == null) return;
    
    setState(() => isPlaying = true);
    await audioPlayer.play(DeviceFileSource(recordingPath!));
    setState(() => isPlaying = false);
  }

  Future<void> _speak(String text) async {
    await ftts.speak(text);
  }

  Widget _buildVocabularySection() {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZhuyinProcessing(
            text: vocab,
            fontSize: fontSize * 1.2,
            color: explanationColor,
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            iconSize: fontSize * 1.2,
            color: explanationColor,
            onPressed: () => _speak(vocab),
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceSection() {
    return Padding(
      padding: EdgeInsets.only(left: fontSize * 0.5),
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
            text: sentence,
            fontSize: fontSize,
            color: whiteColor,
          ),
        ],
      ),
    );
  }

  // Modify _buildPracticeControls to include transcription
  Widget _buildPracticeControls() {
    if (mode == PracticeMode.listening) {
      return ElevatedButton(
        onPressed: () {
          setState(() => mode = PracticeMode.recording);
          _startListening();
        },
        child: Text("開始朗讀", style: TextStyle(fontSize: fontSize)),
      );
    }

    return Column(
      children: [
        if (isRecording) ...[
          AudioLevelIndicator(level: audioLevel),
          Text("剩餘時間: ${10 - recordingSeconds}秒", style: TextStyle(fontSize: fontSize)),
          
          // Add transcription display
          if (transcribedText.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: fontSize * 0.5),
              padding: EdgeInsets.all(fontSize * 0.5),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "辨識結果：",
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    transcribedText,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
            ),
          
          ElevatedButton(
            onPressed: _stopListening,
            child: Text("停止錄音", style: TextStyle(fontSize: fontSize)),
          ),
        ] else if (hasRecording) ...[
          // Show final transcription result
          if (transcribedText.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: fontSize * 0.5),
              padding: EdgeInsets.all(fontSize * 0.5),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "您的朗讀：",
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    transcribedText,
                    style: TextStyle(fontSize: fontSize),
                  ),
                  SizedBox(height: fontSize * 0.5),
                  Text(
                    "正確內容：",
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    vocab,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
            ),

          ElevatedButton(
            onPressed: _playRecording,
            child: Text("播放錄音", style: TextStyle(fontSize: fontSize)),
          ),
          SizedBox(height: fontSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: remainingTrials > 0 ? () {
                  setState(() {
                    transcribedText = '';
                  });
                  _startListening();
                } : null,
                child: Text("重新練習 (剩餘$remainingTrials次)", 
                     style: TextStyle(fontSize: fontSize)),
              ),
              ElevatedButton(
                onPressed: () {
                  // Store practice result
                  // You might want to save the transcribedText and recording
                  setState(() {
                    mode = PracticeMode.listening;
                    hasRecording = false;
                    transcribedText = '';
                  });
                },
                child: Text("完成練習", style: TextStyle(fontSize: fontSize)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationSwitch() {
    return LeftRightSwitch(
      fontSize: fontSize,
      iconsColor: lightGray,
      iconsSize: fontSize * 1.5,
      rightBorder: mode == PracticeMode.listening,
      middleWidget: ZhuyinProcessing(
        text: '說一說',  // Changed from '用一用' to '說一說'
        color: lightGray,
        fontSize: fontSize * 1.2,
        fontWeight: FontWeight.bold,
        centered: true,
      ),
      isFirst: false,
      isLast: isLastPage,
      onLeftClicked: vocabIndex > 0
          ? () {
              setState(() {
                vocabIndex--;
                _initVariables(vocabIndex);
              });
              // _handleGoToUse();
            }
          : null,
      onRightClicked: mode == PracticeMode.listening && !isLastPage 
          ? _onContinuePressed 
          : null,
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      right: fontSize,
      bottom: fontSize,
      child: Text(
        "${vocabIndex + 1} / ${widget.vocabCnt}",
        style: TextStyle(
          fontSize: fontSize * 0.75,
          fontWeight: FontWeight.normal,
          color: backgroundColor,
        ),
      ),
    );
  }

  void _onContinuePressed() {
    if (isLastPage) {
      widget.onNextTab();
    } else {
      setState(() {
        vocabIndex++;
        _initVariables(vocabIndex);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.read(screenInfoProvider);
    fontSize = screenInfo.fontSize;
    deviceWidth = screenInfo.screenWidth;    
    debugPrint('SpeakTab: Building with fontSize $fontSize, widgetId: ${widget.widgetId}, vocabCnt=${widget.vocabCnt}');    
    return TeachWordTabBarView(
      content: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildNavigationSwitch(),
                SizedBox(height: fontSize),
                _buildVocabularySection(),
                SizedBox(height: fontSize),
                _buildSentenceSection(),
                SizedBox(height: fontSize * 1.5),
                _buildPracticeControls(),
              ],
            ),
          ),
          _buildPageIndicator(),
        ],
    ),
    );
  }
}

enum PracticeMode {
  listening,
  recording,
}

class AudioLevelIndicator extends StatelessWidget {
  final double? level;
  
  const AudioLevelIndicator({super.key, this.level});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: (level ?? 0) / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }
}

