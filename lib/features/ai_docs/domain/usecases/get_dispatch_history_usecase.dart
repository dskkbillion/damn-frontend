import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/allocated_item_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

/// 获取某 conversation 的已分发商品历史(#347)。
class GetDispatchHistoryUseCase
    implements UseCase<List<AllocatedItemEntity>, GetDispatchHistoryParams> {
  final IAiChatRepository repository;

  GetDispatchHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<AllocatedItemEntity>>> call(
    GetDispatchHistoryParams params,
  ) async {
    return repository.getDispatchHistory(
      conversationId: params.conversationId,
      userId: params.userId,
    );
  }
}

class GetDispatchHistoryParams extends Equatable {
  final int conversationId;
  final int userId;

  const GetDispatchHistoryParams({
    required this.conversationId,
    required this.userId,
  });

  @override
  List<Object?> get props => [conversationId, userId];
}
