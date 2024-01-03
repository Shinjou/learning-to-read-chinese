import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/views/view_utils.dart';

class WordVocabContent extends StatefulWidget {
  final String vocab;
  final String meaning;
  final String sentence;
  final String vocab2; // wrong answer

  const WordVocabContent({
    Key? key,
    required this.vocab,
    required this.meaning,
    required this.sentence,
    required this.vocab2,
  }) : super(key: key);

  @override
  WordVocabContentState createState() => WordVocabContentState();
}

class WordVocabContentState extends State<WordVocabContent> {
  final FlutterTts ftts = FlutterTts();
  late String displayedSentence;
  late List<String> options;
  String message = '';
  late String blankSentence;

  @override
  void initState() {
    // Called only once by 用一用
    super.initState();

    // Count the number of characters in widget.vocab
    int vocabLength = widget.vocab.length;

    // Create a string of underscores with the same length as widget.vocab
    String underscoreString = "_" * vocabLength;

    // Replace widget.vocab in the sentence with the underscore string
    blankSentence = widget.sentence.replaceAll(widget.vocab, underscoreString);

    displayedSentence = blankSentence;
    options = [widget.vocab, widget.vocab2]..shuffle();
  }

  void _checkAndSetState() {
    if (displayedSentence.contains(widget.vocab2)) {
      // A new "用一用" page

      int vocabLength = widget.vocab.length;
      String underscoreString = "_" * vocabLength;
      blankSentence =
          widget.sentence.replaceAll(widget.vocab, underscoreString);
      options = [widget.vocab, widget.vocab2]..shuffle();
      message = '';

      setState(() {
        displayedSentence = blankSentence;
      });
    }
  }

  Future<void> _speak(String text) async {
    int result = await ftts.speak(text); // Implement the TTS functionality
    if (result == 1) {
      debugPrint('WordVocabContent _speak succeeded!');
    } else {
      debugPrint('WordVocabContent _speak failed!');
    }
  }

  void _selectWord(String word) {
    setState(() {
      if (word == widget.vocab) {
        displayedSentence = widget.sentence;
        message = '答對了！';
      } else {
        displayedSentence = blankSentence;
        message = '再試試！';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double fontSize = getFontSize(context, 16); // Base font size
    const Color explanationColor = Color.fromRGBO(228, 219, 124, 1);
    const Color whiteColor = Colors.white;

    _checkAndSetState(); // Check if this is a new "用一用" page

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.vocab,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize * 2.0, // was 48,
                      color: explanationColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    iconSize:
                        fontSize * 1.5, // Icon size smaller than the text size
                    color: explanationColor,
                    onPressed: () => _speak(widget.vocab),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          // "解釋"
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "解釋：",
              style: TextStyle(
                fontSize: fontSize,
                color: explanationColor, // Assuming explanationColor is defined
                // fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              iconSize: fontSize,
              color: explanationColor, // And here for the icon
              onPressed: () => _speak(widget.meaning),
            ),
          ],
        ),
        Text(
          widget.meaning,
          style: TextStyle(
            fontSize: fontSize,
            color: whiteColor,
          ),
        ),
        SizedBox(height: fontSize * 0.2),
        // "例句"
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
              onPressed: () => _speak(displayedSentence),
            ),
          ],
        ),

        // Display the sentence with blank or filled
        Text(
          displayedSentence,
          style: TextStyle(fontSize: fontSize, color: Colors.white),
        ),
        /*
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              displayedSentence,
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            ),
          ],
        ),
        */
        // Display options (vocab and vocab2) as buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: options.map((word) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => _selectWord(word),
                child: Text(word),
              ),
            );
          }).toList(),
        ),

        // Display message based on selection
        if (message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: TextStyle(
                color: Colors.green,
                fontSize: fontSize,
              ),
            ),
          ),
      ],
    );
  }
}
