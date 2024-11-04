// lib/teach_word/models/quiz_summary.dar

import 'dart:ui';

class QuizSummary {
  final int strokeIndex;
  final bool isCorrect;
  final List<Offset> drawnPoints;
  final Duration drawingTime;

  QuizSummary({
    required this.strokeIndex,
    required this.isCorrect,
    required this.drawnPoints,
    required this.drawingTime,
  });
}
