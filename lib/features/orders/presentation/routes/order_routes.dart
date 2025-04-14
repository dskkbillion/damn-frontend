import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import pages used in this module's routes
import '../pages/order_list_page.dart';
import '../pages/order_detail_page.dart';
import '../seller/pages/seller_order_list_page.dart';
import '../seller/pages/seller_order_detail_page.dart';

/// Defines routes specifically for the Orders feature module.
class OrderRoutes {
  OrderRoutes._(); // Private constructor

  /// Static getter for the list of routes defined in this module.
  static List<RouteBase> get routes => _routes;

  // Define the routes for this module
  static final List<RouteBase> _routes = [
    // Buyer Routes
    GoRoute(
      path: '/orders',
      name: 'orders',
      builder: (context, state) => const OrderListPage(),
    ),
    GoRoute(
      path: '/orderDetail/:orderId',
      name: 'orderDetail',
      builder: (BuildContext context, GoRouterState state) {
        final String orderId = state.pathParameters['orderId'] ?? 'invalid';
        // Consider adding validation here
        return OrderDetailPage(orderId: orderId);
      },
    ),
    // Seller Routes
    GoRoute(
      path: '/seller/orders', // Seller list path
      name: 'sellerOrders', // Optional name
      builder: (context, state) => const SellerOrderListPage(),
    ),
    GoRoute(
      path: '/seller/orders/:orderId', // Seller detail path with parameter
      name: 'sellerOrderDetail', // Optional name
      builder: (BuildContext context, GoRouterState state) {
        final String orderIdStr = state.pathParameters['orderId'] ?? 'invalid';
        final int? orderId = int.tryParse(orderIdStr);
        if (orderId == null) {
          print('Error: Invalid orderId parameter in route: $orderIdStr');
          return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(child: Text('Invalid Order ID: $orderIdStr')));
        }
        return SellerOrderDetailPage(orderId: orderId);
      },
    ),
  ];
}
