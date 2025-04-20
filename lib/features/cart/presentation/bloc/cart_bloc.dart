import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/apply_coupon_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/proceed_to_checkout_usecase.dart';
import '../../domain/usecases/remove_coupon_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_item_quantity_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// 购物车Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCart;
  final AddToCartUseCase addToCart;
  final UpdateCartItemQuantityUseCase updateCartItemQuantity;
  final RemoveFromCartUseCase removeFromCart;
  final ClearCartUseCase clearCart;
  final ApplyCouponUseCase applyCoupon;
  final RemoveCouponUseCase removeCoupon;
  final ProceedToCheckoutUseCase proceedToCheckout;

  CartBloc({
    required this.getCart,
    required this.addToCart,
    required this.updateCartItemQuantity,
    required this.removeFromCart,
    required this.clearCart,
    required this.applyCoupon,
    required this.removeCoupon,
    required this.proceedToCheckout,
  }) : super(const CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddItemToCart>(_onAddItemToCart);
    on<UpdateCartItemQuantity>(_onUpdateCartItemQuantity);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<RemoveCartItems>(_onRemoveCartItems);
    on<ClearCart>(_onClearCart);
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
    on<ProceedToCheckout>(_onProceedToCheckout);
  }

  /// 处理加载购物车事件
  Future<void> _onLoadCart(
    LoadCart event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    final result = await getCart(NoParams());
    result.fold(
      (failure) => emit(CartOperationFailure(message: failure.message ?? '加载购物车失败')),
      (cart) => emit(CartLoaded(cart: cart)),
    );
  }

  /// 处理添加商品到购物车事件
  Future<void> _onAddItemToCart(
    AddItemToCart event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
    }
    
    emit(const CartOperationInProgress());
    
    final params = AddToCartParams(
      productId: event.productId,
      skuId: event.skuId,
      quantity: event.quantity,
    );
    
    final result = await addToCart(params);
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '添加商品失败'));
        // 如果有之前的购物车状态，恢复它
        if (currentCart != null) {
          emit(CartLoaded(cart: currentCart));
        }
      },
      (_) async {
        // 添加成功后，重新加载购物车
        final cartResult = await getCart(NoParams());
        cartResult.fold(
          (failure) => emit(CartOperationFailure(message: failure.message ?? '加载购物车失败')),
          (cart) {
            emit(CartOperationSuccess(message: '商品已添加到购物车'));
            emit(CartLoaded(cart: cart));
          },
        );
      },
    );
  }

  /// 处理更新购物车项数量事件
  Future<void> _onUpdateCartItemQuantity(
    UpdateCartItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
      
      // 乐观更新UI
      final updatedItems = currentCart.items.map((item) {
        if (item.id == event.cartItemId) {
          return item.copyWithNewQuantity(event.newQuantity);
        }
        return item;
      }).toList();
      
      // 创建一个新的Cart对象，但使用更新后的items
      // 注意：这是一个简化的实现，实际上可能需要重新计算摘要信息
      final updatedCart = Cart(
        id: currentCart.id,
        items: updatedItems,
        summary: currentCart.summary,
        appliedCoupon: currentCart.appliedCoupon,
        availableCoupons: currentCart.availableCoupons,
        validationResult: currentCart.validationResult,
      );
      
      emit(CartLoaded(cart: updatedCart));
    }
    
    final params = UpdateCartItemQuantityParams(
      cartItemId: event.cartItemId,
      newQuantity: event.newQuantity,
    );
    
    final result = await updateCartItemQuantity(params);
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '更新数量失败'));
        // 如果有之前的购物车状态，恢复它
        if (currentCart != null) {
          emit(CartLoaded(cart: currentCart));
        }
      },
      (_) async {
        // 更新成功后，重新加载购物车
        final cartResult = await getCart(NoParams());
        cartResult.fold(
          (failure) => emit(CartOperationFailure(message: failure.message ?? '加载购物车失败')),
          (cart) {
            emit(CartOperationSuccess(message: '数量已更新'));
            emit(CartLoaded(cart: cart));
          },
        );
      },
    );
  }

  /// 处理移除购物车项事件
  Future<void> _onRemoveCartItem(
    RemoveCartItem event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
      
      // 乐观更新UI
      final updatedItems = currentCart.items.where((item) => item.id != event.cartItemId).toList();
      
      // 创建一个新的Cart对象，但使用更新后的items
      // 注意：这是一个简化的实现，实际上可能需要重新计算摘要信息
      final updatedCart = Cart(
        id: currentCart.id,
        items: updatedItems,
        summary: currentCart.summary,
        appliedCoupon: currentCart.appliedCoupon,
        availableCoupons: currentCart.availableCoupons,
        validationResult: currentCart.validationResult,
      );
      
      emit(CartLoaded(cart: updatedCart));
    }
    
    final params = RemoveFromCartParams.single(event.cartItemId);
    
    final result = await removeFromCart(params);
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '移除商品失败'));
        // 如果有之前的购物车状态，恢复它
        if (currentCart != null) {
          emit(CartLoaded(cart: currentCart));
        }
      },
      (_) async {
        // 移除成功后，重新加载购物车
        final cartResult = await getCart(NoParams());
        cartResult.fold(
          (failure) => emit(CartOperationFailure(message: failure.message ?? '加载购物车失败')),
          (cart) {
            emit(CartOperationSuccess(message: '商品已从购物车移除'));
            emit(CartLoaded(cart: cart));
          },
        );
      },
    );
  }

  /// 处理批量移除购物车项事件
  Future<void> _onRemoveCartItems(
    RemoveCartItems event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
      
      // 乐观更新UI
      final updatedItems = currentCart.items
          .where((item) => !event.cartItemIds.contains(item.id))
          .toList();
      
      // 创建一个新的Cart对象，但使用更新后的items
      final updatedCart = Cart(
        id: currentCart.id,
        items: updatedItems,
        summary: currentCart.summary,
        appliedCoupon: currentCart.appliedCoupon,
        availableCoupons: currentCart.availableCoupons,
        validationResult: currentCart.validationResult,
      );
      
      emit(CartLoaded(cart: updatedCart));
    }
    
    final params = RemoveFromCartParams(cartItemIds: event.cartItemIds);
    
    final result = await removeFromCart(params);
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '批量移除商品失败'));
        // 如果有之前的购物车状态，恢复它
        if (currentCart != null) {
          emit(CartLoaded(cart: currentCart));
        }
      },
      (_) async {
        // 移除成功后，重新加载购物车
        final cartResult = await getCart(NoParams());
        cartResult.fold(
          (failure) => emit(CartOperationFailure(message: failure.message ?? '加载购物车失败')),
          (cart) {
            emit(CartOperationSuccess(message: '已移除选中的商品'));
            emit(CartLoaded(cart: cart));
          },
        );
      },
    );
  }

  /// 处理清空购物车事件
  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
    }
    
    emit(const CartOperationInProgress());
    
    final result = await clearCart(NoParams());
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '清空购物车失败'));
        // 如果有之前的购物车状态，恢复它
        if (currentCart != null) {
          emit(CartLoaded(cart: currentCart));
        }
      },
      (_) async {
        // 清空成功后，重新加载购物车
        final cartResult = await getCart(NoParams());
        cartResult.fold(
          (failure) => emit(CartOperationFailure(message: failure.message ?? '加载购物车失败')),
          (cart) {
            emit(CartOperationSuccess(message: '购物车已清空'));
            emit(CartLoaded(cart: cart));
          },
        );
      },
    );
  }

  /// 处理应用优惠券事件
  Future<void> _onApplyCoupon(
    ApplyCoupon event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
    }
    
    emit(const CartOperationInProgress());
    
    final params = ApplyCouponParams(couponCode: event.couponCode);
    
    final result = await applyCoupon(params);
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '应用优惠券失败'));
        // 如果有之前的购物车状态，恢复它
        if (currentCart != null) {
          emit(CartLoaded(cart: currentCart));
        }
      },
      (cart) {
        emit(CartOperationSuccess(message: '优惠券已应用'));
        emit(CartLoaded(cart: cart));
      },
    );
  }

  /// 处理移除优惠券事件
  Future<void> _onRemoveCoupon(
    RemoveCoupon event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
    }
    
    emit(const CartOperationInProgress());
    
    final params = RemoveCouponParams(couponCode: event.couponCode);
    
    final result = await removeCoupon(params);
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '移除优惠券失败'));
        // 如果有之前的购物车状态，恢复它
        if (currentCart != null) {
          emit(CartLoaded(cart: currentCart));
        }
      },
      (cart) {
        emit(CartOperationSuccess(message: '优惠券已移除'));
        emit(CartLoaded(cart: cart));
      },
    );
  }

  /// 处理启动结算事件
  Future<void> _onProceedToCheckout(
    ProceedToCheckout event,
    Emitter<CartState> emit,
  ) async {
    // 如果当前状态是CartLoaded，保存当前购物车状态
    Cart? currentCart;
    if (state is CartLoaded) {
      currentCart = (state as CartLoaded).cart;
    } else {
      emit(const CartOperationFailure(message: '购物车未加载，无法结算'));
      return;
    }
    
    emit(const CartOperationInProgress());
    
    final params = CheckoutRequestData(
      cartItemIds: event.cartItemIds,
      selectedAddressId: event.selectedAddressId,
      selectedShippingMethodId: event.selectedShippingMethodId,
      couponCode: event.couponCode,
      note: event.note,
    );
    
    final result = await proceedToCheckout(params);
    
    result.fold(
      (failure) {
        emit(CartOperationFailure(message: failure.message ?? '启动结算失败'));
        emit(CartLoaded(cart: currentCart));
      },
      (checkoutPreview) {
        emit(CheckoutInitiated(checkoutPreview: checkoutPreview));
      },
    );
  }
}