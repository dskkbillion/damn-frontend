import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/alipay_payment_service.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/api/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // 暂时不使用，避免大量日志输出
import 'package:dskk_flutter_refactor/core/network/interceptors/app_info_interceptor.dart';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:dskk_flutter_refactor/core/network/header_interceptor.dart';
import 'package:dskk_flutter_refactor/core/network/interceptors/unauthorized_logout_handler.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dskk_flutter_refactor/core/services/image_compress_service.dart';

// 添加缺失的依赖
import 'package:dskk_flutter_refactor/core/network/i_http_client.dart';
import 'package:dskk_flutter_refactor/core/network/dio_http_client.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';
import 'package:dskk_flutter_refactor/features/chat/di/chat_di.dart';

// Import database and DAO
import 'package:dskk_flutter_refactor/core/database/app_database.dart';

// Import seller module DI
import 'package:dskk_flutter_refactor/features/seller/di/seller_di.dart';

// Import auth module DI
import 'package:dskk_flutter_refactor/features/auth/di/auth_di.dart';

// Import ai_docs module DI
import 'package:dskk_flutter_refactor/features/ai_docs/di/ai_docs_di.dart';

// Import analytics module DI
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart';

// Import home module DI
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart';

// Import cache module DI
import 'package:dskk_flutter_refactor/core/cache/di/cache_injection.dart';
import 'package:dskk_flutter_refactor/core/network/interceptors/cache_interceptor.dart';

// Import orders module DI
import 'package:dskk_flutter_refactor/features/orders/di/orders_di.dart';
import 'package:dskk_flutter_refactor/features/after_sales/di/after_sales_di.dart';

// Import file upload service
import 'package:dskk_flutter_refactor/core/services/file_upload_service.dart';

// Import ProfilePreloader service
import 'package:dskk_flutter_refactor/core/services/profile_preloader_service.dart';
import 'package:dskk_flutter_refactor/core/cache/domain/interfaces/i_cache_manager.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/repositories/i_user_profile_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';
import 'package:dskk_flutter_refactor/features/home/domain/repositories/home_repository.dart';
import 'package:dskk_flutter_refactor/features/chat/data/datasources/i_chat_local_data_source.dart';

// Import payment related modules
import '../../features/payment/di/payment_di.dart';
import 'package:dskk_flutter_refactor/core/services/background_refresh_service.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';

final getIt = GetIt.instance;

// 注册ProfilePreloader服务
Future<void> registerProfilePreloaderService() async {
  if (!getIt.isRegistered<ProfilePreloaderService>()) {
    getIt.registerLazySingleton<ProfilePreloaderService>(
        () => ProfilePreloaderService(
              cacheManager: getIt<ICacheManager>(),
              userProfileRepository: getIt<IUserProfileRepository>(),
              orderRepository: getIt<IOrderRepository>(),
              sellerRepository: getIt<ISellerRepository>(),
              homeRepository: getIt<IHomeRepository>(),
              chatLocalDataSource: getIt<IChatLocalDataSource>(),
            ));
    AppLogger.d('[DI] Registered ProfilePreloaderService');
  } else {
    AppLogger.d(
        '[DI] ProfilePreloaderService already registered, skipping registration');
  }
}

Future<void> registerBackgroundRefreshService() async {
  if (!getIt.isRegistered<BackgroundRefreshService>()) {
    getIt.registerLazySingleton<BackgroundRefreshService>(
        () => BackgroundRefreshService(
              preloaderService: getIt<ProfilePreloaderService>(),
              secureStorage: getIt<ISecureStorageRepository>(),
            ));
    AppLogger.d('[DI] Registered BackgroundRefreshService');
  } else {
    AppLogger.d('[DI] BackgroundRefreshService already registered, skipping registration');
  }
}

// 注册用户仓库依赖
Future<void> registerAuthDependencies() async {
  // 注册IUserRepository（使用Chat模块的实现）
  if (!getIt.isRegistered<IUserRepository>()) {
    getIt.registerLazySingleton<IUserRepository>(
        () => ChatUserRepositoryImpl(getIt<FlutterSecureStorage>()));
    AppLogger.d('[DI] Registered IUserRepository (ChatUserRepositoryImpl)');
  } else {
    AppLogger.d(
        '[DI] IUserRepository already registered, skipping registration');
  }
}

