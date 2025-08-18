import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/models/quiz_history_model.dart';
import '../repositories/quiz_history_repository.dart';

// Repository provider
final quizHistoryRepositoryProvider = Provider<QuizHistoryRepository>((ref) {
  return QuizHistoryRepository(FirebaseFirestore.instance);
});

// History stream provider for a user
final quizHistoryProvider =
    StreamProvider.family<List<QuizHistoryModel>, String>((ref, userId) {
      final repo = ref.watch(quizHistoryRepositoryProvider);
      return repo.getUserHistory(userId);
    });
