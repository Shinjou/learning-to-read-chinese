import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/views/view_utils.dart';

class BopomofoVocabContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    ScreenInfo screenInfo = getScreenInfo(context);
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
                  Text(
                    vocab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize * 2.0, // was 48,
                      color: const Color.fromRGBO(228, 219, 124, 1),
                      fontFamily: 'BpmfOnly',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    iconSize:
                        fontSize * 2.0, // Icon size to match the text size
                    onPressed: () => _speak(vocab),
                  ),
                ],
              ),
              Image(
                height: fontSize * 8.5, // was 9.0
                image: AssetImage('lib/assets/img/bopomo/$word.png'),
              ),
              SizedBox(
                height: fontSize * 0.3, // was 10
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: subSentence.split(vocab)[0],
                          style: TextStyle(
                            height: fontSize * 0.0, // Adjust as needed
                            fontSize:
                                fontSize * 1.3, // Adjust text size as needed
                            color: const Color.fromRGBO(245, 245, 220, 100),
                            fontFamily: 'Serif', // 'BpmfOnly',
                          ),
                        ),
                        TextSpan(
                          text: vocab,
                          style: TextStyle(
                            height: fontSize * 0.0,
                            fontSize: fontSize * 1.3,
                            color: const Color.fromRGBO(228, 219, 124, 1),
                            fontFamily: 'Serif', // 'BpmfOnly',
                          ),
                        ),
                        TextSpan(
                          text: subSentence.split(vocab)[1],
                          style: TextStyle(
                            height: fontSize * 0.0,
                            fontSize: fontSize * 1.3,
                            color: const Color.fromRGBO(245, 245, 220, 100),
                            fontFamily: 'Serif', // 'BpmfOnly',
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: IconButton(
                            icon: const Icon(Icons.volume_up),
                            iconSize: fontSize * 1.3,
                            onPressed: () => _speak(subSentence),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
