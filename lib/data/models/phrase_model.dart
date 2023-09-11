class Phrase {
  Phrase({
    required this.id,
    required this.phrase,
    required this.definition,
    required this.sentence,
  });
  
  final int id ;
  final String phrase;
  final String definition;
  final String sentence;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': phrase,
      'phoneticTone': definition,
      'phonetic': sentence
    };
  }
} 