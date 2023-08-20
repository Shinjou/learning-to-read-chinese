import 'dart:convert';

class Unit {
  Unit({
    required this.grade,
    required this.semester,
    required this.lessonId,
    required this.lessonTitle,
    required this.newWords,
    required this.extraWords
  });
  
  final int grade;
  final String semester;
  final int lessonId;
  final String lessonTitle;
  final List<String> newWords;
  final List<String> extraWords;

  Map<String, dynamic> toMap() {
    return {
      'grade': grade,
      'semester': semester,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'newWords': newWords.join(""),
      'extraWords': extraWords.join("")
    };
  }
} 