import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_notification.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

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
    try {
      // 尝试从JSON字符串中解析标题和内容
      String extractedTitle = '未知通知';
      String extractedContent = '';
      
      // 先尝试直接从顶级字段获取title和content
      if (json['title'] != null) {
        extractedTitle = json['title'].toString();
      }
      
      if (json['content'] != null) {
        extractedContent = json['content'].toString();
      }
      
      // 检查可能包含JSON结构的字段
      final possibleJsonFields = ['message', 'content'];
      
      for (final field in possibleJsonFields) {
        if (json[field] != null) {
          final fieldValue = json[field].toString();
          
          // 检查是否包含{title: xxx, content: yyy}格式
          if (fieldValue.contains('{title:') || fieldValue.contains('title:')) {
            // 尝试解析title
            final titleRegex = RegExp(r'[{]?title:\s*([^,}]+)');
            final titleMatch = titleRegex.firstMatch(fieldValue);
            
            if (titleMatch != null && titleMatch.groupCount >= 1) {
              final title = titleMatch.group(1)?.trim();
              if (title != null && title.isNotEmpty) {
                extractedTitle = title.replaceAll('"', '').replaceAll("'", "");
              }
            }
            
            // 尝试解析content
            final contentRegex = RegExp(r'content:\s*([^}]+)');
            final contentMatch = contentRegex.firstMatch(fieldValue);
            
            if (contentMatch != null && contentMatch.groupCount >= 1) {
              final content = contentMatch.group(1)?.trim();
              if (content != null && content.isNotEmpty) {
                extractedContent = content.replaceAll('"', '').replaceAll("'", "");
              }
            }
          }
        }
      }
      
      return NotificationDto(
        id: json['id']?.toString(),
        messageType: json['messageType']?.toString(),
        title: extractedTitle,
        content: extractedContent,
        read: json['read'] == true || json['read'] == 1 || json['read'] == 'true',
        createTime: json['createTime']?.toString(),
        relatedId: json['relatedId']?.toString(),
      );
    } catch (e) {
      AppLogger.d('Error parsing NotificationDto: $e for json: $json');
      // 返回一个有默认值的对象而不是抛出异常
      return NotificationDto(
        id: '0',
        messageType: 'OTHER',
        title: '解析错误',
        content: '无法解析通知数据',
        read: false,
        createTime: DateTime.now().toIso8601String(),
      );
    }
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