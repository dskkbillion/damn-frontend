import 'package:mockito/mockito.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dartz/dartz.dart';

// 聊天会话模型
class ChatSession {
  final int id;
  final String title;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  ChatSession({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  
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

// Mock聊天仓库接口
abstract class IChatRepository {
  Future<Either<Failure, List<ChatSession>>> getChatRoomList(int userId);
  Future<Either<Failure, ChatSession>> createChatRoom(int userId, {String? title});
  Future<Either<Failure, List<dynamic>>> getChatMessages(int conversationId);
}

class MockChatRepository extends Mock implements IChatRepository {
  @override
  Future<Either<Failure, List<ChatSession>>> getChatRoomList(int userId) async {
    // 模拟聊天会话列表
    final now = DateTime.now();
    return Right([
      ChatSession(
        id: 1001,
        title: '买家一号',
        userId: userId,
        createdAt: now.subtract(Duration(days: 2)),
        updatedAt: now.subtract(Duration(hours: 2)),
      ),
      ChatSession(
        id: 1002,
        title: '买家二号',
        userId: userId,
        createdAt: now.subtract(Duration(days: 1)),
        updatedAt: now.subtract(Duration(hours: 1)),
      ),
      ChatSession(
        id: 1003,
        title: '客服中心',
        userId: userId,
        createdAt: now.subtract(Duration(days: 10)),
        updatedAt: now.subtract(Duration(days: 5)),
      ),
    ]);
  }
  
  @override
  Future<Either<Failure, ChatSession>> createChatRoom(int userId, {String? title}) async {
    final now = DateTime.now();
    return Right(ChatSession(
      id: 1004,
      title: title ?? '新的聊天',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    ));
  }
  
  @override
  Future<Either<Failure, List<dynamic>>> getChatMessages(int conversationId) async {
    // 模拟聊天消息列表
    final now = DateTime.now();
    return Right([
      {
        'id': 101,
        'conversation_id': conversationId,
        'sender_id': 12345, // 卖家ID
        'content': '您好，有什么可以帮您?',
        'created_at': now.subtract(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'is_read': true,
      },
      {
        'id': 102,
        'conversation_id': conversationId,
        'sender_id': 54321, // 买家ID
        'content': '我想了解一下这个商品的详情',
        'created_at': now.subtract(Duration(minutes: 55)).millisecondsSinceEpoch ~/ 1000,
        'is_read': true,
      },
      {
        'id': 103,
        'conversation_id': conversationId,
        'sender_id': 12345, // 卖家ID
        'content': '好的，您可以看看商品描述，有任何疑问随时问我',
        'created_at': now.subtract(Duration(minutes: 50)).millisecondsSinceEpoch ~/ 1000,
        'is_read': true,
      },
    ]);
  }
} 