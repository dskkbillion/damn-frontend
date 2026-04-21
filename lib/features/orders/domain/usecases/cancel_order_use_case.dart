import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_order_repository.dart'; // 实现类需要依赖 Repository 接口

/// 取消订单的用例接口。
@injectable
class CancelOrderUseCase implements UseCase<void, int> {
  final IOrderRepository repository;

  CancelOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    return await repository.cancelOrder(params);
  }
}

// --- Implementation ---

/// [CancelOrderUseCase] 的默认实现。
class CancelOrderUseCaseImpl implements CancelOrderUseCase {
  @override
  final IOrderRepository repository;

  CancelOrderUseCaseImpl({required this.repository});

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return await repository.cancelOrder(orderId);
  }
} 