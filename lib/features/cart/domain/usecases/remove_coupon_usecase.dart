import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/i_cart_repository.dart';

/// 移除当前应用的优惠券
class RemoveCouponUseCase implements UseCase<Cart, RemoveCouponParams> {
  final ICartRepository repository;

  RemoveCouponUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(RemoveCouponParams params) async {
    return await repository.removeCoupon(params.couponCode);
  }
}

/// 移除优惠券的参数
class RemoveCouponParams extends Equatable {
  final String couponCode;

  const RemoveCouponParams({
    required this.couponCode,
  });

  @override
  List<Object> get props => [couponCode];
}