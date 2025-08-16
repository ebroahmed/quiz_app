import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/leaderboard_repository.dart';
import '../models/leaderboard_entry.dart';

// Repository provider
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(FirebaseFirestore.instance);
});

// Leaderboard stream provider by category
final leaderboardProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>((ref, categoryId) {
      final repo = ref.watch(leaderboardRepositoryProvider);
      return repo.getLeaderboardByCategory(categoryId);
    });
