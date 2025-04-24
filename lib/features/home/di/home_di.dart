import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/secure_storage_repository.dart';
import '../data/datasources/home_local_data_source.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_feed_usecase.dart';
import '../domain/usecases/get_home_page_data_usecase.dart';
import '../presentation/navigation/home_navigation_service.dart';
import '../presentation/bloc/home_bloc.dart';

final sl = GetIt.instance;

/// 初始化 Home 模块的依赖注入
Future<void> initHomeDi() async {
  // Register HomeBloc itself
  // Use registerFactory for Blocs/Cubits as they often have state
  sl.registerFactory(() => HomeBloc(
        getHomePageData: sl(),
        getHomeFeed: sl(),
        navigationService: sl(),
      ));

  // 注册 Use Cases
  sl.registerLazySingleton(() => GetHomePageDataUseCase(sl()));
  sl.registerLazySingleton(() => GetHomeFeedUseCase(sl()));

  // 注册 Repository
  sl.registerLazySingleton<IHomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // 检查这些依赖是否已经存在，避免重复注册
  // 'baseUrl' 可能已经在 injection_container.dart 中注册
  if (!sl.isRegistered<String>(instanceName: 'baseUrl')) {
    sl.registerLazySingleton<String>(
      () => dotenv.env['BACKEND_BASE_URL'] ?? 'https://app.duoshaokankan.com/prod-api',
      instanceName: 'baseUrl',
    );
  }
  
  // 使用安全存储服务获取token和userId
  if (!sl.isRegistered<Future<String?> Function()>(instanceName: 'getAuthToken')) {
    sl.registerLazySingleton<Future<String?> Function()>(
      () => () async {
        final secureStorage = sl<ISecureStorageRepository>();
        return await secureStorage.getToken();
      },
      instanceName: 'getAuthToken',
    );
  }
  
  if (!sl.isRegistered<Future<String?> Function()>(instanceName: 'getUserId')) {
    sl.registerLazySingleton<Future<String?> Function()>(
      () => () async {
        final secureStorage = sl<ISecureStorageRepository>();
        final userId = await secureStorage.getUserId();
        return userId?.toString();
      },
      instanceName: 'getUserId',
    );
  }

  // 注册 Data Sources
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(
      client: sl<http.Client>(),
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

  // 注册本地数据源，使用已注册的 SharedPreferences
  sl.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // 注册简单的导航服务
  sl.registerLazySingleton<HomeNavigationService>(
    () => SimpleHomeNavigationService(),
  );

  // http.Client 可能已经注册，避免重复注册
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
  }
}

/// 简单的导航服务实现，用于单独运行home模块
class SimpleHomeNavigationService implements HomeNavigationService {
  @override
  void navigateToProductDetail(String productId) {
    print('导航到产品详情页: $productId');
  }

  @override
  void navigateToSearch(String? query) {
    print('导航到搜索页: $query');
  }

  @override
  void navigateToCategoryDetail(String categoryId) {
    print('导航到分类详情页: $categoryId');
  }

  @override
  void navigateToUrl(String url) {
    print('导航到外部链接: $url');
  }

  @override
  void showRecommendConfirmation(String productId, String productName) {
    print('显示推荐确认对话框: $productId - $productName');
  }
}