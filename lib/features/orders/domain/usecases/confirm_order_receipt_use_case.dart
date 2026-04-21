import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/i_order_repository.dart'; // 实现类需要依赖 Repository 接口

/// 确认收到订单货品的用例接口。
@injectable
class ConfirmOrderReceiptUseCase implements UseCase<void, int> {
  final IOrderRepository repository;

  ConfirmOrderReceiptUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(int params) async {
    return await repository.confirmOrderReceipt(params);
  }
}

// --- Implementation ---

/// [ConfirmOrderReceiptUseCase] 的默认实现。
class ConfirmOrderReceiptUseCaseImpl implements ConfirmOrderReceiptUseCase {
  @override
  final IOrderRepository repository;

  ConfirmOrderReceiptUseCaseImpl({required this.repository});

  @override
  Future<Either<Failure, void>> call(int orderId) async {
    return await repository.confirmOrderReceipt(orderId);
  }
} 