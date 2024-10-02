// word_vocab_content.dart is a stateful widget that displays the vocabulary, meaning, and example sentence.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';

class WordVocabContent extends ConsumerStatefulWidget {
  final String vocab; // correct answer
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

class WordVocabContentState extends ConsumerState<WordVocabContent> {
  final FlutterTts ftts = FlutterTts();
  late String vocab;
  late String vocab2;
  late String meaning;
  late String sentence;
  String displayedSentence = '';
  late List<String> options;
  String message = '';
  late String blankSentence;

  @override
  void initState() {
    super.initState();
    // debugPrint('word_vocab_content initState: vocab = ${widget.vocab}, sentence = ${widget.sentence}, stack: ${StackTrace.current}');
    debugPrint('word_vocab_content initState: vocab = ${widget.vocab}, sentence = ${widget.sentence}');
    _initVariables();
  }

  @override
  void didUpdateWidget(covariant WordVocabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reinitialize variables if vocab or sentence has changed
    if (widget.vocab != oldWidget.vocab || widget.sentence != oldWidget.sentence) {
      debugPrint('Updating variables because vocab or sentence has changed.');
      _initVariables();
    } else {
      debugPrint('No change in vocab or sentence, skipping re-initialization.');
    }
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
    debugPrint('Initialized variables: vocab = $vocab, options = $options');
  }

  String _createBlankSentence(String sentence, String vocab) {
    int vocabLength = vocab.length;
    String underscoreString = "__" * vocabLength;
    return sentence.replaceAll(vocab, underscoreString);
  }

  Future<void> _speak(String text) async {
    int result = await ftts.speak(text);
    if (result == 1) {
      debugPrint('WordVocabContent _speak succeeded! text: $text');
    } else {
      debugPrint('WordVocabContent _speak failed! text: $text');
    }
  }

  void _selectWord(String word) {
    // debugPrint('_selectWord: word = $word, vocab = $vocab, stack: ${StackTrace.current}');
    debugPrint('_selectWord: word = $word, vocab = $vocab');
    _speak(word);
    if (word == vocab) {
      setState(() {
        // debugPrint('setState _selectWord: 答對了, stack: ${StackTrace.current}');
        debugPrint('setState _selectWord: 答對了');
        displayedSentence = widget.sentence;
        message = '答對了！';
      });
    } else {
      setState(() {
        // debugPrint('setState _selectWord: 再試試, stack: ${StackTrace.current}');
        debugPrint('setState _selectWord: 再試試');
        displayedSentence = blankSentence;
        message = '再試試！';
      });
    }
    _speak(message);
  }

  void _onContinuePressed() {
    debugPrint('_onContinuePressed: init variables');
    _initVariables(); // Reset for a new page
    setState(() {
      debugPrint('setState _onContinuePressed: resetting message');
      message = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint('Building WordVocabContent widget: stack: ${StackTrace.current}');
    debugPrint('Building WordVocabContent widget');
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;

    const Color explanationColor = Color.fromRGBO(228, 219, 124, 1);
    const Color whiteColor = Colors.white;

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

      ZhuyinProcessing(
        text: widget.meaning,
        fontSize: fontSize,
        color: whiteColor,
        highlightOn: true,
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
      ZhuyinProcessing(
        text: displayedSentence,
        fontSize: fontSize,
        color: whiteColor,
        highlightOn: true,
      ),

      // Display options (vocab and vocab2) as buttons
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.map((word) {
          return Container(
            width: fontSize * 10.0, // for 4 1.5 fontSize characters
            height: fontSize * 2.0, // word fontSize = 1.0
            alignment: Alignment.center,
            margin: const EdgeInsets.all(0.0),
            child: ElevatedButton(
              onPressed: () => _selectWord(word),
              child: Text(
                word,
                style: TextStyle(
                  fontSize: fontSize * 0.90, // 1.0 will overflow in some small devices
                  color: Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),

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
                backgroundColor: Colors.transparent,
                disabledForegroundColor: Colors.transparent.withOpacity(0.38),
                disabledBackgroundColor: Colors.transparent.withOpacity(0.12),
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              child: Text(
                '續',// Invisible text
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.transparent,
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
