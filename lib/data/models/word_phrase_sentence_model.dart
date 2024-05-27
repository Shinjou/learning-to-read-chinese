class WordPhraseSentence {
  WordPhraseSentence({
    required this.id,
    required this.word,
    required this.phrase,
    required this.definition,
    required this.sentence,
    required this.phrase2,
    required this.definition2,
    required this.sentence2,    
  });
  
  final int id ;
  final String word;
  final String phrase;
  final String definition;
  final String sentence;
  final String phrase2;
  final String definition2;
  final String sentence2;

  // ?? What is this for? How to add word to the database?
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'phrase': phrase,
      'definition': definition,
      'sentence': sentence,
      'phrase2': phrase2,
      'definition2': definition2,
      'sentence2': sentence2
    };
  }

  // Named constructor for error state
  WordPhraseSentence.error()
      : id = -1,
        word = '',
        phrase = '',
        definition = '',
        sentence = '',
        phrase2 = '',
        definition2 = '',
        sentence2 = '';

} 