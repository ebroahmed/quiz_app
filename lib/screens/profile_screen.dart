import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/screens/quiz_history_screen.dart';
import 'package:quiz_app/theme/app_background.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          automaticallyImplyLeading: false,
          title: Text(
            "Profile",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        body: authState.when(
          data: (user) {
            if (user == null) {
              return Center(
                child: Text(
                  "Not logged in",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onPrimaryFixedVariant,
                      radius: 40,
                      child: Text(
                        user.email![0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user.email ?? "No email",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizHistoryScreen(userId: user.uid),
                          ),
                        );
                      },
                      child: Text("View Quiz History"),
                    ),
                    SizedBox(height: 300),
                    ElevatedButton.icon(
                      icon: Icon(Icons.logout_outlined),
                      onPressed: () async {
                        await ref.read(authRepositoryProvider).signOut();
                      },
                      label: Text("Logout"),
                    ),
                  ],
                ),
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
