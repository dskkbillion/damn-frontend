import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_item.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_price_summary.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_payment_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_shipping_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/member.dart';

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
        
    // 根据状态设置各种自动处理时间
    DateTime? autoCancelTime;
    DateTime? autoMaterialTime;
    DateTime? deliveryTimestamp;
    
    switch (status) {
      case OrderStatus.awaitingPayment:
        // 待付款订单30分钟后自动取消
        autoCancelTime = _baseTime.add(const Duration(minutes: 30));
        break;
        
      case OrderStatus.awaitingSubmission:
      case OrderStatus.buyAwaitingSubmission:
        // 待提交材料订单24小时后自动处理
        autoMaterialTime = _baseTime.add(const Duration(hours: 24));
        break;
        
      case OrderStatus.awaitingStart:
        // 等待开始状态，卖家需要在48小时内接单
        autoMaterialTime = _baseTime.add(const Duration(hours: 48));
        break;
        
      case OrderStatus.awaitingDelivery:
        // 等待交付状态，根据deliveryDay设置截止时间
        // 假设已经接单2天了，还剩余时间
        final deliveryDays = 3 + orderId % 5; // 3-7天交付
        autoMaterialTime = _baseTime.add(Duration(days: deliveryDays - 2));
        break;
        
      case OrderStatus.awaitingConfirmation:
        // 待确认收货订单，发货时间设为2天前，7天后自动确认
        deliveryTimestamp = _baseTime.subtract(const Duration(days: 2));
        break;
        
      case OrderStatus.sellerSupplementaryMaterials:
        // 卖家补充材料状态，发货时间设为5天前，需要重新交付
        deliveryTimestamp = _baseTime.subtract(const Duration(days: 5));
        autoMaterialTime = _baseTime.add(const Duration(days: 2)); // 2天内重新交付
        break;
        
      case OrderStatus.awaitingEvaluation:
        // 已收货但未评价，收货时间设为3天前
        deliveryTimestamp = _baseTime.subtract(const Duration(days: 3));
        break;
        
      case OrderStatus.orderCompleted:
        // 已完成订单，收货时间设为7天前
        deliveryTimestamp = _baseTime.subtract(const Duration(days: 7));
        break;
        
      case OrderStatus.afterSale:
      case OrderStatus.AfterSaleRejection:
      case OrderStatus.applyingForMediation:
        // 售后相关状态，收货时间设为10天前
        deliveryTimestamp = _baseTime.subtract(const Duration(days: 10));
        break;
        
      default:
        break;
    }
    
    // 创建买家和卖家信息
    const buyer = Member(
      id: 1001,
      nickname: '测试买家',
      avatar: 'https://picsum.photos/100/100?random=buyer',
      mobile: '138****8000',
    );
    
    final seller = Member(
      id: 2000 + orderId % 3,
      nickname: '设计师${orderId % 3 + 1}号',
      avatar: 'https://picsum.photos/100/100?random=seller$orderId',
      shopName: '创意设计工作室${orderId % 3 + 1}',
      mobile: '139****${9000 + orderId % 3}',
    );
    
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
          deliveryDay: 3 + orderId % 5, // 3-7天交付
          editNum: 2, // 可修改2次
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
      buyer: buyer,
      tenant: seller,
      autoCancelTime: autoCancelTime,
      autoMaterialTime: autoMaterialTime,
      deliveryTimestamp: deliveryTimestamp,
      evaluate: status == OrderStatus.awaitingEvaluation ? false : (status == OrderStatus.orderCompleted ? true : null),
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