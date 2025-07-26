import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_price_summary.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_payment_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_shipping_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart';

/// 简化的模拟订单数据源，用于测试和开发
class SimpleMockOrderDataSource {
  static final DateTime _baseTime = DateTime.now();
  
  /// 获取所有测试订单
  static List<Order> getAllMockOrders() {
    return [
      _createOrderWithStatus(OrderStatus.awaitingPayment, 1001, 'ORD20240120001', 'Logo设计服务', 299.00),
      _createOrderWithStatus(OrderStatus.awaitingSubmission, 1002, 'ORD20240120002', '品牌VI设计', 1999.00),
      _createOrderWithStatus(OrderStatus.awaitingStart, 1003, 'ORD20240120003', '产品包装设计', 599.00),
      _createOrderWithStatus(OrderStatus.awaitingDelivery, 1004, 'ORD20240120004', '海报设计', 199.00),
      _createOrderWithStatus(OrderStatus.awaitingConfirmation, 1005, 'ORD20240120005', '名片设计', 99.00),
      _createOrderWithStatus(OrderStatus.awaitingEvaluation, 1006, 'ORD20240120006', '宣传册设计', 2999.00),
      _createOrderWithStatus(OrderStatus.orderCompleted, 1007, 'ORD20240120007', 'PPT设计', 399.00),
      _createOrderWithStatus(OrderStatus.canceled, 1008, 'ORD20240120008', '插画设计', 299.00),
      _createOrderWithStatus(OrderStatus.applyingForMediation, 1009, 'ORD20240120009', '网站设计', 4999.00),
      _createOrderWithStatus(OrderStatus.afterSale, 1010, 'ORD20240120010', 'UI界面设计', 3999.00),
    ];
  }
  
  /// 根据状态创建订单
  static Order _createOrderWithStatus(
    OrderStatus status,
    int orderId,
    String orderSn,
    String productName,
    double price,
  ) {
    // 根据状态设置支付信息
    final bool isPaid = status != OrderStatus.awaitingPayment && status != OrderStatus.canceled;
    final DateTime? payTime = isPaid ? _baseTime.subtract(const Duration(hours: 2)) : null;
    
    // 根据状态设置完成时间
    final DateTime? completeTime = status == OrderStatus.orderCompleted 
        ? _baseTime.subtract(const Duration(days: 1)) 
        : null;
    
    // 根据状态设置取消时间
    final DateTime? cancelTime = status == OrderStatus.canceled 
        ? _baseTime.subtract(const Duration(hours: 1)) 
        : null;
    
    return Order(
      id: orderId,
      orderSn: orderSn,
      state: status,
      orderType: 'NORMAL',
      items: [
        OrderItem(
          id: orderId,
          orderId: orderId,
          productId: 100 + orderId,
          productName: productName,
          skuId: 200 + orderId,
          skuName: '标准版',
          imageUrl: 'https://picsum.photos/200/200?random=${orderId}',
          quantity: 1,
          price: price,
          totalPrice: price,
        ),
      ],
      shippingAddress: Address(
        recipientName: '测试用户',
        phone: '13800138000',
        areaId: '440305', // 南山区的区域代码
        detailAddress: '科技园南路999号',
      ),
      priceSummary: OrderPriceSummary(
        totalPrice: price,
        discountPrice: price > 1000 ? 100.00 : 0.00,
        deliveryPrice: 0.00,
        payPrice: price > 1000 ? price - 100.00 : price,
      ),
      paymentInfo: OrderPaymentInfo(
        payStatus: isPaid,
        payTime: payTime,
        payChannelCode: isPaid ? (orderId % 2 == 0 ? 'wx_lite' : 'alipay_app') : null,
      ),
      shippingInfo: OrderShippingInfo(
        logisticsId: null,
        logisticsNo: null,
        deliveryTime: null,
      ),
      createdAt: _baseTime.subtract(Duration(days: 10 - orderId % 10)),
      completeTime: completeTime,
      cancelTime: cancelTime,
      buyerRemark: '测试订单备注',
    );
  }
  
  /// 根据状态获取测试订单
  static Order? getOrderByStatus(OrderStatus status) {
    final orders = getAllMockOrders();
    try {
      return orders.firstWhere((order) => order.state == status);
    } catch (e) {
      return null;
    }
  }
}