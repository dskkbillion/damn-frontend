import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart'; // Import GetIt
import 'dart:async'; // Import dart:async for StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart';
// Remove import for non-existent SmsLoginCubit on auth branch?
// import 'package:dskk_flutter_refactor/features/auth/presentation/bloc/sms_login/sms_login_cubit.dart';

// Import authentication related classes
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

// Import the main shell page which will act as the navigator shell
import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';

// --- Import Module Routes ---
// import 'package:dskk_flutter_refactor/features/ai_docs/presentation/routes/ai_docs_routes.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/routes/auth_routes.dart'; // Import Auth routes
// REMOVE non-existent imports for auth branch
// import 'package:dskk_flutter_refactor/features/home/presentation/routes/home_routes.dart';
// import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart';

// REMOVE NotFoundPage for now, as it might not exist
// import 'package:dskk_flutter_refactor/app/widgets/not_found_page.dart';

// Placeholder pages for each tab
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

  // GlobalKey for the root navigator
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  // GlobalKey for the shell navigator
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    // Adjust initial location if /home doesn't make sense on auth branch
    // Maybe initialLocation: '/login' or '/'? Let's keep /home for now, redirect handles it.
    initialLocation: '/home',
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
                  child: PlaceholderPage(title: '多少看看 (Auth Branch)'), // Indicate branch context
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
                  child: PlaceholderPage(title: '主页 (Auth Branch)'),
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
                  child: PlaceholderPage(title: '消息 (Auth Branch)'),
                ),
              ),
            ],
          ),
          // Branch for the '我的' tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile', 
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '我的 (Auth Branch)'),
                ),
              ),
            ],
          ),
          // Branch for the 'AI Docs' tab (Dev Menu placeholder on auth branch)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dev_menu', 
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: 'Dev Menu Placeholder (Auth Branch)'),
                ),
              ),
            ],
          ),
        ],
      ),

      // --- Top-level routes (not part of the shell) ---

      // Aggregate routes from feature modules - ONLY AUTH on this branch
      ...AuthRoutes.routes, // Add routes from Auth module
      // REMOVE non-existent routes for auth branch
      // ...HomeRoutes.routes,
      // ...OrderRoutes.routes,
      
    ],
    // Use a simple placeholder for error page on auth branch
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.uri}\nError: ${state.error}')),
    ),

    // Implement redirection logic for authentication
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

// Helper class to trigger GoRouter redirects when auth status stream changes
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
