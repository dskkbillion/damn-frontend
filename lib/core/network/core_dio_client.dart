import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
import 'package:pretty_dio_logger/pretty_dio_logger.dart'; // Remove alias
import 'interceptors/app_info_interceptor.dart'; // Import the new interceptor

// import 'interceptors/auth_interceptor.dart';
// import 'interceptors/pretty_log_interceptor.dart';

// REMOVED: const String _baseUrl = 'YOUR_API_BASE_URL';

@injectable
class CoreDioClient {
  late final Dio dio;
  final FlutterSecureStorage _secureStorage;
  final AppInfoInterceptor _appInfoInterceptor; // Add AppInfoInterceptor dependency

  CoreDioClient(
    @Named('baseUrl') String baseUrl,
    this._secureStorage, // Inject storage directly if AuthInterceptor isn't injectable
    this._appInfoInterceptor, // Inject AppInfoInterceptor
  ) {
    print('[CoreDioClient] Initializing with baseUrl: $baseUrl');
    try {
      if (baseUrl.isEmpty) {
        throw Exception('[CoreDioClient] BACKEND_BASE_URL is null or empty. Cannot initialize Dio.');
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
      
      // Add Dio's built-in LogInterceptor instead
      final basicLogInterceptor = LogInterceptor(
          requestBody: true, 
          responseBody: true
      );

      dio.interceptors.add(_appInfoInterceptor); // Add AppInfoInterceptor FIRST (or adjust order as needed)
      dio.interceptors.add(authInterceptor);
      // dio.interceptors.add(logInterceptor); // Keep commented out
      dio.interceptors.add(basicLogInterceptor); // Add the built-in logger
      
      print('[CoreDioClient] Dio initialized successfully.');
    } catch (e) {
      print('[CoreDioClient] Error initializing Dio: $e');
      throw Exception('[CoreDioClient] Failed to initialize Dio due to error: $e'); 
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
        options: options ?? Options(contentType: 'multipart/form-data'), // Ensure content type
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
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip adding token for auth endpoints
    if (options.path.contains('/api/auth/login') || 
        options.path.contains('/api/auth/register') ||
        options.path.contains('/api/auth/sms')) {
      print('[AuthInterceptor] Skipping token for auth path: ${options.path}');
      return handler.next(options);
    }

    // --- Restore async logic --- 
    String? token = await _getAuthToken();
    if (token != null && token.isNotEmpty) {
      // Add Bearer prefix and use correct key
      options.headers['Authorization'] = 'Bearer $token'; 
      print('[AuthInterceptor] Added Bearer token to Authorization header.'); // Updated log
    } else {
       print('[AuthInterceptor] No token found. Request proceeding without Authorization header.');
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
        print('[AuthInterceptor] Token retrieved from secure storage.');
      } else {
        print('[AuthInterceptor] Token not found in secure storage (key: $storageKey).');
      }
      return token;
    } catch (e) {
      print('[AuthInterceptor] Error reading token from secure storage: $e');
      return null; // Return null on error
    }
  }
} 
    }
  }
} 