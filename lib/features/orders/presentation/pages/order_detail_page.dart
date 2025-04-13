import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart'; // Needed for _buildDynamicContentSection
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_buttons.dart';
// Import actual widgets confirmed to be used in _buildOrderDetailContent
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_timeline_header.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_detail_item_tile.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_requirement_submission_form.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/after_sale_info_area.dart';
// Add imports for potentially missing dynamic section widgets
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/waiting_action_area.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/delivery_confirmation_area.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_evaluation_form.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_completion_summary.dart';

/// 订单详情页面
class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int? _orderIdInt; // Store parsed int ID

  @override
  void initState() {
    super.initState();
    _orderIdInt = int.tryParse(widget.orderId);
    if (_orderIdInt != null) {
      // Trigger loading only if ID is valid
      context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
    } else {
      // Handle invalid ID case immediately (e.g., show error or pop)
       WidgetsBinding.instance.addPostFrameCallback((_) {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('无效的订单 ID'), backgroundColor: Colors.red),
            );
            Navigator.of(context).pop();
         }
       });
    }
  }

  // Helper function to extract Order from various states
  Order? _extractOrder(OrderDetailState state) {
    if (state is OrderDetailLoaded) {
      return state.order;
    } else if (state is OrderDetailActionLoading && state.previousState != null) {
      return state.previousState!.order;
    } else if (state is OrderDetailActionSuccess && state.updatedState != null) {
      // Prefer updated state if available
      return state.updatedState!.order;
    } else if (state is OrderDetailActionFailure && state.previousState != null) {
      return state.previousState!.order;
    }
    // Special case: If action success/failure doesn't have updated/previous, but the action was loading before,
    // try to get the order from the loading state's previous state.
    // This might happen if the Bloc logic doesn't pass the state correctly in emit.
    // It's a fallback.
    if (state is OrderDetailActionSuccess || state is OrderDetailActionFailure) {
        final currentState = context.read<OrderDetailBloc>().state;
        if (currentState is OrderDetailActionLoading && currentState.previousState != null) {
            return currentState.previousState!.order;
        }
    }
    return null; // Return null if order cannot be extracted
  }

  @override
  Widget build(BuildContext context) {
    // If ID was invalid, show an empty scaffold or error placeholder
    if (_orderIdInt == null) {
       return Scaffold(appBar: AppBar(title: const Text('错误')), body: const Center(child: Text('无效的订单 ID')));
    }

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            final extractedOrder = _extractOrder(state);
            return Text('订单详情${extractedOrder != null ? ' (ID: ${extractedOrder.id})' : ''}');
          },
        ),
      ),
      body: BlocListener<OrderDetailBloc, OrderDetailState>(
        listener: (context, state) {
          // Listen for action results to show feedback
          if (state is OrderDetailActionSuccess) {
            // Show success SnackBar
            print('[OrderDetailPage] Received OrderDetailActionSuccess: ${state.message}');
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green, // Use green for success
                  behavior: SnackBarBehavior.floating, // Make it floating
                ),
              );
            // Navigate back if the action was cancel or delete
            if (state.actionType == OrderAction.cancel || state.actionType == OrderAction.delete) {
               // Use a short delay before popping to allow user to see SnackBar
               Future.delayed(const Duration(milliseconds: 1000), () {
                 if (mounted) {
                    Navigator.of(context).pop();
                 }
               });
            } else {
               // For other successful actions (like confirm receipt), reload details
               // to show updated status/buttons.
               context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
            }
          } else if (state is OrderDetailActionFailure) {
            // Show error SnackBar
            print('[OrderDetailPage] Received OrderDetailActionFailure: ${state.message}');
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error, // Use error color
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            print('[OrderDetailPage] BlocBuilder received state: ${state.runtimeType}');

            // --- Handle Initial Loading and Error States ---
            if (state is OrderDetailInitial || (state is OrderDetailLoading && _extractOrder(state) == null)) {
              // Show full screen loading only during initial load
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderDetailError) {
              // Show error with retry button
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
                           context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
                        }
                      ),
                    ],
                  ),
                ),
              );
            }

             // --- Extract Order Data for Content Building ---
            final order = _extractOrder(state);

            // If order is somehow still null (edge case, should not happen after above checks)
            if (order == null) {
               print('[OrderDetailPage] Error: Order is null even after loading/action states.');
               // Show a more informative error in this edge case
               return Center(
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         const Icon(Icons.error_outline, color: Colors.orange, size: 48),
                         const SizedBox(height: 16),
                         Text('无法显示订单内容', style: Theme.of(context).textTheme.headlineSmall),
                         const SizedBox(height: 8),
                         Text('当前状态: ${state.runtimeType}', textAlign: TextAlign.center),
                         const SizedBox(height: 16),
                         ElevatedButton.icon(
                           icon: const Icon(Icons.refresh),
                           label: const Text('尝试刷新'),
                           onPressed: () {
                              context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
                           }
                         ),
                      ],
                   ),
                 )
               );
            }

            // --- Build Main Content with Loading Overlay ---
            return Stack(
              children: [
                 // Scrollable content built by the helper method
                 _buildOrderDetailContent(context, order),

                 // Loading Overlay shown during actions
                 if (state is OrderDetailActionLoading)
                   Positioned.fill(
                     child: Container(
                       color: Colors.black.withOpacity(0.3), // Semi-transparent overlay
                       child: const Center(child: CircularProgressIndicator()),
                     ),
                   ),
              ],
           );
          },
        ),
      ),
      // --- Persistent Footer Buttons --- (Kept as per previous structure)
      persistentFooterButtons: [
        BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {
            final order = _extractOrder(state);
            if (order != null) {
              // Add padding and align buttons to the right
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OrderDetailActionButtons(order: order),
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
    return RefreshIndicator( // Added RefreshIndicator here
       onRefresh: () async {
          if (_orderIdInt != null) {
             context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
          }
       },
       child: SingleChildScrollView(
          // Keep padding at the scroll view level
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 80.0, top: 0), // Increased bottom padding for buttons
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use actual widgets confirmed from previous code reading
              OrderStatusTimelineHeader(order: order),
              const SizedBox(height: 24),
              _buildDynamicContentSection(context, order),
              const SizedBox(height: 24),
              if (order.items.isNotEmpty)
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text('订单商品', style: textTheme.titleMedium),
                      const SizedBox(height: 8),
                      // Use ListView.builder for multiple items if needed, or just the tile
                      OrderDetailItemTile(item: order.items.first), // Assuming this exists
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                   ],
                 ),
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
              // Add space at the bottom if needed, handled by padding in SingleChildScrollView
            ],
          ),
       ),
    );
  }

  // Builds the section that changes based on order status (e.g., address, requirements)
  // CORRECTION: Return Widget instances, not call methods
  Widget _buildDynamicContentSection(BuildContext context, Order order) {
    switch (order.state) {
      case OrderStatus.awaitingPayment:
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingStart: // Assume these states show a waiting area
        return WaitingActionArea(order: order); // Return Widget instance
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        return OrderRequirementSubmissionForm(order: order); // Return Widget instance
      case OrderStatus.awaitingConfirmation:
         return DeliveryConfirmationArea(order: order); // Return Widget instance
       case OrderStatus.awaitingEvaluation:
         return OrderEvaluationForm(order: order); // Return Widget instance
       case OrderStatus.afterSale:
       case OrderStatus.AfterSaleRejection:
         // Assume AfterSaleInfoArea takes the Order object
         // Remove check for non-existent field and pass order directly
         return AfterSaleInfoArea(order: order); // Return Widget instance, passing the order
       case OrderStatus.orderCompleted:
         return OrderCompletionSummary(order: order); // Return Widget instance
      // Add cases for other statuses if they have specific content areas
      // case OrderStatus.canceled:
      // case OrderStatus.applyingForMediation:
      // case OrderStatus.sellerSupplementaryMaterials:
      // case OrderStatus.applyForRefuse:
      // case OrderStatus.unknown:
      default:
        // For states with no specific dynamic content, return an empty box
        return const SizedBox.shrink();
    }
     // Default return might not be needed if switch is exhaustive or default handles all others
     // return const SizedBox.shrink(); // Can likely be removed if default covers all
  }

  // Helper to build simple info rows
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

  // Helper to build price rows
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

  // Helper to format DateTime (nullable)
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    // Adjust format as needed
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
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