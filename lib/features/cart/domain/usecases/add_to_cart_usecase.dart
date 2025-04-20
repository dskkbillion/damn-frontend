import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/i_cart_repository.dart';

/// 将指定商品（及规格）添加到购物车
class AddToCartUseCase implements UseCase<void, AddToCartParams> {
  final ICartRepository repository;

  AddToCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToCartParams params) async {
    return await repository.addToCart(
      params.productId,
      params.skuId,
      params.quantity,
    );
  }
}

/// 添加到购物车的参数
class AddToCartParams extends Equatable {
  final String productId;
  final String? skuId;
  final int quantity;

  const AddToCartParams({
    required this.productId,
    this.skuId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, skuId, quantity];
}