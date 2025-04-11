import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_after_sales_repository.dart';


@injectable
class ApplyForAfterSalesUseCase implements UseCase<int, ApplyAfterSalesParams> {
  final IAfterSalesRepository repository;

  ApplyForAfterSalesUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(ApplyAfterSalesParams params) async {
    // Input validation could happen here if needed, before calling repo.
    return await repository.applyForAfterSales(params);
  }
} 