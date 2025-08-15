import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/question_repository.dart';
import '../models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final questionRepositoryProvider = Provider<QuestionRepository>((ref) {
  return QuestionRepository(FirebaseFirestore.instance);
});

final questionsProvider = StreamProvider.family<List<Question>, String>((
  ref,
  categoryId,
) {
  final repo = ref.watch(questionRepositoryProvider);
  return repo.getQuestionsByCategory(categoryId);
});
