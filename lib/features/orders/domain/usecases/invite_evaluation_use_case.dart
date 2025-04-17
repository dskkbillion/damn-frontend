import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for the seller to invite evaluation for an order.
@injectable
class InviteEvaluationUseCase implements UseCase<void, int> {
  final IOrderRepository repository;

  InviteEvaluationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return await repository.inviteEvaluation(orderId);
  }
} 