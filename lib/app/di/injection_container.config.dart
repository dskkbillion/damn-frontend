// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker/internet_connection_checker.dart'
    as _i973;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../core/network/dio_http_client.dart' as _i962;
import '../../core/network/i_http_client.dart' as _i493;
import '../../core/network/network_info.dart' as _i892;
import '../../core/storage/secure_storage_repository.dart' as _i822;
import '../../core/storage/secure_storage_repository_impl.dart' as _i912;
import '../../features/cart/data/datasources/favorites_local_data_source.dart'
    as _i187;
import '../../features/cart/data/datasources/favorites_local_data_source_impl.dart'
    as _i446;
import '../../features/cart/data/datasources/favorites_remote_data_source.dart'
    as _i833;
import '../../features/cart/data/datasources/favorites_remote_data_source_impl.dart'
    as _i374;
import '../../features/cart/data/repositories/favorites_repository_impl.dart'
    as _i89;
import '../../features/cart/domain/repositories/i_favorites_repository.dart'
    as _i930;
import '../../features/cart/domain/usecases/add_to_favorites_usecase.dart'
    as _i719;
import '../../features/cart/domain/usecases/check_is_favorite_usecase.dart'
    as _i893;
import '../../features/cart/domain/usecases/follow_seller_usecase.dart'
    as _i769;
import '../../features/cart/domain/usecases/get_favorite_sellers_usecase.dart'
    as _i249;
import '../../features/cart/domain/usecases/get_favorite_services_usecase.dart'
    as _i287;
import '../../features/cart/domain/usecases/remove_from_favorites_usecase.dart'
    as _i940;
import '../../features/cart/domain/usecases/unfollow_seller_usecase.dart'
    as _i164;
import '../../features/cart/presentation/bloc/favorites_bloc.dart' as _i19;
import 'register_module.dart' as _i291;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  final secureStorageModule = _$SecureStorageModule();
  await gh.factoryAsync<_i460.SharedPreferences>(
    () => registerModule.prefs,
    preResolve: true,
  );
  gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => secureStorageModule.secureStorage);
  gh.lazySingleton<_i973.InternetConnectionChecker>(
      () => registerModule.internetConnectionChecker);
  gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
  gh.lazySingleton<_i822.ISecureStorageRepository>(() =>
      _i912.SecureStorageRepositoryImpl(gh<_i558.FlutterSecureStorage>()));
  gh.lazySingleton<_i493.IHttpClient>(() => _i962.DioHttpClient());
  gh.lazySingleton<_i187.FavoritesLocalDataSource>(
      () => _i446.FavoritesLocalDataSourceImpl(
            sharedPreferences: gh<_i460.SharedPreferences>(),
            secureStorageRepository: gh<_i822.ISecureStorageRepository>(),
          ));
  gh.lazySingleton<String>(
    () => registerModule.baseUrl,
    instanceName: 'baseUrl',
  );
  gh.lazySingleton<_i892.NetworkInfo>(
      () => _i892.NetworkInfoImpl(gh<_i973.InternetConnectionChecker>()));
  gh.lazySingleton<_i833.FavoritesRemoteDataSource>(
      () => _i374.FavoritesRemoteDataSourceImpl(
            client: gh<_i519.Client>(),
            baseUrl: gh<String>(instanceName: 'baseUrl'),
            secureStorageRepository: gh<_i822.ISecureStorageRepository>(),
          ));
  gh.lazySingleton<_i930.IFavoritesRepository>(
      () => _i89.FavoritesRepositoryImpl(
            remoteDataSource: gh<_i833.FavoritesRemoteDataSource>(),
            localDataSource: gh<_i187.FavoritesLocalDataSource>(),
            networkInfo: gh<_i892.NetworkInfo>(),
          ));
  gh.factory<_i287.GetFavoriteServicesUseCase>(
      () => _i287.GetFavoriteServicesUseCase(gh<_i930.IFavoritesRepository>()));
  gh.factory<_i940.RemoveFromFavoritesUseCase>(
      () => _i940.RemoveFromFavoritesUseCase(gh<_i930.IFavoritesRepository>()));
  gh.factory<_i719.AddToFavoritesUseCase>(
      () => _i719.AddToFavoritesUseCase(gh<_i930.IFavoritesRepository>()));
  gh.factory<_i769.FollowSellerUseCase>(
      () => _i769.FollowSellerUseCase(gh<_i930.IFavoritesRepository>()));
  gh.factory<_i893.CheckIsFavoriteUseCase>(
      () => _i893.CheckIsFavoriteUseCase(gh<_i930.IFavoritesRepository>()));
  gh.factory<_i164.UnfollowSellerUseCase>(
      () => _i164.UnfollowSellerUseCase(gh<_i930.IFavoritesRepository>()));
  gh.factory<_i249.GetFavoriteSellersUseCase>(
      () => _i249.GetFavoriteSellersUseCase(gh<_i930.IFavoritesRepository>()));
  gh.factory<_i19.FavoritesBloc>(() => _i19.FavoritesBloc(
        getFavoriteServices: gh<_i287.GetFavoriteServicesUseCase>(),
        getFavoriteSellers: gh<_i249.GetFavoriteSellersUseCase>(),
        addToFavorites: gh<_i719.AddToFavoritesUseCase>(),
        removeFromFavorites: gh<_i940.RemoveFromFavoritesUseCase>(),
        checkIsFavorite: gh<_i893.CheckIsFavoriteUseCase>(),
        followSeller: gh<_i769.FollowSellerUseCase>(),
        unfollowSeller: gh<_i164.UnfollowSellerUseCase>(),
      ));
  return getIt;
}

class _$RegisterModule extends _i291.RegisterModule {}

class _$SecureStorageModule extends _i912.SecureStorageModule {}
