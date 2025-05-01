import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_after_sales_repository.dart';


@injectable
class DeleteAfterSalesUseCase implements UseCase<void, List<int>> {
  final IAfterSalesRepository repository;

  DeleteAfterSalesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<int> refundIds) async {
    // Parameter validation (e.g., list not empty) could be added here.
    if (refundIds.isEmpty) {
      // Consider returning a specific validation failure or just success
      return const Right(null); // Or Left(ValidationFailure(...))
    }
    return await repository.deleteAfterSales(refundIds);
  }
} 