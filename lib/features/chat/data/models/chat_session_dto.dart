import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chat_enums.dart';
import '../../domain/entities/chat_session.dart';
import 'message_dto.dart';

part 'chat_session_dto.g.dart';

/// 聊天会话数据传输对象
///
/// 用于在API和应用之间传输会话数据
@JsonSerializable()
class ChatSessionDto {
  /// 会话唯一标识符
  final String id;
  
  /// 会话标题
  final String title;
  
  /// 当前用户ID
  @JsonKey(name: 'user_id')
  final String userId;
  
  /// 对方用户ID
  @JsonKey(name: 'target_user_id')
  final String targetUserId;
  
  /// 最后一条消息DTO
  @JsonKey(name: 'last_message')
  final MessageDto? lastMessageDto;
  
  /// 未读消息数量
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  
  /// 会话创建时间
  @JsonKey(name: 'created_at')
  final String createdAt;
  
  /// 会话更新时间
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  
  /// 会话状态
  final String status;

  /// 创建一个会话DTO
  const ChatSessionDto({
    required this.id,
    required this.title,
    required this.userId,
    required this.targetUserId,
    this.lastMessageDto,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  /// 从JSON创建会话DTO
  factory ChatSessionDto.fromJson(Map<String, dynamic> json) => 
      _$ChatSessionDtoFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ChatSessionDtoToJson(this);

  /// 从实体创建DTO
  factory ChatSessionDto.fromEntity(ChatSession session) {
    return ChatSessionDto(
      id: session.id,
      title: session.title,
      userId: session.userId,
      targetUserId: session.targetUserId,
      lastMessageDto: session.lastMessage != null 
          ? MessageDto.fromEntity(session.lastMessage!) 
          : null,
      unreadCount: session.unreadCount,
      createdAt: session.createdAt.toIso8601String(),
      updatedAt: session.updatedAt.toIso8601String(),
      status: _sessionStatusToString(session.status),
    );
  }

  /// 转换为实体
  ChatSession toEntity() {
    return ChatSession(
      id: id,
      title: title,
      userId: userId,
      targetUserId: targetUserId,
      lastMessage: lastMessageDto?.toEntity(),
      unreadCount: unreadCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      status: _stringToSessionStatus(status),
      // 本地状态默认为false，需要从本地缓存补充
      pinned: false,
      muted: false,
    );
  }

  // 枚举转换工具方法
  static String _sessionStatusToString(SessionStatus status) {
    switch (status) {
      case SessionStatus.ACTIVE:
        return 'active';
      case SessionStatus.ARCHIVED:
        return 'archived';
      case SessionStatus.BLOCKED:
        return 'blocked';
    }
  }

  static SessionStatus _stringToSessionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SessionStatus.ACTIVE;
      case 'archived':
        return SessionStatus.ARCHIVED;
      case 'blocked':
        return SessionStatus.BLOCKED;
      default:
        return SessionStatus.ACTIVE; // 默认为活跃
    }
  }
} 