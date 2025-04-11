import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

@injectable
class SubmitRequirementsUseCase implements UseCase<void, SubmitRequirementsParams> {
  final IOrderRepository repository;

  SubmitRequirementsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SubmitRequirementsParams params) async {
    // Call the actual repository method
    print('[SubmitRequirementsUseCase] Calling repository.submitRequirements...');
    return await repository.submitRequirements(
      orderId: params.orderId,
      requirementsData: params.requirementsData,
      attachmentPaths: params.attachmentPaths,
    );
  }
}

class SubmitRequirementsParams extends Equatable {
  final String orderId;
  final Map<String, String> requirementsData;
  final List<String> attachmentPaths;

  const SubmitRequirementsParams({
    required this.orderId,
    required this.requirementsData,
    required this.attachmentPaths,
  });

  @override
  List<Object?> get props => [orderId, requirementsData, attachmentPaths];
} 