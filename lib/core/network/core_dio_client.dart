import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv

// REMOVED: const String _baseUrl = 'YOUR_API_BASE_URL';

@lazySingleton
class CoreDioClient {
  late final Dio _dio;

  CoreDioClient() {
    // Retrieve Base URL from environment variables
    final baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      // Handle error: Base URL not found or empty in .env
      // You might want to throw an error or use a default fallback
      print('Error: BACKEND_BASE_URL not found or empty in .env file.');
      // For now, let's throw an error to make it obvious during development
      throw Exception('BACKEND_BASE_URL must be set in the .env file');
    }

    final options = BaseOptions(
      baseUrl: baseUrl, // Use retrieved baseUrl
      connectTimeout: const Duration(milliseconds: 15000), // 15 seconds
      receiveTimeout: const Duration(milliseconds: 15000), // 15 seconds
      // Default Headers (can be overridden per request)
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // Add other common headers if needed (e.g., platform info)
      },
      // Allow handling responses with status codes outside 2xx range without throwing DioException
      // This allows us to parse custom error structures from the response body in the DataSource
      validateStatus: (status) {
        return status != null; // Allow all non-null status codes
      },
    );
    _dio = Dio(options);

    // Add interceptors (e.g., for logging, auth token)
    _dio.interceptors.add(LogInterceptor(
      responseBody: true,
      requestBody: true,
      requestHeader: true,
      responseHeader: false, // Optional: avoid verbose headers in log
    ));
    // Add Auth Interceptor
    _dio.interceptors.add(_AuthInterceptor());
  }

  // Provide helper methods to make requests using the configured Dio instance

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get(
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
     return _dio.post(
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
     return _dio.put(
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
     return _dio.delete(
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
      return _dio.post(
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

// Example Auth Interceptor (Uncommented and implemented with hardcoded test token)
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    String? token = await _getAuthToken(); // Retrieve the token
    if (token != null && token.isNotEmpty) {
      // Use the 'Authorization' header as specified in the example,
      // often backends expect this specific header.
      // Adjust 'Authorization' and the 'Bearer ' prefix if your backend expects something different.
      options.headers['Authorization'] = token; // Directly use the token from user
      // options.headers['Authorization'] = 'Bearer $token'; // Common Bearer token format
       print('[AuthInterceptor] Added token to header.');
    }
    super.onRequest(options, handler);
  }

  Future<String?> _getAuthToken() async {
     // TODO: Implement actual logic to retrieve the stored auth token
     // e.g., from SharedPreferences, FlutterSecureStorage, etc. when available.
     // For now, return the hardcoded test token.
     print("[AuthInterceptor] Using hardcoded test token.");
     return "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6ImQ1NzgyZDRjLTMwMmQtNGNjZS1iNzY0LTc0YmVhYmMwOTI4MCJ9.Pq9zB0Pc_cByYzuzogVeSJt6f0h-lXhEa7TXY8UuXkVogGi2eEJZBA6f9QjLzgFNB-ge1-aqH-mMj7fFLotS-w";
  }
} 