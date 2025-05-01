import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

@injectable
class SubmitRequirementsUseCase implements UseCase<void, SubmitRequirementsParams> {
  final IOrderRepository repository;

  SubmitRequirementsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitRequirementsParams params) async {
    // Delegate the call to the repository
    return await repository.submitRequirements(params);
  }
}

/// Parameters required for the SubmitRequirementsUseCase.
class SubmitRequirementsParams extends Equatable {
  final String orderId; // Keep as String to match event/UI for now?
                     // Or align everywhere to int if possible.
                     // Repository method might need int.
  final int productId;
  final List<Map<String, String>> feature;
  final List<String> attachmentPaths;

  const SubmitRequirementsParams({
    required this.orderId,
    required this.productId,
    required this.feature,
    required this.attachmentPaths,
  });

  @override
  List<Object?> get props => [orderId, productId, feature, attachmentPaths];
} 