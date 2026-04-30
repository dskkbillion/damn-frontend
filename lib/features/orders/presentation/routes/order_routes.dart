import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';

// Import the DI container instance
import '../../../../app/di/injection_container.dart';

// Import Blocs needed for providing
import '../bloc/order_detail_bloc.dart';
// Import OrderStatus and potentially an extension for parsing
import '../../domain/entities/order_status.dart';
import '../../domain/entities/order_item.dart';

// Import pages used in this module's routes
import '../pages/order_detail_page.dart';
import '../pages/order_evaluation_page.dart';
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
      path: '/orderDetail/:orderId',
      name: 'orderDetail',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final String orderId = state.pathParameters['orderId'] ?? 'invalid';
        // Provide OrderDetailBloc for the page
        return state.buildSmartPage(
          BlocProvider(
            create: (_) => getIt<OrderDetailBloc>(),
            child: OrderDetailPage(orderId: orderId),
          ),
          name: 'orderDetail',
        );
      },
    ),
    GoRoute(
      path: '/evaluation/:itemId',
      name: 'evaluation',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final String itemIdStr = state.pathParameters['itemId'] ?? 'invalid';
        final int? itemId = int.tryParse(itemIdStr);
        if (itemId == null) {
          print('Error: Invalid itemId parameter in route: $itemIdStr');
          return state.buildSmartPage(
            Scaffold(
              appBar: AppBar(title: Text(AppLocalizations.of(context).order_route_error)),
              body: Center(child: Text(AppLocalizations.of(context).order_route_invalid_item_id(itemIdStr))),
            ),
            name: 'evaluationError',
          );
        }
        // Get orderItem from extra if available
        final orderItem = state.extra as OrderItem?;
        return state.buildSmartPage(
          OrderEvaluationPage(
            itemId: itemId,
            orderItem: orderItem,
          ),
          name: 'evaluation',
        );
      },
    ),
    // Seller Routes
    GoRoute(
      path: '/seller/orders/:orderId', // Seller detail path with parameter
      name: 'sellerOrderDetail', // Optional name
      // Note: Seller detail page likely needs its own BlocProvider too.
      // Assuming SellerOrderDetailBloc is injected by GetIt if needed inside the page.
      pageBuilder: (BuildContext context, GoRouterState state) {
        final String orderIdStr = state.pathParameters['orderId'] ?? 'invalid';
        final int? orderId = int.tryParse(orderIdStr);
        if (orderId == null) {
          print('Error: Invalid orderId parameter in route: $orderIdStr');
          return state.buildSmartPage(
            Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: Center(child: Text('Invalid Order ID: $orderIdStr')),
            ),
            name: 'sellerOrderDetailError',
          );
        }
        return state.buildSmartPage(
          SellerOrderDetailPage(orderId: orderId),
          name: 'sellerOrderDetail',
        );
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

