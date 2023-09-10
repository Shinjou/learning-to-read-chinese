class ShapeSymbol {
  ShapeSymbol({
    required this.id,
    required this.shapeSymbol
  });
  
  final int id ;
  final String shapeSymbol;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shapeSymbol': shapeSymbol,
    };
  }
} 