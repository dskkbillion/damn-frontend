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
            
            // Display the list (potentially with loading/action indicators)
            if (ordersToShow.isEmpty && !isLoading && !isActionInProgress) {
               // Use the current filter from successState if available
               final statusText = successState?.currentStatusFilter?.toString().split('.').last ?? '当前';
               return Center(child: Text('没有找到 $statusText 状态的订单'));
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: SellerOrderItemCard(
                          order: order,
                          onTap: () {
                            // Navigate to the seller detail page using push instead of go
                            context.push('/seller/orders/${order.id}'); 
                             print('[SellerOrderListPage] Pushing to seller detail for order ${order.id}');
                          },
                        ),
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


