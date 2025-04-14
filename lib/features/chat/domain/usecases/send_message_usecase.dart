import 'dart:io';
import 'package:dartz/dartz.dart';

import '../entities/enums.dart';
import '../entities/failure.dart';
import '../entities/message.dart';
import '../repositories/i_chat_repository.dart';

/// 发送消息用例。
/// 处理文本消息和文件消息（图片、语音等）的发送。
class SendMessageUseCase {
  final IChatRepository _repository;

  SendMessageUseCase(this._repository);

  /// 调用此 UseCase 发送消息。
  ///
  /// [params] 包含要发送的消息信息。
  /// 对于文本消息，`params.text` 不为空。
  /// 对于文件消息，`params.file` 不为空。
  ///
  /// **流程**:
  /// 1. 生成本地消息实体 (`Message`)，状态为 `sending`，包含 `localId`。
  /// 2. (可选) 将本地消息添加到本地缓存/UI。
  /// 3. 如果是文件消息，先调用 `_repository.uploadFile` 上传文件。
  /// 4. 获取文件 URL (或使用文本内容) 填充 `Message` 的 `context`。
  /// 5. 调用 `_repository.sendMessage` 发送消息。
  /// 6. 成功后，使用返回的服务器消息更新本地消息状态为 `sent`。
  /// 7. 失败后，更新本地消息状态为 `failed`。
  ///
  /// **注意**: 此 UseCase 内部不直接返回最终的 `Message`，
  /// 调用者应通过监听本地状态或 `ObserveMessagesUseCase` 来获取消息更新。
  /// 这里返回上传或发送操作的结果。
  ///
  /// 成功时返回 `Right(null)`。
  /// 失败时返回 `Left(Failure)`。
  Future<Either<Failure, Message>> call(SendMessageParams params) async {
    // 1. (在 Bloc/Presenter 中) 创建本地 Message 对象 (status: sending, localId)
    //    - 需要当前用户信息来填充 senderId 等字段。
    //    - 添加到 UI 列表。

    String messageContext;
    Message messageToSend = params.initialLocalMessage;

    try {
      // 3. 处理文件上传 (如果需要)
      if (params.file != null) {
        // 模拟文件上传进度更新 (实际应由 Repository 实现)
        // _updateLocalMessageProgress(params.initialLocalMessage.localId, 0.5);

        final uploadResult = await _repository.uploadFile(
          params.file!,
          // onProgress: (progress) {
          //   _updateLocalMessageProgress(params.initialLocalMessage.localId, progress);
          // },
        );

        // 处理上传结果
        return uploadResult.fold(
          (failure) {
            // 上传失败，更新本地消息状态为 failed
            // _updateLocalMessageStatus(params.initialLocalMessage.localId, MessageSendStatus.failed);
            return Left(failure);
          },
          (fileUrl) {
            messageContext = fileUrl; // 使用上传后的 URL 作为 context
            // _updateLocalMessageProgress(params.initialLocalMessage.localId, 1.0);
            messageToSend = messageToSend.copyWith(context: messageContext);
            // 继续发送消息
            return _sendMessageInternal(messageToSend);
          },
        );
      } else if (params.text != null) {
        messageContext = params.text!;
        messageToSend = messageToSend.copyWith(context: messageContext);
        // 直接发送文本消息
        return _sendMessageInternal(messageToSend);
      } else {
        return Left(Failure('Invalid message parameters: text or file must be provided.'));
      }
    } catch (e, s) {
      // 捕获未知异常
      // _updateLocalMessageStatus(params.initialLocalMessage.localId, MessageSendStatus.failed);
      return Left(Failure('Failed to send message: ${e.toString()}', error: e, stackTrace: s));
    }
  }

  /// 内部方法，实际调用 repository 发送消息
  Future<Either<Failure, Message>> _sendMessageInternal(Message message) async {
    final sendResult = await _repository.sendMessage(message);

    // 处理发送结果
    // sendResult.fold(
    //   (failure) => _updateLocalMessageStatus(message.localId, MessageSendStatus.failed),
    //   (sentMessage) => _updateLocalMessageStatus(message.localId, MessageSendStatus.sent, serverMessage: sentMessage),
    // );

    return sendResult;
  }

  // --- 辅助方法 (实际应在 Bloc/Presenter 中实现) ---
  // void _updateLocalMessageStatus(String? localId, MessageSendStatus status, {Message? serverMessage}) {
  //   // 更新本地状态管理中的消息状态
  // }
  //
  // void _updateLocalMessageProgress(String? localId, double progress) {
  //   // 更新本地状态管理中的消息上传进度
  // }
}

/// SendMessageUseCase 的参数
class SendMessageParams {
  /// 初始的本地消息实体 (包含 chatId, typeString, localId, status=sending)
  final Message initialLocalMessage;

  /// 要发送的文本内容 (文本消息时提供)
  final String? text;

  /// 要发送的本地文件 (文件消息时提供)
  final File? file;

  SendMessageParams({
    required this.initialLocalMessage,
    this.text,
    this.file,
  }) : assert(text != null || file != null, 'Either text or file must be provided.');
} 