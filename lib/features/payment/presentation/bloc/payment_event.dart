import 'package:equatable/equatable.dart';

/// 支付事件抽象类
abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

/// 创建订单并支付事件
class CreateOrderAndPayEvent extends PaymentEvent {
  final int productId;
  final int variantId;
  final int quantity;
  final int sellerId;
  final double price;
  final String productName;
  final String? imageUrl;
  final String paymentMethod;

  const CreateOrderAndPayEvent({
    required this.productId,
    required this.variantId,
    required this.quantity,
    required this.sellerId,
    required this.price,
    required this.productName,
    this.imageUrl,
    this.paymentMethod = 'alipay',
  });

  @override
  List<Object?> get props => [
    productId,
    variantId,
    quantity,
    sellerId,
    price,
    productName,
    imageUrl,
    paymentMethod,
  ];
}

/// 直接支付已有订单事件
class DirectPayEvent extends PaymentEvent {
  final String orderId;
  final String paymentMethod;

  const DirectPayEvent({
    required this.orderId,
    this.paymentMethod = 'alipay',
  });

  @override
  List<Object?> get props => [orderId, paymentMethod];
}

/// 重置支付状态事件
class ResetPaymentEvent extends PaymentEvent {}

/// 切换支付方式事件
class ChangePaymentMethodEvent extends PaymentEvent {
  final String paymentMethod;

  const ChangePaymentMethodEvent({
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [paymentMethod];
} 