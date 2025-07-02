import 'package:flutter/material.dart';
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

  // Define Seller Tabs - 单一状态映射，清晰明确
  final List<Tab> _tabs = const [
    Tab(text: '全部'),        // 所有订单
    Tab(text: '待接单'),      // 等待卖家确认接单
    Tab(text: '待提交'),      // 等待卖家提交要求
    Tab(text: '待发货'),      // 等待卖家发货/交付
    Tab(text: '待确认收货'),  // 等待买家确认收货
    Tab(text: '待评价'),      // 等待买家评价
    Tab(text: '已完成'),      // 订单已完成
    Tab(text: '售后中'),      // 售后处理中
    Tab(text: '已取消'),      // 已取消订单
  ];

  final List<OrderStatus> _tabStatuses = [
    OrderStatus.unknown,              // 全部
    OrderStatus.awaitingStart,        // 待接单
    OrderStatus.awaitingSubmission,   // 待提交
    OrderStatus.awaitingDelivery,     // 待发货
    OrderStatus.awaitingConfirmation, // 待确认收货
    OrderStatus.awaitingEvaluation,   // 待评价
    OrderStatus.orderCompleted,       // 已完成
    OrderStatus.afterSale,            // 售后中
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
      print('[SellerOrderListPage] Using initialStatus from URL: ${widget.initialStatus}, parsed: $initialStatus');
    } 
    // 其次，尝试从Bloc状态获取
    else if (context.read<SellerOrderListBloc>().state is SellerOrderListSuccess) {
      initialStatus = (context.read<SellerOrderListBloc>().state as SellerOrderListSuccess).currentStatusFilter;
      print('[SellerOrderListPage] Using initialStatus from Bloc state: $initialStatus');
    }
    
    // 计算初始Tab索引
    final initialIndex = _findIndexForStatus(initialStatus);
    print('[SellerOrderListPage] Setting initial tab index: $initialIndex for status: $initialStatus');
    
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
        // TODO: Add Search Icon/Action?
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs,
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
               // Use the current filter from successState if available
               final statusText = successState?.currentStatusFilter?.toString().split('.').last ?? '当前';
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
                       padding: const EdgeInsets.all(48.0),
                       child: Text('暂无此状态订单', style: Theme.of(context).textTheme.bodyLarge),
                     ),
                   ),
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
                  child: ListView.builder(
                    controller: _scrollController,
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
                          onTap: () {
                            // Navigate to the seller detail page using push instead of go
                            context.push('/seller/orders/${order.id}'); 
                             print('[SellerOrderListPage] Pushing to seller detail for order ${order.id}');
                          },
                        );
                    },
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
}


