import 'package:equatable/equatable.dart';

/// 订单创建结果
class OrderCreationResult extends Equatable {
  /// 订单ID
  final String orderId;
  
  /// 支付信息字符串(支付宝)
  final String orderInfo;
  
  /// 订单总价
  final double totalAmount;
  
  const OrderCreationResult({
    required this.orderId,
    required this.orderInfo,
    required this.totalAmount,
  });
  
  @override
  List<Object?> get props => [orderId, orderInfo, totalAmount];
} 