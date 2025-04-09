import 'package:equatable/equatable.dart';

import 'message.dart';

/// 聊天会话实体类
///
/// 表示一个聊天会话，包含会话基本信息和最后一条消息
class ChatSession extends Equatable {
  /// 会话唯一标识符
  final String id;
  
  /// 会话标题
  final String title;
  
  /// 当前用户ID
  final String currentUserId;
  
  /// 对方用户ID
  final String targetUserId;
  
  /// 最后一条消息
  final Message? lastMessage;
  
  /// 未读消息数量
  final int unreadCount;
  
  /// 会话创建时间
  final DateTime createdAt;
  
  /// 会话更新时间
  final DateTime updatedAt;
  
  /// 是否置顶 (本地状态)
  final bool isPinned;
  
  /// 是否静音 (本地状态)
  final bool isMuted;

  /// 创建一个聊天会话实体
  const ChatSession({
    required this.id,
    required this.title,
    required this.currentUserId,
    required this.targetUserId,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isMuted = false,
  });
  
  /// 创建空会话实例
  factory ChatSession.empty() {
    return ChatSession(
      id: '',
      title: '',
      currentUserId: '',
      targetUserId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// 获取pinned状态，兼容旧代码
  bool get pinned => isPinned;
  
  /// 创建此会话的副本，但部分字段替换为新值
  ChatSession copyWith({
    String? id,
    String? title,
    String? currentUserId,
    String? targetUserId,
    Message? lastMessage,
    bool clearLastMessage = false,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isMuted,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      currentUserId: currentUserId ?? this.currentUserId,
      targetUserId: targetUserId ?? this.targetUserId,
      lastMessage: clearLastMessage ? null : (lastMessage ?? this.lastMessage),
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
    );
  }
  
  /// 使用新消息更新会话
  ChatSession withMessage(Message message, {bool isUnread = false}) {
    // 如果没有最后一条消息或者新消息的时间晚于最后一条消息
    final shouldUpdateLastMessage = lastMessage == null || 
        message.timestamp.isAfter(lastMessage!.timestamp);
    
    return copyWith(
      lastMessage: shouldUpdateLastMessage ? message : null,
      updatedAt: shouldUpdateLastMessage ? message.timestamp : null,
      unreadCount: isUnread ? unreadCount + 1 : unreadCount,
    );
  }
  
  /// 将未读消息计数更新为0
  ChatSession markAsRead() {
    return copyWith(unreadCount: 0);
  }
  
  /// 判断会话是否有未读消息
  bool get hasUnread => unreadCount > 0;
  
  /// 获取用于排序的时间
  /// 
  /// 优先使用最后一条消息的时间，如果没有则使用会话更新时间
  DateTime get sortTime => lastMessage?.timestamp ?? updatedAt;
  
  /// 获取会话显示的最后消息内容预览
  String get lastMessagePreview {
    if (lastMessage == null) {
      return '';
    }
    
    switch (lastMessage!.type) {
      case MessageType.text:
        return lastMessage!.content;
      case MessageType.image:
        return '[图片]';
      case MessageType.audio:
        return '[语音]';
      case MessageType.video:
        return '[视频]';
      case MessageType.file:
        return '[文件]';
      case MessageType.system:
        return '[系统消息]';
      default:
        return '';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    currentUserId,
    targetUserId,
    lastMessage,
    unreadCount,
    createdAt,
    updatedAt,
    isPinned,
    isMuted,
  ];
} 