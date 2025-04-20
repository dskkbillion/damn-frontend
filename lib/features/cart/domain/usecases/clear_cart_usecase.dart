import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/i_cart_repository.dart';

/// 清空购物车
class ClearCartUseCase implements UseCase<void, NoParams> {
  final ICartRepository repository;

  ClearCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearCart();
  }
}