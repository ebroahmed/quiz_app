import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/category_repository.dart';
import '../models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(FirebaseFirestore.instance);
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});
