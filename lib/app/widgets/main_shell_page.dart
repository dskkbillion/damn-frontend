import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

// This widget now receives the StatefulNavigationShell from GoRouter
// and uses it to manage the scaffold body and bottom navigation state.
class MainShellPage extends StatelessWidget { // Changed to StatelessWidget
  final StatefulNavigationShell navigationShell;

  const MainShellPage({required this.navigationShell, super.key});

  // We no longer need StatefulWidget or local state management for index
  // as GoRouter's StatefulNavigationShell handles it.

  // We also don't need the _widgetOptions list here,
  // as the navigationShell widget itself displays the correct page.

  void _onTap(int index) {
    // Use the navigationShell's goBranch method to navigate
    // Tapping the current tab again might reset the inner stack (optional)
    navigationShell.goBranch(
      index,
      // `initialLocation` true = reset the branch to its initial location
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body is now simply the navigationShell widget.
      // It handles displaying the correct page based on the active branch.
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFD0903D),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          // Icons and labels remain the same
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            activeIcon: Icon(Icons.star),
            label: '多少看看',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '消息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
          // Add the new item for the Dev Menu
          BottomNavigationBarItem(
            icon: Icon(Icons.developer_mode_outlined),
            activeIcon: Icon(Icons.developer_mode),
            label: '开发', // Label for the new tab
          ),
        ],
        // Current index is determined by the navigationShell
        currentIndex: navigationShell.currentIndex,
        // onTap calls the GoRouter method to switch branches
        onTap: _onTap,
      ),
    );
  }
} 