import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/network_info.dart';
import '../../data/datasources/favorites_local_data_source.dart';
import '../../data/datasources/favorites_remote_data_source.dart';
import '../../data/repositories/favorites_repository_impl.dart';
import '../../domain/repositories/i_favorites_repository.dart';
import '../../domain/usecases/add_to_favorites_usecase.dart';
import '../../domain/usecases/check_is_favorite_usecase.dart';
import '../../domain/usecases/follow_seller_usecase.dart';
import '../../domain/usecases/get_favorite_sellers_usecase.dart';
import '../../domain/usecases/get_favorite_services_usecase.dart';
import '../../domain/usecases/remove_from_favorites_usecase.dart';
import '../../domain/usecases/unfollow_seller_usecase.dart';
import '../bloc/favorites_bloc.dart';
import '../pages/favorites_page.dart';

/// 收藏模块路由
class FavoritesRoutes {
  /// 路由名称
  static const String favoritesPage = '/favorites';

  /// 路由生成器
  static Route<dynamic> generateRoute(
    RouteSettings settings,
    IFavoritesRepository repository,
  ) {
    switch (settings.name) {
      case favoritesPage:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => FavoritesBloc(
              getFavoriteServicesUseCase: GetFavoriteServicesUseCase(repository),
              getFavoriteSellersUseCase: GetFavoriteSellersUseCase(repository),
              addToFavoritesUseCase: AddToFavoritesUseCase(repository),
              removeFromFavoritesUseCase: RemoveFromFavoritesUseCase(repository),
              checkIsFavoriteUseCase: CheckIsFavoriteUseCase(repository),
              followSellerUseCase: FollowSellerUseCase(repository),
              unfollowSellerUseCase: UnfollowSellerUseCase(repository),
            ),
            child: const FavoritesPage(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('未找到路由: ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// 创建仓库实例
  static IFavoritesRepository createRepository(
    FavoritesRemoteDataSource remoteDataSource,
    FavoritesLocalDataSource localDataSource,
    NetworkInfo networkInfo,
  ) {
    return FavoritesRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
  }
}