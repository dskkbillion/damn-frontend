import 'package:equatable/equatable.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/i_cart_repository.dart';

/// 购物车状态基类
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// 购物车初始状态
class CartInitial extends CartState {
  const CartInitial();
}

/// 购物车加载中状态
class CartLoading extends CartState {
  const CartLoading();
}

/// 购物车加载成功状态
class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded({
    required this.cart,
  });

  @override
  List<Object> get props => [cart];

  /// 创建一个新的CartLoaded状态，但更新购物车
  CartLoaded copyWith({
    Cart? cart,
  }) {
    return CartLoaded(
      cart: cart ?? this.cart,
    );
  }
}

/// 购物车操作中状态
class CartOperationInProgress extends CartState {
  const CartOperationInProgress();
}

/// 购物车操作成功状态
class CartOperationSuccess extends CartState {
  final String message;

  const CartOperationSuccess({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// 购物车操作失败状态
class CartOperationFailure extends CartState {
  final String message;

  const CartOperationFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}

/// 结算启动成功状态
class CheckoutInitiated extends CartState {
  final CheckoutPreview checkoutPreview;

  const CheckoutInitiated({
    required this.checkoutPreview,
  });

  @override
  List<Object> get props => [checkoutPreview];
}