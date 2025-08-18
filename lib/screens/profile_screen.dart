import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/screens/home_screen.dart';
import 'package:quiz_app/screens/quiz_history_screen.dart';
import 'package:quiz_app/widgets/main_screen.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Not logged in"));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  child: Text(user.email![0].toUpperCase()),
                ),
                const SizedBox(height: 12),
                Text(user.email ?? "No email"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizHistoryScreen(userId: user.uid),
                      ),
                    );
                  },
                  child: const Text("View Quiz History"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                  },
                  child: const Text("Logout"),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      // bottomNavigationBar: CurvedNavigationBar(
      //   items: bottomNavItems,
      //   index: _index,
      //   backgroundColor: Colors.transparent,
      //   color: Theme.of(context).colorScheme.onPrimaryFixed, // navbar color
      //   buttonBackgroundColor: Theme.of(
      //     context,
      //   ).colorScheme.onPrimaryFixed, // selected icon bg
      //   height: 60,
      //   animationDuration: Duration(milliseconds: 600),
      //   onTap: (index) {
      //     setState(() => _index = index);
      //     if (index == 0) {
      //       Navigator.of(
      //         context,
      //       ).push(MaterialPageRoute(builder: (_) => HomeScreen()));
      //     }
      //   },
      // ),
    );
  }
}
