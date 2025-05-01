import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient._({required Dio dio}) : _dio = dio;

  static ApiClient? _instance;

  /// 获取ApiClient单例实例
  static ApiClient getInstance({
    required String baseUrl,
    String? token,
    int connectTimeout = 15000,
    int receiveTimeout = 15000,
    int sendTimeout = 15000,
  }) {
    _instance ??= ApiClient._(
      dio: Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(milliseconds: connectTimeout),
          receiveTimeout: Duration(milliseconds: receiveTimeout),
          sendTimeout: Duration(milliseconds: sendTimeout),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      ),
    );

    // 添加日志拦截器
    if (!_instance!._dio.interceptors.any((i) => i is LogInterceptor)) {
      _instance!._dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    return _instance!;
  }

  /// 获取底层Dio实例
  Dio get dio => _dio;
}
