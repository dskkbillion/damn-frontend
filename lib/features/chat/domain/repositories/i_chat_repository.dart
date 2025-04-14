import 'dart:io';

import 'package:dartz/dartz.dart';

import '../entities/chat_session.dart';
import '../entities/failure.dart';
import '../entities/message.dart';

/// 聊天仓库接口
abstract class IChatRepository {
  /// 获取当前用户的聊天会话列表。
  ///
  /// 返回 `Failure` 如果获取失败。
  Future<Either<Failure, List<ChatSession>>> getChatSessions();

  /// 监听聊天会话列表的变化。
  ///
  /// 每当会话列表（例如最后一条消息、未读数）发生变化时，流会发出新的列表。
  /// 如果监听过程中发生错误，流会发出错误。
  Stream<Either<Failure, List<ChatSession>>> observeChatSessions();

  /// 获取指定会话的消息列表。
  ///
  /// [chatId] 是要获取消息的会话 ID。
  /// 注意：根据 API 定义，此接口获取该会话的所有历史消息，不支持分页。
  /// 返回 `Failure` 如果获取失败。
  Future<Either<Failure, List<Message>>> getMessages(int chatId);

  /// 发送一条新的消息。
  ///
  /// [message] 是要发送的消息实体。通常需要包含 `chatId`, `context`, `type`。
  /// 对于媒体消息，`context` 应为上传后的文件 URL。
  /// 发送前，应将消息以 `sendStatus: MessageSendStatus.sending` 状态添加到本地缓存/UI。
  ///
  /// 成功时返回包含服务器分配的 `id` 和 `createTime` 的完整 `Message` 对象。
  /// 返回 `Failure` 如果发送失败。
  Future<Either<Failure, Message>> sendMessage(Message message);

  /// 撤回一条已发送的消息。
  ///
  /// [messageId] 是要撤回的消息的服务器 ID。
  /// 返回 `Failure` 如果撤回失败（例如超时、无权限）。
  Future<Either<Failure, void>> revokeMessage(int messageId);

  /// 标记指定会话为已读。
  ///
  /// [chatId] 是要标记为已读的会话 ID。
  /// 注意：API 并未直接提供标记已读的接口，此操作的实现可能涉及更新本地状态，
  /// 或者依赖于进入会话获取消息列表时服务器自动处理。
  /// 返回 `Failure` 如果操作失败。
  Future<Either<Failure, void>> markSessionAsRead(int chatId);

  /// 创建或获取与目标用户的聊天会话。
  ///
  /// [targetUserId] 是要聊天的对方用户的 ID。
  /// 后端 API (/api/chat/addChat) 需要 `doctorId` 参数，这里需要根据 `targetUserId` 的类型判断。
  ///
  /// 成功时返回会话的 `chatId`。
  /// 返回 `Failure` 如果创建或获取失败。
  Future<Either<Failure, int>> createChatSession(int targetUserId);

  /// 上传文件（如图片、语音）。
  ///
  /// [file] 是要上传的本地文件。
  /// [onProgress] 是一个可选的回调函数，用于报告上传进度 (0.0 - 1.0)。
  ///
  /// 成功时返回文件在服务器上的 URL。
  /// 返回 `Failure` 如果上传失败。
  Future<Either<Failure, String>> uploadFile(File file, {Function(double)? onProgress});
} 