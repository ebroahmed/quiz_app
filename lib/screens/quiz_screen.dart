import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../providers/question_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Category category;
  const QuizScreen({super.key, required this.category});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider(widget.category.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text("No questions available"));
          }

          final question = questions[_currentQuestionIndex];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Question ${_currentQuestionIndex + 1}/${questions.length}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(question.question, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ...List.generate(question.options.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        if (index == question.correctAnswerIndex) {
                          _score++;
                        }

                        if (_currentQuestionIndex < questions.length - 1) {
                          setState(() => _currentQuestionIndex++);
                        } else {
                          // Quiz finished
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Quiz Completed"),
                              content: Text(
                                "Your score: $_score/${questions.length}",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(
                                      context,
                                    ); // Back to categories
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Text(question.options[index]),
                    ),
                  );
                }),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}
