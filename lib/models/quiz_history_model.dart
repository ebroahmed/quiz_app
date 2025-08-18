import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistoryModel {
  final String id;
  final String categoryId;
  final int score;
  final int totalQuestions;
  final DateTime? timestamp;

  QuizHistoryModel({
    required this.id,
    required this.categoryId,
    required this.score,
    required this.totalQuestions,
    this.timestamp,
  });

  factory QuizHistoryModel.fromMap(String id, Map<String, dynamic> data) {
    return QuizHistoryModel(
      id: id,
      categoryId: data['categoryId'] ?? '',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
