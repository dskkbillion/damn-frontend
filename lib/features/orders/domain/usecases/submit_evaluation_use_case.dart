import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_order_repository.dart';

/// Use case for submitting an order evaluation.
@injectable
class SubmitEvaluationUseCase implements UseCase<void, SubmitEvaluationParams> {
  final IOrderRepository repository;

  SubmitEvaluationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitEvaluationParams params) async {
    print('[SubmitEvaluationUseCase] Called with orderId: ${params.orderId}');
    // Ensure repository method gets a non-nullable list
    return await repository.addEvaluation(
      orderId: params.orderId,
      score: params.score,
      content: params.content,
      isAnonymous: params.isAnonymous,
      pictures: params.pictures ?? [], // Handle potential null
    );
  }
}

/// Parameters for the SubmitEvaluationUseCase.
class SubmitEvaluationParams extends Equatable {
  final int orderId;
  final double score;
  final String content;
  final bool isAnonymous;
  final List<String>? pictures; // Optional

  const SubmitEvaluationParams({
    required this.orderId,
    required this.score,
    required this.content,
    required this.isAnonymous,
    this.pictures,
  });

  @override
  List<Object?> get props => [
        orderId,
        score,
        content,
        isAnonymous,
        pictures,
      ];
} 