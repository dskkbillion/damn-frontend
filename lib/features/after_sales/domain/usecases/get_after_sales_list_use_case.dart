import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/after_sales_application.dart';
import '../repositories/i_after_sales_repository.dart';


@injectable
class GetAfterSalesListUseCase
    implements UseCase<List<AfterSalesApplication>, GetAfterSalesListParams> {
  final IAfterSalesRepository repository;

  GetAfterSalesListUseCase(this.repository);

  @override
  Future<Either<Failure, List<AfterSalesApplication>>> call(
      GetAfterSalesListParams params) async {
    return await repository.getAfterSalesList(params);
  }
} 