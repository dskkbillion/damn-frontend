import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Use correct package name for imports and point to bloc/
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_item_card.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/order_detail_page.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
// Correct import path for DI container
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
// Import the new AfterSalesDetailPage
import 'package:dskk_flutter_refactor/features/after_sales/presentation/pages/after_sales_detail_page.dart';
// TODO: Import AfterSalesBloc if needed for AfterSalesDetailPage
import '../../../../core/navigation/navigation_helper.dart';
import 'package:dskk_flutter_refactor/core/config/app_config.dart';

/// 订单列表页面
class OrderListPage extends StatefulWidget {
  // Add optional initialStatus parameter
  final String? initialStatus; 

  const OrderListPage({super.key, this.initialStatus}); // Modify constructor

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scrollController = ScrollController();

  // Define the statuses corresponding to each tab index
  // IMPORTANT: Ensure this list order matches the TabBar tabs order
  final List<OrderStatus?> _tabStatuses = [
    null, // Index 0: 全部 (All)
    OrderStatus.awaitingPayment, // Index 1: 待付款
    OrderStatus.awaitingSubmission, // Index 2: 待提交
    OrderStatus.awaitingDelivery, // Index 3: 待交付
    OrderStatus.awaitingConfirmation, // Index 4: 待收货
    OrderStatus.awaitingEvaluation, // Index 5: 待评价
    OrderStatus.afterSale, // Index 6: 售后中 (NEW)
  ];

