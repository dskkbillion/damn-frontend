import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'package:dskk_flutter_refactor/core/network/interceptors/unauthorized_logout_handler.dart';

class ApiClient {
  final Dio _dio;

  ApiClient._({required Dio dio}) : _dio = dio;

  static ApiClient? _instance;

  /// 获取ApiClient单例实例
  static ApiClient getInstance({
    required String baseUrl,
    String? token,
    String? version, // 保留参数但不使用，避免破坏API
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
            // 移除重复的Header设置，让AppInfoInterceptor负责设置:
            // - client
            // - version  
            // - clienttype
            // 移除静态token，让AuthInterceptor动态获取
          },
        ),
      ),
    );

    // 添加必要的拦截器
    if (!_instance!._dio.interceptors.any((i) => i is LogInterceptor)) {
      // 添加AppInfo拦截器
      _instance!._dio.interceptors.add(_createAppInfoInterceptor());
      
      // 添加Auth拦截器（动态获取Token）
      _instance!._dio.interceptors.add(_createAuthInterceptor());
      
      // 添加日志拦截器
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

  /// 创建AppInfo拦截器
  static Interceptor _createAppInfoInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // 添加后端期望的头信息
        options.headers['clienttype'] = '1'; // 固定值
        options.headers['client'] = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
        options.headers['version'] = '100'; // 使用固定值100
        
        handler.next(options);
      },
    );
  }

  /// 创建Auth拦截器（动态获取Token）
  static Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 跳过认证端点
        if (options.path.contains('/api/auth/login') || 
            options.path.contains('/api/auth/register') ||
            options.path.contains('/api/auth/sms')) {
          return handler.next(options);
        }

        // 从SecureStorage动态获取Token
        try {
          const storage = FlutterSecureStorage();
          const storageKey = 'auth_token';
          final token = await storage.read(key: storageKey);
          
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = token; // 直接使用token，不添加Bearer前缀
            AppLogger.d('[ApiClient AuthInterceptor] Added token to request');
          } else {
            AppLogger.d('[ApiClient AuthInterceptor] No token found in secure storage');
          }
        } catch (e) {
          AppLogger.d('[ApiClient AuthInterceptor] Error reading token: $e');
        }
        
        handler.next(options);
      },
      onError: (err, handler) async {
        await UnauthorizedLogoutHandler.handle(err);
        handler.next(err);
      },
    );
  }

  /// 更新Header参数
  void updateHeaders(Map<String, String> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// 获取底层Dio实例
  Dio get dio => _dio;
}
