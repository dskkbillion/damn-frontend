import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/chat_allocation_result_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template allocate_chat_resource_usecase}
/// Use case for triggering a chat allocation action (/chat/allocate).
/// {@endtemplate}
@lazySingleton
class AllocateChatResourceUseCase 
    implements UseCase<ChatAllocationResultEntity, AllocateChatResourceParams> {
      
  final IAiChatRepository repository;

  /// {@macro allocate_chat_resource_usecase}
  AllocateChatResourceUseCase(this.repository);

  @override
  Future<Either<Failure, ChatAllocationResultEntity>> call(
      AllocateChatResourceParams params) async {
    // TODO: Add validation for parameters once they are confirmed.
    return await repository.allocateChatResource(
      conversationId: params.conversationId,
      userId: params.userId,
      item: params.item,
      merchantId: params.merchantId,
    );
  }
}

/// {@template allocate_chat_resource_params}
/// Parameters required for allocating a chat resource.
/// {@endtemplate}
class AllocateChatResourceParams extends Equatable {
  final int conversationId;
  final int userId;
  final Map<String, dynamic> item;
  final int merchantId;

  /// {@macro allocate_chat_resource_params}
  const AllocateChatResourceParams({
    required this.conversationId,
    required this.userId,
    required this.item,
    required this.merchantId,
  });

  @override
  List<Object?> get props => [
        conversationId,
        userId,
        item,
        merchantId,
      ];
} 