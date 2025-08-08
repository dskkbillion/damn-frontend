import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/features/orders/data/datasources/simple_mock_order_data_source.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';

/// 测试页面：直接显示mock订单数据，不通过Bloc
class TestOrderDisplayPage extends StatelessWidget {
  final int orderId;
  
  const TestOrderDisplayPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final allMockOrders = SimpleMockOrderDataSource.getAllMockOrders();
    final order = allMockOrders.where((o) => o.id == orderId).firstOrNull;
    
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: Text('订单 $orderId')),
        body: Center(child: Text('订单 $orderId 不存在')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('测试订单 ${order.id}'),
        backgroundColor: Colors.orange,
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 基本信息
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '订单信息',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('ID: ${order.id}'),
                    Text('编号: ${order.orderSn}'),
                    Text('状态: ${order.state}'),
                    Text('价格: ${RegionConfig.currencySymbol}${order.priceSummary.payPrice}'),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // 商品信息
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '商品信息',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (order.items.isNotEmpty) ...[
                      Text('商品名称: ${order.items.first.productName}'),
                      Text('SKU: ${order.items.first.skuName}'),
                      Text('数量: ${order.items.first.quantity}'),
                      Text('单价: ${RegionConfig.currencySymbol}${order.items.first.price}'),
                    ] else
                      Text('没有商品信息'),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // 用户信息
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '用户信息',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('买家: ${order.buyer?.nickname ?? "未知"}'),
                    Text('卖家: ${order.tenant?.nickname ?? "未知"}'),
                    if (order.tenant?.shopName != null)
                      Text('店铺: ${order.tenant!.shopName}'),
                  ],
                ),
              ),
              
              SizedBox(height: 80), // 底部间距
            ],
          ),
        ),
      ),
    );
  }
}