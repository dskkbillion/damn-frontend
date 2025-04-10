import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';
import 'message_dto.dart';

/// 聊天消息模型类
/// 用于消息数据的转换和处理
class ChatMessageModel extends Equatable {
  final MessageDto dto;

  const ChatMessageModel({required this.dto});

  /// 从DTO创建模型
  factory ChatMessageModel.fromDto(MessageDto dto) {
    return ChatMessageModel(dto: dto);
  }

  /// 从领域实体创建模型
  factory ChatMessageModel.fromDomain(Message message) {
    return ChatMessageModel(dto: MessageDto.fromDomain(message));
  }

  /// 从JSON映射创建模型
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(dto: MessageDto.fromJson(json));
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return dto.toJson();
  }

  /// 转换为领域实体
  Message toDomain() {
    return dto.toDomain();
  }

  @override
  List<Object?> get props => [dto];
} 