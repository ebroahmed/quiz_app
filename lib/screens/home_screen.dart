import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/screens/login_screen.dart';
import 'package:quiz_app/theme/app_background.dart';
import '../providers/category_provider.dart';
import 'quiz_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          automaticallyImplyLeading: false,
          title: Text(
            "Category",
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
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
        body: categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) {
              return Center(
                child: Text(
                  "No categories available",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(category: category),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.onPrimary,
                        image: category.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(category.imageUrl),
                                // fit: BoxFit.contain,
                              )
                            : null,
                      ),
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryFixedVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
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
