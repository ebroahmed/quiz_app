import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/screens/leaderboard_screen.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../providers/question_provider.dart';
// for current user

class QuizScreen extends ConsumerStatefulWidget {
  final Category category;
  const QuizScreen({super.key, required this.category});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 20; // 20s per question
  Timer? _timer;

  List<String> _shuffledOptions = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(List<Question> questions) {
    _timer?.cancel();
    setState(() => _timeLeft = 20);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _goToNextQuestion(questions);
      }
    });
  }

  void _shuffleOptions(Question question) {
    _shuffledOptions = List<String>.from(question.options)..shuffle();
  }

  void _goToNextQuestion(List<Question> questions) {
    _timer?.cancel();
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _shuffleOptions(questions[_currentQuestionIndex]);
        _startTimer(questions);
      });
    } else {
      _finishQuiz(questions.length);
    }
  }

  Future<void> _finishQuiz(int totalQuestions) async {
    _timer?.cancel();

    final authState = ref.read(authStateProvider);
    final user = authState.value; // User? type
    if (user != null) {
      await FirebaseFirestore.instance.collection("quizHistory").add({
        "userId": user.uid,
        "categoryId": widget.category.id,
        "score": _score,
        "totalQuestions": totalQuestions,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed"),
        content: Text("Your score: $_score / $totalQuestions"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to categories
            },
            child: const Text("Back"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
              });
            },
            child: const Text("Retry"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LeaderboardScreen(category: widget.category),
                ),
              );
            },
            child: const Text("View Leaderboard"),
          ),
        ],
      ),
    );
  }

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

          // First time load
          if (_shuffledOptions.isEmpty) {
            _shuffleOptions(questions[_currentQuestionIndex]);
            _startTimer(questions);
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
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _timeLeft / 20,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                Text(question.question, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ..._shuffledOptions.map((option) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        if (option ==
                            question.options[question.correctAnswerIndex]) {
                          _score++;
                        }
                        _goToNextQuestion(questions);
                      },
                      child: Text(option),
                    ),
                  );
                }).toList(),
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
