class Word {
  Word({
    required this.word,
    required this.vocab1,
    required this.meaning1,
    required this.sentence1,
    required this.vocab2,
    required this.meaning2,
    required this.sentence2,
  });
  
  final String word;
  final String vocab1;
  final String meaning1;
  final String sentence1;
  final String vocab2;
  final String meaning2;
  final String sentence2;

  Map<String, dynamic> toMap() {
    return {
      'word': word,
      'vocab_1': vocab1,
      'meaning_1': meaning1,
      'sentence_1': sentence1,
      'vocab_2': vocab2,
      'meaning_2': meaning2,
      'sentence_2': sentence2,
    };
  }

  @override
  String toString() {
    return "Word{word: $word, vocab_1: $vocab1, vocab_2: $vocab2}";
  }
} 