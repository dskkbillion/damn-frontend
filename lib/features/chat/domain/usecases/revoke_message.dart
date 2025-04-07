import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../entities/message.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 撤回消息参数
class RevokeMessageParams extends Equatable {
  /// 要撤回的消息ID
  final String messageId;

  /// 创建撤回消息参数
  const RevokeMessageParams({required this.messageId});

  @override
  List<Object> get props => [messageId];
}

/// 撤回消息用例
///
/// 负责撤回已发送的消息，将消息状态改为已撤回
class RevokeMessageUseCase implements UseCase<Either<ChatFailure, Message>, RevokeMessageParams> {
  final IChatRepository _chatRepository;

  /// 创建撤回消息用例
  ///
  /// [chatRepository] 聊天仓库接口
  const RevokeMessageUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, Message>> call(RevokeMessageParams params) async {
    return _chatRepository.revokeMessage(messageId: params.messageId);
  }
} 