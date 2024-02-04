import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/views/view_utils.dart';

class WordVocabContent extends StatefulWidget {
  final String vocab;
  final String meaning;
  final String sentence;
  final String vocab2; // wrong answer

  const WordVocabContent({
    super.key,
    required this.vocab,
    required this.meaning,
    required this.sentence,
    required this.vocab2,
  });

  @override
  WordVocabContentState createState() => WordVocabContentState();
}

class WordVocabContentState extends State<WordVocabContent> {
  final FlutterTts ftts = FlutterTts();
  late String vocab;
  late String vocab2;
  late String meaning;
  late String sentence;
  // late String displayedSentence;
  String displayedSentence = '';
  late List<String> options;
  String message = '';
  late String blankSentence;
  late String reconstructedSentence;

  @override
  void initState() {
    super.initState();
    debugPrint('initState: vocab = ${widget.vocab}, meaning = ${widget.meaning}');
    _initVariables();
  }

  void _initVariables() {
    vocab = widget.vocab;
    vocab2 = widget.vocab2;
    meaning = widget.meaning;
    sentence = widget.sentence;
    blankSentence = _createBlankSentence(sentence, vocab);
    displayedSentence = blankSentence;
    options = [vocab, vocab2]..shuffle();
    message = '';
  }

  String _createBlankSentence(String sentence, String vocab) {
    int vocabLength = vocab.length;
    String underscoreString = "_" * vocabLength;
    return sentence.replaceAll(vocab, underscoreString);
  }

  Future<void> _speak(String text) async {
    int result = await ftts.speak(text);
    if (result == 1) {
      // debugPrint('WordVocabContent _speak succeeded!');
    } else {
      debugPrint('WordVocabContent _speak failed!');
    }
  }

  void _selectWord(String word) {
    // debugPrint('_selectWord: word = $word, vocab = $vocab');
    _speak(word);
    setState(() {
      if (word == vocab) {
        displayedSentence = widget.sentence;
        message = '答對了！';
      } else {
        displayedSentence = blankSentence;
        message = '再試試！';
      }
    });
  }

  void _onContinuePressed() {
    _initVariables(); // Reset for a new page
    setState(() {
      message = '';
    });
  }

  // 因為 initState 只做一次，這個 function 會在每次 build() 時被呼叫，用來檢查是否更新解釋、例句、選項
  void _checkAndSetLiju() {
    // debugPrint(
    //     '_checkAndSetLiju: message = $message, $meaning, $vocab, $widget.meaning, $displayedSentence');
    if (message != '' && meaning == widget.meaning) {
      // 使用者重複在同一頁選擇字詞
      setState(() {
        options = [vocab, vocab2]..shuffle();
        // message = ''; // 不能清空 message，否則會導致後面的判斷錯誤
      });

    } else {
      // 新“用一用”頁，因為 initState 只做一次，因此需要在這裡 init Variables
      setState(() {
        _initVariables();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    double fontSize = getFontSize(context, 16); // Base font size
    const Color explanationColor = Color.fromRGBO(228, 219, 124, 1);
    const Color whiteColor = Colors.white;

    _checkAndSetLiju(); // Ensure state is correct for each build

    List<Widget> children = [
      // Vocabulary display with TTS button
      Container(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.vocab,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize * 1.2,
                color: explanationColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              iconSize: fontSize * 1.2,
              color: explanationColor,
              onPressed: () => _speak(widget.vocab),
            ),
          ],
        ),
      ),

      // Meaning of the vocabulary
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "解釋：",
            style: TextStyle(
              fontSize: fontSize,
              color: explanationColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            iconSize: fontSize,
            color: explanationColor,
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
      SizedBox(height: fontSize * 0.1),

      // Example sentence with TTS button
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
            onPressed: () => _speak(widget.sentence),
          ),
        ],
      ),

      // Displayed sentence (with blanks or filled)
      Text(
        displayedSentence,
        style: TextStyle(fontSize: fontSize, color: whiteColor),
      ),

      // Display options (vocab and vocab2) as buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.map((word) {
          return Container(
              width: fontSize * 9.0, // for 3 1.5 fontSize characters
              height: fontSize * 1.50, // word fontSize = 1.0
              alignment: Alignment.center,
              margin: const EdgeInsets.all(0.0),
              decoration: const BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(1 / 1)), // 38 / 2
                // color: Colors.grey,
              ),
              child: ElevatedButton(
                onPressed: () => _selectWord(word),
                child: Text(word,
                    style: TextStyle(
                      fontSize: fontSize * 0.92, // 1.0 will overflow in some small devices
                      // fontWeight: FontWeight.w900,
                      color: Colors.black,
                    )),
              )); // Container
        }).toList(),
      ), // Row

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '繼    ', // Invisible text to center "答對了！" and "再試試！"
            style: TextStyle(
              fontSize: fontSize, // Adjust font size accordingly
              color: Colors.transparent, // Text color is transparent
            ),
          ),
          // Display message based on selection
          if (message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(
                message,
                style: TextStyle(
                  color: explanationColor,
                  fontSize: fontSize * 1.0,
                ),
              ),
            ),

          // Continue button
          if (message.isNotEmpty)
            ElevatedButton(
              onPressed: _onContinuePressed,
              // 用下面 style 把 button 隱藏起來
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .transparent, // Button background color is transparent
                disabledForegroundColor: Colors.transparent.withOpacity(0.38),
                disabledBackgroundColor: Colors.transparent.withOpacity(
                    0.12), // Used for disabled state, also transparent
                shadowColor: Colors.transparent, // No shadow
                elevation: 0, // No elevation
              ),

              child: Text(
                '續', // Invisible text
                style: TextStyle(
                  fontSize: fontSize, // Adjust font size accordingly
                  color: Colors.transparent, // Text color is transparent
                ),
              ),
            ),
        ],
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}
