import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
// import 'package:flutter_bloc/flutter_bloc.dart'; // Seems unused now

// Import authentication related classes
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

// Import the main shell page which will act as the navigator shell
import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';
// Import the dev menu page
import 'package:dskk_flutter_refactor/app/widgets/dev_menu_page.dart';

// Import feature routes
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart';
import 'package:dskk_flutter_refactor/features/after_sales/presentation/routes/after_sales_routes.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/routes/ai_docs_routes.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/routes/auth_routes.dart'; 
import 'package:dskk_flutter_refactor/features/profile/presentation/routes/profile_routes.dart'; // Import Profile routes

// Placeholder pages for each tab - Keep one definition
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

// Provider for the GoRouter instance - Use Provider from refactor/auth-module
final goRouterProvider = Provider<GoRouter>((ref) {
  // Access the AuthRepository via GetIt
  final authRepository = GetIt.instance<IAuthRepository>();

  // GlobalKey for the root navigator
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  // GlobalKey for the shell navigator - Seems unused
  // final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home', // Keep initial location, redirect handles it
    debugLogDiagnostics: true, // Enable debug logging
    refreshListenable: GoRouterRefreshStream(authRepository.authStatus), // Listen to auth status changes

    routes: [
      // Configuration for the bottom navigation bar using StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch for the '多少看看' tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '多少看看'), // Simplified title
                ),
              ),
            ],
          ),
          // Branch for the '主页' tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '主页'), // Simplified title
                ),
              ),
            ],
          ),
          // Branch for the '消息' tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '消息'), // Simplified title
                ),
              ),
            ],
          ),
          // Branch for the '我的' tab
          StatefulShellBranch(
            routes: [
              // Use the routes from the profile module here
              ...ProfileRoutes.routes, 
            ],
          ),
          // Branch for the '开发' tab (Temporary Debug Menu)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dev_menu', // Path for the fifth tab
                pageBuilder: (context, state) => const NoTransitionPage(
                  // Ensure DevMenuPage is imported
                  child: DevMenuPage(),
                ),
              ),
            ],
          ),
        ],
      ),

      // --- Top-level routes (not part of the shell) ---
      // Aggregate routes from feature modules
      ...AuthRoutes.routes, 
      ...OrderRoutes.routes, 
      ...AfterSalesRoutes.routes, 
      ...AiDocsRoutes.routes, 
      // Profile routes are now part of the shell, no need to aggregate here
    ],

    // Use the errorBuilder from refactor/auth-module
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.uri}\nError: ${state.error}')),
    ),

    // Implement redirection logic for authentication - Keep from refactor/auth-module
    redirect: (context, state) {
      final loginStatus = authRepository.getLoggedInUserSync().fold(
        (failure) => const Unauthenticated(),
        (user) => user != null ? Authenticated(user) : const Unauthenticated(),
      );
      final isLoggingIn = state.matchedLocation == '/login';
      final isUnknown = loginStatus is AuthUnknown;

      print('Redirect Check: Current Location: ${state.matchedLocation}, Login Status: $loginStatus, Is Logging In: $isLoggingIn');

      if (isUnknown) {
        print('Redirect Check: Auth status unknown, no redirect.');
        return null;
      }
      if (loginStatus is Unauthenticated && !isLoggingIn) {
         print('Redirect Check: Not logged in, redirecting to /login');
        return '/login';
      }
      if (loginStatus is Authenticated && isLoggingIn) {
        print('Redirect Check: Logged in, redirecting from /login to /home');
        return '/home';
      }
       print('Redirect Check: No redirect needed.');
      return null;
    },
  );
});

// Helper class to trigger GoRouter redirects when auth status stream changes - Keep from refactor/auth-module
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
} 