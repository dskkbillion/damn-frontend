import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/cart_local_data_source.dart';
import '../data/datasources/cart_local_data_source_impl.dart';
import '../data/datasources/cart_remote_data_source.dart';
import '../data/datasources/cart_remote_data_source_impl.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../domain/repositories/i_cart_repository.dart';
import '../domain/usecases/add_to_cart_usecase.dart';
import '../domain/usecases/apply_coupon_usecase.dart';
import '../domain/usecases/clear_cart_usecase.dart';
import '../domain/usecases/get_cart_usecase.dart';
import '../domain/usecases/proceed_to_checkout_usecase.dart';
import '../domain/usecases/remove_coupon_usecase.dart';
import '../domain/usecases/remove_from_cart_usecase.dart';
import '../domain/usecases/update_cart_item_quantity_usecase.dart';
import '../presentation/bloc/cart_bloc.dart';

/// 购物车模块依赖注入
class CartDI {
  /// 注册购物车模块的所有依赖项
  static void init(GetIt sl) {
    // 数据源
    sl.registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(
        client: sl<http.Client>(),
        baseUrl: sl<String>(instanceName: 'baseUrl'),
        getToken: () => sl<String>(instanceName: 'authToken'),
        getUserId: () => sl<String>(instanceName: 'userId'),
      ),
    );

    sl.registerLazySingleton<CartLocalDataSource>(
      () => CartLocalDataSourceImpl(
        sharedPreferences: sl<SharedPreferences>(),
        getUserId: () => sl<String>(instanceName: 'userId'),
      ),
    );

    // 仓库
    sl.registerLazySingleton<ICartRepository>(
      () => CartRepositoryImpl(
        remoteDataSource: sl<CartRemoteDataSource>(),
        localDataSource: sl<CartLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    // 用例
    sl.registerLazySingleton(() => GetCartUseCase(sl<ICartRepository>()));
    sl.registerLazySingleton(() => AddToCartUseCase(sl<ICartRepository>()));
    sl.registerLazySingleton(() => UpdateCartItemQuantityUseCase(sl<ICartRepository>()));
    sl.registerLazySingleton(() => RemoveFromCartUseCase(sl<ICartRepository>()));
    sl.registerLazySingleton(() => ClearCartUseCase(sl<ICartRepository>()));
    sl.registerLazySingleton(() => ApplyCouponUseCase(sl<ICartRepository>()));
    sl.registerLazySingleton(() => RemoveCouponUseCase(sl<ICartRepository>()));
    sl.registerLazySingleton(() => ProceedToCheckoutUseCase(sl<ICartRepository>()));

    // Bloc
    sl.registerFactory(
      () => CartBloc(
        getCart: sl<GetCartUseCase>(),
        addToCart: sl<AddToCartUseCase>(),
        updateCartItemQuantity: sl<UpdateCartItemQuantityUseCase>(),
        removeFromCart: sl<RemoveFromCartUseCase>(),
        clearCart: sl<ClearCartUseCase>(),
        applyCoupon: sl<ApplyCouponUseCase>(),
        removeCoupon: sl<RemoveCouponUseCase>(),
        proceedToCheckout: sl<ProceedToCheckoutUseCase>(),
      ),
    );
  }
}