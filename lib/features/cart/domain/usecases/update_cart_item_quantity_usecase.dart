import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/i_cart_repository.dart';

/// 更新购物车中某项商品的数量
class UpdateCartItemQuantityUseCase implements UseCase<void, UpdateCartItemQuantityParams> {
  final ICartRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCartItemQuantityParams params) async {
    return await repository.updateItemQuantity(
      params.cartItemId,
      params.newQuantity,
    );
  }
}

/// 更新购物车项数量的参数
class UpdateCartItemQuantityParams extends Equatable {
  final String cartItemId;
  final int newQuantity;

  const UpdateCartItemQuantityParams({
    required this.cartItemId,
    required this.newQuantity,
  });

  @override
  List<Object> get props => [cartItemId, newQuantity];
}