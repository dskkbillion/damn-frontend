import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import After Sales pages
import '../pages/after_sales_list_page.dart';
import '../pages/after_sales_detail_page.dart';
import '../pages/select_after_sales_type_page.dart';
import '../pages/after_sales_apply_page.dart';

// Import necessary entities or models used in route parameters/extra
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart'; // Needed for extra

/// Defines routes specifically for the After Sales feature module.
class AfterSalesRoutes {
  // Private constructor to prevent instantiation
  AfterSalesRoutes._();

  // Static getter to expose the list of routes
  static List<RouteBase> get routes => _routes;

  // Define the routes for this module
  static final List<RouteBase> _routes = [
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
          // Consider navigating to an error page or showing a dialog
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
          // Extract parameters carefully
          final String? itemIdStr = state.uri.queryParameters['itemId'];
          final String? type = state.uri.queryParameters['type'];
          final OrderItem? orderItem = state.extra as OrderItem?; // Get OrderItem from extra

          final int? itemId = int.tryParse(itemIdStr ?? '');

          // Validate parameters
          if (itemId == null || type == null || type.isEmpty || orderItem == null) {
             print('Error: Invalid parameters for /afterSalesApply. ItemId: $itemIdStr, Type: $type, Item: ${orderItem == null ? 'null' : 'provided'}');
             return Scaffold(body: Center(child: Text('Error: Invalid apply parameters.')));
          }

          print('Navigating to /afterSalesApply with itemId: $itemId, type: $type, item: ${orderItem.productName}');
          // Pass parameters to the page constructor
          return AfterSalesApplyPage(orderItemId: itemId, afterSalesType: type, orderItem: orderItem);
        },
    ),
    // Add other after-sales specific routes here if needed
  ];
} 