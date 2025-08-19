import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/theme/app_background.dart';
import '../providers/quiz_history_provider.dart';

class QuizHistoryScreen extends ConsumerWidget {
  final String userId;
  const QuizHistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(quizHistoryProvider(userId));

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          title: Text(
            "Quiz History",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        body: historyAsync.when(
          data: (history) {
            if (history.isEmpty) {
              return Center(
                child: Text(
                  "No quiz attempts yet.",

                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final attempt = history[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      "Category: ${attempt.categoryId}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    subtitle: Text(
                      "Score: ${attempt.score}/${attempt.totalQuestions}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    trailing: Text(
                      attempt.timestamp != null
                          ? "${attempt.timestamp!.day}/${attempt.timestamp!.month}/${attempt.timestamp!.year}"
                          : "",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          error: (e, _) => Center(child: Text("Error: $e")),
        ),
      ),
    );
  }
}
