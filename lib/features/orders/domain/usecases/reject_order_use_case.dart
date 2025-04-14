import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for adding a demand to an order, often used by the seller to reject an order.
/// Requires [AddOrderDemandParams] containing the order ID, demand type, reason, and optional remarks.
@injectable
class RejectOrderUseCase implements UseCase<void, AddOrderDemandParams> { // Changed Params from int to AddOrderDemandParams
  final IOrderRepository repository;

  RejectOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddOrderDemandParams params) async { // Changed parameter from orderId to params
    // Directly use the provided params object
    return await repository.addOrderDemand(params);
  }
} 