import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the main shell page which will act as the navigator shell
import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';

// Placeholder pages for each tab
// TODO: Replace these with actual feature pages later
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar if you want titles per section
      // appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

// Provider for the GoRouter instance
final goRouterProvider = Provider<GoRouter>((ref) {
  // TODO: Add observers later if needed (e.g., for analytics)
  // final observers = <NavigatorObserver>[];

  // GlobalKey for the root navigator
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  // GlobalKey for the shell navigator
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home', // Set initial tab to '主页'
    // observers: observers,
    debugLogDiagnostics: true, // Enable debug logging

    routes: [
      // Configuration for the bottom navigation bar using StatefulShellRoute
      StatefulShellRoute.indexedStack(
        // This builder is responsible for building the shell UI (e.g., Scaffold with BottomNavBar)
        builder: (context, state, navigationShell) {
          // The navigationShell is passed to the MainShellPage 
          // It contains the pages for the different tabs and methods to navigate between them
          return MainShellPage(navigationShell: navigationShell);
        },
        // Define the branches for each tab
        branches: [
          // Branch for the '多少看看' tab
          StatefulShellBranch(
            // navigatorKey: shellNavigatorKey, // Optional key if needed for inner navigation
            routes: [
              GoRoute(
                path: '/discover', // Path for the first tab
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '多少看看'),
                ),
                // TODO: Add sub-routes for this branch if needed
              ),
            ],
          ),
          // Branch for the '主页' tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home', // Path for the second tab
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '主页'),
                ),
              ),
            ],
          ),
          // Branch for the '消息' tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat', // Path for the third tab
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '消息'),
                ),
              ),
            ],
          ),
          // Branch for the '我的' tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile', // Path for the fourth tab
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '我的'),
                ),
              ),
            ],
          ),
        ],
      ),
      // TODO: Add other top-level routes here later (e.g., for login, settings outside the shell)
      // GoRoute(
      //   path: '/login',
      //   builder: (context, state) => const LoginPage(),
      // ),
    ],
    // TODO: Add error handling later
    // errorBuilder: (context, state) => const ErrorScreen(),

    // TODO: Add redirection logic later (e.g., for authentication)
    // redirect: (context, state) {
    //   // Check auth status
    //   return null; // Return null means no redirect
    // },
  );
}); 