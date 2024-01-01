import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/views/view_utils.dart';

class WordVocabContent extends StatelessWidget {
  final String vocab;
  final String meaning;
  final String sentence;
  final FlutterTts ftts = FlutterTts(); // Initialize the TTS engine

  WordVocabContent({
    Key? key,
    required this.vocab,
    required this.meaning,
    required this.sentence,
  }) : super(key: key);

  Future<void> _speak(String text) async {
    int result = await ftts.speak(text); // Implement the TTS functionality
    if (result == 1) {
      debugPrint('WordVocabContent _speak succeeded!');
    } else {
      print('WordVocabContent _speak failed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = getFontSize(context, 16); // 16 is the base font size for 360dp width

    // Define the color used for both text and icons
    const Color explanationColor = Color.fromRGBO(228, 219, 124, 1);
    // const Color backgroundColor = Color.fromRGBO(245, 245, 220, 100);
    const Color whiteColor = Colors.white;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          vocab,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize * 1.5,
            color: whiteColor, // Assuming whiteColor is defined somewhere in your code
          )
        ),
        Padding(
          padding: EdgeInsets.all(fontSize * 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "解釋：",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: explanationColor, // Assuming explanationColor is defined
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    iconSize: fontSize,
                    color: explanationColor, // And here for the icon
                    onPressed: () => _speak(meaning),
                  ),
                ],
              ),
              Text(
                meaning,
                style: TextStyle(
                  fontSize: fontSize,
                  color: whiteColor,
                ),
              ),
              SizedBox(height: fontSize * 0.1),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "例句：",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: explanationColor,
                      fontWeight: FontWeight.bold,
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
              Text(
                sentence,
                style: TextStyle(
                  fontSize: fontSize,
                  color: whiteColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
