import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/order_detail_page.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/order_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

// Import the new page
import 'package:dskk_flutter_refactor/features/after_sales/presentation/pages/after_sales_list_page.dart';

// Access the service locator instance (assuming it's globally accessible or passed)
final sl = GetIt.instance;

/// Defines the routes for the Orders feature module.
class OrdersRoutes {
  static const String orderListPath = '/orders';
  static const String orderDetailPathSegment = ':id'; // Correct segment for detail
  static const String afterSalesListPathSegment = 'after-sales'; // New path segment

  static List<RouteBase> get routes => [
        GoRoute(
          path: orderListPath,
          name: 'order_list', // Optional name for the route
          pageBuilder: (context, state) => const MaterialPage(
            // Use MaterialPage or CustomPage for transitions
            child: OrderListPage(),
            key: ValueKey('OrderListPage'), // Add key for state preservation
          ),
          routes: [
            // Existing nested route for order details: "/orders/:id"
            GoRoute(
              path: orderDetailPathSegment, // Correct: use the segment ":id"
              name: 'order_detail',
              pageBuilder: (context, state) {
                final orderId = state.pathParameters['id'];
                // Basic error handling if ID is missing or invalid
                if (orderId == null || int.tryParse(orderId) == null) {
                  // TODO: Redirect to an error page or show an error message
                  // For now, navigate back or show a placeholder
                  print('Error: Invalid or missing order ID in route');
                  return const MaterialPage(child: Scaffold(body: Center(child: Text('无效的订单ID'))));
                }
                // Wrap OrderDetailPage with BlocProvider
                return MaterialPage(
                  child: BlocProvider<OrderDetailBloc>(
                    // Create a new Bloc instance using the service locator
                    create: (_) => sl<OrderDetailBloc>(),
                    child: OrderDetailPage(
                      orderId: orderId, // Pass the string ID
                    ),
                  ),
                  key: ValueKey('OrderDetailPage_$orderId'), // Key includes ID
                );
              },
            ),
            // New nested route for after-sales list: "/orders/after-sales"
            GoRoute(
              path: afterSalesListPathSegment, // "after-sales"
              name: 'after_sales_list',
              pageBuilder: (context, state) => const MaterialPage(
                child: AfterSalesListPage(), // Point to our new page
                key: ValueKey('AfterSalesListPage'),
              ),
              // TODO: Add nested routes for after-sales detail/apply later
              // routes: [
              //   GoRoute(path: ':refundId', ...),
              //   GoRoute(path: 'apply', ...),
              // ]
            ),
          ],
        ),
      ];

  // Private constructor to prevent instantiation
  OrdersRoutes._();
} 