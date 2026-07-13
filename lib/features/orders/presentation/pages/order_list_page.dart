import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

// Use correct package name for imports and point to bloc/
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/widgets/order_item_card.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_page.dart';
import 'package:dskk_flutter_refactor/core/widgets/skeleton/skeleton_card.dart';
import 'package:dskk_flutter_refactor/core/widgets/glass_surface.dart';
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

  // Define the statuses corresponding to each tab index
  // IMPORTANT: Ensure this list order matches the TabBar tabs order
  final List<OrderStatus?> _tabStatuses = [
    null, // Index 0: 全部 (All)
    OrderStatus.awaitingPayment, // Index 1: 待付款
    OrderStatus.awaitingSubmission, // Index 2: 待提交
    OrderStatus.awaitingStart, // Index 3: 待接单
    OrderStatus.awaitingDelivery, // Index 4: 待交付
    OrderStatus.awaitingConfirmation, // Index 5: 待收货
    OrderStatus.awaitingEvaluation, // Index 6: 待评价
    OrderStatus.afterSale, // Index 7: 售后中 (NEW)
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
   void _loadOrdersForStatus(OrderStatus? status, {bool forceRefresh = false}) {
      context.read<OrderListBloc>().add(
            LoadOrders(status: status, forceRefresh: forceRefresh),
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
          title: Text(AppLocalizations.of(context).order_list_title),
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
                        hintText: AppLocalizations.of(context).order_list_search_hint,
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
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                 SnackBar(content: Text(AppLocalizations.of(context).order_list_load_error(state.message))),
               );
             }
           },
           builder: (context, state) {
               // Use the correct state names: OrderListLoaded, OrderListError, OrderListLoading, OrderListInitial
               if (state is OrderListLoaded) { // Correct success state name
                   if (state.orders.isEmpty) {
                     return Align(
                       alignment: const Alignment(0, -0.38),
                       child: Padding(
                         padding: const EdgeInsets.all(32.0),
                         child: GlassCard(
                           padding: const EdgeInsets.all(48.0),
                           borderRadius: BorderRadius.circular(12),
                           tintOpacity: 0.62,
                              child: Text(AppLocalizations.of(context).order_list_empty, style: Theme.of(context).textTheme.bodyLarge),
                         ),
                       ),
                     );
                   }
                   return RefreshIndicator(
                     onRefresh: () async {
                       // 触觉反馈
                       HapticFeedback.mediumImpact();
                       // #213 ORD-03: 下拉刷新走 forceRefresh,绕过 stale-while-revalidate 缓存
                       _loadOrdersForStatus(_tabStatuses[_tabController.index], forceRefresh: true);
                       // 等待加载完成
                       await Future.delayed(const Duration(milliseconds: 500));
                     },
                     child: ListView.builder(
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

                         // Determine if the current order is in an after-sales state.
                         // #399: 退款完成后订单变 canceled，退出了 afterSalesStatuses 集合，
                         // 但只要带有 refundId 就说明走过售后流程，应允许点进售后详情回看退款结果。
                         final bool isAfterSalesOrder =
                             afterSalesStatuses.contains(order.state) ||
                             (order.state == OrderStatus.canceled && order.refundId != null);

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
                   return SkeletonPage(itemCount: 4, itemBuilder: (_, __) => const SkeletonCard());
                } else if (state is OrderListError) { // Correct error state name
                   // Show a simple error message, maybe with a retry button
                   return Center(
                     child: Padding(
                       padding: const EdgeInsets.all(32.0),
                       child: GlassCard(
                         padding: const EdgeInsets.all(32.0),
                         borderRadius: BorderRadius.circular(12),
                         tintOpacity: 0.62,
                           child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                                const SizedBox(height: 16),
                                Text(AppLocalizations.of(context).order_list_load_failed(state.message)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  // Use the renamed function for retry
                                  onPressed: () => _loadOrdersForStatus(_tabStatuses[_tabController.index]),
                                  child: Text(AppLocalizations.of(context).order_list_retry),
                                )
                              ],
                      ),
                       ),
                     ),
                   );
                }
                return Center(child: Text(AppLocalizations.of(context).order_list_select_category)); // Initial or empty state
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
    
    // Tab标签名称
    final l10n = AppLocalizations.of(context);
    final tabLabels = [l10n.order_list_tab_all, l10n.order_list_tab_awaiting_payment, l10n.order_list_tab_awaiting_submission, l10n.order_list_tab_awaiting_start, l10n.order_list_tab_awaiting_delivery, l10n.order_list_tab_awaiting_confirmation, l10n.order_list_tab_awaiting_evaluation, l10n.order_list_tab_after_sale];
    
    return List.generate(_tabStatuses.length, (index) {
      final status = _tabStatuses[index];
      final label = tabLabels[index];
      final count = statusCounts?[status] ?? 0;
      
      // 判断是否需要高亮显示（待付款、待提交、待交付）
      final shouldHighlight = status == OrderStatus.awaitingPayment ||
                            status == OrderStatus.awaitingSubmission ||
                            status == OrderStatus.awaitingDelivery;
      
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