  // Helper to find index for a given status string
  int _findIndexForStatus(String? statusString) {
    if (statusString == null) return 0; // Default to '全部'
    try {
      // Find the OrderStatus enum corresponding to the string
      final statusEnum = OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == statusString,
        orElse: () => OrderStatus.unknown // Or some default/fallback if string doesn't match
      );
      // Find the index in our tab list
      final index = _tabStatuses.indexWhere((s) => s == statusEnum);
      return index != -1 ? index : 0; // Return found index or default to 0
    } catch (e) {
      print("Error finding index for status '$statusString': $e");
      return 0; // Default to '全部' on error
    }
  }

  @override
  void initState() {
    super.initState();

    // Calculate initial index based on widget.initialStatus
    final initialIndex = _findIndexForStatus(widget.initialStatus);
    print('[OrderListPage initState] Received initialStatus: ${widget.initialStatus}, setting initialIndex: $initialIndex');

    // Initialize TabController with the calculated initial index
    _tabController = TabController(
      length: _tabStatuses.length,
      vsync: this,
      initialIndex: initialIndex, // <-- Set initial index here
    );

    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);

    // Initial load for the determined tab
    // No need to call _loadOrdersForCurrentTab here explicitly, 
    // as the TabController listener might fire initially, or we can load based on initialIndex.
    // Let's be explicit to ensure it loads:
    _loadOrdersForStatus(_tabStatuses[initialIndex]);
  }

  void _onTabChanged() {
    // Load orders only when the tab index actually changes (manual swipe/tap)
    // Check if the controller index matches the animation target
    if (!_tabController.indexIsChanging && _tabController.previousIndex != _tabController.index) {
        final selectedStatus = _tabStatuses[_tabController.index];
        print('[OrderListPage _onTabChanged] Loading orders for tab index: ${_tabController.index}, status: $selectedStatus');
        _loadOrdersForStatus(selectedStatus);
    }
  }

   // Renamed function for clarity
   void _loadOrdersForStatus(OrderStatus? status) {
      context.read<OrderListBloc>().add(
            LoadOrders(status: status),
          );
   }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Scroll listener to trigger loading more orders
  void _onScroll() {
    if (_isBottom) {
      context.read<OrderListBloc>().add(OrderListLoadMore());
    }
  }

  /// Helper to check if scrolled near the bottom
  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger loading when reaching 80% of the scroll extent
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).canPop() 
              ? Navigator.of(context).pop() 
              : context.go('/profile'), // 如果不能返回，则导航到个人中心
          ),
          title: const Text('我的订单'),
          // automaticallyImplyLeading 默认为 true，会自动显示返回按钮
          actions: [
            // 添加模拟数据切换按钮
            IconButton(
              icon: Icon(
                AppConfig.useMockData ? Icons.cloud_off : Icons.cloud_queue,
                color: AppConfig.useMockData ? Colors.orange : null,
              ),
              tooltip: AppConfig.useMockData ? '正在使用模拟数据' : '正在使用真实数据',
              onPressed: () {
                setState(() {
                  AppConfig.toggleMockMode();
                });
                // 重新加载当前标签的数据
                _loadOrdersForStatus(_tabStatuses[_tabController.index]);
                
                // 显示提示
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppConfig.useMockData ? '已切换到模拟数据模式' : '已切换到真实数据模式'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppConfig.useMockData ? Colors.orange : Colors.green,
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: '全部'),
              Tab(text: '待付款'),
              Tab(text: '待提交'),
              Tab(text: '待交付'),
              Tab(text: '待收货'),
              Tab(text: '待评价'),
              Tab(text: '售后中'),
            ],
          ),
        ),
        body: BlocConsumer<OrderListBloc, OrderListState>(
           listener: (context, state) {
             if (state is OrderListError) {
               // Optional: Show a Snackbar for errors
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('加载错误: ${state.message}')),
               );
             }
           },
           builder: (context, state) {
               // Use the correct state names: OrderListLoaded, OrderListError, OrderListLoading, OrderListInitial
               if (state is OrderListLoaded) { // Correct success state name
                   if (state.orders.isEmpty) {
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
                              child: Text('暂无相关订单', style: Theme.of(context).textTheme.bodyLarge),
                             ),
                         ),
                       ),
                     );
                   }
                   return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: state.hasReachedMax ? state.orders.length : state.orders.length + 1,
                      itemBuilder: (context, index) {
                         if (index >= state.orders.length) {
                           return const Padding(
                             padding: EdgeInsets.symmetric(vertical: 16.0),
                             child: Center(child: CircularProgressIndicator()),
                           );
                         }
                         final order = state.orders[index];

                         // Define the set of after-sales statuses
                         const afterSalesStatuses = {
                            OrderStatus.afterSale,
                            OrderStatus.AfterSaleRejection,
                            OrderStatus.applyingForMediation,
                         };

                         // Determine if the current order is in an after-sales state
                         final bool isAfterSalesOrder = afterSalesStatuses.contains(order.state);

                         return OrderItemCard(
                            order: order,
                            onTap: () {
                              // TODO: Refactor this navigation logic to use context.go() from go_router for better practice.
                              if (isAfterSalesOrder) {
                                // Navigate to AfterSalesDetailPage
                                // Option 1: Using go_router (preferred if setup allows)
                                // context.go('/afterSalesDetail/${order.id}');

                                // Option 2: Using NavigationHelper.pushDetailPage (keeping existing style for now)
                                NavigationHelper.pushDetailPage(
                                  context,
                                  AfterSalesDetailPage(id: order.id.toString()),
                                );
                              } else {
                                // Navigate to OrderDetailPage (existing logic)
                                NavigationHelper.pushDetailPage(
                                  context,
                                  BlocProvider<OrderDetailBloc>(
                                    create: (context) => getIt<OrderDetailBloc>()
                                      ..add(LoadOrderDetail(orderId: order.id)),
                                    child: OrderDetailPage(orderId: order.id.toString()),
                                  ),
                                );
                              }
                            },
                         );
                      },
                   );
                } else if (state is OrderListLoading) {
                   return const Center(child: CircularProgressIndicator());
                } else if (state is OrderListError) { // Correct error state name
                   // Show a simple error message, maybe with a retry button
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
                                  // Use the renamed function for retry
                                  onPressed: () => _loadOrdersForStatus(_tabStatuses[_tabController.index]), 
                                  child: const Text('重试'),
                                )
                              ],
                           ),
                         ),
                       ),
                     ),
                   );
                }
                return const Center(child: Text('请选择分类查看订单')); // Initial or empty state
           },
        ),
      );
  }
}
