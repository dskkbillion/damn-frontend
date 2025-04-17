import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider

// Import the DI container instance
import '../../../../app/di/injection_container.dart';

// Import Blocs needed for providing
import '../bloc/order_list_bloc.dart';
import '../seller/bloc/seller_order_list_bloc.dart';

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
      // Wrap OrderListPage with BlocProvider
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<OrderListBloc>(), // Use GetIt to create Bloc
        child: const OrderListPage(),
      ),
    ),
    GoRoute(
      path: '/orderDetail/:orderId',
      name: 'orderDetail',
      // Note: Detail page might also need its own BlocProvider
      // depending on how its state is managed.
      // Assuming OrderDetailBloc is injected by GetIt if needed inside the page.
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
      // Wrap SellerOrderListPage with BlocProvider
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<SellerOrderListBloc>(), // Use GetIt to create Seller Bloc
        child: const SellerOrderListPage(),
      ),
    ),
    GoRoute(
      path: '/seller/orders/:orderId', // Seller detail path with parameter
      name: 'sellerOrderDetail', // Optional name
      // Note: Seller detail page likely needs its own BlocProvider too.
      // Assuming SellerOrderDetailBloc is injected by GetIt if needed inside the page.
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

