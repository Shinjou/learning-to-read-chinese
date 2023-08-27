class Unit {
  Unit({
    required this.publisher,
    required this.grade,
    required this.semester,
    required this.unitId,
    required this.unitTitle,
    required this.newWords,
    required this.extraWords
  });
  
  final String publisher;
  final int grade;
  final String semester;
  final int unitId;
  final String unitTitle;
  final List<String> newWords;
  final List<String> extraWords;

  Map<String, dynamic> toMap() {
    return {
      'publisher': publisher,
      'grade': grade,
      'semester': semester,
      'unitId': unitId,
      'unitTitle': unitTitle,
      'newWords': newWords.join(),
      'extraWords': extraWords.join()
    };
  }

  @override
  String toString() {
    return "Unit{publisher: $publisher, grade: $grade, semester: $semester, unitId: $unitId, unitTitle: $unitTitle, newWords: ${newWords.toString()}, extraWords: ${extraWords.toString()}}";
  }
} 