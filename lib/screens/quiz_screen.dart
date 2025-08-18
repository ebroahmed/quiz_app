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

  List<String> _shuffledOptions = [];
  int? _selectedIndex; // for feedback
  bool _answered = false; // disable after one answer

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(List<Question> questions) {
    _timer?.cancel();
    setState(() {
      _timeLeft = 15;
      _selectedIndex = null;
      _answered = false;
    });
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
    final user = authState.value;
    if (user != null) {
      await FirebaseFirestore.instance.collection("quiz_results").add({
        "userId": user.uid,
        "categoryId": widget.category.id,
        "score": _score,
        "totalQuestions": totalQuestions,
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    // Move to a nicer result screen later, for now keep dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed"),
        content: Text("Your score: $_score / $totalQuestions"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _shuffledOptions.clear();
              });
            },
            child: const Text("Retry"),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                    child: Text(
                      question.question,
                      key: ValueKey(_currentQuestionIndex),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(_shuffledOptions.length, (index) {
                    final option = _shuffledOptions[index];
                    final correctAnswer =
                        question.options[question.correctAnswerIndex];

                    Color backgroundColor = Theme.of(
                      context,
                    ).colorScheme.onPrimaryFixed;
                    if (_answered) {
                      if (index == _selectedIndex) {
                        backgroundColor = (option == correctAnswer)
                            ? Colors.green
                            : Colors.red;
                      } else if (option == correctAnswer) {
                        backgroundColor = Colors.green;
                      } else {
                        backgroundColor = Theme.of(
                          context,
                        ).colorScheme.primaryContainer;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            backgroundColor,
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            Colors.white,
                          ),
                          minimumSize: MaterialStateProperty.all(
                            const Size.fromHeight(50),
                          ),
                        ),
                        onPressed: _answered
                            ? null
                            : () {
                                setState(() {
                                  _selectedIndex = index;
                                  _answered = true;
                                  if (option == correctAnswer) {
                                    _score++;
                                  }
                                });
                                Future.delayed(
                                  const Duration(seconds: 1),
                                  () => _goToNextQuestion(questions),
                                );
                              },
                        child: Text(option),
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
      ),
    );
  }
}
