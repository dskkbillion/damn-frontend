import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import '../repositories/i_chat_repository.dart';

// Use case definition
abstract class RevokeMessage implements UseCase<void, RevokeMessageParams> {}

// Implementation
class RevokeMessageImpl implements RevokeMessage {
  final IChatRepository repository;

  RevokeMessageImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(RevokeMessageParams params) async {
    return await repository.revokeMessage(params.messageId);
  }
}

// Parameters
class RevokeMessageParams extends Equatable {
  final int messageId;

  const RevokeMessageParams({required this.messageId});

  @override
  List<Object?> get props => [messageId];
} 