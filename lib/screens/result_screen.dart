import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';

class ResultScreen extends ConsumerWidget {
  final Category category;
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.category,
    required this.score,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percent = (score / totalQuestions);

    return Scaffold(
      appBar: AppBar(title: const Text("Quiz Result"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Circular percentage
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: percent >= 0.5 ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  "${(percent * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              "Score: $score / $totalQuestions",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close result
                    Navigator.pop(context); // back to categories
                  },
                  icon: const Icon(Icons.home),
                  label: const Text("Back"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close result
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
