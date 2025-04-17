import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../data/datasources/home_mock_data_source.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_feed_usecase.dart';
import '../domain/usecases/get_home_page_data_usecase.dart';
import '../presentation/navigation/home_navigation_service.dart';
import '../presentation/navigation/home_navigation_service_impl.dart';
import '../presentation/navigation/home_preview_router.dart';

final sl = GetIt.instance;

/// 初始化 Home 模块的依赖注入（预览版本）
Future<void> initHomePreviewDi() async {
  // 注册导航服务
  sl.registerLazySingleton<HomeNavigationService>(
    () => HomeNavigationServiceImpl(navigatorKey: HomePreviewRouter.navigatorKey),
  );

  // 注册 Use Cases
  sl.registerLazySingleton(() => GetHomePageDataUseCase(sl()));
  sl.registerLazySingleton(() => GetHomeFeedUseCase(sl()));

  // 注册 Repository - 简化版，不使用 NetworkInfo 和 LocalDataSource
  sl.registerLazySingleton<IHomeRepository>(
    () => HomeRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: null, // 简化版不使用本地数据源
      networkInfo: null, // 简化版不使用网络信息
    ),
  );

  // 注册 Data Sources - 只使用 Mock 数据源
  sl.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeMockDataSource(), // 使用 Mock 数据源
  );

  // 注册外部依赖
  sl.registerLazySingleton(() => http.Client());
}