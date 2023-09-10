class SoundSymbol {
  SoundSymbol({
    required this.id,
    required this.soundSymbol
  });
  
  final int id ;
  final String soundSymbol;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'soundSymbol': soundSymbol,
    };
  }
} 