import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/network_info.dart';
import '../../features/favorites/data/datasources/favorites_local_data_source.dart';
import '../../features/favorites/data/datasources/favorites_local_data_source_impl.dart';
import '../../features/favorites/data/datasources/favorites_remote_data_source.dart';
import '../../features/favorites/data/datasources/favorites_remote_data_source_impl.dart';
import '../../features/favorites/data/models/favorite_model.dart';
import '../../features/favorites/data/models/favorite_service_model.dart';
import '../../features/favorites/data/models/favorite_seller_model.dart';
import '../../features/favorites/data/models/common_user_model.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/entities/favorite_service.dart';
import '../../features/favorites/domain/entities/favorite_seller.dart';
import '../../features/favorites/domain/repositories/i_favorites_repository.dart';
import '../../features/favorites/domain/usecases/add_to_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/check_is_favorite_usecase.dart';
import '../../features/favorites/domain/usecases/follow_seller_usecase.dart';
import '../../features/favorites/domain/usecases/get_favorite_sellers_usecase.dart';
import '../../features/favorites/domain/usecases/get_favorite_services_usecase.dart';
import '../../features/favorites/domain/usecases/remove_from_favorites_usecase.dart';
import '../../features/favorites/domain/usecases/unfollow_seller_usecase.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';

/// 服务定位器
final sl = GetIt.instance;

/// 主函数
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化依赖
  await initDependencies();
  
  runApp(const MyApp());
}

/// 初始化依赖
Future<void> initDependencies() async {
  // 外部依赖
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  
  // 为Web平台创建一个特殊的NetworkInfo实现
  sl.registerLazySingleton<NetworkInfo>(() => MockNetworkInfo());
  
  // 配置
  sl.registerLazySingleton<String>(
    () => 'https://app.duoshaokankan.com/prod-api',
    instanceName: 'baseUrl'
  );
  
  // 注册获取token和userId的函数 - 使用硬编码的token和userId
  sl.registerLazySingleton<Future<String?> Function()>(
    () => () async => 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjJmZDc3ZTM0LTY0YTQtNDRkYy1hMzRkLTRlNzI1YzA1YzA0YiJ9.aCyO_gQyGvrLTd5-WZXLwUVT8pWI-UkHtEXRzHiUMuVtJcZ-pEj-NKjOvTwKRLfbXjXaABgWmhIQq_ixvjGguA', // 硬编码token用于预览
    instanceName: 'getAuthToken',
  );
  
  sl.registerLazySingleton<Future<String?> Function()>(
    () => () async => '1', // 硬编码用户ID用于预览
    instanceName: 'getUserId',
  );
  
  // 数据源
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sharedPreferences: sl()),
  );
  
  // 使用真实数据源进行预览
  sl.registerLazySingleton<FavoritesRemoteDataSource>(
    () => FavoritesRemoteDataSourceImpl(
      client: sl(),
      baseUrl: sl(instanceName: 'baseUrl'),
      getToken: () async {
        final tokenGetter = sl<Future<String?> Function()>(instanceName: 'getAuthToken');
        return await tokenGetter() ?? '';
      },
      getUserId: () async {
        final userIdGetter = sl<Future<String?> Function()>(instanceName: 'getUserId');
        return await userIdGetter() ?? '';
      },
    ),
  );
  
  // 仓库
  sl.registerLazySingleton<IFavoritesRepository>(
    () => FavoritesRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  
  // 用例
  sl.registerLazySingleton(() => GetFavoriteServicesUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoriteSellersUseCase(sl()));
  sl.registerLazySingleton(() => AddToFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => RemoveFromFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => CheckIsFavoriteUseCase(sl()));
  sl.registerLazySingleton(() => FollowSellerUseCase(sl()));
  sl.registerLazySingleton(() => UnfollowSellerUseCase(sl()));
  
  // Bloc
  sl.registerFactory(
    () => FavoritesBloc(
      getFavoriteServicesUseCase: sl(),
      getFavoriteSellersUseCase: sl(),
      addToFavoritesUseCase: sl(),
      removeFromFavoritesUseCase: sl(),
      checkIsFavoriteUseCase: sl(),
      followSellerUseCase: sl(),
      unfollowSellerUseCase: sl(),
    ),
  );
}

