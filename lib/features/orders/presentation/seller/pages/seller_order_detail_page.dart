import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Assuming you use GetIt for DI
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter for context.pop()

import '../bloc/seller_order_detail_bloc.dart';
// Import Order entity to use in builder
import '../../../domain/entities/order.dart';
// Import the timeline header widget
import '../../widgets/order_status_timeline_header.dart';
// Import the item tile widget
import '../../widgets/order_detail_item_tile.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
// Import the action buttons widget
import '../widgets/seller_order_detail_actions.dart';
// Import the dynamic content area widget
import '../widgets/seller_dynamic_content_area.dart';
// Import the materials section widget
import '../widgets/seller_order_materials_section.dart';
// Import entities
import '../../../domain/entities/order_materials.dart';
import '../../../domain/entities/order_delivery.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';

class SellerOrderDetailPage extends StatelessWidget {
  final int orderId;

  const SellerOrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    AppLogger.d('💰💰💰 [卖家OrderDetailPage] 正在构建页面，订单ID: $orderId 💰💰💰');
    
    return BlocProvider(
      create: (context) => GetIt.instance<SellerOrderDetailBloc>()
        ..add(LoadSellerOrderDetail(orderId: orderId)),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text('订单详情 (卖家) - #$orderId'),
        ),
        body: BlocListener<SellerOrderDetailBloc, SellerOrderDetailState>(
          listener: (context, state) {
            // Show SnackBar for action success/failure
            if (state is SellerOrderDetailActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is SellerOrderDetailActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Theme.of(context).colorScheme.error),
              );
            }
          },
          child: BlocBuilder<SellerOrderDetailBloc, SellerOrderDetailState>(
            builder: (context, state) {
              // --- Handle different states to build UI --- 
              // Action states that still show the UI
              if (state is SellerOrderDetailActionInProgress) {
                return _buildSuccessUI(context, state.order, isLoadingAction: true);
              } else if (state is SellerOrderDetailActionFailure) {
                return _buildSuccessUI(context, state.order, isLoadingAction: false);
              } else if (state is SellerOrderDetailActionSuccess) {
                // If action succeeded without reload, show the success state order
                return _buildSuccessUI(context, state.order, isLoadingAction: false);
              } 
              // Main success state
              else if (state is SellerOrderDetailLoadSuccess) {
                // If loaded successfully, show the loaded order
                return _buildSuccessUI(context, state.order, isLoadingAction: false, materials: state.materials, deliveries: state.deliveries);
              } 
              // Loading state
              else if (state is SellerOrderDetailLoading && state.loadingOrderId == orderId) {
                // Show loading indicator only during initial load
                return const Center(child: CircularProgressIndicator());
              } 
              // Failure state
              else if (state is SellerOrderDetailLoadFailure && state.failedOrderId == orderId) {
                 // Show error message on load failure
                return Center(child: Text('加载订单 #${state.failedOrderId} 失败: ${state.message}'));
              } 
              // Initial state or fallback
              else {
                return const Center(child: Text('正在准备加载...'));
              }
            },
          ), // End BlocBuilder
        ), // End BlocListener
        // Make sure bottomNavigationBar is inside Scaffold
        bottomNavigationBar: BlocBuilder<SellerOrderDetailBloc, SellerOrderDetailState>(
          builder: (context, state) {
             Order? currentOrder;
             // Extract order from relevant states that should show actions
             if (state is SellerOrderDetailLoadSuccess) currentOrder = state.order;
             if (state is SellerOrderDetailActionInProgress) currentOrder = state.order;
             if (state is SellerOrderDetailActionFailure) currentOrder = state.order;
             if (state is SellerOrderDetailActionSuccess) currentOrder = state.order;

             // If we have order data, show the actions bar
             if (currentOrder != null) {
               return SellerOrderDetailActions(order: currentOrder);
             }
             // Otherwise, return an empty container
             return const SizedBox.shrink();
          },
        ),
      ), // End Scaffold
    ); // End BlocProvider
  }

  // Helper function to build price rows consistently
  Widget _buildPriceRow(BuildContext context, String label, double value, {bool isTotal = false, bool isDiscount = false}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyMedium),
          Text(
            '${isDiscount ? '-' : ''}${RegionConfig.currencySymbol}${value.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : (isTotal ? colorScheme.primary : null),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build simple info rows (like Order SN)
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
          Expanded(child: Text(value, style: textTheme.bodySmall)),
        ],
      ),
    );
  }

  // Helper function to build time rows consistently, handling nulls and formatting
  Widget _buildTimeRow(BuildContext context, String label, DateTime? time) {
    if (time == null) {
      return const SizedBox.shrink(); // Don't show row if time is null
    }
    final textTheme = Theme.of(context).textTheme;
    // Format the date and time using intl package
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.secondary)),
          Expanded(child: Text(formattedTime, style: textTheme.bodySmall)),
        ],
      ),
    );
  }

  // --- Helper Widget Builder for Success/Action States ---
  Widget _buildSuccessUI(BuildContext context, Order order, {bool isLoadingAction = false, List<OrderMaterials>? materials, List<OrderDelivery>? deliveries}) {
     return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Status Timeline Header
              OrderStatusTimelineHeader(order: order),
              const SizedBox(height: 24), // 调整间距
              // 2. 移除状态描述卡片，直接显示订单商品
              // 3. Order Items Section
              Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 0,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), 
                      child: Column(
                        children: List.generate(order.items.length, (index) {
                            final item = order.items[index];
                            return Column(
                            children: [
                              OrderDetailItemTile(item: item),
                              if (index < order.items.length - 1)
                                const Divider(height: 16, thickness: 0.5),
                            ],
                          );
                        }),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
              // 4. Price Summary Section
              Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildPriceRow(context, '商品总额', order.priceSummary.totalPrice),
                        if (order.priceSummary.deliveryPrice > 0)
                          _buildPriceRow(context, '运费', order.priceSummary.deliveryPrice),
                        if (order.priceSummary.discountPrice > 0)
                          _buildPriceRow(context, '优惠金额', -order.priceSummary.discountPrice, isDiscount: true),
                        const Divider(height: 16, thickness: 0.5),
                        _buildPriceRow(context, '实付款', order.priceSummary.payPrice, isTotal: true),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              // 5. Time Info Section
               Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(context, '订单编号', order.orderSn ?? 'N/A'),
                        _buildTimeRow(context, '下单时间', order.createdAt),
                        if (order.paymentInfo?.payTime != null)
                            _buildTimeRow(context, '付款时间', order.paymentInfo!.payTime),
                        if (order.completeTime != null)
                            _buildTimeRow(context, '完成时间', order.completeTime),
                        if (order.cancelTime != null)
                            _buildTimeRow(context, '取消时间', order.cancelTime),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Spacing after time card
                
              SellerDynamicContentArea(order: order),

              if (!OrderStatusMapper.isLightConsultationOrder(order)) ...[
                SellerOrderMaterialsSection(
                  order: order,
                  materials: materials,
                  deliveries: deliveries,
                ),
              ],

              const SizedBox(height: 80), // Add padding at the bottom for the action bar
            ],
          ),
        ),
        if (isLoadingAction)
           Positioned.fill(
             child: Container(
               color: Colors.black.withOpacity(0.1),
               child: const Center(child: CircularProgressIndicator()),
             ),
           ),
      ],
    );
  }
}
