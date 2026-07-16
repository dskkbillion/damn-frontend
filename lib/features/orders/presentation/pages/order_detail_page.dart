import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/payment/presentation/pages/order_payment_method_page.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_timeline_header.dart';

// 新的组件导入
import '../widgets/order_action_buttons.dart';
import '../widgets/order_payment_status_warning.dart';
import '../widgets/order_items_section.dart';
import '../widgets/order_info_section.dart';
import '../widgets/order_materials_section.dart';
import '../widgets/order_price_details_section.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_page_skeleton.dart';

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
            SnackBar(
              content: Text(AppLocalizations.of(context).order_detail_invalid_id),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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
    Order? normalize(Order? order) {
      if (order == null || !order.isPaymentExpired) return order;
      return order.copyWith(state: OrderStatus.canceled);
    }

    if (state is OrderDetailLoaded) {
      return normalize(state.order);
    } else if (state is OrderDetailActionLoading && state.previousState != null) {
      return normalize(state.previousState!.order);
    } else if (state is OrderDetailActionSuccess && state.updatedState != null) {
      return normalize(state.updatedState!.order);
    } else if (state is OrderDetailActionFailure && state.previousState != null) {
      return normalize(state.previousState!.order);
    } else if (state is OrderDetailNavigateToPaymentSelection) {
      // #324 之前漏掉这个分支会让页面闪显"订单不可用"
      return normalize(state.order);
    } else if (state is OrderDetailPaymentLoading && state.previousState != null) {
      return normalize(state.previousState!.order);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_orderIdInt == null) {
      return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).order_detail_error)),
        body: Center(child: Text(AppLocalizations.of(context).order_detail_invalid_id)),
      );
    }

    final navigator = Navigator.of(context);
    final canGoBack = navigator.canPop();

    return PopScope(
      // 允许有路由栈时的 iOS 边缘返回手势；根路由没有上级时仍由下面的
      // 回调和明确的返回按钮兜底到订单列表。
      canPop: canGoBack,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/profile/orders');
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: '返回订单列表',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (canGoBack) {
                context.pop();
              } else {
                context.go('/profile/orders');
              }
            },
          ),
          title: BlocBuilder<OrderDetailBloc, OrderDetailState>(
            builder: (context, state) {
              return Text(AppLocalizations.of(context).order_detail_title);
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
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } else if (state is OrderDetailNavigateToPaymentSelection) {
      // #324 之前 bloc emit 这个 state 后 UI 没人监听导航,导致"订单不可用"
      // 用同一个 bloc 实例 push 到支付方式选择页
      final bloc = context.read<OrderDetailBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: OrderPaymentMethodPage(order: state.order),
          ),
        ),
      ).then((_) {
        // #373 支付流程返回后（无论成功/取消/失败）重新拉取订单状态，
        // 避免详情页停留在旧的 awaitingPayment（后端已流转到 awaitingConfirmation），
        // 否则用户被迫再次付款（资损）。LoadOrderDetail 幂等，多拉一次无害。
        if (_orderIdInt != null && mounted) {
          bloc.add(LoadOrderDetail(orderId: _orderIdInt!));
        }
      });
    }
  }

  /// 构建主要内容
  Widget _buildContent(BuildContext context, OrderDetailState state) {
    if (state is OrderDetailLoading) {
      return const SellerPageSkeleton(variant: SellerSkeletonVariant.detail);
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
                        color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
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
            color: Theme.of(context).colorScheme.scrim.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  /// 构建订单详情内容
  Widget _buildOrderDetailContent(BuildContext context, Order order) {
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
