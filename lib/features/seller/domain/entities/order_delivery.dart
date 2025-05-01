import 'package:equatable/equatable.dart';

/// 订单交付实体
class OrderDelivery extends Equatable {
  /// 交付ID
  final int? id;
  
  /// 订单ID
  final int orderId;
  
  /// 交付内容（文本描述）
  final String content;
  
  /// 附件文件URLs
  final List<String> files;
  
  /// 创建时间
  final DateTime? createdAt;
  
  /// 构造函数
  const OrderDelivery({
    this.id,
    required this.orderId,
    required this.content,
    required this.files,
    this.createdAt,
  });
  
  @override
  List<Object?> get props => [id, orderId, content, files, createdAt];
  
  /// 创建副本并更新部分字段
  OrderDelivery copyWith({
    int? id,
    int? orderId,
    String? content,
    List<String>? files,
    DateTime? createdAt,
  }) {
    return OrderDelivery(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      content: content ?? this.content,
      files: files ?? this.files,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 