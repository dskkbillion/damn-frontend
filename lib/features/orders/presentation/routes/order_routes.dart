import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider

// Import the DI container instance
import '../../../../app/di/injection_container.dart';

// Import Blocs needed for providing
import '../bloc/order_list_bloc.dart';
import '../bloc/order_detail_bloc.dart';
import '../seller/bloc/seller_order_list_bloc.dart';
// Import OrderStatus and potentially an extension for parsing
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_item.dart'; 

// Import pages used in this module's routes
import '../pages/order_list_page.dart';
import '../pages/order_detail_page.dart';
import '../pages/order_evaluation_page.dart';
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
      builder: (context, state) {
        // Extract the 'status' query parameter
        final statusString = state.uri.queryParameters['status']; 
        print('[GoRoute /orders] Received raw status string from URL: $statusString'); 
        
        final parsedStatus = OrderStatusExtension.fromString(statusString);
        print('[GoRoute /orders] Parsed status using OrderStatusExtension.fromString: $parsedStatus');
        
        // Assuming OrderListBloc should be provided here
        return BlocProvider(
          // Use the parsed status for the initial event
          create: (_) => getIt<OrderListBloc>()..add(LoadOrders(status: parsedStatus)), 
          child: OrderListPage(initialStatus: statusString), // Pass the original string
        );
      },
    ),
    GoRoute(
      path: '/orderDetail/:orderId',
      name: 'orderDetail',
      builder: (BuildContext context, GoRouterState state) {
        final String orderId = state.pathParameters['orderId'] ?? 'invalid';
        // Provide OrderDetailBloc for the page
        return BlocProvider(
          create: (_) => getIt<OrderDetailBloc>(),
          child: OrderDetailPage(orderId: orderId),
        );
      },
    ),
    GoRoute(
      path: '/evaluation/:itemId',
      name: 'evaluation',
      builder: (BuildContext context, GoRouterState state) {
        final String itemIdStr = state.pathParameters['itemId'] ?? 'invalid';
        final int? itemId = int.tryParse(itemIdStr);
        if (itemId == null) {
          print('Error: Invalid itemId parameter in route: $itemIdStr');
          return Scaffold(
            appBar: AppBar(title: const Text('错误')),
            body: Center(child: Text('无效的商品ID: $itemIdStr')),
          );
        }
        // Get orderItem from extra if available
        final orderItem = state.extra as OrderItem?;
        return OrderEvaluationPage(
          itemId: itemId,
          orderItem: orderItem,
        );
      },
    ),
    // Seller Routes
    GoRoute(
      path: '/seller/orders', // Seller list path
      name: 'sellerOrders', // Optional name
      // Wrap SellerOrderListPage with BlocProvider
      builder: (context, state) {
        // 提取status查询参数
        final statusString = state.uri.queryParameters['status'];
        print('[GoRoute /seller/orders] Received raw status string from URL: $statusString');
        
        // 解析status为OrderStatus枚举
        final parsedStatus = OrderStatusExtension.fromString(statusString);
        print('[GoRoute /seller/orders] Parsed status using OrderStatusExtension.fromString: $parsedStatus');
        
        return BlocProvider(
          create: (_) => getIt<SellerOrderListBloc>()
            ..add(LoadSellerOrdersRequested(statusFilter: parsedStatus)),
          child: const SellerOrderListPage(),
        );
      },
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

// Example Extension (Add this if you don't have one)
// Place it in a relevant file, like near OrderStatus definition or in a utils file
extension OrderStatusExtension on OrderStatus {
  static OrderStatus? fromString(String? statusString) {
    if (statusString == null) return null;
    try {
      // Find the enum value matching the string representation
      return OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusString
      );
    } catch (e) {
      print('Error parsing OrderStatus from string: $statusString - $e');
      // Decide error handling: return null, a default, or throw
      return null; // Returning null for now, adjust as needed
    }
  }
}

