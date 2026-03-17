import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Use correct package name for imports and point to bloc/
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_item_card.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
// Import the new AfterSalesDetailPage

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
  final _searchController = TextEditingController();
  bool _showSearchBar = false;

  // 轻咨询模式：简化的Tab状态列表
  // IMPORTANT: Ensure this list order matches the TabBar tabs order
  final List<OrderStatus?> _tabStatuses = [
    null, // Index 0: 全部 (All)
    OrderStatus.awaitingPayment, // Index 1: 待付款
    OrderStatus.awaitingConfirmation, // Index 2: 待交付 (映射到awaitingConfirmation)
    OrderStatus.awaitingEvaluation, // Index 3: 评价
    OrderStatus.orderCompleted, // Index 4: 完成
    OrderStatus.applyingForMediation, // Index 5: 平台介入
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
      AppLogger.d("Error finding index for status '$statusString': $e");
      return 0; // Default to '全部' on error
    }
  }

  @override
  void initState() {
    super.initState();

    // Calculate initial index based on widget.initialStatus
    final initialIndex = _findIndexForStatus(widget.initialStatus);
    AppLogger.d('[OrderListPage initState] Received initialStatus: ${widget.initialStatus}, setting initialIndex: $initialIndex');

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
        AppLogger.d('[OrderListPage _onTabChanged] Loading orders for tab index: ${_tabController.index}, status: $selectedStatus');
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
    _searchController.dispose();
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
            // 搜索按钮
            IconButton(
              icon: Icon(_showSearchBar ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _showSearchBar = !_showSearchBar;
                  if (!_showSearchBar) {
                    // 关闭搜索时清空搜索内容并重新加载
                    _searchController.clear();
                    _loadOrdersForStatus(_tabStatuses[_tabController.index]);
                  }
                });
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(_showSearchBar ? 108 : 48),
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: _buildTabsWithBadges(),
                ),
                if (_showSearchBar)
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '搜索订单号或商品名称',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _performSearch('');
                              },
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) => _performSearch(value),
                      onChanged: (value) {
                        setState(() {}); // 更新清除按钮显示
                      },
                    ),
                  ),
              ],
            ),
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
                   return RefreshIndicator(
                     onRefresh: () async {
                       // 触觉反馈
                       HapticFeedback.mediumImpact();
                       // 重新加载当前标签的数据
                       context.read<OrderListBloc>().add(
                         LoadOrders(
                           status: _tabStatuses[_tabController.index],
                           forceRefresh: true,
                         ),
                       );
                     },
                     child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
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
                           onTap: () async {
                            // TODO: Refactor this navigation logic to use context.go() from go_router for better practice.
                            if (isAfterSalesOrder) {
                              // Navigate to AfterSalesDetailPage using GoRouter
                              context.push('/afterSalesDetail/${order.id}');
                            } else {
                              // Navigate to OrderDetailPage using GoRouter and wait for result
                              final shouldRefresh = await context.push<bool>('/orderDetail/${order.id}');
                              // If the detail page indicates a refresh is needed (e.g., after cancel/delete)
                              if (shouldRefresh == true) {
                                // Reload the current tab's orders
                                _loadOrdersForStatus(_tabStatuses[_tabController.index]);
                              }
                            }
                          },
                         );
                      },
                     ),
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
  
  /// 构建Tab标签，包含数量角标
  List<Widget> _buildTabsWithBadges() {
    // 获取当前状态中的数量统计
    Map<OrderStatus?, int>? statusCounts;
    final state = context.watch<OrderListBloc>().state;
    if (state is OrderListLoaded) {
      statusCounts = state.statusCounts;
    }
    
    // 轻咨询模式的Tab标签名称
    final tabLabels = ['全部', '待付款', '待交付', '评价', '完成', '平台介入'];
    
    return List.generate(_tabStatuses.length, (index) {
      final status = _tabStatuses[index];
      final label = tabLabels[index];
      final count = statusCounts?[status] ?? 0;
      
      // 轻咨询模式：只对待付款高亮显示
      final shouldHighlight = status == OrderStatus.awaitingPayment;
      
      if (count > 0 && status != null) { // 不显示"全部"的数量
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
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
  
  /// 执行搜索
  void _performSearch(String query) {
    context.read<OrderListBloc>().add(SearchOrders(query: query));
  }
}
