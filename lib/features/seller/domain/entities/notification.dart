import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/notification_type.dart';

/// 通知实体类
class Notification extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  
  const Notification({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.type,
    required this.isRead,
  });
  
  @override
  List<Object?> get props => [id, title, content, createdAt, type, isRead];
  
  Notification copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    NotificationType? type,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
} 