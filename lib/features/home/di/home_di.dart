import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/secure_storage_repository.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/home_local_data_source.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_feed_usecase.dart';
import '../domain/usecases/get_home_page_data_usecase.dart';
import '../domain/usecases/search_products_usecase.dart';
import '../presentation/navigation/home_navigation_service.dart';
import '../presentation/bloc/home_bloc.dart';
import '../presentation/cubit/product_detail_cubit.dart';
import '../presentation/cubit/search_cubit.dart';

final sl = GetIt.instance;

/// 初始化 Home 模块的依赖注入
Future<void> initHomeDi() async {
  // Register HomeBloc itself
  // Use registerFactory for Blocs/Cubits as they often have state
  if (!sl.isRegistered<HomeBloc>()) {
    sl.registerFactory(() => HomeBloc(
          getHomePageData: sl(),
          getHomeFeed: sl(),
          navigationService: sl(),
        ));
    print('[home_di] 注册 HomeBloc');
  } else {
    print('[home_di] HomeBloc 已经注册，跳过重复注册');
  }
      
  // 注册ProductDetailCubit，避免重复注册
  if (!sl.isRegistered<ProductDetailCubit>()) {
    sl.registerFactory(() => ProductDetailCubit(sl()));
    print('[home_di] 注册 ProductDetailCubit');
  } else {
    print('[home_di] ProductDetailCubit 已经注册，跳过重复注册');
  }
  
  // 注册SearchCubit，避免重复注册
  if (!sl.isRegistered<SearchCubit>()) {
    sl.registerFactory(() => SearchCubit(searchProductsUsecase: sl()));
    print('[home_di] 注册 SearchCubit');
  } else {
    print('[home_di] SearchCubit 已经注册，跳过重复注册');
  }

  // 注册 Use Cases
  if (!sl.isRegistered<GetHomePageDataUseCase>()) {
    sl.registerLazySingleton(() => GetHomePageDataUseCase(sl()));
    print('[home_di] 注册 GetHomePageDataUseCase');
  } else {
    print('[home_di] GetHomePageDataUseCase 已经注册，跳过重复注册');
  }
  
  if (!sl.isRegistered<GetHomeFeedUseCase>()) {
    sl.registerLazySingleton(() => GetHomeFeedUseCase(sl()));
    print('[home_di] 注册 GetHomeFeedUseCase');
  } else {
    print('[home_di] GetHomeFeedUseCase 已经注册，跳过重复注册');
  }
  
  // 注册搜索产品用例
  if (!sl.isRegistered<SearchProductsUsecase>()) {
    sl.registerLazySingleton(() => SearchProductsUsecase(sl()));
    print('[home_di] 注册 SearchProductsUsecase');
  } else {
    print('[home_di] SearchProductsUsecase 已经注册，跳过重复注册');
  }

  // 注册 Repository
  if (!sl.isRegistered<IHomeRepository>()) {
    sl.registerLazySingleton<IHomeRepository>(
      () => HomeRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ),
    );
    print('[home_di] 注册 IHomeRepository');
  } else {
    print('[home_di] IHomeRepository 已经注册，跳过重复注册');
  }

  // 检查这些依赖是否已经存在，避免重复注册
  // 'baseUrl' 可能已经在 injection_container.dart 中注册
  if (!sl.isRegistered<String>(instanceName: 'baseUrl')) {
    sl.registerLazySingleton<String>(
      () {
        final backendUrlFromEnv = dotenv.env['BACKEND_BASE_URL'];
        print('[home_di] 读取到的 BACKEND_BASE_URL: $backendUrlFromEnv');
        final baseUrlToRegister = backendUrlFromEnv ?? 'https://app.duoshaokankan.com/prod-api';
        print('[home_di] 最终注册为 baseUrl 的值: $baseUrlToRegister');
        return baseUrlToRegister;
      },
      instanceName: 'baseUrl',
    );
  } else {
    final existingBaseUrl = sl<String>(instanceName: 'baseUrl');
    print('[home_di] 名为 baseUrl 的实例已被注册，值为: $existingBaseUrl');
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
    print('[home_di] 注册 getAuthToken 函数');
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
    print('[home_di] 注册 getUserId 函数');
  }

  // 注册 Data Sources
  if (!sl.isRegistered<HomeRemoteDataSource>()) {
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
    print('[home_di] 注册 HomeRemoteDataSource');
  } else {
    print('[home_di] HomeRemoteDataSource 已经注册，跳过重复注册');
  }

  // 注册本地数据源，使用已注册的 SharedPreferences
  if (!sl.isRegistered<HomeLocalDataSource>()) {
    sl.registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
    );
    print('[home_di] 注册 HomeLocalDataSource');
  } else {
    print('[home_di] HomeLocalDataSource 已经注册，跳过重复注册');
  }

  // 注册简单的导航服务
  if (!sl.isRegistered<HomeNavigationService>()) {
    sl.registerLazySingleton<HomeNavigationService>(
      () => SimpleHomeNavigationService(),
    );
    print('[home_di] 注册 HomeNavigationService');
  } else {
    print('[home_di] HomeNavigationService 已经注册，跳过重复注册');
  }

  // http.Client 可能已经注册，避免重复注册
  if (!sl.isRegistered<http.Client>()) {
    sl.registerLazySingleton(() => http.Client());
    print('[home_di] 注册 http.Client');
  } else {
    print('[home_di] http.Client 已经注册，跳过重复注册');
  }
  
  // 确保NetworkInfo已注册
  if (!sl.isRegistered<NetworkInfo>()) {
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
    print('[home_di] 注册 NetworkInfo');
  } else {
    print('[home_di] NetworkInfo 已经注册，跳过重复注册');
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