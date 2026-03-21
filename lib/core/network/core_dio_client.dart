import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
// import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // 暂时不使用，避免大量日志输出
import 'interceptors/app_info_interceptor.dart'; // Import the new interceptor
import 'interceptors/cache_interceptor.dart'; // Import cache interceptor
import 'interceptors/unauthorized_logout_handler.dart';

// import 'interceptors/auth_interceptor.dart';
// import 'interceptors/pretty_log_interceptor.dart';

// REMOVED: const String _baseUrl = 'YOUR_API_BASE_URL';

@injectable
class CoreDioClient {
  late final Dio dio;
  final FlutterSecureStorage _secureStorage;
  final AppInfoInterceptor
      _appInfoInterceptor; // Add AppInfoInterceptor dependency
  final SmartCacheInterceptor?
      _cacheInterceptor; // Cache interceptor (optional)

  CoreDioClient(
    @Named('baseUrl') String baseUrl,
    this._secureStorage, // Inject storage directly if AuthInterceptor isn't injectable
    this._appInfoInterceptor, // Inject AppInfoInterceptor
    @factoryParam this._cacheInterceptor, // Optional cache interceptor
  ) {
    AppLogger.d('[CoreDioClient] Initializing with baseUrl: $baseUrl');
    try {
      if (baseUrl.isEmpty) {
        throw Exception(
            '[CoreDioClient] BACKEND_BASE_URL is null or empty. Cannot initialize Dio.');
      }

      final options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      );
      dio = Dio(options);

      // Add interceptors
      // Pass the injected storage to AuthInterceptor
      final authInterceptor = AuthInterceptor(_secureStorage);
      // Comment out PrettyLogInterceptor due to persistent Linter issues
      // final logInterceptor = PrettyLogInterceptor(
      //     requestHeader: true,
      //     requestBody: true,
      //     responseBody: true,
      //     responseHeader: false,
      //     error: true,
      //     compact: true,
      //     maxWidth: 90);

      // Add custom LogInterceptor with conditional response body logging
      final basicLogInterceptor = LogInterceptor(
          requestBody: true,
          responseBody: false, // 默认不打印响应体
          responseHeader: false,
          logPrint: (o) {
            // 过滤掉聊天相关的大量日志
            final logStr = o.toString();
            if (!logStr.contains('/api/chat/list') &&
                !logStr.contains('chatMessageNewVo') &&
                !logStr.contains('productVo')) {
              AppLogger.d(logStr);
            }
          });

      dio.interceptors.add(
          _appInfoInterceptor); // Add AppInfoInterceptor FIRST (or adjust order as needed)

      // 添加缓存拦截器（如果提供了）
      if (_cacheInterceptor != null) {
        dio.interceptors.add(_cacheInterceptor);
        AppLogger.d('[CoreDioClient] Cache interceptor added');
      }

      dio.interceptors.add(authInterceptor);
      // dio.interceptors.add(logInterceptor); // Keep commented out
      dio.interceptors.add(basicLogInterceptor); // Add the built-in logger

      AppLogger.d('[CoreDioClient] Dio initialized successfully.');
    } catch (e) {
      AppLogger.d('[CoreDioClient] Error initializing Dio: $e');
      throw Exception(
          '[CoreDioClient] Failed to initialize Dio due to error: $e');
    }
  }

  // Provide helper methods to make requests using the configured Dio instance

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Method for file uploads
  Future<Response<T>> postMultipart<T>(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return dio.post(
      path,
      data: formData,
      queryParameters: queryParameters,
      options: options ??
          Options(contentType: 'multipart/form-data'), // Ensure content type
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

// Auth Interceptor using FlutterSecureStorage
class AuthInterceptor extends Interceptor {
  // Inject FlutterSecureStorage instead of creating it
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage); // Constructor to receive storage

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip adding token for auth endpoints
    if (options.path.contains('/api/auth/login') ||
        options.path.contains('/api/auth/register') ||
        options.path.contains('/api/auth/sms')) {
      AppLogger.d(
          '[AuthInterceptor] Skipping token for auth path: ${options.path}');
      return handler.next(options);
    }

    // --- Restore async logic ---
    String? token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      // Add Bearer prefix and use correct key
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.d(
          '[AuthInterceptor] Added Bearer token to Authorization header.'); // Updated log
    } else {
      AppLogger.d(
          '[AuthInterceptor] No token found. Request proceeding without Authorization header.');
    }
    // --- End restore ---

    handler.next(options);
  }

  Future<String?> _getAuthToken() async {
    // Read the token from secure storage using the correct key
    try {
      const storageKey = 'auth_token'; // CORRECT KEY
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
      return null; // Return null on error
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
