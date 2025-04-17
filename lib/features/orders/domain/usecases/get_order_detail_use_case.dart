import 'package:dartz/dartz.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/i_order_repository.dart';

/// 获取订单详情的用例接口。
@injectable
class GetOrderDetailUseCase implements UseCase<Order, int> {
  final IOrderRepository repository;

  GetOrderDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Order>> call(int params) async {
    return await repository.getOrderDetail(params);
  }
}

// --- Implementation ---

/// [GetOrderDetailUseCase] 的默认实现。
class GetOrderDetailUseCaseImpl implements GetOrderDetailUseCase {
  final IOrderRepository repository;

  GetOrderDetailUseCaseImpl({required this.repository});

  @override
  Future<Either<Failure, Order>> call(int orderId) async {
    return await repository.getOrderDetail(orderId);
  }
}