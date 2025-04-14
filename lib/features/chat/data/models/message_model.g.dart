// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: (json['id'] as num).toInt(),
      chatId: (json['chatId'] as num).toInt(),
      doctorId: (json['doctorId'] as num?)?.toInt(),
      memberId: (json['memberId'] as num?)?.toInt(),
      context: json['context'] as String,
      typeString: json['type'] as String,
      readFlg: json['readFlg'] as bool?,
      recipientId: (json['recipientId'] as num?)?.toInt(),
      messageNum: (json['messageNum'] as num?)?.toInt(),
      withdrawFlag: json['withdrawFlag'] as bool?,
      senderDelFlag: json['senderDelFlag'] as bool?,
      receiverDelFlag: json['receiverDelFlag'] as bool?,
      member: json['member'] == null
          ? null
          : UserModel.fromJson(json['member'] as Map<String, dynamic>),
      doctor: json['doctor'] == null
          ? null
          : UserModel.fromJson(json['doctor'] as Map<String, dynamic>),
      createTime:
          MessageModel._dateTimeFromString(json['createTime'] as String?),
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'doctorId': instance.doctorId,
      'memberId': instance.memberId,
      'context': instance.context,
      'type': instance.typeString,
      'readFlg': instance.readFlg,
      'recipientId': instance.recipientId,
      'messageNum': instance.messageNum,
      'withdrawFlag': instance.withdrawFlag,
      'senderDelFlag': instance.senderDelFlag,
      'receiverDelFlag': instance.receiverDelFlag,
      'member': instance.member?.toJson(),
      'doctor': instance.doctor?.toJson(),
      'createTime': MessageModel._dateTimeToString(instance.createTime),
    };
