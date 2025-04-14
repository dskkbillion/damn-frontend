import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for the seller to delete their record of an order.
@injectable
class DeleteSellerRecordUseCase implements UseCase<void, int> {
  final IOrderRepository repository;

  DeleteSellerRecordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return await repository.deleteSellerOrderRecord(orderId);
  }
} 