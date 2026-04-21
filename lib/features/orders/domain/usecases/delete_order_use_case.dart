import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_order_repository.dart'; // 实现类需要依赖 Repository 接口

/// 删除订单的用例接口。
@injectable
class DeleteOrderUseCase implements UseCase<void, int> {
  final IOrderRepository repository;

  DeleteOrderUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    return await repository.deleteOrder(params);
  }
}

// --- Implementation ---

/// [DeleteOrderUseCase] 的默认实现。
class DeleteOrderUseCaseImpl implements DeleteOrderUseCase {
  @override
  final IOrderRepository repository;

  DeleteOrderUseCaseImpl({required this.repository});

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return await repository.deleteOrder(orderId);
  }
} 