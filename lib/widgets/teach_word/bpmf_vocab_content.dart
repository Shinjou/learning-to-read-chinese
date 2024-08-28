import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';

class BopomofoVocabContent extends ConsumerWidget {
  final String word;
  final String vocab;
  final String sentence;
  final FlutterTts ftts = FlutterTts(); // Initialize the TTS engine

  BopomofoVocabContent({
    super.key,
    required this.word,
    required this.vocab,
    required this.sentence,
  });

  Future<void> _speak(String text) async {
    int result = await ftts.speak(text); // Implement the TTS functionality
    if (result == 1) {
      // debugPrint('BopomofoVocabContent _speak succeeded!');
    } else {
      debugPrint('BopomofoVocabContent _speak failed!');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    

    String subSentence = sentence;
    if (subSentence.length > 25) {
      subSentence = "${subSentence.substring(0, 25)}...。";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZhuyinProcessing(
                    text: vocab,
                    fontSize: fontSize * 2.0, 
                    color: const Color.fromRGBO(228, 219, 124, 1),
                    highlightOn: true,
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    iconSize: fontSize * 2.0,
                    color: const Color.fromRGBO(228, 219, 124, 1),
                    onPressed: () => _speak(vocab),
                  ),
                ],
              ),
              Image(
                height: fontSize * 8.5,
                image: AssetImage('lib/assets/img/bopomo/$word.png'),
              ),
              SizedBox(height: fontSize * 0.5),
              ZhuyinProcessing(
                text: subSentence,
                fontSize: fontSize * 1.3, 
                color: const Color.fromRGBO(245, 245, 220, 100),
                highlightOn: true,
              ),              
              IconButton(
                icon: const Icon(Icons.volume_up),
                iconSize: fontSize * 1.3,
                color: const Color.fromRGBO(245, 245, 220, 100),
                onPressed: () => _speak(subSentence),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

