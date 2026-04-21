import 'package:dskk_flutter_refactor/features/seller/domain/entities/notification.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';

/// 通知模型类
class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.type,
    required super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: _parseNotificationType(json['type'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'isRead': isRead,
    };
  }

  /// 解析通知类型
  static NotificationType _parseNotificationType(String type) {
    return NotificationType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => NotificationType.other,
    );
  }
} 