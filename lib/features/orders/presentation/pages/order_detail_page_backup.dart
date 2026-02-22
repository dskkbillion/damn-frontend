import 'dart:async';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // For date formatting

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_materials.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_delivery.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_action_buttons.dart';
import 'package:dskk_flutter_refactor/core/payment/services/payment_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/models/payment_models.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_timeline_header.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_detail_item_tile.dart';

/// 订单详情页面
class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int? _orderIdInt; // Store parsed int ID
  Timer? _pollingTimer;
  int _pollingAttempts = 0;

  @override
  void initState() {
    super.initState();
    _orderIdInt = int.tryParse(widget.orderId);
    if (_orderIdInt != null) {
      // 检查当前状态，避免重复加载
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentState = context.read<OrderDetailBloc>().state;
        
        // 只有在初始状态时才触发加载
        if (currentState is OrderDetailInitial) {
          context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
        }
      });
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

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // 启动轮询检查订单状态更新
  void _startPollingForOrderStatusUpdate() {
    _pollingAttempts = 0;
    _pollingTimer?.cancel();
    
    // 立即查询一次
    context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
    
    // 每3秒查询一次，最多查询10次（30秒）
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _pollingAttempts++;
      
      final currentState = context.read<OrderDetailBloc>().state;
      if (currentState is OrderDetailLoaded) {
        // 如果订单状态已经不是待付款，说明支付成功了
        if (currentState.order.state != OrderStatus.awaitingPayment) {
          AppLogger.d('[OrderDetailPage] 订单状态已更新: ${currentState.order.state}');
          timer.cancel();
          return;
        }
      }
      
      if (_pollingAttempts >= 10) {
        AppLogger.d('[OrderDetailPage] 轮询超时，停止查询');
        timer.cancel();
        // 显示提示
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('订单状态更新可能有延迟，请稍后刷新查看'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // 继续查询
      AppLogger.d('[OrderDetailPage] 轮询订单状态，第 $_pollingAttempts 次');
      context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
    });
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
    AppLogger.d('🔥🔥🔥 [买家OrderDetailPage] 正在构建页面，订单ID: ${widget.orderId} 🔥🔥🔥');
    
    // If ID was invalid, show an empty scaffold or error placeholder
    if (_orderIdInt == null) {
       return Scaffold(appBar: AppBar(title: const Text('错误')), body: const Center(child: Text('无效的订单 ID')));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/orders');
        }
      },
      child: Scaffold(
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
                    // Pop with result to indicate that the list should refresh
                    if (context.canPop()) {
                      context.pop(true); // Return true to indicate refresh needed
                    } else {
                      context.go('/orders');
                    }
                 }
               });
            } else {
               // For other successful actions (like confirm receipt), reload details
               // to show updated status/buttons.
               context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
            }
          } else if (state is OrderDetailActionFailure) {
            // Show error SnackBar
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error, // Use error color
                  behavior: SnackBarBehavior.floating,
                ),
              );
          } else if (state is OrderDetailPaymentResult) {
            // Handle payment result and navigate accordingly
            PaymentNavigationService.handlePaymentResult(context, state.paymentResponse);
            
            // 如果支付成功，启动轮询检查订单状态更新
            if (state.paymentResponse.resultType == PaymentResultType.success) {
              _startPollingForOrderStatusUpdate();
            } else {
              // 其他情况直接刷新一次
              context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
            }
          }
        },
        child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, state) {

            // --- Handle Initial Loading and Error States ---
            if (state is OrderDetailInitial || (state is OrderDetailLoading && _extractOrder(state) == null)) {
              // Show full screen loading only during initial load
              AppLogger.d('📱📱📱 [买家OrderDetailPage] 显示加载中状态 📱📱📱');
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderDetailError) {
              // Show error with retry button
              AppLogger.d('❌❌❌ [买家OrderDetailPage] 显示错误状态: ${state.message} ❌❌❌');
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
            AppLogger.d('🎯🎯🎯 [买家OrderDetailPage] 当前状态: ${state.runtimeType}, 提取到的订单: ${order?.id} 🎯🎯🎯');

            // If order is somehow still null (edge case, should not happen after above checks)
            if (order == null) {
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

            // --- Build Main Content with Loading Overlay and Bottom Buttons ---
            return Stack(
              children: [
                _buildOrderDetailContent(context, order),
                
                // 底部按钮固定在屏幕底部
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
                    builder: (context, buttonState) {
                      final buttonOrder = _extractOrder(buttonState);
                      if (buttonOrder != null) {
                        // Don't show footer buttons for completed or canceled orders
                        if (buttonOrder.state == OrderStatus.orderCompleted || buttonOrder.state == OrderStatus.canceled) {
                          return const SizedBox.shrink();
                        }
                        
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                                Theme.of(context).scaffoldBackgroundColor,
                              ],
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).dividerColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: SafeArea(
                            child: OrderDetailActionButtons(order: buttonOrder),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                
                // Loading overlay for action processing
                if (state is OrderDetailActionLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      // --- 临时禁用 Bottom Navigation Bar 来调试内容显示问题 ---
      // bottomNavigationBar: BlocBuilder<OrderDetailBloc, OrderDetailState>(
      //   builder: (context, state) {
      //     final order = _extractOrder(state);
      //     if (order != null) {
      //       // Don't show footer buttons for completed or canceled orders
      //       if (order.state == OrderStatus.orderCompleted || order.state == OrderStatus.canceled) {
      //         return const SizedBox.shrink();
      //       }
      //       
      //       // 修复布局问题：确保bottomNavigationBar不会覆盖主要内容
      //       return SafeArea(
      //         child: Container(
      //           decoration: BoxDecoration(
      //             color: Theme.of(context).scaffoldBackgroundColor,
      //             border: Border(
      //               top: BorderSide(
      //                 color: Theme.of(context).dividerColor.withOpacity(0.2),
      //                 width: 1,
      //               ),
      //             ),
      //           ),
      //           padding: const EdgeInsets.all(16.0),
      //           child: OrderDetailActionButtons(order: order),
      //         ),
      //       );
      //     }
      //     // Return empty widget if order is not loaded
      //     return const SizedBox.shrink();
      //   },
      // ),
      ),
    );
  }

  // This method builds the scrollable content part
  Widget _buildOrderDetailContent(BuildContext context, Order order) {
    AppLogger.d('🎨🎨🎨 [买家OrderDetailPage] _buildOrderDetailContent 被调用，订单ID: ${order.id}, 状态: ${order.state} 🎨🎨🎨');
    
    try {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 150), // 增加底部padding，为固定按钮留出更多空间
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 订单状态时间线头部
            Builder(
              builder: (context) {
                AppLogger.d('🔍 正在构建 OrderStatusTimelineHeader');
                try {
                  return OrderStatusTimelineHeader(order: order);
                } catch (e) {
                  AppLogger.d('❌ OrderStatusTimelineHeader 出错: $e');
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.withOpacity(0.3),
                    child: Text('OrderStatusTimelineHeader 错误: $e'),
                  );
                }
              },
            ),
            
            // 支付状态警告（如果需要）
            Builder(
              builder: (context) {
                AppLogger.d('🔍 正在构建 PaymentStatusWarning');
                try {
                  return _buildPaymentStatusWarning(context, order);
                } catch (e) {
                  AppLogger.d('❌ PaymentStatusWarning 出错: $e');
                  return const SizedBox.shrink();
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 商品信息部分
            Builder(
              builder: (context) {
                AppLogger.d('🔍 正在构建 OrderItemsSection');
                try {
                  return _buildOrderItemsSection(context, order);
                } catch (e) {
                  AppLogger.d('❌ OrderItemsSection 出错: $e');
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.withOpacity(0.3),
                    child: Text('OrderItemsSection 错误: $e'),
                  );
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 订单信息部分
            Builder(
              builder: (context) {
                AppLogger.d('🔍 正在构建 OrderInfoSection');
                try {
                  return _buildOrderInfoSection(context, order);
                } catch (e) {
                  AppLogger.d('❌ OrderInfoSection 出错: $e');
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.withOpacity(0.3),
                    child: Text('OrderInfoSection 错误: $e'),
                  );
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 材料展示部分（根据订单状态显示）
            Builder(
              builder: (context) {
                // 只在特定状态下显示材料部分
                if (order.state == OrderStatus.awaitingConfirmation || 
                    order.state == OrderStatus.awaitingEvaluation ||
                    order.state == OrderStatus.orderCompleted) {
                  try {
                    return _buildMaterialsSection(context, order);
                  } catch (e) {
                    AppLogger.d('❌ MaterialsSection 出错: $e');
                    return const SizedBox.shrink();
                  }
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 8),
            
            // 价格明细部分
            Builder(
              builder: (context) {
                AppLogger.d('🔍 正在构建 PriceDetailsSection');
                try {
                  return _buildPriceDetailsSection(context, order);
                } catch (e) {
                  AppLogger.d('❌ PriceDetailsSection 出错: $e');
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.withOpacity(0.3),
                    child: Text('PriceDetailsSection 错误: $e'),
                  );
                }
              },
            ),
            
            const SizedBox(height: 32), // 底部额外空间
          ],
        ),
      );
    } catch (e, stack) {
      AppLogger.d('❌❌❌ _buildOrderDetailContent 整体出错: $e');
      AppLogger.d('Stack trace: $stack');
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '页面渲染错误',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  

  // Helper to build simple info rows
  // Restore original implementation
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    // AppLogger.d('Building info row: $label - Value: "$value"'); // Remove print
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Restore alignment
        children: [
          Text(label, style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600])), // Restore original style
          const SizedBox(width: 8),
          // Container( // Remove container
          //    color: Colors.yellow,
          //    child: Text(value, style: TextStyle(color: Colors.black)),
          // ),
          Expanded(child: Text(value, style: textTheme.bodyMedium)), // Restore Expanded with original style
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

  // 构建支付状态警告
  Widget _buildPaymentStatusWarning(BuildContext context, Order order) {
    // 只有在订单状态为"待付款"时才显示警告
    if (order.state != OrderStatus.awaitingPayment) {
      return const SizedBox.shrink();
    }

    // 检查订单是否已经超过自动取消时间但仍未支付
    final now = DateTime.now();
    final orderCreatedAt = order.createdAt;
    final timeDifference = now.difference(orderCreatedAt).inMinutes;
    
    // 如果订单创建超过30分钟且仍为待付款状态，显示警告
    if (timeDifference > 30) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '支付状态提醒',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '如果您已经完成支付但订单仍显示"待付款"，可能是系统延迟所致。请稍后刷新页面查看。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
  
  // 构建商品信息部分
  Widget _buildOrderItemsSection(BuildContext context, Order order) {
    AppLogger.d('🔍 OrderItemsSection: 商品数量 ${order.items.length}');
    final items = order.items;
    if (items.isEmpty) {
      AppLogger.d('⚠️ OrderItemsSection: 商品列表为空');
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('暂无商品信息'),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '商品信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}件',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 商品列表
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: items.map((item) => OrderDetailItemTile(item: item)).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建订单信息部分
  Widget _buildOrderInfoSection(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '订单信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 内容部分
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(context, '订单编号：', order.orderSn ?? 'N/A'),
                _buildInfoRow(context, '下单时间：', _formatDateTime(order.createdAt)),
                if (order.paymentInfo.payTime != null)
                  _buildInfoRow(context, '付款时间：', _formatDateTime(order.paymentInfo.payTime)),
                if (order.completeTime != null)
                  _buildInfoRow(context, '完成时间：', _formatDateTime(order.completeTime)),
                if (order.buyerRemark != null && order.buyerRemark!.isNotEmpty)
                  _buildInfoRow(context, '订单备注：', order.buyerRemark!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建材料展示部分
  Widget _buildMaterialsSection(BuildContext context, Order order) {
    return BlocBuilder<OrderDetailBloc, OrderDetailState>(
      builder: (context, state) {
        // 获取材料和交付数据
        List<OrderMaterials>? materials;
        List<OrderDelivery>? deliveries;
        
        if (state is OrderDetailLoaded) {
          materials = state.materials;
          deliveries = state.deliveries;
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题部分
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '材料信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // 内容部分
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 买家提交的材料
                    Text(
                      '买家提交的材料',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBuyerMaterialsContent(context, materials),
                    
                    // 如果是待收货、待评价或已完成状态，显示卖家交付内容
                    if (order.state == OrderStatus.awaitingConfirmation ||
                        order.state == OrderStatus.awaitingEvaluation ||
                        order.state == OrderStatus.orderCompleted) ...[
                      const SizedBox(height: 16),
                      Text(
                        '卖家交付内容',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSellerDeliveriesContent(context, deliveries),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 构建买家材料内容
  Widget _buildBuyerMaterialsContent(BuildContext context, List<OrderMaterials>? materials) {
    if (materials == null || materials.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Text(
          '暂无买家提交的材料',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: materials.map((material) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 显示特征问答
            if (material.features.isNotEmpty) ...[
              ...material.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${feature.question}: ${feature.answer}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )),
              const SizedBox(height: 8),
            ],
            // 显示附件
            if (material.files.isNotEmpty) ...[
              const Text(
                '附件:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: material.files.map((fileUrl) => _buildFileChip(_extractFileName(fileUrl))).toList(),
              ),
            ],
          ],
        ),
      )).toList(),
    );
  }
  
  // 构建卖家交付内容
  Widget _buildSellerDeliveriesContent(BuildContext context, List<OrderDelivery>? deliveries) {
    if (deliveries == null || deliveries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Text(
          '卖家暂未交付内容',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: deliveries.map((delivery) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '交付说明: ${delivery.content}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (delivery.files.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                '交付文件:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: delivery.files.map((fileUrl) => _buildFileChip(_extractFileName(fileUrl))).toList(),
              ),
            ],
          ],
        ),
      )).toList(),
    );
  }

  // 构建文件标签
  Widget _buildFileChip(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(fileName),
            size: 14,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            fileName,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 根据文件扩展名获取图标
  IconData _getFileIcon(String fileName) {
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    switch (extension) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'jpg': case 'jpeg': case 'png': case 'gif': return Icons.image;
      case 'ai': case 'psd': return Icons.design_services;
      default: return Icons.insert_drive_file;
    }
  }
  
  // 从URL中提取文件名
  String _extractFileName(String fileUrl) {
    if (fileUrl.contains('/')) {
      return fileUrl.split('/').last;
    }
    return fileUrl;
  }
  
  // 构建收货信息部分
  // 构建价格明细部分
  Widget _buildPriceDetailsSection(BuildContext context, Order order) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题部分
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '价格明细',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 内容部分
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPriceRow(context, '商品总价', '¥${order.priceSummary.totalPrice.toStringAsFixed(2)}'),
                if (order.priceSummary.deliveryPrice > 0)
                  _buildPriceRow(context, '运费', '¥${order.priceSummary.deliveryPrice.toStringAsFixed(2)}'),
                if (order.priceSummary.discountPrice > 0)
                  _buildPriceRow(context, '优惠金额', '-¥${order.priceSummary.discountPrice.toStringAsFixed(2)}'),
                const Divider(height: 24, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '实付金额',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¥${order.priceSummary.payPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

