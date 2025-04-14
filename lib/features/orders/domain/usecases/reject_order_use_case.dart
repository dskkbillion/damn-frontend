import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for the seller to reject an order, likely by adding a refusal demand.
/// Requires AddOrderDemandParams which should be defined in i_order_repository.dart
/// TODO: Determine if this UseCase should construct the AddOrderDemandParams or receive it.
/// For now, let's assume it just needs orderId and constructs a basic refusal param internally,
/// or maybe it should be AddOrderDemandUseCase instead of RejectOrderUseCase.
@injectable
class RejectOrderUseCase implements UseCase<void, int> { // Simplified Params for now
  final IOrderRepository repository;

  RejectOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    // TODO: Construct appropriate AddOrderDemandParams for refusal
    // Example:
    final params = AddOrderDemandParams(
      orderId: orderId, 
      type: 'refuse', // Standard refusal type?
      reasonValue: 'seller_reject', // Example reason code
      reasonLabel: '卖家拒绝接单', // Example reason text
      // remarks: null,
      );
    return await repository.addOrderDemand(params);
  }
} 