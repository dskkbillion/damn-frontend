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

// Import feature routes (Merged imports)
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart';
import 'package:dskk_flutter_refactor/features/after_sales/presentation/routes/after_sales_routes.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/routes/ai_docs_routes.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/routes/auth_routes.dart'; 
import 'package:dskk_flutter_refactor/features/profile/presentation/routes/profile_routes.dart'; 
import 'package:dskk_flutter_refactor/features/home/presentation/routes/home_routes.dart';
import 'package:dskk_flutter_refactor/features/favorites/presentation/routes/favorites_routes.dart';
// Import Seller routes
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';

// Placeholder page (defined once) - Only used if a module's routes aren't ready
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

// Provider for the GoRouter instance (from HEAD/auth-module)
final goRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = GetIt.instance<IAuthRepository>();
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  // Create the GoRouter instance
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home', // Initial location
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authRepository.authStatus),

    routes: [
      // StatefulShellRoute structure from HEAD
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: AI Chat (Replaces Discover)
          StatefulShellBranch(
            routes: [
              // Use AiDocsRoutes, assuming its root path is handled internally or is '/ai_chat'
              ...AiDocsRoutes.routes, 
              // If AiDocsRoutes doesn't define the root path, add it explicitly:
              // GoRoute(
              //   path: '/ai_chat', // Define the root path for this branch
              //   pageBuilder: (context, state) => NoTransitionPage(
              //     child: AiChatPage(), // Replace with actual AI Chat page
              //   ),
              //   routes: AiDocsRoutes.routes, // Assuming these are sub-routes
              // ),
            ],
          ),
          // Branch for '主页' (Home) - Integrated from theirs
          StatefulShellBranch(
            routes: [
              ...HomeRoutes.routes, // Use Home module routes
            ],
          ),
          // Branch for '消息' (Chat)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderPage(title: '消息'),
                ),
              ),
            ],
          ),
          // Branch for '我的' (Profile) - Integrated from HEAD
          StatefulShellBranch(
            routes: [
              ...ProfileRoutes.routes, 
            ],
          ),
          // Branch for '开发' (Dev Menu) - From HEAD
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dev_menu',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DevMenuPage(),
                ),
              ),
            ],
          ),
        ],
      ),

      // Top-level routes (not part of the shell) - Aggregated from HEAD
      ...AuthRoutes.routes, 
      ...OrderRoutes.routes, 
      ...AfterSalesRoutes.routes,
      ...FavoritesRoutes.routes, // Add favorites module routes
      ...SellerRoutes.routes, // Add Seller module routes
      // ...AiDocsRoutes.routes, // Remove duplicate AiDocs routes from top-level
      // Profile routes are in the shell
    ],

    // errorBuilder from HEAD/auth-module
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.uri}\nError: ${state.error}')),
    ),

    // redirect logic from HEAD/auth-module
    redirect: (context, state) {
      final loginStatus = authRepository.getLoggedInUserSync().fold(
        (failure) => const Unauthenticated(),
        (user) => user != null ? Authenticated(user) : const Unauthenticated(),
      );
      final isLoggingIn = state.matchedLocation == '/login';
      final isUnknown = loginStatus is AuthUnknown;

      // Keep print statements for debugging temporarily
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

  // Removed GoRouter registration to GetIt

  return router;
}); 

// GoRouterRefreshStream helper class (from HEAD/auth-module)
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