Future<void> configureDependencies({required String backendBaseUrl}) async {
  // Register backendBaseUrl as named instance
  getIt.registerSingleton<String>(backendBaseUrl,
      instanceName: 'backendBaseUrl');
  AppLogger.d('[DI] Registered backendBaseUrl: $backendBaseUrl');

  // 手动初始化配置，代替generated文件
  await registerCoreDependencies();
  AppLogger.d('[DI] Core dependencies initialization complete.');

  // 注册用户仓库依赖 - 这一步要在其他模块之前
  await registerAuthDependencies();
  AppLogger.d('[DI] Auth dependencies initialization complete.');

  // 初始化Home模块依赖 - 必须在Chat模块之前，因为Chat依赖Home的IHomeRepository
  try {
    AppLogger.d('[DI] Starting Home module initialization...');
    await initHomeDi();
    AppLogger.d('[DI] Home module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize Home module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 初始化Chat模块依赖
  try {
    AppLogger.d('[DI] Starting Chat module initialization...');
    await ChatDI.init(getIt);
    AppLogger.d('[DI] Chat module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize Chat module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 初始化Auth模块依赖
  try {
    AppLogger.d('[DI] Starting Auth module initialization...');
    await AuthDI.init(getIt);
    AppLogger.d('[DI] Auth module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize Auth module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 注册支付模块依赖
  try {
    AppLogger.d('[DI] Starting Payment module initialization...');
    await PaymentDI.init(getIt);
    AppLogger.d('[DI] Payment module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize Payment module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 注册卖家模块依赖
  try {
    AppLogger.d('[DI] Starting Seller module initialization...');
    await SellerDI.init(getIt);
    AppLogger.d('[DI] Seller module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize Seller module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 初始化Analytics模块依赖
  try {
    AppLogger.d('[DI] Starting Analytics module initialization...');
    await initAnalyticsModule();
    AppLogger.d('[DI] Analytics module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize Analytics module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 初始化AI文档模块依赖
  try {
    AppLogger.d('[DI] Starting AI Docs module initialization...');
    await AiDocsDI.init(getIt);
    AppLogger.d('[DI] AI Docs module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize AI Docs module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 初始化订单模块依赖
  try {
    AppLogger.d('[DI] Starting Orders module initialization...');
    await OrdersDI.init(getIt);
    AppLogger.d('[DI] Orders module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize Orders module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 初始化售后模块依赖
  try {
    AppLogger.d('[DI] Starting After Sales module initialization...');
    await AfterSalesDI.init(getIt);
    AppLogger.d(
        '[DI] After Sales module dependencies initialization complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to initialize After Sales module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 注册ProfilePreloader服务
  try {
    AppLogger.d('[DI] Registering ProfilePreloader service...');
    await registerProfilePreloaderService();
    AppLogger.d('[DI] ProfilePreloader service registration complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to register ProfilePreloader service: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }

  // 注册BackgroundRefresh服务
  try {
    AppLogger.d('[DI] Registering BackgroundRefresh service...');
    await registerBackgroundRefreshService();
    AppLogger.d('[DI] BackgroundRefresh service registration complete.');
  } catch (e) {
    AppLogger.d('[DI] Failed to register BackgroundRefresh service: $e');
  }
}

// 注册核心依赖
Future<void> registerCoreDependencies() async {
  final packageInfo = await PackageInfo.fromPlatform();
  getIt.registerSingleton<PackageInfo>(packageInfo);

  // 注册FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage());

  // 注册Connectivity
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // 注册InternetConnectionChecker
  getIt.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker());

  // 注册NetworkInfo
  getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(getIt<InternetConnectionChecker>()));

  // 注册ImageCompressService
  getIt.registerLazySingleton<ImageCompressService>(
      () => ImageCompressService());
  AppLogger.d('[DI] Registered ImageCompressService');

  // 注册缓存系统
  CacheInjection.init(getIt);
  AppLogger.d('[DI] Registered Cache System');

  // 注册HTTP缓存管理器
  getIt.registerLazySingleton(() => CacheInterceptorManager());
  getIt.registerFactory<SmartCacheInterceptor>(() => SmartCacheInterceptor());
  AppLogger.d('[DI] Registered HTTP Cache Manager');

  // 注册AppDatabase
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // 注册AppInfoInterceptor
  getIt.registerLazySingleton<AppInfoInterceptor>(
      () => AppInfoInterceptor(getIt<PackageInfo>()));

  // 注册Dio
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = getIt<String>(instanceName: 'backendBaseUrl');
    AppLogger.d('Dio configured with Base URL: ${dio.options.baseUrl}');
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.contentType = 'application/json';

    // 创建并添加AuthInterceptor
    final authInterceptor = AuthInterceptor(getIt<FlutterSecureStorage>());

    dio.interceptors.add(getIt<AppInfoInterceptor>()); // 添加AppInfoInterceptor
    dio.interceptors.add(authInterceptor); // 添加AuthInterceptor
    dio.interceptors.add(HeaderInterceptor()); // 添加HeaderInterceptor

    // 添加日志拦截器，但限制大响应的日志输出
    dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        // 对聊天列表等大响应跳过日志记录
        final path = response.requestOptions.path;
        if (path.contains('/api/chat/list') ||
            path.contains('/api/chat/messages')) {
          // 只记录基本信息，不记录响应体
          AppLogger.d(
              '[HTTP] ${response.requestOptions.method} $path - Status: ${response.statusCode}');
        } else {
          // 对其他请求使用PrettyDioLogger
          // 这里无法直接调用PrettyDioLogger，所以只记录简单日志
          if (response.statusCode != 200 && response.statusCode != 201) {
            AppLogger.d(
                '[HTTP] ${response.requestOptions.method} $path - Status: ${response.statusCode}');
            if (response.data != null) {
              final dataStr = response.data.toString();
              if (dataStr.length < 1000) {
                AppLogger.d('[HTTP] Response: $dataStr');
              }
            }
          }
        }
        handler.next(response);
      },
      onRequest: (request, handler) {
        AppLogger.d('[HTTP] ${request.method} ${request.path}');
        handler.next(request);
      },
      onError: (error, handler) {
        AppLogger.d(
            '[HTTP ERROR] ${error.requestOptions.method} ${error.requestOptions.path}');
        AppLogger.d('[HTTP ERROR] ${error.message}');
        handler.next(error);
      },
    ));

    return dio;
  });

  // 添加：注册IHttpClient实现
  getIt.registerLazySingleton<IHttpClient>(() => DioHttpClient());
  AppLogger.d('[DI] Registered IHttpClient (DioHttpClient)');

  // 注册CoreDioClient（默认不带缓存）
  getIt.registerFactory<CoreDioClient>(() => CoreDioClient(
        getIt<String>(instanceName: 'backendBaseUrl'),
        getIt<FlutterSecureStorage>(),
        getIt<AppInfoInterceptor>(),
        null, // 默认不使用缓存
      ));

  // 注册带缓存的CoreDioClient
  getIt.registerFactory<CoreDioClient>(
    () => CoreDioClient(
      getIt<String>(instanceName: 'backendBaseUrl'),
      getIt<FlutterSecureStorage>(),
      getIt<AppInfoInterceptor>(),
      getIt<SmartCacheInterceptor>(), // 使用缓存拦截器
    ),
    instanceName: 'cachedDioClient',
  );

  // 注册Navigation Service mock
  getIt
      .registerLazySingleton<INavigationService>(() => MockNavigationService());

  // 注册ApiClient（如果尚未注册）
  if (!getIt.isRegistered<ApiClient>()) {
    final packageInfo = getIt<PackageInfo>();
    getIt.registerLazySingleton<ApiClient>(
      () => ApiClient.getInstance(
        baseUrl: getIt<String>(instanceName: 'backendBaseUrl'),
        token: null,
        version: packageInfo.buildNumber, // 使用真实的构建版本号
      ),
    );
  }

  // 注册FileUploadService
  getIt.registerLazySingleton<IFileUploadService>(
      () => FileUploadService(getIt<Dio>()));
  AppLogger.d('[DI] Registered FileUploadService');

  // 注册AlipayPaymentService (使用实际实现替代Mock)
  getIt.registerLazySingleton<IPaymentService>(() => AlipayPaymentService(
        getIt<ApiClient>(),
      ));
}

// Auth Interceptor using FlutterSecureStorage
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // 记录进入拦截器前的Headers状态
    AppLogger.d(
        '[AuthInterceptor] 进入拦截器，当前path: ${options.path}, headers: ${options.headers}');

    // Skip adding token for auth endpoints
    if (options.path.contains('/api/auth/login') ||
        options.path.contains('/api/auth/register') ||
        options.path.contains('/api/auth/sms')) {
      AppLogger.d(
          '[AuthInterceptor] Skipping token for auth path: ${options.path}');
      return handler.next(options);
    }

    String? token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = token; // 直接使用token，不添加Bearer前缀
      AppLogger.d(
          '[AuthInterceptor] Added token to Authorization header: ${token.substring(0, 15)}...');
    } else {
      AppLogger.d(
          '[AuthInterceptor] No token found. Request proceeding without Authorization header.');
    }

    // 记录最终的Headers状态
    AppLogger.d('[AuthInterceptor] 最终headers: ${options.headers}');

    handler.next(options);
  }

  Future<String?> _getAuthToken() async {
    try {
      const storageKey = 'auth_token';
      final token = await _storage.read(key: storageKey);
      if (token != null) {
        AppLogger.d('[AuthInterceptor] Token retrieved from secure storage.');
      } else {
        AppLogger.d(
            '[AuthInterceptor] Token not found in secure storage (key: $storageKey).');
      }
      return token;
    } catch (e) {
      AppLogger.d(
          '[AuthInterceptor] Error reading token from secure storage: $e');
      return null;
    }
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    await UnauthorizedLogoutHandler.handle(err);
    handler.next(err);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    await UnauthorizedLogoutHandler.handleResponse(response);
    handler.next(response);
  }
}
