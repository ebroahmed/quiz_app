import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/screens/category_screen.dart';
import 'package:quiz_app/screens/login_screen.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authRepo.signOut();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => LoginScreen()),
              ); // Back to login screen
            },
          ),
        ],
      ),
      body: Center(
        child: IconButton(
          icon: Icon(Icons.quiz),
          onPressed: () async {
            await authRepo.signOut();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => CategoryScreen()),
            ); // Back to login screen
          },
        ),
      ),
    );
  }
}
