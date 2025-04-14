import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/chat_session.dart';
import './message_model.dart';
import './user_model.dart';

part 'chat_session_model.g.dart';

/// API `/api/chat/list` 的会话数据模型
@JsonSerializable(explicitToJson: true)
class ChatSessionModel {
  final int id;
  final int? doctorId;
  final int? memberId;
  final int? messageNum; // API 返回可能为 null
  final String? context;
  final MessageModel? chatMessageNewVo;
  final UserModel? member;
  final UserModel? doctor;

  ChatSessionModel({
    required this.id,
    this.doctorId,
    this.memberId,
    this.messageNum,
    this.context,
    this.chatMessageNewVo,
    this.member,
    this.doctor,
  });

  /// 从 JSON 数据创建 ChatSessionModel 实例
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionModelFromJson(json);

  /// 将 ChatSessionModel 实例转换为 JSON 数据
  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);

  /// 将 ChatSessionModel 转换为 Domain 层的 ChatSession 实体
  ChatSession toEntity() {
    return ChatSession(
      id: id,
      doctorId: doctorId,
      memberId: memberId,
      messageNum: messageNum ?? 0, // 默认为 0
      context: context,
      chatMessageNewVo: chatMessageNewVo?.toEntity(),
      member: member?.toEntity(),
      doctor: doctor?.toEntity(),
    );
  }

  /// 从 Domain 层的 ChatSession 实体创建 ChatSessionModel
  /// 注意：这通常用于测试或特定场景，因为实体可能不包含所有模型字段
  factory ChatSessionModel.fromEntity(ChatSession entity) {
    return ChatSessionModel(
      id: entity.id,
      doctorId: entity.doctorId,
      memberId: entity.memberId,
      messageNum: entity.messageNum,
      context: entity.context,
      chatMessageNewVo: entity.chatMessageNewVo != null
          ? MessageModel.fromEntity(entity.chatMessageNewVo!)
          : null,
      member: entity.member != null ? UserModel.fromEntity(entity.member!) : null,
      doctor: entity.doctor != null ? UserModel.fromEntity(entity.doctor!) : null,
    );
  }
} 