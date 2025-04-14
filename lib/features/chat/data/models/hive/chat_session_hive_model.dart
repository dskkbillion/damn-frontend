import 'package:hive/hive.dart';

import '../../../domain/entities/chat_session.dart';
import './message_hive_model.dart';
import './user_hive_model.dart';

part 'chat_session_hive_model.g.dart';

@HiveType(typeId: 0) // typeId 需要在项目中唯一
class ChatSessionHiveModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int? doctorId;

  @HiveField(2)
  final int? memberId;

  @HiveField(3)
  final int messageNum;

  @HiveField(4)
  final String? context;

  @HiveField(5)
  final MessageHiveModel? chatMessageNewVo;

  @HiveField(6)
  final UserHiveModel? member;

  @HiveField(7)
  final UserHiveModel? doctor;

  // Hive 不直接支持 DateTime?，但 chatMessageNewVo.createTime 可以用于排序

  ChatSessionHiveModel({
    required this.id,
    this.doctorId,
    this.memberId,
    required this.messageNum,
    this.context,
    this.chatMessageNewVo,
    this.member,
    this.doctor,
  });

  /// 从 Domain Entity 创建 Hive Model
  factory ChatSessionHiveModel.fromEntity(ChatSession entity) {
    return ChatSessionHiveModel(
      id: entity.id,
      doctorId: entity.doctorId,
      memberId: entity.memberId,
      messageNum: entity.messageNum,
      context: entity.context,
      chatMessageNewVo: entity.chatMessageNewVo != null
          ? MessageHiveModel.fromEntity(entity.chatMessageNewVo!)
          : null,
      member: entity.member != null ? UserHiveModel.fromEntity(entity.member!) : null,
      doctor: entity.doctor != null ? UserHiveModel.fromEntity(entity.doctor!) : null,
    );
  }

  /// 转换为 Domain Entity
  ChatSession toEntity() {
    return ChatSession(
      id: id,
      doctorId: doctorId,
      memberId: memberId,
      messageNum: messageNum,
      context: context,
      chatMessageNewVo: chatMessageNewVo?.toEntity(),
      member: member?.toEntity(),
      doctor: doctor?.toEntity(),
    );
  }
} 