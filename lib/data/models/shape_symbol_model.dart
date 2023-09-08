class ShapeSymbol {
  ShapeSymbol({
    required this.id,
    required this.shapeSymbol
  });
  
  final String id ;
  final String shapeSymbol;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shapeSymbol': shapeSymbol,
    };
  }
} 