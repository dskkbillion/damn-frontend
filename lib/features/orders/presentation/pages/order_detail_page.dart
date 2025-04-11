import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_buttons.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_widget.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_price_summary.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart'; // Ensure Address is imported
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart'; // Ensure OrderItem is imported
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart'; // Import OrderStatus
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_detail_item_tile.dart'; // Import the new widget
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_buttons.dart';// TODO: 可能还需要导入 AddressWidget, OrderItemWidget 等自定义或通用 Widget
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_timeline_header.dart'; // Import the new header
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_requirement_submission_form.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/delivery_confirmation_area.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_evaluation_form.dart'; // Import the evaluation form
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/waiting_action_area.dart'; // Import the new widget
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_completion_summary.dart'; // Import the completion summary
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/after_sale_info_area.dart'; // Import the new widget
import 'package:intl/intl.dart'; // For date formatting

/// 订单详情页面
class OrderDetailPage extends StatefulWidget {
  final String orderId; // Receive order ID as a string from GoRouter path parameter

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final int _orderIdInt;

  @override
  void initState() {
    super.initState();
    // Parse the ID once
    _orderIdInt = int.tryParse(widget.orderId) ?? 0;
    // Trigger loading the order detail when the page initializes
    if (_orderIdInt > 0) { // Only load if ID is valid
       // Access the Bloc provided by the route
      context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use BlocBuilder to potentially update AppBar title when order loads
        title: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            if (state is OrderDetailLoaded && state.order != null) {
              // Example: Show order number when loaded
              return Text('订单: ${state.order.orderSn}');
            } else if (state is OrderDetailLoading) {
              return const Text('加载中...');
            }
             else if (state is OrderDetailError) {
               return const Text('加载失败');
             }
            return Text('订单详情 (ID: $_orderIdInt)'); // Default title
          },
        ),
      ),
      body: BlocListener<OrderDetailBloc, OrderDetailState>(
        listener: (context, state) {
          // Listen for action results to show feedback
          if (state is OrderDetailActionSuccess) {
            // Show success SnackBar
            print('[OrderDetailPage] Received OrderDetailActionSuccess: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Note: Bloc already triggers reload on evaluation success.
            // If other actions need explicit reload here, add logic.
          } else if (state is OrderDetailActionFailure) {
            // Show error SnackBar
            print('[OrderDetailPage] Received OrderDetailActionFailure: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            print('[OrderDetailPage] BlocBuilder received state: ${state.runtimeType}');
            if (state is OrderDetailLoading || state is OrderDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text('加载失败', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(state.message, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('重试'),
                        onPressed: () {
                           // Ensure orderId is parsed correctly
                           final int? orderIdInt = int.tryParse(widget.orderId);
                           if (orderIdInt != null) {
                              context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: orderIdInt));
                           } else {
                              // Handle error: Show a message or log, maybe disable button
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('无法重试：订单 ID 无效')),
                              );
                           }
                        }
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is OrderDetailLoaded) {
              print('[OrderDetailPage] Displaying OrderDetailLoaded state for order: ${state.order.orderSn}');
              return _buildOrderDetailContent(context, state.order);
            } else {
              print('[OrderDetailPage] Unknown state in BlocBuilder: ${state.runtimeType}');
              // Fallback for unhandled states (like action loading/success/failure if not handled by listener)
              // Might show previous loaded state or a generic error/loading
              // For now, show a simple placeholder
              return const Center(child: Text('未知状态'));
            }
          },
        ),
      ),
      // Use persistentFooterButtons for bottom actions
      persistentFooterButtons: [
        // Use BlocBuilder here as well to get the latest order data for buttons
        BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            if (state is OrderDetailLoaded && state.order != null) {
              // Add padding and align buttons to the right
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                // Use Row + MainAxisAlignment.end for right alignment
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OrderDetailActionButtons(order: state.order),
                  ],
                ),
              );
            }
            // Return an empty container if order is not loaded
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  // This method builds the scrollable content part
  Widget _buildOrderDetailContent(BuildContext context, Order order) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // The main scrollable content
    return SingleChildScrollView(
      // Keep padding at the scroll view level
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 0), // Adjust top padding if header has its own
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header (Timeline + Status Card) ---
          OrderStatusTimelineHeader(order: order),
          const SizedBox(height: 24), // Add more space after header

          // --- Dynamic Content Area based on Order Status ---
          _buildDynamicContentSection(context, order),
          const SizedBox(height: 24), // Space after dynamic section

          // --- TEMPORARY: Display First Order Item with Apply Button ---
          if (order.items.isNotEmpty)
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text('订单商品', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  OrderDetailItemTile(item: order.items.first),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
               ],
             ),
          // ---------------------------------------------------------

          // --- Static Order Info (Price, Timestamps) ---
          Text('价格信息', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildPriceRow(context, '商品总价', '¥${order.priceSummary.totalPrice.toStringAsFixed(2)}'),
          _buildPriceRow(context, '运费', '+ ¥${order.priceSummary.deliveryPrice.toStringAsFixed(2)}'),
          _buildPriceRow(context, '优惠金额', '- ¥${order.priceSummary.discountPrice.toStringAsFixed(2)}'),
           const Divider(height: 16, thickness: 0.5),
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text('实付款', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    '¥${order.priceSummary.payPrice.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
              ]
           ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('订单信息', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildInfoRow(context, '订单编号:', order.orderSn),
          _buildInfoRow(context, '创建时间:', _formatDateTime(order.createdAt)),
          if (order.paymentInfo.payTime != null)
            _buildInfoRow(context, '付款时间:', _formatDateTime(order.paymentInfo.payTime!)),
          if (order.shippingInfo.deliveryTime != null)
            _buildInfoRow(context, '发货时间:', _formatDateTime(order.shippingInfo.deliveryTime!)),
          if (order.completeTime != null)
            _buildInfoRow(context, '完成时间:', _formatDateTime(order.completeTime!)),
          if (order.cancelTime != null)
            _buildInfoRow(context, '取消时间:', _formatDateTime(order.cancelTime!)),
          const SizedBox(height: 24), // Space at the bottom
        ],
      ),
    );
  }

  // Builds the dynamic content section based on order state
  Widget _buildDynamicContentSection(BuildContext context, Order order) {
    print('[OrderDetailPage] _buildDynamicContentSection called for order ${order.orderSn}, state: ${order.state}');
    switch (order.state) {
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        print('[OrderDetailPage] Returning OrderRequirementSubmissionForm for state: ${order.state}');
        return OrderRequirementSubmissionForm(order: order);

      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
        // Use the actual WaitingActionArea widget
        print('[OrderDetailPage] Returning WaitingActionArea for state: ${order.state}');
        return WaitingActionArea(order: order);

      case OrderStatus.awaitingConfirmation:
        print('[OrderDetailPage] Returning DeliveryConfirmationArea for state: ${order.state}');
        return DeliveryConfirmationArea(order: order);

      case OrderStatus.awaitingEvaluation:
        // Use the actual evaluation form widget
        print('[OrderDetailPage] Returning OrderEvaluationForm for state: ${order.state}');
        return OrderEvaluationForm(order: order);

      case OrderStatus.afterSale:
      case OrderStatus.applyingForMediation:
      case OrderStatus.AfterSaleRejection:
         // Use the new AfterSaleInfoArea widget
         print('[OrderDetailPage] Returning AfterSaleInfoArea for state: ${order.state}');
        return AfterSaleInfoArea(order: order);

      case OrderStatus.orderCompleted:
      case OrderStatus.canceled:
        print('[OrderDetailPage] Returning OrderCompletionSummary for state: ${order.state}');
        return OrderCompletionSummary(order: order);

      default:
        print('[OrderDetailPage] Returning SizedBox.shrink (Default) for state: ${order.state}');
        return const SizedBox.shrink();
    }
  }

  // Helper widget to build a row for price details
  Widget _buildPriceRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(value, style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  // Helper widget to build a row for general info (like timestamps)
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])), // Lighter label
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  // Basic date/time formatter (TODO: Replace with intl package for proper localization)
  String _formatDateTime(DateTime dt) {
    return dt.toLocal().toString().substring(0, 19); // Simple YYYY-MM-DD HH:MM:SS
  }
}

// Simple placeholder widget for dynamic content areas
class _PlaceholderContentCard extends StatelessWidget {
  final String title;
  final OrderStatus status;
  const _PlaceholderContentCard({required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
             Text(title, style: Theme.of(context).textTheme.labelLarge),
             const SizedBox(height: 8),
             Text('(当前状态: ${status.name})'),
          ],
        ),
      ),
    );
  }
} 