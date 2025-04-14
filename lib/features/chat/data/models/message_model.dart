import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/message.dart';
import './user_model.dart'; // 引入 UserModel

part 'message_model.g.dart';

/// API `/api/chat/message/list` 和 `/common/chat/message/add` 的消息数据模型
@JsonSerializable(explicitToJson: true)
class MessageModel {
  final int id;
  final int chatId;
  final int? doctorId;
  final int? memberId;
  final String context;

  @JsonKey(name: 'type') // API 返回的字段名是 type
  final String typeString;

  final bool? readFlg; // 发送时可能为 null
  final int? recipientId; // 发送时后端自动填充
  final int? messageNum; // 意义不明，暂不使用
  final bool? withdrawFlag; // 发送时为 null
  final bool? senderDelFlag; // 发送时为 null
  final bool? receiverDelFlag; // 发送时为 null
  final UserModel? member;
  final UserModel? doctor;

  @JsonKey(fromJson: _dateTimeFromString, toJson: _dateTimeToString)
  final DateTime? createTime; // 发送时为 null，接收时从 String 转换

  MessageModel({
    required this.id,
    required this.chatId,
    this.doctorId,
    this.memberId,
    required this.context,
    required this.typeString,
    this.readFlg,
    this.recipientId,
    this.messageNum,
    this.withdrawFlag,
    this.senderDelFlag,
    this.receiverDelFlag,
    this.member,
    this.doctor,
    this.createTime,
  });

  /// 从 JSON 数据创建 MessageModel 实例
  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  /// 将 MessageModel 实例转换为 JSON 数据
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  /// 将 MessageModel 转换为 Domain 层的 Message 实体
  Message toEntity() {
    // 确保必要的字段不为空，或提供默认值
    if (createTime == null) {
       print("Warning: createTime is null for message id: $id. Using current time.");
    }

    return Message(
      id: id,
      chatId: chatId,
      doctorId: doctorId,
      memberId: memberId,
      context: context,
      typeString: typeString,
      readFlg: readFlg ?? false, // 默认为 false
      recipientId: recipientId ?? -1, // 提供默认值或确保非空
      withdrawFlag: withdrawFlag ?? false,
      senderDelFlag: senderDelFlag ?? false,
      receiverDelFlag: receiverDelFlag ?? false,
      member: member?.toEntity(),
      doctor: doctor?.toEntity(),
      createTime: createTime ?? DateTime.now(), // 提供默认值
      // localId 和 sendStatus 是 Domain 层维护的，这里不处理
    );
  }

  /// 从 Domain 层的 Message 实体创建 MessageModel (主要用于发送请求)
  factory MessageModel.fromEntity(Message entity) {
    // 注意：这个转换只包含发送消息 (/common/chat/message/add) 所需的关键字段
    // id, createTime 等字段在发送时不提供
    return MessageModel(
      id: entity.id, // 发送时不使用，但构造函数需要
      chatId: entity.chatId,
      context: entity.context,
      typeString: entity.typeString,
      // doctorId, memberId 等发送者信息由后端根据 token 判断，这里不传
      // readFlg, recipientId, flags 等由后端处理
    );
  }

  // Helper functions for DateTime conversion
  static DateTime? _dateTimeFromString(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString).toLocal(); // 假设 API 返回的是 UTC 或可解析格式
    } catch (e) {
      print("Error parsing date string: $dateString. Error: $e");
      return null;
    }
  }

  static String? _dateTimeToString(DateTime? dateTime) {
    return dateTime?.toUtc().toIso8601String(); // 发送时转换为 UTC ISO8601 格式
  }
} 