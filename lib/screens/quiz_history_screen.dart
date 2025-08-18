import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quiz_history_provider.dart';

class QuizHistoryScreen extends ConsumerWidget {
  final String userId;
  const QuizHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(quizHistoryProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz History")),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text("No quiz attempts yet."));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final attempt = history[index];
              return ListTile(
                title: Text("Category: ${attempt.categoryId}"),
                subtitle: Text(
                  "Score: ${attempt.score}/${attempt.totalQuestions}",
                ),
                trailing: Text(
                  attempt.timestamp != null
                      ? "${attempt.timestamp!.day}/${attempt.timestamp!.month}/${attempt.timestamp!.year}"
                      : "",
                ),
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
