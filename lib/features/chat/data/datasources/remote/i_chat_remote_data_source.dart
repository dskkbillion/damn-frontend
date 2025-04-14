import 'dart:io';

import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

/// 远程数据源接口，定义与聊天相关的 API 调用
abstract class IChatRemoteDataSource {
  /// 获取当前用户的聊天会话列表
  /// API: POST /api/chat/list
  Future<List<ChatSessionModel>> getChatSessions();

  /// 获取指定会话的消息列表
  /// API: POST /api/chat/message/list
  /// Body: { "chatId": chatId }
  Future<List<MessageModel>> getMessages(int chatId);

  /// 发送消息
  /// API: POST /common/chat/message/add
  /// Body: { "chatId": chatId, "context": context, "type": typeString }
  Future<MessageModel> sendMessage({
    required int chatId,
    required String context,
    required String typeString,
  });

  /// 撤回消息
  /// API: POST /api/chat/message/withdraw
  /// Body: { "id": messageId }
  Future<void> revokeMessage(int messageId);

  /// 创建或获取聊天会话
  /// API: POST /api/chat/addChat
  /// Body: { "doctorId": targetUserId } // 注意 API 参数名是 doctorId
  Future<int> createChatSession(int targetUserId);

  /// 获取当前用户信息 (包含 commonUserId)
  /// API: GET /api/member/info
  Future<UserModel> getCurrentUserInfo();

  /// 上传文件
  /// API: POST /api/common/public/upload (假设这是通用上传接口)
  /// Body: multipart/form-data with 'file' field
  Future<String> uploadFile(File file, {Function(double)? onProgress});
} 