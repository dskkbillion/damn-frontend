import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_after_sales_repository.dart';

class GetRefundIdByOrderIdParams extends Equatable {
  final int orderId;

  const GetRefundIdByOrderIdParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

@injectable
class GetRefundIdByOrderIdUseCase implements UseCase<int?, GetRefundIdByOrderIdParams> {
  final IAfterSalesRepository repository;

  GetRefundIdByOrderIdUseCase(this.repository);

  @override
  Future<Either<Failure, int?>> call(GetRefundIdByOrderIdParams params) async {
    return await repository.getRefundIdByOrderId(params.orderId);
  }
}