import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the main shell page which will act as the navigator shell
// REMOVE: import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';

// REMOVE: Direct import of profile page, handled by module routes now
// import 'package:dskk_flutter_refactor/features/profile/presentation/pages/simple_profile_page.dart';

// ADD: Import profile module routes
import 'package:dskk_flutter_refactor/features/profile/presentation/routes/profile_routes.dart';

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
  // REMOVE: final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home', // Set initial tab to '主页'
    // observers: observers,
    debugLogDiagnostics: true, // Enable debug logging

    routes: [
      // REMOVE: Old StatefulShellRoute structure
      // ... (Removed StatefulShellRoute and its branches) ...

      // Define top-level routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const PlaceholderPage(title: '主页'),
      ),
      // REMOVE: Direct GoRoute definition for /profile
      // GoRoute(
      //   path: '/profile',
      //   builder: (context, state) => const SimpleProfilePage(),
      // ),

      // ADD: Aggregate routes from modules
      ...ProfileRoutes.routes, // Aggregate profile routes
      // ... Other module routes can be aggregated here later ...

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