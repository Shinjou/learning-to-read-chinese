class Word {
  Word({
    required this.id,
    required this.word,
    required this.phoneticTone,
    required this.phonetic,
    required this.tone,
    required this.shapeSymbol,
    required this.soundSymbol,
    required this.strokes,
    required this.common,
  });
  
  final int id ;
  final String word;
  final String phoneticTone;
  final String phonetic;
  final String tone;
  final String shapeSymbol;
  final String soundSymbol;
  final int strokes;
  final int common;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'phoneticTone': phoneticTone,
      'phonetic': phonetic,
      'tone': tone,
      'shapeSymbol': shapeSymbol,
      'soundSymbol': soundSymbol,
      'strokes': strokes,
      'common': common,
    };
  }
} 