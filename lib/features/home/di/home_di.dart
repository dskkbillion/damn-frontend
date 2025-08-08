import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
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

// 卖家主页相关导入
import '../data/datasources/seller_products_data_source.dart';
import '../data/repositories/seller_products_repository_impl.dart';
import '../domain/repositories/seller_products_repository.dart';
import '../domain/usecases/get_seller_products.dart';
import '../domain/usecases/follow_seller.dart';
import '../domain/usecases/unfollow_seller.dart';
import '../presentation/bloc/seller_profile_bloc.dart';
import '../domain/usecases/get_seller_info.dart';

// 商品评论相关导入
import '../data/datasources/product_reviews_remote_data_source.dart';
import '../data/repositories/product_reviews_repository_impl.dart';
import '../domain/repositories/product_reviews_repository.dart';
import '../domain/usecases/get_product_reviews_use_case.dart';
import '../presentation/cubit/product_reviews_cubit.dart';

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
  
  // 注册商品评论相关依赖
  _registerProductReviewsDependencies();
  
  // 注册卖家主页相关依赖
  _registerSellerProfileDependencies();

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
        if (backendUrlFromEnv == null || backendUrlFromEnv.isEmpty) {
          throw Exception('BACKEND_BASE_URL environment variable is not set. Please configure it in your .env file.');
        }
        print('[home_di] 最终注册为 baseUrl 的值: $backendUrlFromEnv');
        return backendUrlFromEnv;
      },
      instanceName: 'baseUrl',
    );
  } else {
    final existingBaseUrl = sl<String>(instanceName: 'baseUrl');
    print('[home_di] 名为 baseUrl 的实例已被注册，值为: $existingBaseUrl');
  }
  
  // 注册 MODEL_BASE_URL
  if (!sl.isRegistered<String>(instanceName: 'modelBaseUrl')) {
    sl.registerLazySingleton<String>(
      () {
        final modelUrl = RegionConfig.modelBaseUrl;
        print('[home_di] 使用区域配置的模型服务URL: $modelUrl');
        print('[home_di] 当前区域: ${RegionConfig.currentRegion.displayName}');
        return modelUrl;
      },
      instanceName: 'modelBaseUrl',
    );
  } else {
    final existingModelBaseUrl = sl<String>(instanceName: 'modelBaseUrl');
    print('[home_di] 名为 modelBaseUrl 的实例已被注册，值为: $existingModelBaseUrl');
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
  
  // 注册获取 CommonUserId 的函数
  if (!sl.isRegistered<Future<String?> Function()>(instanceName: 'getCommonUserId')) {
    sl.registerLazySingleton<Future<String?> Function()>(
      () => () async {
        final secureStorage = sl<ISecureStorageRepository>();
        final commonUserId = await secureStorage.getCommonUserId();
        return commonUserId?.toString();
      },
      instanceName: 'getCommonUserId',
    );
    print('[home_di] 注册 getCommonUserId 函数');
  }

  // 注册 Data Sources
  if (!sl.isRegistered<HomeRemoteDataSource>()) {
    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(
        client: sl<http.Client>(),
        baseUrl: sl(instanceName: 'baseUrl'),
        modelBaseUrl: sl(instanceName: 'modelBaseUrl'),
        getToken: () async {
          final tokenGetter = sl<Future<String?> Function()>(instanceName: 'getAuthToken');
          return await tokenGetter() ?? '';
        },
        getUserId: () async {
          final userIdGetter = sl<Future<String?> Function()>(instanceName: 'getUserId');
          return await userIdGetter() ?? '';
        },
        getCommonUserId: () async {
          final commonUserIdGetter = sl<Future<String?> Function()>(instanceName: 'getCommonUserId');
          return await commonUserIdGetter() ?? '1';
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

// 卖家主页相关依赖注册
void _registerSellerProfileDependencies() {
  // 数据源
  if (!sl.isRegistered<SellerProductsDataSource>()) {
    sl.registerFactory<SellerProductsDataSource>(
      () => SellerProductsDataSourceImpl(dio: sl()),
    );
    print('[home_di] 注册 SellerProductsDataSource');
  } else {
    print('[home_di] SellerProductsDataSource 已经注册，跳过重复注册');
  }
  
  // 仓库
  if (!sl.isRegistered<SellerProductsRepository>()) {
    sl.registerFactory<SellerProductsRepository>(
      () => SellerProductsRepositoryImpl(dataSource: sl()),
    );
    print('[home_di] 注册 SellerProductsRepository');
  } else {
    print('[home_di] SellerProductsRepository 已经注册，跳过重复注册');
  }
  
  // 用例
  if (!sl.isRegistered<GetSellerProducts>()) {
    sl.registerLazySingleton(
      () => GetSellerProducts(sl<SellerProductsRepository>()),
    );
    print('[home_di] 注册 GetSellerProducts');
  } else {
    print('[home_di] GetSellerProducts 已经注册，跳过重复注册');
  }
  
  // 收藏卖家用例
  if (!sl.isRegistered<FollowSeller>()) {
    sl.registerLazySingleton(
      () => FollowSeller(sl<SellerProductsRepository>()),
    );
    print('[home_di] 注册 FollowSeller');
  } else {
    print('[home_di] FollowSeller 已经注册，跳过重复注册');
  }
  
  // 取消收藏卖家用例
  if (!sl.isRegistered<UnfollowSeller>()) {
    sl.registerLazySingleton(
      () => UnfollowSeller(sl<SellerProductsRepository>()),
    );
    print('[home_di] 注册 UnfollowSeller');
  } else {
    print('[home_di] UnfollowSeller 已经注册，跳过重复注册');
  }
  
  // 注册GetSellerInfo用例
  if (!sl.isRegistered<GetSellerInfo>()) {
    sl.registerLazySingleton(
      () => GetSellerInfo(sl<SellerProductsRepository>()),
    );
    print('[home_di] 注册 GetSellerInfo');
  } else {
    print('[home_di] GetSellerInfo 已经注册，跳过重复注册');
  }
  
  // BLoC
  if (!sl.isRegistered<SellerProfileBloc>()) {
    sl.registerFactory(
      () => SellerProfileBloc(
        getSellerProducts: sl(),
        followSeller: sl(),
        unfollowSeller: sl(),
        getSellerInfo: sl(),
      ),
    );
    print('[home_di] 注册 SellerProfileBloc');
  } else {
    print('[home_di] SellerProfileBloc 已经注册，跳过重复注册');
  }
}

// 商品评论相关依赖注册
void _registerProductReviewsDependencies() {
  // 注册ProductReviewsCubit
  if (!sl.isRegistered<ProductReviewsCubit>()) {
    sl.registerFactory(() => ProductReviewsCubit(sl()));
    print('[home_di] 注册 ProductReviewsCubit');
  } else {
    print('[home_di] ProductReviewsCubit 已经注册，跳过重复注册');
  }

  // 注册GetProductReviewsUseCase
  if (!sl.isRegistered<GetProductReviewsUseCase>()) {
    sl.registerLazySingleton(() => GetProductReviewsUseCase(sl()));
    print('[home_di] 注册 GetProductReviewsUseCase');
  } else {
    print('[home_di] GetProductReviewsUseCase 已经注册，跳过重复注册');
  }

  // 注册ProductReviewsRepository
  if (!sl.isRegistered<ProductReviewsRepository>()) {
    sl.registerLazySingleton<ProductReviewsRepository>(
      () => ProductReviewsRepositoryImpl(sl(), sl()),
    );
    print('[home_di] 注册 ProductReviewsRepository');
  } else {
    print('[home_di] ProductReviewsRepository 已经注册，跳过重复注册');
  }

  // 注册ProductReviewsRemoteDataSource
  if (!sl.isRegistered<ProductReviewsRemoteDataSource>()) {
    sl.registerLazySingleton<ProductReviewsRemoteDataSource>(
      () => ProductReviewsRemoteDataSourceImpl(
        client: sl<http.Client>(),
        baseUrl: sl(instanceName: 'baseUrl'),
        getToken: () async {
          final tokenGetter = sl<Future<String?> Function()>(instanceName: 'getAuthToken');
          return await tokenGetter() ?? '';
        },
      ),
    );
    print('[home_di] 注册 ProductReviewsRemoteDataSource');
  } else {
    print('[home_di] ProductReviewsRemoteDataSource 已经注册，跳过重复注册');
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