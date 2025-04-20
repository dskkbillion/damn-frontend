import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import the generated file
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'init', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async => init(getIt);

/// 应用级别依赖注入容器
///
/// 负责注册应用级别的服务，如网络客户端、偏好设置等共享资源
Future<void> init(GetIt locator) async {
  // 核心服务 - 单例

  // Dio - HTTP客户端
  locator.registerLazySingleton(() {
    final dio = Dio();
    // 配置Dio实例
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.contentType = 'application/json';

    // 拦截器配置
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    return dio;
  });

  // 共享偏好设置
  final sharedPreferences = await SharedPreferences.getInstance();
  locator.registerLazySingleton(() => sharedPreferences);

  // 网络连接检查器
  locator.registerLazySingleton(() => InternetConnectionChecker());
}

// Later, you will register your modules/services like this:
// @module
// abstract class RegisterModule {
//   @lazySingleton
//   MyService get myService => MyServiceImpl();
// }
