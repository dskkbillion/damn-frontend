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

/// 订单列表页面
class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  void initState() {
    super.initState();
    // Initialize TabController with the new length
    _tabController = TabController(length: _tabStatuses.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Initial load for the first tab (All)
    _loadOrdersForCurrentTab();
  }

  void _onTabChanged() {
    // Load orders only when the tab index actually changes and animation finished
    if (_tabController.indexIsChanging || !_tabController.indexIsChanging && _tabController.previousIndex != _tabController.index) {
       _loadOrdersForCurrentTab();
    }
  }

   void _loadOrdersForCurrentTab() {
     final selectedStatus = _tabStatuses[_tabController.index];
     print('[OrderListPage] Loading orders for tab index: ${_tabController.index}, status: $selectedStatus');
      context.read<OrderListBloc>().add(
            // Simplify event call, assuming LoadOrders only takes status
            LoadOrders(status: selectedStatus),
          );
   }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('我的订单'),
          actions: [
            // IconButton removed as requested
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true, // <-- Enable horizontal scrolling
            tabs: const [
              Tab(text: '全部'),
              Tab(text: '待付款'),
              Tab(text: '待提交'),
              Tab(text: '待交付'),
              Tab(text: '待收货'),
              Tab(text: '待评价'),
              Tab(text: '售后中'), // <-- New Tab
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
                     return const Center(child: Text('暂无相关订单'));
                   }
                   return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: state.orders.length,
                      itemBuilder: (context, index) {
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

                                // Option 2: Using Navigator.push (keeping existing style for now)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) {
                                      // TODO: Provide AfterSalesBloc if the detail page needs it.
                                      // For now, just navigate to the page.
                                      return AfterSalesDetailPage(id: order.id.toString());
                                    },
                                  ),
                                );
                              } else {
                                // Navigate to OrderDetailPage (existing logic)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider<OrderDetailBloc>(
                                      create: (context) => getIt<OrderDetailBloc>()
                                        ..add(LoadOrderDetail(orderId: order.id)),
                                      child: OrderDetailPage(orderId: order.id.toString()),
                                    ),
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
                     child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('加载失败: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadOrdersForCurrentTab,
                            child: const Text('重试'),
                          )
                        ],
                     )
                    );
                }
                return const Center(child: Text('请选择分类查看订单')); // Initial or empty state
           },
        ),
      );
  }
}
