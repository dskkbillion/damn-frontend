part of 'order_delivery_bloc.dart';

/// 订单交付状态基类
abstract class OrderDeliveryState extends Equatable {
  /// 构造函数
  const OrderDeliveryState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class OrderDeliveryInitial extends OrderDeliveryState {}

/// 表单状态
class OrderDeliveryFormState extends OrderDeliveryState {
  /// 订单ID
  final int orderId;
  
  /// 交付内容
  final String content;
  
  /// 附件文件路径列表
  final List<String> files;

  /// 构造函数
  const OrderDeliveryFormState({
    required this.orderId,
    required this.content,
    required this.files,
  });

  @override
  List<Object?> get props => [orderId, content, files];

  /// 复制构造函数
  OrderDeliveryFormState copyWith({
    int? orderId,
    String? content,
    List<String>? files,
  }) {
    return OrderDeliveryFormState(
      orderId: orderId ?? this.orderId,
      content: content ?? this.content,
      files: files ?? this.files,
    );
  }
}

/// 提交中状态
class OrderDeliverySubmitting extends OrderDeliveryState {}

/// 提交成功状态
class OrderDeliverySuccess extends OrderDeliveryState {}

/// 错误状态
class OrderDeliveryError extends OrderDeliveryState {
  /// 错误信息
  final String message;

  /// 构造函数
  const OrderDeliveryError(this.message);

  @override
  List<Object?> get props => [message];
} 