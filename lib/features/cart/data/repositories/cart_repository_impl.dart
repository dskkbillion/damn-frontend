import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/i_cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../datasources/cart_remote_data_source.dart';
import '../models/cart_model.dart';

/// 购物车仓库实现
class CartRepositoryImpl implements ICartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Cart>> getCart() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCart = await remoteDataSource.getCart();
        await localDataSource.cacheCart(remoteCart);
        return Right(remoteCart);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final localCart = await localDataSource.getCachedCart();
        if (localCart != null) {
          return Right(localCart);
        } else {
          return Left(CacheFailure());
        }
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(String productId, String? skuId, int quantity) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addToCart(productId, skuId, quantity);
        
        // 更新本地缓存
        final remoteCart = await remoteDataSource.getCart();
        await localDataSource.cacheCart(remoteCart);
        
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法添加商品到购物车'));
    }
  }

  @override
  Future<Either<Failure, void>> updateItemQuantity(String cartItemId, int newQuantity) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateItemQuantity(cartItemId, newQuantity);
        
        // 更新本地缓存
        final remoteCart = await remoteDataSource.getCart();
        await localDataSource.cacheCart(remoteCart);
        
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法更新购物车数量'));
    }
  }

  @override
  Future<Either<Failure, void>> removeItem(String cartItemId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeItem(cartItemId);
        
        // 更新本地缓存
        final remoteCart = await remoteDataSource.getCart();
        await localDataSource.cacheCart(remoteCart);
        
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法移除购物车商品'));
    }
  }

  @override
  Future<Either<Failure, void>> removeItems(List<String> cartItemIds) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.removeItems(cartItemIds);
        
        // 更新本地缓存
        final remoteCart = await remoteDataSource.getCart();
        await localDataSource.cacheCart(remoteCart);
        
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法批量移除购物车商品'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.clearCart();
        await localDataSource.clearCache();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法清空购物车'));
    }
  }

  @override
  Future<Either<Failure, Cart>> applyCoupon(String couponCode) async {
    if (await networkInfo.isConnected) {
      try {
        final cart = await remoteDataSource.applyCoupon(couponCode);
        await localDataSource.cacheCart(cart);
        return Right(cart);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法应用优惠券'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeCoupon(String couponCode) async {
    if (await networkInfo.isConnected) {
      try {
        final cart = await remoteDataSource.removeCoupon(couponCode);
        await localDataSource.cacheCart(cart);
        return Right(cart);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法移除优惠券'));
    }
  }

  @override
  Future<Either<Failure, CheckoutPreview>> initiateCheckout(CheckoutRequestData data) async {
    if (await networkInfo.isConnected) {
      try {
        final checkoutData = {
          'cartItemIds': data.cartItemIds,
          'addressId': data.selectedAddressId,
          'shippingMethodId': data.selectedShippingMethodId,
          'couponCode': data.couponCode,
          'note': data.note,
        };
        
        final result = await remoteDataSource.initiateCheckout(checkoutData);
        
        final checkoutPreview = CheckoutPreview(
          preOrderId: result['preOrderId'].toString(),
          totalAmount: result['totalAmount'] is int 
              ? (result['totalAmount'] as int).toDouble() 
              : result['totalAmount'] as double,
          itemCount: result['itemCount'] as int,
          shippingFee: result['shippingFee'] is int 
              ? (result['shippingFee'] as int).toDouble() 
              : result['shippingFee'] as double,
          tax: result['tax'] is int 
              ? (result['tax'] as int).toDouble() 
              : result['tax'] as double,
          discount: result['discount'] is int 
              ? (result['discount'] as int).toDouble() 
              : result['discount'] as double,
          finalAmount: result['finalAmount'] is int 
              ? (result['finalAmount'] as int).toDouble() 
              : result['finalAmount'] as double,
        );
        
        return Right(checkoutPreview);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: '网络连接不可用，无法启动结算'));
    }
  }
}