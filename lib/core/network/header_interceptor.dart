import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
// import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart'; // Temporarily removed
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage directly
import 'package:shared_preferences/shared_preferences.dart';

class HeaderInterceptor extends Interceptor {
  // Temporary: Directly use FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Constructor no longer needs injection for this temporary fix
  // HeaderInterceptor({required this.secureStorageRepository});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 记录进入拦截器前的Headers状态
    AppLogger.d('[HeaderInterceptor] 进入拦截器，当前headers: ${options.headers}');
    
    // Add required headers here
    // 根据实际平台设置client头
    options.headers['clienttype'] = '1';       // 固定值
    options.headers['client'] = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');   // 根据平台动态设置
    options.headers['version'] = '100';      // 固定版本号

    // 获取语言设置：优先使用 App 内语言设置，否则跟随系统语言
    final prefs = await SharedPreferences.getInstance();
    final appLanguage = prefs.getString('app_language');
    final language = appLanguage ?? PlatformDispatcher.instance.locale.languageCode;
    options.headers['Accept-Language'] = language;

    // 检查是否已存在Authorization头，避免重复添加
    if (!options.headers.containsKey('Authorization')) {
      // 修正：使用正确的auth_token键名
      final String? token = await _secureStorage.read(key: 'auth_token'); 
      
      // 调试：检查token是否存在
      if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          AppLogger.d('[HeaderInterceptor] 成功添加Authorization头');
      } else {
          AppLogger.d('[HeaderInterceptor] 警告: 在secure storage中未找到auth_token');
          // 尝试查找是否有备用token
          final userToken = await _secureStorage.read(key: 'user_token');
          if (userToken != null && userToken.isNotEmpty) {
              AppLogger.d('[HeaderInterceptor] 找到备用token (user_token)');
              options.headers['Authorization'] = 'Bearer $userToken';
          }
      }
    } else {
      AppLogger.d('[HeaderInterceptor] Authorization头已存在');
    }

    // 过滤敏感信息后记录headers
    final safeHeaders = Map<String, dynamic>.from(options.headers)
      ..['Authorization'] = options.headers.containsKey('Authorization') ? '[REDACTED]' : 'N/A';
    AppLogger.d('[HeaderInterceptor] 最终headers: $safeHeaders'); 
    super.onRequest(options, handler);
  }

  // Optionally implement onResponse and onError for logging or other actions
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // AppLogger.d('[HeaderInterceptor] Response received: ${response.statusCode}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // AppLogger.d('[HeaderInterceptor] Error occurred: ${err.message}');
    super.onError(err, handler);
  }
} 