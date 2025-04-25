import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';

/// 通知DTO模型
class NotificationDto {
  /// 通知ID
  final String? id;
  
  /// 通知类型
  final String? messageType;
  
  /// 通知标题
  final String? title;
  
  /// 通知内容
  final String? content;
  
  /// 是否已读
  final bool? read;
  
  /// 创建时间
  final String? createTime;
  
  /// 关联实体ID
  final String? relatedId;

  /// 构造函数
  NotificationDto({
    this.id,
    this.messageType,
    this.title,
    this.content,
    this.read,
    this.createTime,
    this.relatedId,
  });

  /// 从JSON构造
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id']?.toString(),
      messageType: json['messageType'],
      title: json['title'],
      content: json['content'],
      read: json['read'] ?? false,
      createTime: json['createTime'],
      relatedId: json['relatedId']?.toString(),
    );
  }

  /// 转换为领域实体
  SellerNotification toEntity() {
    // 解析创建时间字符串为DateTime对象
    DateTime parsedCreateTime;
    if (createTime != null) {
      try {
        parsedCreateTime = DateTime.parse(createTime!);
      } catch (e) {
        // 如果解析失败，使用当前时间
        parsedCreateTime = DateTime.now();
      }
    } else {
      parsedCreateTime = DateTime.now();
    }
    
    // 解析通知类型
    NotificationType notificationType = NotificationType.fromValue(
      messageType ?? 'OTHER'
    );
    
    return SellerNotification(
      notificationId: id ?? '',
      type: notificationType,
      title: title ?? '未知通知',
      content: content ?? '',
      isRead: read ?? false,
      createdAt: parsedCreateTime,
      relatedEntityId: relatedId,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (id != null) data['id'] = id;
    if (messageType != null) data['messageType'] = messageType;
    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (read != null) data['read'] = read;
    if (createTime != null) data['createTime'] = createTime;
    if (relatedId != null) data['relatedId'] = relatedId;
    
    return data;
  }
} 