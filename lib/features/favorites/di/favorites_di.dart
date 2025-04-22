import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
        client: sl<http.Client>(),
        baseUrl: sl<String>(instanceName: 'baseUrl'),
        authToken: sl<String>(instanceName: 'authToken'),
        userId: sl<String>(instanceName: 'userId'),
      ),
    );

    sl.registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSourceImpl(
        sharedPreferences: sl<SharedPreferences>(),
      ),
    );

    // External
    if (!sl.isRegistered<http.Client>()) {
      sl.registerLazySingleton(() => http.Client());
    }
  }

  /// 注册Mock依赖（用于测试和预览）
  static void initMock(GetIt sl) {
    // 这里可以注册Mock实现，用于测试和预览
  }
}