import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // For navigation

import '../../../domain/entities/order.dart'; // Import Order
import '../../../domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/widgets/seller_order_item_card.dart';
import '../bloc/seller_order_list_bloc.dart';

class SellerOrderListPage extends StatefulWidget {
  const SellerOrderListPage({super.key});

  @override
  State<SellerOrderListPage> createState() => _SellerOrderListPageState();
}

class _SellerOrderListPageState extends State<SellerOrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  // Define Seller Tabs
  // TODO: Finalize tab statuses based on seller workflow
  final List<Tab> _tabs = const [
    Tab(text: '全部'),       // OrderStatus.unknown
    Tab(text: '待确认'),     // OrderStatus.awaitingStart
    Tab(text: '进行中'),     // OrderStatus.awaitingDelivery, etc.
    Tab(text: '待确认收货'), // OrderStatus.awaitingConfirmation
    Tab(text: '已完成'),     // OrderStatus.orderCompleted
    Tab(text: '售后中'),     // OrderStatus.afterSale, etc.
    // Add more seller-specific statuses if needed
  ];

  final List<OrderStatus> _tabStatuses = [
    OrderStatus.unknown,
    OrderStatus.awaitingStart,
    OrderStatus.awaitingDelivery, // Combine relevant in-progress states here?
    OrderStatus.awaitingConfirmation,
    OrderStatus.orderCompleted, // Add corresponding status
    OrderStatus.afterSale, // Combine relevant after-sale states here?
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Initial load (assuming Bloc is provided above this widget)
    // Consider loading 'All' initially or the first tab status
    context.read<SellerOrderListBloc>().add(const LoadSellerOrdersRequested());
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
            // Optional: Show snackbars for errors on load more?
            // if (state is SellerOrderListFailure && state.isLoadMoreError) { // Need to add flag to state
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(content: Text('加载更多失败: ${state.message}')),
            //   );
            // }
          },
          builder: (context, state) {
            if (state is SellerOrderListLoading && state.orders.isEmpty) { // Check if loading initial data
               return const Center(child: CircularProgressIndicator());
            }
            if (state is SellerOrderListFailure && state.orders.isEmpty) { // Check if initial load failed
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
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
               );
            }
            if (state is SellerOrderListSuccess || (state is SellerOrderListLoading && state.orders.isNotEmpty) || (state is SellerOrderListFailure && state.orders.isNotEmpty)) {
              // Show list data even if loading more or if load more failed
              final orders = state.orders;
              final bool isLoadingMore = state is SellerOrderListLoading;

              if (orders.isEmpty && !isLoadingMore) {
                 return const Center(child: Text('没有找到相关订单'));
              }

              return RefreshIndicator(
                onRefresh: () async {
                   context.read<SellerOrderListBloc>().add(
                        LoadSellerOrdersRequested(statusFilter: _tabStatuses[_tabController.index], refresh: true)
                    );
                   // Consider returning a Future that completes when loading finishes
                   // return context.read<SellerOrderListBloc>().stream.firstWhere((s) => s is! SellerOrderListLoading);
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: orders.length + (isLoadingMore ? 1 : 0), // Add space for loading indicator
                  itemBuilder: (context, index) {
                    if (index >= orders.length) {
                      // Bottom loading indicator
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final order = orders[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: SellerOrderItemCard(
                        order: order,
                        onTap: () {
                          // TODO: Define seller detail route
                          // context.go('/seller/orders/${order.id}');
                           print('Navigate to seller detail for order ${order.id}');
                        },
                      ),
                    );
                  },
                ),
              );
            }
            // Should not happen if initial state is handled, but provide fallback
            return const Center(child: Text('未知状态'));
          },
       ),
    );
  }
}

// Extension to access orders from any state for builder convenience
// Avoids direct casting and handles potential null cases if states change
extension SellerOrderListStateOrders on SellerOrderListState {
  List<Order> get orders {
    if (this is SellerOrderListSuccess) {
      return (this as SellerOrderListSuccess).orders;
    } else if (this is SellerOrderListLoading && (this as SellerOrderListLoading).previousState != null) {
       // If loading more, show previous orders
       return (this as SellerOrderListLoading).previousState!.orders;
    } else if (this is SellerOrderListFailure && (this as SellerOrderListFailure).previousState != null) {
      // If loading more failed, show previous orders
      return (this as SellerOrderListFailure).previousState!.orders;
    }
    return []; // Default to empty list for Initial or unhandled states
  }
}

