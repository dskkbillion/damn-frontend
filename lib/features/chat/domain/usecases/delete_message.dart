import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import 'usecase.dart';

/// 删除消息参数
class DeleteMessageParams extends Equatable {
  /// 要删除的消息ID
  final String messageId;

  /// 创建删除消息参数
  const DeleteMessageParams({required this.messageId});

  @override
  List<Object> get props => [messageId];
}

/// 删除消息用例
///
/// 负责删除指定的聊天消息
class DeleteMessageUseCase implements UseCase<Either<ChatFailure, bool>, DeleteMessageParams> {
  final IChatRepository _chatRepository;

  /// 创建删除消息用例
  ///
  /// [chatRepository] 聊天仓库接口
  const DeleteMessageUseCase(this._chatRepository);

  @override
  Future<Either<ChatFailure, bool>> call(DeleteMessageParams params) async {
    return _chatRepository.deleteMessage(messageId: params.messageId);
  }
} 