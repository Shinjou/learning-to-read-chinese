class Word {
  Word({
    required this.word,
  });
  
  final String word;

  Map<String, dynamic> toMap() {
    return {
      'word': word,
    };
  }

  @override
  String toString() {
    return "Unit{publisher: $word}";
  }
} 