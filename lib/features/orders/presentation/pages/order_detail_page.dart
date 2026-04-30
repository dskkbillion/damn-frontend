import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_timeline_header.dart';

// 新的组件导入
import '../widgets/order_action_buttons.dart';
import '../widgets/order_payment_status_warning.dart';
import '../widgets/order_items_section.dart';
import '../widgets/order_info_section.dart';
import '../widgets/order_materials_section.dart';
import '../widgets/order_price_details_section.dart';

/// 订单详情页面
class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int? _orderIdInt;

  @override
  void initState() {
    super.initState();
    _orderIdInt = int.tryParse(widget.orderId);
    if (_orderIdInt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentState = context.read<OrderDetailBloc>().state;
        if (currentState is OrderDetailInitial) {
          context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).order_detail_invalid_id), backgroundColor: Colors.red),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


  /// 从各种状态中提取订单数据
  Order? _extractOrder(OrderDetailState state) {
    if (state is OrderDetailLoaded) {
      return state.order;
    } else if (state is OrderDetailActionLoading && state.previousState != null) {
      return state.previousState!.order;
    } else if (state is OrderDetailActionSuccess && state.updatedState != null) {
      return state.updatedState!.order;
    } else if (state is OrderDetailActionFailure && state.previousState != null) {
      return state.previousState!.order;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    print('🔥🔥🔥 [买家OrderDetailPage] 正在构建页面，订单ID: ${widget.orderId} 🔥🔥🔥');
    
    if (_orderIdInt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).order_detail_error)),
        body: Center(child: Text(AppLocalizations.of(context).order_detail_invalid_id)),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile/orders');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              final extractedOrder = _extractOrder(state);
              return Text(extractedOrder != null ? AppLocalizations.of(context).order_detail_title_with_id(extractedOrder.id) : AppLocalizations.of(context).order_detail_title);
            },
          ),
        ),
        body: BlocListener<OrderDetailBloc, OrderDetailState>(
          listener: _handleBlocStateChanges,
          child: BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              return _buildContent(context, state);
            },
          ),
        ),
      ),
    );
  }

  /// 处理BLoC状态变化
  void _handleBlocStateChanges(BuildContext context, OrderDetailState state) {
    if (state is OrderDetailActionSuccess) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      
      if (state.actionType == OrderAction.cancel || state.actionType == OrderAction.delete) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            if (context.canPop()) {
              context.pop(true);
            } else {
              context.go('/profile/orders');
            }
          }
        });
      } else {
        context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
      }
    } else if (state is OrderDetailActionFailure) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  /// 构建主要内容
  Widget _buildContent(BuildContext context, OrderDetailState state) {
    if (state is OrderDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OrderDetailError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context).order_detail_load_failed(state.message)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
              },
              child: Text(AppLocalizations.of(context).order_detail_reload),
            ),
          ],
        ),
      );
    }

    final extractedOrder = _extractOrder(state);
    if (extractedOrder == null) {
      return Center(child: Text(AppLocalizations.of(context).order_detail_unavailable));
    }

    return Stack(
      children: [
        _buildOrderDetailContent(context, extractedOrder),
        
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
                if (buttonOrder.state == OrderStatus.orderCompleted || 
                    buttonOrder.state == OrderStatus.canceled) {
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
  }

  /// 构建订单详情内容
  Widget _buildOrderDetailContent(BuildContext context, Order order) {
    print('🎨🎨🎨 [买家OrderDetailPage] _buildOrderDetailContent 被调用，订单ID: ${order.id}, 状态: ${order.state} 🎨🎨🎨');
    
    return Column(
      children: [
        // 时间轴头部
        OrderStatusTimelineHeader(order: order),
        
        // 可滚动内容区域
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                
                // 支付状态警告
                OrderPaymentStatusWarning(order: order),
                
                // 商品信息
                OrderItemsSection(order: order),
                const SizedBox(height: 16),
                
                // 订单信息
                OrderInfoSection(order: order),
                const SizedBox(height: 16),
                
                // 材料信息
                OrderMaterialsSection(order: order),
                const SizedBox(height: 16),
                
                // 价格详情
                OrderPriceDetailsSection(order: order),
                const SizedBox(height: 100), // 为底部按钮留出空间
              ],
            ),
          ),
        ),
        
        // 底部操作按钮
        BlocBuilder<OrderDetailBloc, OrderDetailState>(
          builder: (context, buttonState) {
            return OrderDetailActionButtons(order: order);
          },
        ),
      ],
    );
  }
}