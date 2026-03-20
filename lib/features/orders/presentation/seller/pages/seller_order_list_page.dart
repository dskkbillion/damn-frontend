import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // For navigation

import '../../../domain/entities/order.dart'; // Import Order
import '../../../domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/widgets/seller_order_item_card.dart';
import '../bloc/seller_order_list_bloc.dart';

class SellerOrderListPage extends StatefulWidget {
  /// 初始状态参数，可以为null
  final String? initialStatus;
  
  const SellerOrderListPage({this.initialStatus, super.key});

  @override
  State<SellerOrderListPage> createState() => _SellerOrderListPageState();
}

class _SellerOrderListPageState extends State<SellerOrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // 轻咨询模式 - 卖家视角简化Tab
  final List<Tab> _tabs = const [
    Tab(text: '全部'),        // 所有订单
    Tab(text: '待交付'),      // 待交付（映射到awaitingConfirmation）
    Tab(text: '待评价'),      // 待评价
    Tab(text: '完成'),        // 已完成
    Tab(text: '售后中'),      // 售后中
    Tab(text: '平台介入中'),  // 平台介入中
    Tab(text: '已取消'),      // 已取消
  ];

  final List<OrderStatus> _tabStatuses = [
    OrderStatus.unknown,              // 全部
    OrderStatus.awaitingConfirmation, // 待交付（使用awaitingConfirmation）
    OrderStatus.awaitingEvaluation,   // 待评价
    OrderStatus.orderCompleted,       // 完成
    OrderStatus.afterSale,            // 售后中
    OrderStatus.applyingForMediation, // 平台介入中
    OrderStatus.canceled,             // 已取消
  ];

  // 根据状态查找对应的Tab索引
  int _findIndexForStatus(OrderStatus? status) {
    if (status == null) return 0; // 默认返回"全部"索引
    
    final index = _tabStatuses.indexWhere((s) => s == status);
    return index != -1 ? index : 0; // 如果找不到匹配项，返回默认索引
  }

  @override
  void initState() {
    super.initState();
    
    // 处理初始状态参数
    OrderStatus? initialStatus;
    
    // 首先，从URL参数获取状态
    if (widget.initialStatus != null) {
      initialStatus = OrderStatus.fromString(widget.initialStatus);
      AppLogger.d('[SellerOrderListPage] Using initialStatus from URL: ${widget.initialStatus}, parsed: $initialStatus');
    } 
    // 其次，尝试从Bloc状态获取
    else if (context.read<SellerOrderListBloc>().state is SellerOrderListSuccess) {
      initialStatus = (context.read<SellerOrderListBloc>().state as SellerOrderListSuccess).currentStatusFilter;
      AppLogger.d('[SellerOrderListPage] Using initialStatus from Bloc state: $initialStatus');
    }
    
    // 计算初始Tab索引
    final initialIndex = _findIndexForStatus(initialStatus);
    AppLogger.d('[SellerOrderListPage] Setting initial tab index: $initialIndex for status: $initialStatus');
    
    _tabController = TabController(
      length: _tabs.length, 
      vsync: this,
      initialIndex: initialIndex
    );
    _tabController.addListener(_handleTabSelection);

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // 不再需要初始加载，因为通过路由的Builder已经初始加载了
    // context.read<SellerOrderListBloc>().add(const LoadSellerOrdersRequested());
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      final selectedStatus = _tabStatuses[_tabController.index];
      context.read<SellerOrderListBloc>().add(SellerOrderStatusFilterChanged(newStatusFilter: selectedStatus));
    }
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SellerOrderListBloc>().add(LoadMoreSellerOrders());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger slightly before reaching the absolute bottom
    return currentScroll >= (maxScroll * 0.9);
  }

  Widget _buildEmptyState(String message) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '暂时没有需要处理的订单',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).canPop() 
            ? Navigator.of(context).pop() 
            : context.go('/seller'), // 如果不能返回，则导航到卖家首页
        ),
        title: const Text('我的订单 (卖家)'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _buildTabsWithCounts(),
        ),
      ),
      body: BlocConsumer<SellerOrderListBloc, SellerOrderListState>(
         listener: (context, state) {
            // Listen for action failures and show SnackBar
            if (state is SellerOrderListActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('操作失败: ${state.message}'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                  ), 
              );
            }
            // Optional: Add listener for ActionSuccess if we define such a state for feedback
            // if (state is SellerOrderListActionSuccess) {
            //    ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            //   );
            // }
          },
          builder: (context, state) {
            // Determine the list of orders to display based on the current state
            // This now correctly handles ActionInProgress and ActionFailure by using their previousState
            final List<Order> ordersToShow;
            SellerOrderListSuccess? successState;
            if (state is SellerOrderListSuccess) {
              ordersToShow = state.orders;
              successState = state;
            } else if (state is SellerOrderListActionInProgress) {
              ordersToShow = state.previousState.orders;
              successState = state.previousState;
            } else if (state is SellerOrderListActionFailure) {
              ordersToShow = state.previousState.orders;
              successState = state.previousState;
            } else if (state is SellerOrderListLoading && state.previousState != null) {
              // Handle loading more case
              ordersToShow = state.previousState!.orders;
              successState = state.previousState;
            } else {
               ordersToShow = []; // Default for Initial or complete failure
               successState = null;
            }

            final bool isLoading = state is SellerOrderListLoading;
            final bool isActionInProgress = state is SellerOrderListActionInProgress;

            // Handle initial loading and initial error states separately
            if (state is SellerOrderListLoading && state.previousState == null) {
               return const Center(child: CircularProgressIndicator());
            }
            if (state is SellerOrderListFailure && state.previousState == null) {
               return Center(
                 child: Padding(
                   padding: const EdgeInsets.all(32.0),
                   child: Card(
                     elevation: 0,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(12.0),
                       side: BorderSide(
                         color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                       ),
                     ),
                     child: Padding(
                       padding: const EdgeInsets.all(32.0),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                           const SizedBox(height: 16),
                           Text('加载失败: ${state.message}'),
                           const SizedBox(height: 16),
                           ElevatedButton(
                              onPressed: () => context.read<SellerOrderListBloc>().add(
                                  LoadSellerOrdersRequested(statusFilter: _tabStatuses[_tabController.index])
                              ),
                             child: const Text('重试'),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
               );
            }
            
            // Display the list (potentially with loading/action indicators)
            if (ordersToShow.isEmpty && !isLoading && !isActionInProgress) {
               return Center(
                 child: Padding(
                   padding: const EdgeInsets.all(32.0),
                   child: _buildEmptyState('暂无此状态订单'),
                 ),
               );
            }

            return Stack( // Use Stack to overlay progress indicator
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                     context.read<SellerOrderListBloc>().add(
                          LoadSellerOrdersRequested(statusFilter: _tabStatuses[_tabController.index], refresh: true)
                      );
                     // Consider returning a Future that completes when loading finishes
                     // return context.read<SellerOrderListBloc>().stream.firstWhere((s) => s is! SellerOrderListLoading);
                  },
                  child: Column(
                    children: [
                      // 待处理订单提醒卡片
                      if (_hasPendingOrders(successState))
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Icon(
                                  Icons.notifications_active,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              title: Text(
                                '您有${_getPendingCount(successState)}个订单待处理',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              subtitle: Text(
                                _getPendingDescription(successState),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                              onTap: () {
                                // 切换到待接单Tab
                                _tabController.animateTo(1); // 待接单是第2个tab
                              },
                            ),
                          ),
                        ),
                      // 订单列表
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16.0),
                    itemCount: ordersToShow.length + (isLoading ? 1 : 0), // Add space for loading indicator
                    itemBuilder: (context, index) {
                      if (index >= ordersToShow.length) {
                        // Bottom loading indicator
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final order = ordersToShow[index];
                      return SellerOrderItemCard(
                          order: order,
                          hasBuyerMaterials: _checkHasBuyerMaterials(order),
                          onTap: () {
                            // Navigate to the seller detail page using push instead of go
                            context.push('/seller/orders/${order.id}'); 
                             AppLogger.d('[SellerOrderListPage] Pushing to seller detail for order ${order.id}');
                          },
                        );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                 // Overlay a progress indicator if an action is in progress
                if (isActionInProgress)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.1), // Semi-transparent overlay
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
       ),
    );
  }
  
  /// 构建Tab标签，包含数量角标
  List<Widget> _buildTabsWithCounts() {
    // 获取当前状态中的数量统计
    Map<OrderStatus, int>? statusCounts;
    final state = context.watch<SellerOrderListBloc>().state;
    if (state is SellerOrderListSuccess) {
      // TODO: 需要在bloc中实现状态计数功能
      // statusCounts = state.statusCounts;
    }
    
    return List.generate(_tabs.length, (index) {
      final status = _tabStatuses[index];
      final label = _tabs[index].text;
      final count = statusCounts?[status] ?? 0;
      
      // 判断是否需要高亮显示（待接单、待发货）
      final shouldHighlight = status == OrderStatus.awaitingStart ||
                            status == OrderStatus.awaitingDelivery;
      
      if (count > 0 && status != OrderStatus.unknown) { // 不显示"全部"的数量
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label!),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: shouldHighlight 
                    ? Theme.of(context).colorScheme.error 
                    : Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: shouldHighlight
                      ? Theme.of(context).colorScheme.onError
                      : Theme.of(context).colorScheme.onPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Tab(text: label);
      }
    });
  }
  
  /// 判断是否有待处理订单
  bool _hasPendingOrders(SellerOrderListSuccess? state) {
    if (state == null) return false;
    // 检查是否有待接单或待发货的订单
    return state.orders.any((order) => 
      order.state == OrderStatus.awaitingStart || 
      order.state == OrderStatus.awaitingDelivery
    );
  }
  
  /// 获取待处理订单数量
  int _getPendingCount(SellerOrderListSuccess? state) {
    if (state == null) return 0;
    return state.orders.where((order) => 
      order.state == OrderStatus.awaitingStart || 
      order.state == OrderStatus.awaitingDelivery
    ).length;
  }
  
  /// 获取待处理描述
  String _getPendingDescription(SellerOrderListSuccess? state) {
    if (state == null) return '';
    
    final awaitingStart = state.orders.where((o) => o.state == OrderStatus.awaitingStart).length;
    final awaitingDelivery = state.orders.where((o) => o.state == OrderStatus.awaitingDelivery).length;
    
    final parts = <String>[];
    if (awaitingStart > 0) parts.add('$awaitingStart个待接单');
    if (awaitingDelivery > 0) parts.add('$awaitingDelivery个待发货');
    
    return parts.join('、');
  }
  
  /// 检查订单是否有买家提供的材料
  /// 这是一个简化的实现，基于订单状态和买家备注判断
  /// 在实际生产环境中，应该通过API或State获取实际的材料数据
  bool _checkHasBuyerMaterials(Order order) {
    // 简单判断：如果有买家备注，则认为有材料
    // TODO: 后续应该从实际的材料数据判断
    return order.buyerRemark != null && order.buyerRemark!.isNotEmpty;
  }
}
