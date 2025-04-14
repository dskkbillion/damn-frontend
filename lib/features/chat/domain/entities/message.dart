import 'package:equatable/equatable.dart';

import './enums.dart';
import './user.dart';

/// 消息实体 (字段严格参考 chat_api.openapi.json -> /api/chat/message/list response.rows[x])
class Message extends Equatable {
  /// 消息 ID (来自服务器)
  final int id;

  /// 所属会话 ID
  final int chatId;

  /// 发送者 ID (如果发送者是 "doctor")
  final int? doctorId;

  /// 发送者 ID (如果发送者是 "member")
  final int? memberId;

  /// 消息内容 (文本或媒体 URL)
  final String context;

  /// 消息类型 (来自服务器的字符串, 需要映射为 MessageType)
  final String typeString; // API 返回的是字符串 'text', 'image', 'audio'

  /// 是否已读
  final bool readFlg;

  /// 接收者 ID
  final int recipientId;

  /// 是否已撤回
  final bool withdrawFlag;

  /// 发送者是否删除
  final bool senderDelFlag;

  /// 接收者是否删除
  final bool receiverDelFlag;

  /// 发送者信息 (如果发送者是 "member")
  final User? member;

  /// 发送者信息 (如果发送者是 "doctor")
  final User? doctor;

  /// 消息创建时间 (需要从服务器返回的 String 转换)
  final DateTime createTime;

  // --- 本地维护字段 ---

  /// 本地生成的唯一 ID (用于发送中的消息或无法立即获取服务器 ID 的情况)
  final String? localId;

  /// 消息发送状态 (本地维护)
  final MessageSendStatus sendStatus;

  /// 文件上传进度 (本地维护, 0.0 - 1.0)
  final double? fileUploadProgress;

  const Message({
    required this.id,
    required this.chatId,
    this.doctorId,
    this.memberId,
    required this.context,
    required this.typeString,
    required this.readFlg,
    required this.recipientId,
    required this.withdrawFlag,
    required this.senderDelFlag,
    required this.receiverDelFlag,
    this.member,
    this.doctor,
    required this.createTime,
    this.localId,
    this.sendStatus = MessageSendStatus.none,
    this.fileUploadProgress,
  });

  /// 根据 typeString 获取对应的 MessageType 枚举
  MessageType get messageType {
    switch (typeString.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'audio':
        return MessageType.audio;
      default:
        return MessageType.unknown;
    }
  }

  /// 获取发送者的 User 对象 (优先 doctor)
  User? get sender => doctor ?? member;

  /// 获取发送者的 ID (优先 doctorId)
  int? get senderId => doctorId ?? memberId;

  /// 判断消息是否由当前用户发送 (需要传入当前用户 ID)
  bool isSentByCurrentUser(int currentUserId) {
    return memberId == currentUserId || doctorId == currentUserId; // 假设 memberId 和 doctorId 不会同时是当前用户
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        doctorId,
        memberId,
        context,
        typeString,
        readFlg,
        recipientId,
        withdrawFlag,
        senderDelFlag,
        receiverDelFlag,
        member,
        doctor,
        createTime,
        localId,
        sendStatus,
        fileUploadProgress,
      ];

  /// 创建副本并更新部分字段
  Message copyWith({
    int? id,
    int? chatId,
    int? doctorId,
    int? memberId,
    String? context,
    String? typeString,
    bool? readFlg,
    int? recipientId,
    bool? withdrawFlag,
    bool? senderDelFlag,
    bool? receiverDelFlag,
    User? member,
    User? doctor,
    DateTime? createTime,
    String? localId,
    MessageSendStatus? sendStatus,
    double? fileUploadProgress,
    bool clearFileUploadProgress = false,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      doctorId: doctorId ?? this.doctorId,
      memberId: memberId ?? this.memberId,
      context: context ?? this.context,
      typeString: typeString ?? this.typeString,
      readFlg: readFlg ?? this.readFlg,
      recipientId: recipientId ?? this.recipientId,
      withdrawFlag: withdrawFlag ?? this.withdrawFlag,
      senderDelFlag: senderDelFlag ?? this.senderDelFlag,
      receiverDelFlag: receiverDelFlag ?? this.receiverDelFlag,
      member: member ?? this.member,
      doctor: doctor ?? this.doctor,
      createTime: createTime ?? this.createTime,
      localId: localId ?? this.localId,
      sendStatus: sendStatus ?? this.sendStatus,
      fileUploadProgress: clearFileUploadProgress ? null : fileUploadProgress ?? this.fileUploadProgress,
    );
  }
} 