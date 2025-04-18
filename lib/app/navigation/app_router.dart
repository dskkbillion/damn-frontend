import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'dart:async'; // Import dart:async for StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';

// Import authentication related classes
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

// Import the main shell page which will act as the navigator shell
import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';
// Import the actual login page - NO LONGER NEEDED HERE, handled by AuthRoutes
// import 'package:dskk_flutter_refactor/features/auth/presentation/pages/sms_login_page.dart';

// --- Import Module Routes ---
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/routes/ai_docs_routes.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/routes/auth_routes.dart'; // Import Auth routes
// TODO: Import other feature module routes here

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
  // Access the AuthRepository via GetIt
  final authRepository = GetIt.instance<IAuthRepository>();

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
    refreshListenable: GoRouterRefreshStream(authRepository.authStatus), // Listen to auth status changes

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
          // Branch for the 'AI Docs' tab (using DevMenuPage for now)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dev_menu', // Path for the dev menu tab
                pageBuilder: (context, state) => const NoTransitionPage(
                  // Load DevMenuPage which contains the link to /ai_chat
                  // child: DevMenuPage(), 
                  // TEMPORARY FIX: Use PlaceholderPage until DevMenuPage is restored/found
                  child: PlaceholderPage(title: 'Dev Menu (Placeholder)'),
                ),
              ),
            ],
          ),
        ],
      ),

      // --- Top-level routes (not part of the shell) ---

      // Aggregate routes from feature modules
      ...AuthRoutes.routes, // Add routes from Auth module
      ...AiDocsRoutes.routes, // Add routes from AI Docs module
      // TODO: Add routes from other modules here ...

      // Add other top-level routes if needed

    ],
    // TODO: Add error handling later
    // errorBuilder: (context, state) => const ErrorScreen(),

    // Implement redirection logic for authentication
    redirect: (context, state) {
      // Get the current login status synchronously.
      // Note: This relies on the repository having been initialized.
      final loginStatus = authRepository.getLoggedInUserSync().fold(
        (failure) => const Unauthenticated(), // Treat failure to get status as unauthenticated
        (user) => user != null ? Authenticated(user) : const Unauthenticated(),
      );

      final isLoggingIn = state.matchedLocation == '/login';
      final isUnknown = loginStatus is AuthUnknown; // Check if status is still unknown

      print('Redirect Check: Current Location: ${state.matchedLocation}, Login Status: $loginStatus, Is Logging In: $isLoggingIn');

      // If the status is still unknown, don't redirect yet.
      // The refreshListenable will trigger a re-evaluation once the status is known.
      if (isUnknown) {
        print('Redirect Check: Auth status unknown, no redirect.');
        return null;
      }

      // If the user is not logged in and not trying to access the login page, redirect to login.
      if (loginStatus is Unauthenticated && !isLoggingIn) {
         print('Redirect Check: Not logged in, redirecting to /login');
        return '/login';
      }

      // If the user is logged in and trying to access the login page, redirect to home.
      if (loginStatus is Authenticated && isLoggingIn) {
        print('Redirect Check: Logged in, redirecting from /login to /home');
        return '/home';
      }

      // No redirect needed in other cases.
       print('Redirect Check: No redirect needed.');
      return null;
    },
  );
});

// Helper class to trigger GoRouter redirects when auth status stream changes
// (From GoRouter documentation example)
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
