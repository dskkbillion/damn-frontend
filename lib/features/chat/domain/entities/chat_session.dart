import 'package:equatable/equatable.dart';
import 'message.dart';

/// 会话实体类
class ChatSession extends Equatable {
  /// 会话唯一标识
  final String id;
  
  /// 当前用户ID
  final String userId;
  
  /// 对方用户ID
  final String targetUserId;
  
  /// 会话标题/名称 (通常是对方用户名)
  final String title;
  
  /// 最后一条消息
  final Message? lastMessage;
  
  /// 未读消息数
  final int unreadCount;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 是否置顶 (本地状态) [TODO: 下一次开发中实现]
  final bool pinned;
  
  /// 是否静音 (本地状态) [TODO: 下一次开发中实现]
  final bool muted;

  const ChatSession({
    required this.id,
    required this.userId,
    required this.targetUserId,
    required this.title,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.pinned = false,
    this.muted = false,
  });

  /// 复制并返回一个新的会话对象，可更新指定字段
  ChatSession copyWith({
    String? id,
    String? userId,
    String? targetUserId,
    String? title,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? pinned,
    bool? muted,
  }) {
    return ChatSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      targetUserId: targetUserId ?? this.targetUserId,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pinned: pinned ?? this.pinned,
      muted: muted ?? this.muted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    targetUserId,
    title,
    lastMessage,
    unreadCount,
    createdAt,
    updatedAt,
    pinned,
    muted,
  ];
} 