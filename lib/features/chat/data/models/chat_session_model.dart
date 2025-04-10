import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_session.dart';
import 'chat_session_dto.dart';

/// 聊天会话模型类
/// 用于会话数据的转换和处理
class ChatSessionModel extends Equatable {
  final ChatSessionDto dto;

  const ChatSessionModel({required this.dto});

  /// 从DTO创建模型
  factory ChatSessionModel.fromDto(ChatSessionDto dto) {
    return ChatSessionModel(dto: dto);
  }

  /// 从领域实体创建模型
  factory ChatSessionModel.fromDomain(ChatSession session) {
    return ChatSessionModel(dto: ChatSessionDto.fromDomain(session));
  }

  /// 从JSON映射创建模型
  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(dto: ChatSessionDto.fromJson(json));
  }

  /// 转换为JSON映射
  Map<String, dynamic> toJson() {
    return dto.toJson();
  }

  /// 转换为领域实体
  ChatSession toDomain() {
    return dto.toDomain();
  }

  @override
  List<Object?> get props => [dto];
} 