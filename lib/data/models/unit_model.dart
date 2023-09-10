class Unit {
  Unit({
    required this.id,
    required this.publisher,
    required this.grade,
    required this.semester,
    required this.unitId,
    required this.unitTitle,
    required this.newWords,
    required this.extraWords,
    this.unitContent=""
  });
  final int id;
  final String publisher;
  final int grade;
  final String semester;
  final int unitId;
  final String unitTitle;
  final List<String> newWords;
  final List<String> extraWords;
  String unitContent;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'publisher': publisher,
      'grade': grade,
      'semester': semester,
      'unitId': unitId,
      'unitTitle': unitTitle,
      'newWords': newWords.join(),
      'extraWords': extraWords.join(),
      'unitContent': unitContent
    };
  }

  @override
  String toString() {
    return "Unit{id: $id, publisher: $publisher, grade: $grade, semester: $semester, unitId: $unitId, unitTitle: $unitTitle, newWords: ${newWords.toString()}, extraWords: ${extraWords.toString()}, unit_content: $unitContent}";
  }
} 