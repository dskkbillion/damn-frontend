import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/i_cart_repository.dart';

/// 应用优惠券到购物车
class ApplyCouponUseCase implements UseCase<Cart, ApplyCouponParams> {
  final ICartRepository repository;

  ApplyCouponUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(ApplyCouponParams params) async {
    return await repository.applyCoupon(params.couponCode);
  }
}

/// 应用优惠券的参数
class ApplyCouponParams extends Equatable {
  final String couponCode;

  const ApplyCouponParams({
    required this.couponCode,
  });

  @override
  List<Object> get props => [couponCode];
}