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
// TODO: Import other pages like HomePage, SettingsPage etc. if they exist within MainNavigationPage's tabs

// Define Route Names (optional but good practice)
// Example: static const String login = '/login';

/// Application router configuration using go_router
class AppRouter {
  // Private constructor
  AppRouter._();

  // GoRouter instance
  static final router = GoRouter(
    // Set the initial route
    // initialLocation: '/', // Adjusted initial location as / might depend on ShellRoute
    initialLocation: '/orders', // Temporarily set orders as initial

    // Define application routes
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

      // --- Top Level Routes (Temporarily moved from ShellRoute) ---
       GoRoute(
            path: '/orders',
            name: 'orders',
            builder: (context, state) => const OrderListPage(), // Using builder for simplicity now
       ),
       GoRoute(
            path: '/afterSales',
            name: 'afterSales',
            builder: (context, state) => const AfterSalesListPage(), // Using builder
       ),
      // -------------------------------------------------------------

      // Detail Pages (typically outside the main shell)
      GoRoute(
        path: '/orderDetail/:orderId',
        name: 'orderDetail',
        builder: (BuildContext context, GoRouterState state) {
          // Extract the orderId from the path parameters
          final String orderId = state.pathParameters['orderId'] ?? 'invalid';
          return OrderDetailPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/afterSalesDetail/:id', // Using :id as the parameter name
        name: 'afterSalesDetail',
        builder: (BuildContext context, GoRouterState state) {
          // Extract the id (could be orderId or afterSalesId)
          final String id = state.pathParameters['id'] ?? 'invalid';
          return AfterSalesDetailPage(id: id);
        },
      ),

       // After Sales Flow Pages
       GoRoute(
         path: '/selectAfterSalesType/:orderItemId',
         name: 'selectAfterSalesType',
         builder: (BuildContext context, GoRouterState state) {
           // Get the OrderItem object passed via 'extra'
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
             // Extract parameters from query
             final String? itemIdStr = state.uri.queryParameters['itemId'];
             final String? type = state.uri.queryParameters['type'];
             // Extract OrderItem from extra
             final OrderItem? orderItem = state.extra as OrderItem?;

             // Validate parameters
             final int? itemId = int.tryParse(itemIdStr ?? '');
             if (itemId == null || type == null || type.isEmpty || orderItem == null) { // Also check orderItem
                print('Error: Invalid parameters for /afterSalesApply. ItemId: $itemIdStr, Type: $type, Item: ${orderItem == null ? 'null' : 'provided'}');
                return Scaffold(body: Center(child: Text('Error: Invalid apply parameters.')));
             }

             print('Navigating to /afterSalesApply with itemId: $itemId, type: $type, item: ${orderItem.productName}');
             // Pass the OrderItem to the page constructor
             return AfterSalesApplyPage(orderItemId: itemId, afterSalesType: type, orderItem: orderItem);
           },
       ),
       // TODO: Add route for AfterSalesApplyPage later
       // GoRoute(
       //   path: '/afterSalesApply', // Maybe use query params: /afterSalesApply?itemId=123&type=REFUND
       //   name: 'afterSalesApply',
       //   builder: (context, state) => AfterSalesApplyPage(...),
       // ),

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