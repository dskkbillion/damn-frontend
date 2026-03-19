import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_after_sales_repository.dart';


@injectable
class CancelAfterSalesUseCase implements UseCase<void, int> {
  final IAfterSalesRepository repository;

  CancelAfterSalesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int refundId) async {
    // Parameter validation could be added here.
    return await repository.cancelAfterSales(refundId);
  }
}
