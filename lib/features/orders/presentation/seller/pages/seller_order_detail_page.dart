import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // Assuming you use GetIt for DI

import '../bloc/seller_order_detail_bloc.dart';
// Import Order entity to use in builder
import '../../../domain/entities/order.dart';

class SellerOrderDetailPage extends StatelessWidget {
  final int orderId;

  const SellerOrderDetailPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    // It's often better to provide the Bloc higher up (e.g., in the router)
    // But for simplicity in this skeleton, we provide it here.
    // Ensure SellerOrderDetailBloc and its dependencies are registered in GetIt.
    return BlocProvider(
      create: (context) => GetIt.instance<SellerOrderDetailBloc>()
        ..add(LoadSellerOrderDetail(orderId: orderId)), // Trigger load on creation
      child: Scaffold(
        appBar: AppBar(
          title: Text('订单详情 (卖家) - #$orderId'),
        ),
        body: BlocBuilder<SellerOrderDetailBloc, SellerOrderDetailState>(
          builder: (context, state) {
            if (state is SellerOrderDetailLoading && state.loadingOrderId == orderId) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SellerOrderDetailLoadFailure && state.failedOrderId == orderId) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('加载订单 #${state.failedOrderId} 失败: ${state.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<SellerOrderDetailBloc>()
                          .add(LoadSellerOrderDetail(orderId: orderId)),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }
            if (state is SellerOrderDetailLoadSuccess && state.order.id == orderId) {
              // --- Main Content Area ---
              // TODO: Build the actual detail UI using state.order
              return SingleChildScrollView( // Use SingleChildScrollView for potentially long content
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('订单号: ${state.order.orderSn ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    Text('状态: ${state.order.state.toString()}'), // Placeholder
                    const SizedBox(height: 8),
                    Text('买家: ${state.order.shippingAddress.recipientName}'), // Placeholder
                    const SizedBox(height: 8),
                     Text('总金额: ¥${state.order.priceSummary.payPrice.toStringAsFixed(2)}'), // Placeholder
                    const Divider(height: 32),
                    const Text('--- 页面内容待实现 ---', style: TextStyle(color: Colors.grey)),
                     // TODO: Add Status Timeline Header
                     // TODO: Add Status Description Card
                     // TODO: Add Dynamic Content Section based on state.order.state
                     // TODO: Add Fixed Bottom Action Buttons
                  ],
                ),
              );
              // --- End Main Content Area ---
            }
            // Initial state or state for a different orderId
            return const Center(child: Text('正在准备加载订单详情...'));
          },
        ),
      ),
    );
  }
}
