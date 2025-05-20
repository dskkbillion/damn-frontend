import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/alipay_payment_service.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:dskk_flutter_refactor/core/network/interceptors/app_info_interceptor.dart';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
import 'package:dskk_flutter_refactor/core/network/header_interceptor.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// 添加缺失的依赖
import 'package:dskk_flutter_refactor/core/network/i_http_client.dart';
import 'package:dskk_flutter_refactor/core/network/dio_http_client.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_user_repository.dart';
import 'package:dskk_flutter_refactor/features/chat/di/chat_di.dart';

// Import database and DAO
import 'package:dskk_flutter_refactor/core/database/app_database.dart';

// Import chat module DI
import 'package:dskk_flutter_refactor/features/chat/di/chat_di.dart';

// Import seller module DI
import 'package:dskk_flutter_refactor/features/seller/di/seller_di.dart';

// Import payment related modules
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/orders/domain/usecases/create_order_use_case.dart';

final getIt = GetIt.instance;

// 初始化函数，用于替代generated文件中的init函数
Future<void> configurePaymentDependencies() async {
  // 注册PaymentBloc
  if (!getIt.isRegistered<PaymentBloc>()) {
    getIt.registerFactory<PaymentBloc>(() => PaymentBloc(
          createOrderUseCase: getIt<CreateOrderUseCase>(),
          paymentService: getIt<IPaymentService>(),
        ));
    print('[DI] Registered PaymentBloc');
  } else {
    print('[DI] PaymentBloc already registered, skipping registration');
  }
}

// 注册用户仓库依赖
Future<void> registerAuthDependencies() async {
  // 注册IUserRepository（使用Chat模块的实现）
  if (!getIt.isRegistered<IUserRepository>()) {
    getIt.registerLazySingleton<IUserRepository>(() => ChatUserRepositoryImpl(
      getIt<FlutterSecureStorage>()
    ));
    print('[DI] Registered IUserRepository (ChatUserRepositoryImpl)');
  } else {
    print('[DI] IUserRepository already registered, skipping registration');
  }
}

Future<void> configureDependencies({required String backendBaseUrl}) async {
  // Register backendBaseUrl as named instance 
  getIt.registerSingleton<String>(backendBaseUrl, instanceName: 'backendBaseUrl');
  print('[DI] Registered backendBaseUrl: $backendBaseUrl');

  // 手动初始化配置，代替generated文件
  await registerCoreDependencies();
  print('[DI] Core dependencies initialization complete.');
  
  // 注册用户仓库依赖 - 这一步要在其他模块之前
  await registerAuthDependencies();
  print('[DI] Auth dependencies initialization complete.');
  
  // 注册支付模块依赖
  await configurePaymentDependencies();
  print('[DI] Payment dependencies initialization complete.');
  
  // 注册聊天模块所需的额外依赖（特别是带参数的BLoC）
  registerChatBlocs();
  print('[DI] Chat module blocs registered.');
  
  // 注册卖家模块依赖
  try {
    print('[DI] Starting Seller module initialization...');
    await SellerDI.init(getIt);
    print('[DI] Seller module dependencies initialization complete.');
  } catch (e) {
    print('[DI] Failed to initialize Seller module: $e');
    // 不抛出异常，允许应用继续启动，但记录错误信息
  }
}

// 注册聊天模块的BLoC
void registerChatBlocs() {
  // 注册ChatMessagesBloc，需要额外的chatId参数
  registerChatMessagesBloc(getIt);
}

// 注册核心依赖
Future<void> registerCoreDependencies() async {
  final packageInfo = await PackageInfo.fromPlatform();
  getIt.registerSingleton<PackageInfo>(packageInfo);
  
  // 注册FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  
  // 注册Connectivity
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());
  
  // 注册InternetConnectionChecker
  getIt.registerLazySingleton<InternetConnectionChecker>(() => InternetConnectionChecker());
  
  // 注册NetworkInfo
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt<InternetConnectionChecker>()));
  
  // 注册AppDatabase
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());
  
  // 注册AppInfoInterceptor
  getIt.registerLazySingleton<AppInfoInterceptor>(() => AppInfoInterceptor(getIt<PackageInfo>()));
  
  // 注册Dio
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = getIt<String>(instanceName: 'backendBaseUrl');
    print('Dio configured with Base URL: ${dio.options.baseUrl}');
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.contentType = 'application/json';

    // 创建并添加AuthInterceptor
    final authInterceptor = AuthInterceptor(getIt<FlutterSecureStorage>()); 

    dio.interceptors.add(getIt<AppInfoInterceptor>()); // 添加AppInfoInterceptor
    dio.interceptors.add(authInterceptor);   // 添加AuthInterceptor
    dio.interceptors.add(HeaderInterceptor()); // 添加HeaderInterceptor
    
    // 添加日志拦截器
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90));
    
    return dio;
  });
  
  // 添加：注册IHttpClient实现
  getIt.registerLazySingleton<IHttpClient>(() => DioHttpClient());
  print('[DI] Registered IHttpClient (DioHttpClient)');
  
  // 注册CoreDioClient
  getIt.registerFactory<CoreDioClient>(() => CoreDioClient(
    getIt<String>(instanceName: 'backendBaseUrl'),
    getIt<FlutterSecureStorage>(),
    getIt<AppInfoInterceptor>(),
  ));
  
  // 注册Navigation Service mock
  getIt.registerLazySingleton<INavigationService>(() => MockNavigationService());

  // 注册AlipayPaymentService (使用实际实现替代Mock)
  getIt.registerLazySingleton<IPaymentService>(() => AlipayPaymentService(
    getIt<Dio>(),
    getIt<NetworkInfo>(),
  ));
}

// Auth Interceptor using FlutterSecureStorage
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip adding token for auth endpoints
    if (options.path.contains('/api/auth/login') || 
        options.path.contains('/api/auth/register') ||
        options.path.contains('/api/auth/sms')) {
      print('[AuthInterceptor] Skipping token for auth path: ${options.path}');
      return handler.next(options);
    }

    String? token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token'; 
      print('[AuthInterceptor] Added Bearer token to Authorization header.');
    } else {
       print('[AuthInterceptor] No token found. Request proceeding without Authorization header.');
    }
    
    handler.next(options); 
  }

  Future<String?> _getAuthToken() async {
    try {
      const storageKey = 'auth_token';
      final token = await _storage.read(key: storageKey);
      if (token != null) {
        print('[AuthInterceptor] Token retrieved from secure storage.');
      } else {
        print('[AuthInterceptor] Token not found in secure storage (key: $storageKey).');
      }
      return token;
    } catch (e) {
      print('[AuthInterceptor] Error reading token from secure storage: $e');
      return null;
    }
  }
}
