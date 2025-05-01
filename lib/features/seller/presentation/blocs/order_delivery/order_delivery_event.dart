part of 'order_delivery_bloc.dart';

/// 订单交付事件基类
abstract class OrderDeliveryEvent extends Equatable {
  /// 构造函数
  const OrderDeliveryEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化订单交付表单事件
class InitOrderDelivery extends OrderDeliveryEvent {
  /// 订单ID
  final int orderId;

  /// 构造函数
  const InitOrderDelivery({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// 内容变更事件
class ContentChanged extends OrderDeliveryEvent {
  /// 新的内容
  final String content;

  /// 构造函数
  const ContentChanged({required this.content});

  @override
  List<Object?> get props => [content];
}

/// 添加文件事件
class AddFile extends OrderDeliveryEvent {
  /// 文件路径
  final String filePath;

  /// 构造函数
  const AddFile({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// 移除文件事件
class RemoveFile extends OrderDeliveryEvent {
  /// 文件索引
  final int index;

  /// 构造函数
  const RemoveFile({required this.index});

  @override
  List<Object?> get props => [index];
}

/// 清空文件事件
class ClearFiles extends OrderDeliveryEvent {}

/// 提交订单交付事件
class SubmitOrderDelivery extends OrderDeliveryEvent {}

/// 重置表单事件
class ResetForm extends OrderDeliveryEvent {} 