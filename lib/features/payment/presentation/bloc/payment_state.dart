import 'package:equatable/equatable.dart';

/// 支付状态抽象类
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class PaymentInitial extends PaymentState {}

/// 创建订单中状态
class CreatingOrderState extends PaymentState {}

/// 支付中状态
class PayingState extends PaymentState {
  final String orderId;
  
  const PayingState({
    required this.orderId,
  });
  
  @override
  List<Object?> get props => [orderId];
}

/// 支付完成状态
class PaymentCompletedState extends PaymentState {
  final String orderId;
  
  const PaymentCompletedState({
    required this.orderId,
  });
  
  @override
  List<Object?> get props => [orderId];
}

/// 支付失败状态
class PaymentFailedState extends PaymentState {
  final String errorMessage;
  final String? orderId;
  
  const PaymentFailedState({
    required this.errorMessage,
    this.orderId,
  });
  
  @override
  List<Object?> get props => [errorMessage, orderId];
}

/// 外部支付处理中状态（如Stripe跳转）
class ExternalPaymentProcessingState extends PaymentState {
  final String orderId;
  final String paymentUrl;
  
  const ExternalPaymentProcessingState({
    required this.orderId,
    required this.paymentUrl,
  });
  
  @override
  List<Object?> get props => [orderId, paymentUrl];
} 