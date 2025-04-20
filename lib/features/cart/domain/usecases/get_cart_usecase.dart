import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/i_cart_repository.dart';

/// 获取当前用户的购物车内容和状态
class GetCartUseCase implements UseCase<Cart, NoParams> {
  final ICartRepository repository;

  GetCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(NoParams params) async {
    return await repository.getCart();
  }
}