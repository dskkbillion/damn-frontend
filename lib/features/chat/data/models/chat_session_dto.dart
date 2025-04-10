import 'package:equatable/equatable.dart';
import '../../domain/entities/entities.dart';
import 'message_dto.dart';

/// 会话数据传输对象
class ChatSessionDto extends Equatable {
  /// 会话ID
  final String id;
  
  /// 会话标题
  final String title;
  
  /// 用户ID
  final String userId;
  
  /// 对方用户ID (可能需要从其他字段推导)
  final String? targetUserId;
  
  /// 最后一条消息
  final MessageDto? lastMessage;
  
  /// 未读消息数
  final int unreadCount;
  
  /// 创建时间（毫秒）
  final int createdAt;
  
  /// 更新时间（毫秒）
  final int updatedAt;

  const ChatSessionDto({
    required this.id,
    required this.title,
    required this.userId,
    this.targetUserId,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON映射创建DTO
  factory ChatSessionDto.fromJson(Map<String, dynamic> json) {
    // 解析最后一条消息
    MessageDto? lastMsg;
    if (json['last_message'] != null) {
      lastMsg = MessageDto.fromJson(json['last_message']);
    }
    
    // 解析对方用户ID (可能需要从参与者列表或其他字段推导)
    String? targetId = json['target_user_id'] ?? json['partner_id'];
    
    return ChatSessionDto(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      userId: json['user_id'] ?? '',
      targetUserId: targetId,
      lastMessage: lastMsg,
      unreadCount: json['unread_count'] ?? json['total'] ?? 0,
      createdAt: json['created_at'] ?? DateTime.now().millisecondsSinceEpoch,
      updatedAt: json['updated_at'] ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      if (targetUserId != null) 'target_user_id': targetUserId,
      if (lastMessage != null) 'last_message': lastMessage!.toJson(),
      'unread_count': unreadCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 转换为领域实体
  ChatSession toDomain() {
    return ChatSession(
      id: id,
      userId: userId,
      targetUserId: targetUserId ?? '',
      title: title,
      lastMessage: lastMessage?.toDomain(),
      unreadCount: unreadCount,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      // 本地状态都设置为默认值
      pinned: false,
      muted: false,
    );
  }

  /// 从领域实体创建DTO
  factory ChatSessionDto.fromDomain(ChatSession session) {
    return ChatSessionDto(
      id: session.id,
      title: session.title,
      userId: session.userId,
      targetUserId: session.targetUserId,
      lastMessage: session.lastMessage != null 
          ? MessageDto.fromDomain(session.lastMessage!) 
          : null,
      unreadCount: session.unreadCount,
      createdAt: session.createdAt.millisecondsSinceEpoch,
      updatedAt: session.updatedAt.millisecondsSinceEpoch,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    userId,
    targetUserId,
    lastMessage,
    unreadCount,
    createdAt,
    updatedAt,
  ];
} 