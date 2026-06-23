import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/core_dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/favorites_local_data_source.dart';
import '../data/datasources/favorites_local_data_source_impl.dart';
import '../data/datasources/favorites_remote_data_source.dart';
import '../data/datasources/favorites_remote_data_source_impl.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../domain/repositories/i_favorites_repository.dart';
import '../domain/usecases/add_to_favorites_usecase.dart';
import '../domain/usecases/check_is_favorite_usecase.dart';
import '../domain/usecases/follow_seller_usecase.dart';
import '../domain/usecases/get_favorite_sellers_usecase.dart';
import '../domain/usecases/get_favorite_services_usecase.dart';
import '../domain/usecases/remove_from_favorites_usecase.dart';
import '../domain/usecases/remove_from_favorites_by_object_id_usecase.dart';
import '../domain/usecases/unfollow_seller_usecase.dart';
import '../presentation/bloc/favorites_bloc.dart';

/// 收藏模块依赖注入
class FavoritesDI {
  /// 注册依赖
  static Future<void> init(GetIt sl) async {
    // Bloc
    sl.registerFactory(
      () => FavoritesBloc(
        getFavoriteServicesUseCase: sl<GetFavoriteServicesUseCase>(),
        getFavoriteSellersUseCase: sl<GetFavoriteSellersUseCase>(),
        addToFavoritesUseCase: sl<AddToFavoritesUseCase>(),
        removeFromFavoritesUseCase: sl<RemoveFromFavoritesUseCase>(),
        removeFromFavoritesByObjectIdUseCase: sl<RemoveFromFavoritesByObjectIdUseCase>(),
        checkIsFavoriteUseCase: sl<CheckIsFavoriteUseCase>(),
        followSellerUseCase: sl<FollowSellerUseCase>(),
        unfollowSellerUseCase: sl<UnfollowSellerUseCase>(),
      ),
    );

    // Use cases
    sl.registerLazySingleton(() => GetFavoriteServicesUseCase(sl<IFavoritesRepository>()));
    sl.registerLazySingleton(() => GetFavoriteSellersUseCase(sl<IFavoritesRepository>()));
    sl.registerLazySingleton(() => AddToFavoritesUseCase(sl<IFavoritesRepository>()));
    sl.registerLazySingleton(() => RemoveFromFavoritesUseCase(sl<IFavoritesRepository>()));
    sl.registerLazySingleton(() => RemoveFromFavoritesByObjectIdUseCase(sl<IFavoritesRepository>()));
    sl.registerLazySingleton(() => CheckIsFavoriteUseCase(sl<IFavoritesRepository>()));
    sl.registerLazySingleton(() => FollowSellerUseCase(sl<IFavoritesRepository>()));
    sl.registerLazySingleton(() => UnfollowSellerUseCase(sl<IFavoritesRepository>()));

    // Repository
    sl.registerLazySingleton<IFavoritesRepository>(
      () => FavoritesRepositoryImpl(
        remoteDataSource: sl<FavoritesRemoteDataSource>(),
        localDataSource: sl<FavoritesLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    // Data sources
    sl.registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(
        coreDioClient: sl<CoreDioClient>(),
      ),
    );

    sl.registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl(
        sharedPreferences: sl<SharedPreferences>(),
      ),
    );
  }

  /// 注册Mock依赖（用于测试和预览）
  static void initMock(GetIt sl) {
    // 注册Mock实现，用于测试和预览
    // TODO: 创建 MockFavoritesRemoteDataSource 类或使用真实实现
    // 暂时注释掉，以避免编译错误
    // sl.registerLazySingleton<FavoritesRemoteDataSource>(
    //   () => MockFavoritesRemoteDataSource(),
    //   dispose: (param) {},
    //   instanceName: 'mockFavoritesRemoteDataSource',
    // );
  }
}