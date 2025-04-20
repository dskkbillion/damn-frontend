import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile/data/repositories/wallet_repository_impl.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/profile/domain/repositories/wallet_repository.dart';
import '../api/api_client.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  static const String _apiBaseUrl = 'https://api.example.com/v1';

  /// 初始化服务定位器
  static Future<void> init() async {
    // 注册API客户端
    sl.registerLazySingleton<ApiClient>(
      () => ApiClient.getInstance(
        baseUrl: _apiBaseUrl,
        token: '', // 初始为空，登录后更新
      ),
    );

    sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

    // 注册Profile模块数据源
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        dio: sl<Dio>(),
        token: '', // 初始为空，登录后更新
        userId: '', // 初始为空，登录后更新
      ),
    );

    // 注册Profile模块仓库
    sl.registerLazySingleton<UserProfileRepository>(
      () => UserProfileRepositoryImpl(
        remoteDataSource: sl<ProfileRemoteDataSource>(),
      ),
    );

    sl.registerLazySingleton<WalletRepository>(
      () => WalletRepositoryImpl(
        remoteDataSource: sl<ProfileRemoteDataSource>(),
      ),
    );
  }

  /// 更新用户认证信息
  static void updateAuthInfo({required String token, required String userId}) {
    // 重新注册ProfileRemoteDataSource
    if (sl.isRegistered<ProfileRemoteDataSource>()) {
      sl.unregister<ProfileRemoteDataSource>();
    }

    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        dio: sl<Dio>(),
        token: token,
        userId: userId,
      ),
    );

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
