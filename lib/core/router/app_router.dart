import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import application pages
// import '../../features/auth/presentation/pages/login_page.dart'; // Commented out
// import '../../features/auth/presentation/pages/registration_page.dart'; // Commented out
// import '../../features/main/presentation/pages/main_navigation_page.dart'; // Commented out
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/order_list_page.dart';
// Import OrderItem entity here for the router builder
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import '../../features/after_sales/presentation/pages/after_sales_list_page.dart';
import '../../features/after_sales/presentation/pages/after_sales_detail_page.dart';
import '../../features/after_sales/presentation/pages/select_after_sales_type_page.dart';
import '../../features/after_sales/presentation/pages/after_sales_apply_page.dart';
// Remove direct seller page imports - Handled by OrderRoutes
// import 'package:dskk_flutter_refactor/features/orders/presentation/seller/pages/seller_order_list_page.dart';
// import 'package:dskk_flutter_refactor/features/orders/presentation/seller/pages/seller_order_detail_page.dart';

// Import module route definitions
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart';
import 'package:dskk_flutter_refactor/features/after_sales/presentation/routes/after_sales_routes.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
// TODO: Import other module route definitions (e.g., after_sales_routes.dart)

// Define Route Names (optional but good practice)
// Example: static const String login = '/login';

/// Application router configuration using go_router
class AppRouter {
  // Private constructor
  AppRouter._();

  // GoRouter instance
  static final router = GoRouter(
    // Set the initial route (can be changed later, e.g., to '/login' or '/')
    initialLocation: '/orders', // Changed to '/orders' as a common start point

    // Define application routes by aggregating module routes
    routes: <RouteBase>[
      // Authentication Routes (Commented out)
      /*
      GoRoute(
        path: '/login',
        name: 'login', // Optional name
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegistrationPage();
        },
      ),
      */

      // Main Application Shell with Bottom Navigation (Partially Commented out)
      /* ShellRoute(
        // This navigatorKey is important for preserving state across tabs
        navigatorKey: GlobalKey<NavigatorState>(debugLabel: 'shell'),
        builder: (BuildContext context, GoRouterState state, Widget child) {
          // The child parameter is the widget for the selected tab's route
          // return MainNavigationPage(child: child); // Commented out
          return const Placeholder(); // Placeholder builder
        },
        routes: <RouteBase>[
          // Nested routes for each tab in MainNavigationPage
          GoRoute(
            path: '/', // Default tab
            name: 'home', // Assuming a home tab exists or orders is the default
            // TODO: Replace with actual default tab page if not orders
            // builder: (context, state) => const HomePage(), // Example
            // For now, redirecting to orders as a potential default
            redirect: (context, state) => '/orders',
          ),
          GoRoute(
            path: '/orders',
            name: 'orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrderListPage(),
            ),
          ),
          GoRoute(
            path: '/afterSales', // Changed from '/afterSalesList' for consistency
            name: 'afterSales',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AfterSalesListPage(),
            ),
          ),
          // TODO: Add routes for other tabs within MainNavigationPage (e.g., profile)
          // GoRoute(
          //   path: '/profile',
          //   name: 'profile',
          //   pageBuilder: (context, state) => NoTransitionPage(
          //     child: ProfilePage(),
          //   ),
          // ),
        ],
      ),*/

      // --- Aggregate Module Routes --- 
       // Include routes from the Orders module
      ...OrderRoutes.routes, // Keep this line

       // Include routes from the Seller module
      ...SellerRoutes.routes,

       // TODO: Include routes from other modules here (e.g., AfterSales)
       // Example (needs after_sales_routes.dart to be created first):
       // ...AfterSalesRoutes.routes,

      // --- Top Level Buyer Routes (Keep AfterSales temporarily for now) ---
       // Note: AfterSales routes should also be moved to their own module eventually.
       GoRoute(
            path: '/afterSales',
            name: 'afterSales',
            builder: (context, state) => const AfterSalesListPage(), // Using builder
       ),
       GoRoute(
         path: '/afterSalesDetail/:id', // Using :id as the parameter name
         name: 'afterSalesDetail',
         builder: (BuildContext context, GoRouterState state) {
           final String id = state.pathParameters['id'] ?? 'invalid';
           return AfterSalesDetailPage(id: id);
         },
       ),
        GoRoute(
          path: '/selectAfterSalesType/:orderItemId',
          name: 'selectAfterSalesType',
          builder: (BuildContext context, GoRouterState state) {
            final OrderItem? orderItem = state.extra as OrderItem?;
            if (orderItem == null) {
              print('Error: OrderItem not passed correctly to /selectAfterSalesType');
              return Scaffold(body: Center(child: Text('Error: Missing order item data.')));
            }
            print('Navigated to /selectAfterSalesType, received item: ${orderItem.productName}');
            return SelectAfterSalesTypePage(orderItem: orderItem);
          },
        ),
        GoRoute(
           path: '/afterSalesApply', // Path for the application form
           name: 'afterSalesApply',
           builder: (BuildContext context, GoRouterState state) {
              final String? itemIdStr = state.uri.queryParameters['itemId'];
              final String? type = state.uri.queryParameters['type'];
              final OrderItem? orderItem = state.extra as OrderItem?;
              final int? itemId = int.tryParse(itemIdStr ?? '');
              if (itemId == null || type == null || type.isEmpty || orderItem == null) { 
                 print('Error: Invalid parameters for /afterSalesApply. ItemId: $itemIdStr, Type: $type, Item: ${orderItem == null ? 'null' : 'provided'}');
                 return Scaffold(body: Center(child: Text('Error: Invalid apply parameters.')));
              }
              print('Navigating to /afterSalesApply with itemId: $itemId, type: $type, item: ${orderItem.productName}');
              return AfterSalesApplyPage(orderItemId: itemId, afterSalesType: type, orderItem: orderItem);
            },
        ),
      // -----------------------------------------------------------------
    ],

    // Optional: Error page handler
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(child: Text('Error: ${state.error}')),
    ),

    // Optional: Redirect logic (e.g., for authentication)
    // redirect: (BuildContext context, GoRouterState state) {
    //   // Implement authentication checks here
    //   // final bool loggedIn = ... check auth status ...;
    //   // final bool loggingIn = state.matchedLocation == '/login';
    //   // if (!loggedIn && !loggingIn) return '/login';
    //   // if (loggedIn && loggingIn) return '/'; // Redirect to home if logged in and on login page
    //   return null; // No redirect needed
    // },
  );
}

// Consider adding a GlobalKey for the root navigator if needed elsewhere
// final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
// And pass it to GoRouter: navigatorKey: _rootNavigatorKey 