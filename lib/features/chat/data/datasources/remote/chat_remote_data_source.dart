import 'dart:io';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart'; // Assuming core failure definition
import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart'; // Assuming a UserModel for user info

/// 抽象类：定义与聊天相关的远程数据操作
abstract class IChatRemoteDataSource {
  /// 获取当前登录用户的详细信息 (特别是 commonUserId)
  Future<Either<Failure, UserModel>> getCurrentUserInfo();

  /// 获取聊天会话列表
  Future<Either<Failure, List<ChatSessionModel>>> getChatSessions();

  /// 获取指定会话的消息列表
  /// API 不支持分页，返回指定 chatId 的所有消息
  Future<Either<Failure, List<MessageModel>>> getMessages(int chatId);

  /// 发送消息
  /// - type: 'text', 'image', 'audio', etc.
  /// - context: 文本内容或上传后的文件 URL
  Future<Either<Failure, MessageModel>> sendMessage({
    required int chatId,
    required String type,
    required String context,
  });

  /// 撤回消息
  Future<Either<Failure, void>> revokeMessage(int messageId);

  /// 创建或获取聊天会话
  /// API 参数为 doctorId (对方用户ID)
  Future<Either<Failure, int>> createChatSession(int targetUserId);

  /// 上传文件 (图片、语音等)
  /// 返回文件在服务器上的 URL
  Future<Either<Failure, String>> uploadFile(File file, {Function(double progress)? onProgress});
} 