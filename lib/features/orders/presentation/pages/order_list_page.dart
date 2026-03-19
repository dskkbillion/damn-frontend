import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dskk_flutter_refactor/features/after_sales/presentation/bloc/after_sales_bloc.dart';
import 'package:dskk_flutter_refactor/features/after_sales/domain/entities/after_sales_application.dart';

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
    OrderStatus.afterSale, // Index 5: 售后中
    OrderStatus.applyingForMediation, // Index 6: 平台介入中
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
      final normalizedStatus = _normalizeStatusForTab(statusEnum);
      // Find the index in our tab list
      final index = _tabStatuses.indexWhere((s) => s == normalizedStatus);
      return index != -1 ? index : 0; // Return found index or default to 0
    } catch (e) {
      AppLogger.d("Error finding index for status '$statusString': $e");
      return 0; // Default to '全部' on error
    }
  }

  OrderStatus? _normalizeStatusForTab(OrderStatus? status) {
    switch (status) {
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
      case OrderStatus.awaitingStart:
      case OrderStatus.awaitingDelivery:
      case OrderStatus.awaitingConfirmation:
        return OrderStatus.awaitingConfirmation;
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.sellerSupplementaryMaterials:
      case OrderStatus.applyForRefuse:
        return OrderStatus.afterSale;
      case OrderStatus.applyingForMediation:
        return OrderStatus.applyingForMediation;
      default:
        return status;
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

    // Only trigger an initial load if the route/provider has not already done so.
    if (context.read<OrderListBloc>().state is OrderListInitial) {
      _loadOrdersForStatus(_tabStatuses[initialIndex]);
    }
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
            LoadOrders(status: _normalizeStatusForTab(status)),
          );
   }

  bool _isAfterSalesTab(OrderStatus? status) {
    return status == OrderStatus.afterSale || status == OrderStatus.applyingForMediation;
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
                Icons.receipt_long_outlined,
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
              '下拉刷新或切换分类后再看看',
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
               final currentTabStatus = _tabStatuses[_tabController.index];
               if (_isAfterSalesTab(currentTabStatus)) {
                 return _buildAfterSalesTabBody(currentTabStatus!);
               }

               // Use the correct state names: OrderListLoaded, OrderListError, OrderListLoading, OrderListInitial
               if (state is OrderListLoaded) { // Correct success state name
                   if (state.orders.isEmpty) {
                     return RefreshIndicator(
                       onRefresh: _refreshCurrentTab,
                       child: ListView(
                         physics: const AlwaysScrollableScrollPhysics(),
                         padding: const EdgeInsets.all(32.0),
                         children: [
                           _buildEmptyState('暂无相关订单'),
                         ],
                       ),
                     );
                   }
                   return RefreshIndicator(
                     onRefresh: _refreshCurrentTab,
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
                              context.push('/afterSalesDetail/${order.id}?mode=order');
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

  Future<void> _refreshCurrentTab() async {
    HapticFeedback.mediumImpact();
    final currentTabStatus = _tabStatuses[_tabController.index];
    if (_isAfterSalesTab(currentTabStatus)) {
      return;
    }
    context.read<OrderListBloc>().add(
      LoadOrders(
        status: currentTabStatus,
        forceRefresh: true,
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
    final tabLabels = ['全部', '待付款', '待交付', '评价', '完成', '售后中', '平台介入中'];
    
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

  Widget _buildAfterSalesTabBody(OrderStatus status) {
    return BlocProvider(
      key: ValueKey('after-sales-${status.name}'),
      create: (_) => getIt<AfterSalesBloc>()
        ..add(const LoadAfterSalesListRequested(pageSize: 50)),
      child: BlocConsumer<AfterSalesBloc, AfterSalesState>(
        listener: (context, state) {
          if (state is AfterSalesActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '操作失败')),
            );
          } else if (state is AfterSalesActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.actionSuccessMessage ?? '操作成功')),
            );
            context.read<AfterSalesBloc>().add(const LoadAfterSalesListRequested(pageSize: 50));
          }
        },
        builder: (context, state) {
          if (state is AfterSalesListLoading || state is AfterSalesInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AfterSalesListError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(state.errorMessage ?? '加载失败'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AfterSalesBloc>().add(const LoadAfterSalesListRequested(pageSize: 50));
                      },
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AfterSalesListLoaded) {
            final applications = state.applications.where((application) {
              final orderState = _normalizeStatus(application.orderState ?? '');
              if (status == OrderStatus.applyingForMediation) {
                return orderState == 'applyingformediation';
              }
              return orderState != 'applyingformediation';
            }).toList();

            if (applications.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AfterSalesBloc>().add(const LoadAfterSalesListRequested(pageSize: 50));
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(32.0),
                  children: [
                    _buildEmptyState(status == OrderStatus.applyingForMediation ? '暂无平台介入记录' : '暂无售后记录'),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AfterSalesBloc>().add(const LoadAfterSalesListRequested(pageSize: 50));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  return _buildAfterSalesApplicationCard(context, applications[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAfterSalesApplicationCard(BuildContext context, AfterSalesApplication application) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusText = _getAfterSalesStatusText(application);
    final statusColor = _getAfterSalesStatusColor(application);
    final canApplyMediation = _canApplyMediation(application);
    final canCancel = _canCancelAfterSales(application);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/afterSalesDetail/${application.id}?mode=refund'),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: colorScheme.surfaceContainerHighest,
                      child: application.productImage != null && application.productImage!.isNotEmpty
                          ? Image.network(
                              application.productImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, color: Colors.grey[400]),
                            )
                          : Icon(Icons.image, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                application.productName ?? '商品名称未知',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                statusText,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (application.variantName != null && application.variantName!.isNotEmpty)
                          Text(
                            '规格：${application.variantName}',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMetaRow(
                                theme,
                                '售后原因',
                                application.refundReason ?? '未填写',
                              ),
                              const SizedBox(height: 8),
                              _buildMetaRow(
                                theme,
                                '退款金额',
                                '￥${application.refundPrice?.toStringAsFixed(2) ?? '--'}',
                                valueColor: colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push('/afterSalesDetail/${application.id}?mode=refund'),
                      child: const Text('查看售后'),
                    ),
                  ),
                  if (canCancel || canApplyMediation) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: canApplyMediation
                          ? ElevatedButton(
                              onPressed: () {
                                context.read<AfterSalesBloc>().add(ApplyMediationRequested(application.id));
                              },
                              child: const Text('申请介入'),
                            )
                          : OutlinedButton(
                              onPressed: () {
                                context.read<AfterSalesBloc>().add(CancelAfterSalesRequested(application.id));
                              },
                              child: const Text('撤销申请'),
                            ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  String _getAfterSalesStatusText(AfterSalesApplication application) {
    final orderState = _normalizeStatus(application.orderState ?? '');
    final refundState = _normalizeStatus(application.refundState);
    final finalState = _normalizeStatus(application.finalState ?? '');

    if (orderState == 'applyingformediation') return '平台介入中';
    if (finalState == 'pass') return '已退款';
    if (refundState == 'auditrefused') return '售后被拒';
    if (refundState == 'waitaudit') return '售后中';
    return application.refundStateText ?? '售后中';
  }

  Color _getAfterSalesStatusColor(AfterSalesApplication application) {
    final orderState = _normalizeStatus(application.orderState ?? '');
    final refundState = _normalizeStatus(application.refundState);
    final finalState = _normalizeStatus(application.finalState ?? '');

    if (orderState == 'applyingformediation') return Colors.blueGrey;
    if (finalState == 'pass') return Colors.green;
    if (refundState == 'auditrefused') return Colors.redAccent;
    return Colors.deepOrange;
  }

  bool _canApplyMediation(AfterSalesApplication application) {
    final orderState = _normalizeStatus(application.orderState ?? '');
    final refundState = _normalizeStatus(application.refundState);
    final finalState = _normalizeStatus(application.finalState ?? '');
    if (orderState == 'applyingformediation') return false;
    if (finalState == 'pass' || finalState == 'cancel') return false;
    return refundState == 'auditrefused';
  }

  bool _canCancelAfterSales(AfterSalesApplication application) {
    final orderState = _normalizeStatus(application.orderState ?? '');
    final refundState = _normalizeStatus(application.refundState);
    final finalState = _normalizeStatus(application.finalState ?? '');
    if (orderState == 'applyingformediation') return false;
    if (finalState == 'pass' || finalState == 'cancel') return false;
    return refundState == 'waitaudit';
  }

  String _normalizeStatus(String status) => status.toLowerCase().replaceAll('_', '');
}
