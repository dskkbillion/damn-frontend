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
  final String? paymentMethod;
  
  const PayingState({
    required this.orderId,
    this.paymentMethod,
  });
  
  @override
  List<Object?> get props => [orderId, paymentMethod];
}

/// 支付完成状态
class PaymentCompletedState extends PaymentState {
  final String orderId;
  final String? paymentMethod;
  
  const PaymentCompletedState({
    required this.orderId,
    this.paymentMethod,
  });
  
  @override
  List<Object?> get props => [orderId, paymentMethod];
}

/// 支付失败状态
class PaymentFailedState extends PaymentState {
  final String errorMessage;
  final String? orderId;
  final String? paymentMethod;
  
  const PaymentFailedState({
    required this.errorMessage,
    this.orderId,
    this.paymentMethod,
  });
  
  @override
  List<Object?> get props => [errorMessage, orderId, paymentMethod];
}

/// 支付方式已更改状态
class PaymentMethodChangedState extends PaymentState {
  final String paymentMethod;
  
  const PaymentMethodChangedState({
    required this.paymentMethod,
  });
  
  @override
  List<Object?> get props => [paymentMethod];
} 