import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_status_timeline_header.dart';
import 'package:dskk_flutter_refactor/features/chat/domain/repositories/i_chat_repository.dart';

// 新的组件导入
import '../widgets/order_action_buttons.dart';
import '../widgets/order_payment_status_warning.dart';
import '../widgets/order_items_section.dart';
import '../widgets/order_info_section.dart';
// import '../widgets/order_materials_section.dart'; // 轻咨询模式：隐藏材料上传
import '../widgets/order_price_details_section.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/utils/order_status_mapper.dart';

/// 订单详情页面
class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int? _orderIdInt;
  bool _isCreatingChat = false;
  late final IChatRepository _chatRepository = GetIt.I<IChatRepository>();

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
            const SnackBar(content: Text('无效的订单 ID'), backgroundColor: Colors.red),
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

  /// 处理联系卖家功能
  Future<void> _handleContactSeller(Order order) async {
    if (_isCreatingChat) return;

    if (order.tenant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法获取卖家信息')),
      );
      return;
    }

    setState(() {
      _isCreatingChat = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final productId = order.items.isNotEmpty ? order.items.first.productId : null;

      final result = await _chatRepository.createRoom(
        order.tenant!.id,
        productId: productId,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('创建聊天失败: ${failure.message}')),
            );
          }
        },
        (chatId) {
          if (mounted) {
            GoRouter.of(context).push('/chat/refactored/$chatId');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发生错误: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingChat = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔥🔥🔥 [买家OrderDetailPage] 正在构建页面，订单ID: ${widget.orderId} 🔥🔥🔥');
    
    if (_orderIdInt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('错误')),
        body: const Center(child: Text('无效的订单 ID')),
      );
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
              context.go('/orders');
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
            Text('加载失败: ${state.message}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<OrderDetailBloc>().add(LoadOrderDetail(orderId: _orderIdInt!));
              },
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    final extractedOrder = _extractOrder(state);
    if (extractedOrder == null) {
      return const Center(child: Text('订单数据不可用'));
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
                    child: OrderDetailActionButtons(
                      order: buttonOrder,
                      onContactSeller: _handleContactSeller,
                      isCreatingChat: _isCreatingChat,
                    ),
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
                
                // 轻咨询模式：隐藏材料上传部分
                // if (!OrderStatusMapper.isLightConsultationOrder(order)) ...[
                //   OrderMaterialsSection(order: order),
                //   const SizedBox(height: 16),
                // ],
                
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
            return OrderDetailActionButtons(
              order: order,
              onContactSeller: _handleContactSeller,
              isCreatingChat: _isCreatingChat,
            );
          },
        ),
      ],
    );
  }
}