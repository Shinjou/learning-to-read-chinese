class BopomoSpelling {
  BopomoSpelling(
    {this.initial = "",
    this.prenuclear = "",
    this.finals = "",
    this.tone = 1}
  );
  
  String initial;
  String prenuclear;
  String finals;
  int tone;

  @override
  String toString(){
    return("{initial: $initial, prenuclear: $prenuclear, finals: $finals, tone: $tone}");
  }

  @override
  bool operator ==(Object other){
    if (identical(this, other)){
      return true;
    }
    return (
      other is BopomoSpelling &&
      other.runtimeType == runtimeType &&
      other.initial == initial &&
      other.finals == finals &&
      other.prenuclear == prenuclear &&
      other.tone == tone
    );
  }

  @override
  int get hashCode => Object.hash(initial, prenuclear, finals, tone);
} 