import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/home_screen.dart';
import 'package:quiz_app/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _pages = [HomeScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_index], // switch content here
      bottomNavigationBar: CurvedNavigationBar(
        items: [
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        index: _index,
        backgroundColor: Colors.transparent,
        color: Theme.of(context).colorScheme.onPrimaryFixed,
        buttonBackgroundColor: Theme.of(context).colorScheme.onPrimaryFixed,
        height: 60,
        animationDuration: Duration(milliseconds: 450),
        onTap: (index) {
          setState(() => _index = index);
        },
      ),
    );
  }
}