/// 应用程序
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '收藏功能预览',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) => sl<FavoritesBloc>(),
        child: const FavoritesPage(),
      ),
    );
  }
}

/// Mock网络信息实现（用于预览，特别是Web平台）
class MockNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected => Future.value(true);
}

/// Mock远程数据源实现（用于预览）
class MockFavoritesRemoteDataSource implements FavoritesRemoteDataSource {
  final List<FavoriteService> _mockServices = [
    FavoriteService(
      id: 1,
      title: '专业清洗服务',
      description: '提供专业的家电清洗服务，包括空调、洗衣机等',
      imageUrl: 'https://via.placeholder.com/150',
      price: 100.0,
      isFavorite: true,
    ),
    FavoriteService(
      id: 2,
      title: '上门维修服务',
      description: '专业技师上门维修各类家电',
      imageUrl: 'https://via.placeholder.com/150',
      price: 150.0,
      isFavorite: true,
    ),
    FavoriteService(
      id: 3,
      title: '家居安装服务',
      description: '提供各类家居产品的安装服务',
      imageUrl: 'https://via.placeholder.com/150',
      price: 200.0,
      isFavorite: true,
    ),
  ];

  final List<FavoriteSeller> _mockSellers = [
    FavoriteSeller(
      id: 1,
      referId: 101,
      nickName: '专业清洁公司',
      trueName: '北京专业清洁有限公司',
      avatar: 'https://via.placeholder.com/150',
      type: 'ENTERPRISE',
      status: 'ACTIVE',
      isFavorite: true,
    ),
    FavoriteSeller(
      id: 2,
      referId: 102,
      nickName: '家电维修专家',
      trueName: '张师傅',
      avatar: 'https://via.placeholder.com/150',
      type: 'MEMBER',
      status: 'ACTIVE',
      isFavorite: true,
    ),
    FavoriteSeller(
      id: 3,
      referId: 103,
      nickName: '安装达人',
      trueName: '李师傅',
      avatar: 'https://via.placeholder.com/150',
      type: 'MEMBER',
      status: 'ACTIVE',
      isFavorite: true,
    ),
  ];

  final Map<int, bool> _mockFavoriteStatus = {
    1: true,
    2: true,
    3: true,
    101: true,
    102: true,
    103: true,
  };

  @override
  Future<List<FavoriteServiceModel>> getFavoriteServices({int? pageNum, int? pageSize}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    // 将实体转换为模型
    return _mockServices.map((service) => FavoriteServiceModel(
      id: service.id,
      title: service.title,
      description: service.description,
      imageUrl: service.imageUrl,
      price: service.price,
      isFavorite: service.isFavorite,
    )).toList();
  }

  @override
  Future<List<FavoriteSellerModel>> getFavoriteSellers({int? pageNum, int? pageSize}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));
    // 将实体转换为模型
    return _mockSellers.map((seller) => FavoriteSellerModel(
      id: seller.id,
      referId: seller.referId,
      nickName: seller.nickName,
      trueName: seller.trueName,
      avatar: seller.avatar,
      mobile: seller.mobile,
      gender: seller.gender,
      type: seller.type,
      status: seller.status,
      isFavorite: seller.isFavorite,
    )).toList();
  }

  @override
  Future<void> addToFavorites(String type, int objectId, Map<String, dynamic>? feature) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    _mockFavoriteStatus[objectId] = true;
  }

  @override
  Future<void> removeFromFavorites(List<int> favoriteIds) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    for (final id in favoriteIds) {
      _mockFavoriteStatus[id] = false;
      _mockServices.removeWhere((service) => service.id == id);
      _mockSellers.removeWhere((seller) => seller.id == id);
    }
  }

  @override
  Future<Map<int, bool>> checkIsFavorite(String type, List<int> objectIds) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));
    final result = <int, bool>{};
    for (final id in objectIds) {
      result[id] = _mockFavoriteStatus[id] ?? false;
    }
    return result;
  }

  @override
  Future<void> followSeller(dynamic user) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    // 在实际应用中，这里会调用API关注卖家
  }

  @override
  Future<void> unfollowSeller(dynamic user) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));
    // 在实际应用中，这里会调用API取消关注卖家
    if (user.referId != null) {
      _mockSellers.removeWhere((seller) => seller.referId == user.referId);
    }
  }
}