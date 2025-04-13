import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/failures.dart';
import '../../repositories/i_order_repository.dart';

// --- Confirm Order Acceptance Use Case ---

abstract class IConfirmOrderAcceptanceUseCase {
  Future<Either<Failure, void>> call(int orderId);
}

@Injectable(as: IConfirmOrderAcceptanceUseCase)
class ConfirmOrderAcceptanceUseCase implements IConfirmOrderAcceptanceUseCase {
  final IOrderRepository _repository;

  ConfirmOrderAcceptanceUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return await _repository.confirmOrderAcceptance(orderId);
  }
}

// --- Add Order Demand Use Case ---

abstract class IAddOrderDemandUseCase {
  Future<Either<Failure, void>> call(AddOrderDemandParams params);
}

@Injectable(as: IAddOrderDemandUseCase)
class AddOrderDemandUseCase implements IAddOrderDemandUseCase {
  final IOrderRepository _repository;

  AddOrderDemandUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(AddOrderDemandParams params) async {
    // Add any specific business logic/validation for adding demand here if needed
    return await _repository.addOrderDemand(params);
  }
}

// --- Deliver Order Use Case ---

abstract class IDeliverOrderUseCase {
  Future<Either<Failure, void>> call(DeliverOrderParams params);
}

@Injectable(as: IDeliverOrderUseCase)
class DeliverOrderUseCase implements IDeliverOrderUseCase {
  final IOrderRepository _repository;

  DeliverOrderUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeliverOrderParams params) async {
    // Add any specific business logic/validation for delivering order here if needed
    return await _repository.deliverOrder(params);
  }
}

// --- Delete Seller Order Record Use Case ---

abstract class IDeleteSellerOrderRecordUseCase {
  Future<Either<Failure, void>> call(int orderId);
}

@Injectable(as: IDeleteSellerOrderRecordUseCase)
class DeleteSellerOrderRecordUseCase implements IDeleteSellerOrderRecordUseCase {
  final IOrderRepository _repository;

  DeleteSellerOrderRecordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return await _repository.deleteSellerOrderRecord(orderId);
  }
}

// --- Invite Evaluation Use Case ---

abstract class IInviteEvaluationUseCase {
  Future<Either<Failure, void>> call(int orderId);
}

@Injectable(as: IInviteEvaluationUseCase)
class InviteEvaluationUseCase implements IInviteEvaluationUseCase {
  final IOrderRepository _repository;

  InviteEvaluationUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    // API endpoint is still TBC, but structure is ready
    return await _repository.inviteEvaluation(orderId);
  }
}

// Note: AddOrderDemandParams and DeliverOrderParams are currently defined in
// i_order_repository.dart. Consider moving them here or to a dedicated params file
// within the usecases folder if preferred for better separation.
