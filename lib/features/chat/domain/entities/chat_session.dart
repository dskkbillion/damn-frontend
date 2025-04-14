import 'package:equatable/equatable.dart';

import './message.dart';
import './user.dart';

/// 聊天会话实体 (字段严格参考 chat_api.openapi.json -> /api/chat/list response.rows[x])
class ChatSession extends Equatable {
  /// 会话 ID
  final int id;

  /// 对方用户 ID (如果对方是 "doctor")
  final int? doctorId;

  /// 对方用户 ID (如果对方是 "member")
  final int? memberId;

  /// 未读消息数
  final int messageNum;

  /// 最后一条消息内容预览
  final String? context;

  /// 最后一条消息详情 (可能为 null)
  final Message? chatMessageNewVo;

  /// 对方用户信息 (如果对方是 "member")
  final User? member;

  /// 对方用户信息 (如果对方是 "doctor")
  final User? doctor;

  const ChatSession({
    required this.id,
    this.doctorId,
    this.memberId,
    required this.messageNum,
    this.context,
    this.chatMessageNewVo,
    this.member,
    this.doctor,
  });

  /// 获取对方用户信息 (优先 doctor)
  User? get targetUser => doctor ?? member;

  /// 获取对方用户 ID (优先 doctorId)
  int? get targetUserId => doctorId ?? memberId;

  /// 获取最后一条消息的时间戳
  DateTime? get lastMessageTimestamp => chatMessageNewVo?.createTime;

  @override
  List<Object?> get props => [
        id,
        doctorId,
        memberId,
        messageNum,
        context,
        chatMessageNewVo,
        member,
        doctor,
      ];

  /// 创建副本并更新部分字段
  ChatSession copyWith({
    int? id,
    int? doctorId,
    int? memberId,
    int? messageNum,
    String? context,
    Message? chatMessageNewVo,
    bool clearChatMessageNewVo = false, // 用于显式设置 chatMessageNewVo 为 null
    User? member,
    User? doctor,
  }) {
    return ChatSession(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      memberId: memberId ?? this.memberId,
      messageNum: messageNum ?? this.messageNum,
      context: context ?? this.context,
      chatMessageNewVo: clearChatMessageNewVo ? null : (chatMessageNewVo ?? this.chatMessageNewVo),
      member: member ?? this.member,
      doctor: doctor ?? this.doctor,
    );
  }
} 