import 'package:equatable/equatable.dart';

/// 通知类型枚举
enum NotificationType {
  /// 订单相关通知
  order('ORDER', '订单通知'),
  
  /// 系统通知
  system('SYSTEM', '系统通知'),
  
  /// 消息通知
  message('MESSAGE', '消息通知'),
  
  /// 售后通知
  refund('REFUND', '售后通知'),
  
  /// 评价通知
  review('REVIEW', '评价通知'),
  
  /// 认证通知
  authentication('AUTHENTICATION', '认证通知'),
  
  /// 其他通知
  other('OTHER', '其他通知');

  /// 通知类型的API值
  final String value;
  
  /// 通知类型的显示名称
  final String displayName;

  const NotificationType(this.value, this.displayName);

  /// 从API值获取枚举
  static NotificationType fromValue(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.other,
    );
  }
}

/// 卖家通知实体
class SellerNotification extends Equatable {
  /// 通知ID
  final String notificationId;
  
  /// 通知类型
  final NotificationType type;
  
  /// 通知标题
  final String title;
  
  /// 通知内容
  final String content;
  
  /// 是否已读
  final bool isRead;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 关联实体ID (订单ID, 聊天ID等)
  final String? relatedEntityId;

  const SellerNotification({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.relatedEntityId,
  });

  @override
  List<Object?> get props => [
    notificationId,
    type,
    title,
    content,
    isRead,
    createdAt,
    relatedEntityId,
  ];
  
  /// 创建已读版本的通知
  SellerNotification markAsRead() {
    return SellerNotification(
      notificationId: notificationId,
      type: type,
      title: title,
      content: content,
      isRead: true,
      createdAt: createdAt,
      relatedEntityId: relatedEntityId,
    );
  }
} 