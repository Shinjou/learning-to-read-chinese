// widgets/teach_word/word_vocab_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/teach_word/zhuyin_processing.dart';

class WordVocabContent extends ConsumerStatefulWidget {
  final String vocab;
  final String meaning;
  final String sentence;
  final String vocab2;

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
  late final ValueNotifier<String> selectedWord;
  late final ValueNotifier<String> message;
  final ValueNotifier<bool> isAnswerCorrect = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    selectedWord = ValueNotifier('');
    message = ValueNotifier('');
    _initializeTts();
  }

  void _initializeTts() {
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5);
    ftts.setVolume(1.0);
  }

  @override
  void dispose() {
    selectedWord.dispose();
    message.dispose();
    isAnswerCorrect.dispose();
    ftts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      await ftts.speak(text);
    } catch (e) {
      debugPrint('TTS Error: $e');
    }
  }

  void _handleWordSelection(String word) {
    _speak(word);
    if (word == widget.vocab) {
      selectedWord.value = word;
      message.value = '答對了！';
      isAnswerCorrect.value = true;
    } else {
      message.value = '再試試！';
      isAnswerCorrect.value = false;
    }
    _speak(message.value);
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    final fontSize = screenInfo.fontSize;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildVocabHeader(fontSize),
        _buildMeaning(fontSize),
        SizedBox(height: fontSize * 0.1),
        _buildSentence(fontSize),
        _buildWordOptions(fontSize),
        _buildMessage(fontSize),
      ],
    );
  }

  Widget _buildVocabHeader(double fontSize) {
    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: selectedWord,
            builder: (context, selected, child) {
              return Text(
                selected.isEmpty ? widget.vocab : selected,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize * 1.2,
                  color: explanationColor,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            iconSize: fontSize * 1.2,
            color: explanationColor,
            onPressed: () => _speak(widget.vocab),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaning(double fontSize) {
    return Padding(
      padding: EdgeInsets.only(left: fontSize * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
        ],
      ),
    );
  }

  Widget _buildSentence(double fontSize) {
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
                onPressed: () => _speak(widget.sentence),
              ),
            ],
          ),
          ValueListenableBuilder<String>(
            valueListenable: selectedWord,
            builder: (context, selected, child) {
              final displaySentence = selected.isEmpty ? 
                widget.sentence.replaceAll(widget.vocab, "__" * widget.vocab.length) : 
                widget.sentence;
              return ZhuyinProcessing(
                text: displaySentence,
                fontSize: fontSize,
                color: whiteColor,
                highlightOn: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWordOptions(double fontSize) {
    final options = [widget.vocab, widget.vocab2]..shuffle();
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: options.map((word) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: fontSize * 0.25),
              child: ElevatedButton(
                onPressed: () => _handleWordSelection(word),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: fontSize * 0.5),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: fontSize * 0.90,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessage(double fontSize) {
    return ValueListenableBuilder<String>(
      valueListenable: message,
      builder: (context, msg, child) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: fontSize * 0.5),
            child: Text(
              msg,
              style: TextStyle(
                color: explanationColor,
                fontSize: fontSize,
              ),
            ),
          ),
        );
      },
    );
  }
}