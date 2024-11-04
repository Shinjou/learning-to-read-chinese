// lib/teach_word/models/word_data.dart

class WordData {
  final bool wordExists;
  final bool svgExists;
  final bool img1Exists;
  final bool img2Exists;
  final bool isBpmf;
  final String svgData;
  final List<String> vocabulary;
  final List<String> sentences;
  final List<String> meanings;

  const WordData({
    this.wordExists = false,
    this.svgExists = false,
    this.img1Exists = false,
    this.img2Exists = false,
    this.isBpmf = false,
    this.svgData = '',
    this.vocabulary = const [],
    this.sentences = const [],
    this.meanings = const [],
  });
}
