import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for the seller to confirm acceptance of an order.
@injectable
class ConfirmOrderAcceptanceUseCase implements UseCase<void, int> {
  final IOrderRepository repository;

  ConfirmOrderAcceptanceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    // TODO: Add any specific business logic here if needed before calling repo
    return await repository.confirmOrderAcceptance(orderId);
  }
} 