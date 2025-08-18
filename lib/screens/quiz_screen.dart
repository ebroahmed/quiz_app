import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/theme/app_background.dart';
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
  int _timeLeft = 15;
  Timer? _timer;

  // UI control
  List<String> _shuffledOptions = [];
  bool _quizFinished = false; // prevent rebuilding question UI after finish
  bool _isFinishing = false; // guard against double finish (timer + tap)

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(List<Question> questions) {
    _timer?.cancel();
    setState(() => _timeLeft = 15);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _quizFinished) return;
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
    if (_isFinishing) return; // already finishing
    _timer?.cancel();

    if (_currentQuestionIndex < questions.length - 1) {
      if (!mounted) return;
      setState(() {
        _currentQuestionIndex++;
        _shuffleOptions(questions[_currentQuestionIndex]);
        _startTimer(questions);
      });
    } else {
      _finishQuiz(questions.length);
    }
  }

  Future<void> _saveResult(String? uid, int totalQuestions) async {
    try {
      if (uid != null) {
        await FirebaseFirestore.instance.collection("quiz_results").add({
          "userId": uid,
          "categoryId": widget.category.id,
          "score": _score,
          "totalQuestions": totalQuestions,
          "timestamp": FieldValue.serverTimestamp(),
        });
        debugPrint("Score saved to quizHistory");
      } else {
        debugPrint("No user logged in; skipping save.");
      }
    } catch (e) {
      debugPrint("Failed to save quizHistory: $e");
    }
  }

  Future<void> _finishQuiz(int totalQuestions) async {
    if (_isFinishing) return;
    _isFinishing = true;
    _timer?.cancel();

    // Mark finished so build() doesn't try to lay out another question UI
    if (mounted) {
      setState(() => _quizFinished = true);
    }

    // Fire-and-forget save (don’t block dialog)
    final authState = ref.read(authStateProvider);
    final user = authState.value; // User?
    _saveResult(user?.uid, totalQuestions);

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(
          "Quiz Completed",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed),
        ),
        content: Text(
          "Your score: $_score / $totalQuestions",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryFixed),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              if (mounted) Navigator.pop(context); // back to categories
            },
            child: Text(
              "Back",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryFixed,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              if (!mounted) return;
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _timeLeft = 15;
                _quizFinished = false;
                _isFinishing = false;
                _shuffledOptions = [];
              });
            },
            child: Text(
              "Retry",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryFixed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(questionsProvider(widget.category.id));

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          title: Text(
            '${widget.category.name} Quiz',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        body: questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return Center(
                child: Text(
                  "No questions available",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }

            // If finished, keep the UI stable while the dialog is shown.
            if (_quizFinished) {
              return Center(
                child: Text(
                  "Calculating results...",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }

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
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _timeLeft / 15,
                    minHeight: 8,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    color: Theme.of(context).colorScheme.onPrimaryFixed,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.question,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._shuffledOptions.map((option) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_quizFinished || _isFinishing) return;
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
          error: (e, _) => Center(
            child: Text(
              "Error: $e",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
