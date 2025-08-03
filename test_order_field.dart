import 'package:dskk_flutter_refactor/features/orders/domain/entities/order.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_status.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/address.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_price_summary.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_payment_info.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/entities/order_shipping_info.dart';

void main() {
  // 测试创建一个带有autoOrderReceivinTime的订单
  final testOrder = Order(
    id: 1,
    orderSn: 'TEST001',
    state: OrderStatus.awaitingStart,
    items: [],
    shippingAddress: const Address(
      recipientName: 'Test',
      phone: '123456',
      areaId: '1',
      detailAddress: 'Test Address'
    ),
    priceSummary: const OrderPriceSummary(
      totalPrice: 100,
      discountPrice: 0,
      deliveryPrice: 0,
      payPrice: 100
    ),
    paymentInfo: const OrderPaymentInfo(),
    shippingInfo: const OrderShippingInfo(),
    createdAt: DateTime.now(),
    autoOrderReceivinTime: DateTime.now().add(const Duration(hours: 48)),
  );
  
  print('Order created successfully');
  print('Order state: ${testOrder.state}');
  print('Auto order receiving time: ${testOrder.autoOrderReceivinTime}');
}