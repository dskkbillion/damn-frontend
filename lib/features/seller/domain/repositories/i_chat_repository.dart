import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';

/// 聊天会话模型
class ChatSession extends Equatable {
  /// 会话ID
  final int id;
  
  /// 会话标题
  final String title;
  
  /// 用户ID
  final int userId;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 构造函数
  const ChatSession({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object> get props => [id, title, userId, createdAt, updatedAt];
  
  /// 转换为JSON格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }
}

/// 聊天仓库接口
abstract class IChatRepository {
  /// 获取聊天室列表
  Future<Either<Failure, List<ChatSession>>> getChatRoomList(int userId);
  
  /// 创建聊天室
  Future<Either<Failure, ChatSession>> createChatRoom(int userId, {String? title});
  
  /// 获取聊天消息列表
  Future<Either<Failure, List<dynamic>>> getChatMessages(int conversationId);
} 