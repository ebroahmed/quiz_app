import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_provider.dart';
import '../models/category_model.dart';

class LeaderboardScreen extends ConsumerWidget {
  final Category category;
  const LeaderboardScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider(category.id));

    return Scaffold(
      appBar: AppBar(title: Text("${category.name} Leaderboard")),
      body: leaderboardAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text("No leaderboard data yet."));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(entry.userName ?? "User ${entry.userId}"),
                trailing: Text("${entry.score} pts"),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
