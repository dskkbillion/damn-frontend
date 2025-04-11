import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveRequirementDraftUseCase implements UseCase<void, SaveRequirementDraftParams> {
  final IOrderRepository repository;

  SaveRequirementDraftUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveRequirementDraftParams params) async {
    // Call the actual repository method
    print('[SaveRequirementDraftUseCase] Calling repository.saveRequirementDraft...');
    return await repository.saveRequirementDraft(
      orderId: params.orderId,
      requirementsData: params.requirementsData,
      attachmentPaths: params.attachmentPaths,
    );
  }
}

class SaveRequirementDraftParams extends Equatable {
  final String orderId;
  final Map<String, String> requirementsData;
  final List<String> attachmentPaths;

  const SaveRequirementDraftParams({
    required this.orderId,
    required this.requirementsData,
    required this.attachmentPaths,
  });

  @override
  List<Object?> get props => [orderId, requirementsData, attachmentPaths];
} 