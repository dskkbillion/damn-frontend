import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/related_service_entity.dart';
import '../repositories/i_ai_chat_repository.dart';

/// {@template get_related_services_usecase}
/// Use case for fetching related service recommendations.
/// {@endtemplate}
@lazySingleton
class GetRelatedServicesUseCase 
    implements UseCase<List<RelatedServiceEntity>, GetRelatedServicesParams> {
      
  final IAiChatRepository repository;

  /// {@macro get_related_services_usecase}
  GetRelatedServicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<RelatedServiceEntity>>> call(
      GetRelatedServicesParams params) async {
    return await repository.getRelatedServices(
      conversationId: params.conversationId,
      userId: params.userId,
      limit: params.limit,
      messageId: params.messageId,
    );
  }
}

/// {@template get_related_services_params}
/// Parameters required for fetching related services.
/// {@endtemplate}
class GetRelatedServicesParams extends Equatable {
  final int conversationId;
  final int userId;
  final int? limit;
  final int? messageId;

  /// {@macro get_related_services_params}
  const GetRelatedServicesParams({
    required this.conversationId,
    required this.userId,
    this.limit,
    this.messageId,
  });

  @override
  List<Object?> get props => [conversationId, userId, limit, messageId];
} 