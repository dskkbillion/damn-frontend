import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile/data/repositories/wallet_repository_impl.dart';
import '../../features/profile/domain/repositories/i_user_profile_repository.dart';
import '../../features/profile/domain/repositories/i_wallet_repository.dart';
import '../api/api_client.dart';
import '../network/network_info.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  static const String _apiBaseUrl = 'https://api.example.com/v1';

  /// 初始化服务定位器
  static Future<void> init() async {
    // 注册基础依赖
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );

    // 注册SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

    // 注册InternetConnectionChecker
    sl.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker(),
    );

    sl.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
    );

    // 注册API客户端
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient.getInstance(
        baseUrl: _apiBaseUrl,
        token: '', // 初始为空，登录后更新
      ),
    );

    sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

    // 注册Profile模块数据源
    sl.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(
        sharedPreferences: sl<SharedPreferences>(),
      ),
    );

    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        dio: sl<Dio>(),
        storage: sl<FlutterSecureStorage>(),
      ),
    );

    // 注册Profile模块仓库
    sl.registerLazySingleton<IUserProfileRepository>(
      () => UserProfileRepositoryImpl(
        remoteDataSource: sl<ProfileRemoteDataSource>(),
        localDataSource: sl<ProfileLocalDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );

    sl.registerLazySingleton<IWalletRepository>(
      () => WalletRepositoryImpl(
        remoteDataSource: sl<ProfileRemoteDataSource>(),
        networkInfo: sl<NetworkInfo>(),
      ),
    );
  }

  /// 更新用户认证信息
  static void updateAuthInfo({required String token, required String userId}) {
    // 更新ApiClient中的token
    if (sl.isRegistered<ApiClient>()) {
      sl.unregister<ApiClient>();
    }

    sl.registerLazySingleton<ApiClient>(
      () => ApiClient.getInstance(
        baseUrl: _apiBaseUrl,
        token: token,
      ),
    );

    sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);
  }
}
