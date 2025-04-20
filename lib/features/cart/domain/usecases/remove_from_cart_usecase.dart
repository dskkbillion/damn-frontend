import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/i_cart_repository.dart';

/// 从购物车中移除一项或多项商品
class RemoveFromCartUseCase implements UseCase<void, RemoveFromCartParams> {
  final ICartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartParams params) async {
    if (params.cartItemIds.length == 1) {
      // 如果只有一个商品项，使用removeItem方法
      return await repository.removeItem(params.cartItemIds.first);
    } else {
      // 如果有多个商品项，使用removeItems方法
      return await repository.removeItems(params.cartItemIds);
    }
  }
}

/// 从购物车移除商品的参数
class RemoveFromCartParams extends Equatable {
  final List<String> cartItemIds;

  const RemoveFromCartParams({
    required this.cartItemIds,
  });

  /// 创建只移除一个商品项的参数
  factory RemoveFromCartParams.single(String cartItemId) {
    return RemoveFromCartParams(cartItemIds: [cartItemId]);
  }

  @override
  List<Object> get props => [cartItemIds];
}