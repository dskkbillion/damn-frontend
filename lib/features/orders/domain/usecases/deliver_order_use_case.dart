import 'package:dartz/dartz.dart';
import 'package:dskk_flutter_refactor/core/error/failures.dart';
import 'package:dskk_flutter_refactor/core/usecases/usecase.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case for the seller to deliver an order.
/// Requires DeliverOrderParams which should be defined in i_order_repository.dart
@injectable
class DeliverOrderUseCase implements UseCase<void, DeliverOrderParams> {
  final IOrderRepository repository;

  DeliverOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeliverOrderParams params) async {
    return await repository.deliverOrder(params);
  }
} 