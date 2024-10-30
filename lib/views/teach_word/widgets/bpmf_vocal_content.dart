// widgets/teach_word/bpmf_vocab_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/providers.dart';
// import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';

class BopomofoVocabContent extends ConsumerStatefulWidget {
  final String word;
  final String vocab;
  final String sentence;

  const BopomofoVocabContent({
    super.key,
    required this.word,
    required this.vocab,
    required this.sentence,
  });

  @override
  BopomofoVocabContentState createState() => BopomofoVocabContentState();
}

class BopomofoVocabContentState extends ConsumerState<BopomofoVocabContent> {
  final FlutterTts ftts = FlutterTts();
  late final String truncatedSentence;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    truncatedSentence = _truncateSentence(widget.sentence);
  }

  void _initializeTts() {
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);
    ftts.setCompletionHandler(() {
      debugPrint('TTS Completed');
    });
    ftts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
    });
  }

  String _truncateSentence(String sentence) {
    if (sentence.length > 25) {
      return "${sentence.substring(0, 25)}...。";
    }
    return sentence;
  }

  Future<void> _speak(String text) async {
    try {
      await ftts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  @override
  void dispose() {
    ftts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    final fontSize = screenInfo.fontSize;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              _buildVocabWithAudio(fontSize),
              _buildCharacterImage(fontSize),
              SizedBox(height: fontSize * 0.5),
              _buildSentenceWithAudio(fontSize),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVocabWithAudio(double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZhuyinProcessing(
          text: widget.vocab,
          fontSize: fontSize * 2.0,
          color: const Color.fromRGBO(228, 219, 124, 1),
          highlightOn: true,
        ),
        IconButton(
          icon: const Icon(Icons.volume_up),
          iconSize: fontSize * 2.0,
          color: const Color.fromRGBO(228, 219, 124, 1),
          onPressed: () => _speak(widget.vocab),
        ),
      ],
    );
  }

  Widget _buildCharacterImage(double fontSize) {
    return Image(
      height: fontSize * 8.5,
      image: AssetImage('lib/assets/img/bopomo/${widget.word}.png'),
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading image: $error');
        return SizedBox(height: fontSize * 8.5);
      },
    );
  }

  Widget _buildSentenceWithAudio(double fontSize) {
    return Column(
      children: [
        ZhuyinProcessing(
          text: truncatedSentence,
          fontSize: fontSize * 1.3,
          color: const Color.fromRGBO(245, 245, 220, 100),
          highlightOn: true,
        ),
        IconButton(
          icon: const Icon(Icons.volume_up),
          iconSize: fontSize * 1.3,
          color: const Color.fromRGBO(245, 245, 220, 100),
          onPressed: () => _speak(truncatedSentence),
        ),
      ],
    );
  }
}

