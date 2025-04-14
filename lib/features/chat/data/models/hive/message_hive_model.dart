import 'package:hive/hive.dart';

import '../../../domain/entities/enums.dart';
import '../../../domain/entities/message.dart';
import './user_hive_model.dart';

part 'message_hive_model.g.dart';

@HiveType(typeId: 1) // typeId 需要在项目中唯一
class MessageHiveModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int chatId;

  @HiveField(2)
  final int? doctorId;

  @HiveField(3)
  final int? memberId;

  @HiveField(4)
  final String context;

  @HiveField(5)
  final String typeString; // 存储原始字符串

  @HiveField(6)
  final bool readFlg;

  @HiveField(7)
  final int recipientId;

  @HiveField(8)
  final bool withdrawFlag;

  @HiveField(9)
  final bool senderDelFlag;

  @HiveField(10)
  final bool receiverDelFlag;

  @HiveField(11)
  final UserHiveModel? member;

  @HiveField(12)
  final UserHiveModel? doctor;

  @HiveField(13)
  final DateTime createTime;

  @HiveField(14)
  final String? localId;

  @HiveField(15)
  final int sendStatusIndex; // 存储枚举的 index

  @HiveField(16)
  final double? fileUploadProgress;

  MessageHiveModel({
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
    required this.sendStatusIndex,
    this.fileUploadProgress,
  });

  /// 从 Domain Entity 创建 Hive Model
  factory MessageHiveModel.fromEntity(Message entity) {
    return MessageHiveModel(
      id: entity.id,
      chatId: entity.chatId,
      doctorId: entity.doctorId,
      memberId: entity.memberId,
      context: entity.context,
      typeString: entity.typeString,
      readFlg: entity.readFlg,
      recipientId: entity.recipientId,
      withdrawFlag: entity.withdrawFlag,
      senderDelFlag: entity.senderDelFlag,
      receiverDelFlag: entity.receiverDelFlag,
      member: entity.member != null ? UserHiveModel.fromEntity(entity.member!) : null,
      doctor: entity.doctor != null ? UserHiveModel.fromEntity(entity.doctor!) : null,
      createTime: entity.createTime,
      localId: entity.localId,
      sendStatusIndex: entity.sendStatus.index,
      fileUploadProgress: entity.fileUploadProgress,
    );
  }

  /// 转换为 Domain Entity
  Message toEntity() {
    return Message(
      id: id,
      chatId: chatId,
      doctorId: doctorId,
      memberId: memberId,
      context: context,
      typeString: typeString,
      readFlg: readFlg,
      recipientId: recipientId,
      withdrawFlag: withdrawFlag,
      senderDelFlag: senderDelFlag,
      receiverDelFlag: receiverDelFlag,
      member: member?.toEntity(),
      doctor: doctor?.toEntity(),
      createTime: createTime,
      localId: localId,
      sendStatus: MessageSendStatus.values[sendStatusIndex],
      fileUploadProgress: fileUploadProgress,
    );
  }
} 