import 'dart:io' show Platform;
import 'dart:ui' show PlatformDispatcher;
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:dio/dio.dart';
// import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart'; // Temporarily removed
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage directly
import 'package:shared_preferences/shared_preferences.dart';

class HeaderInterceptor extends Interceptor {
  HeaderInterceptor({
    Future<SharedPreferences> Function()? preferencesLoader,
    Future<String?> Function(String key)? secureStorageReader,
  })  : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance,
        _secureStorageReader = secureStorageReader ??
            ((key) => const FlutterSecureStorage().read(key: key));

  final Future<SharedPreferences> Function() _preferencesLoader;
  final Future<String?> Function(String key) _secureStorageReader;

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    AppLogger.d('[HeaderInterceptor] 处理请求: ${options.path}');

    // Add required headers here
    // 根据实际平台设置client头
    options.headers['clienttype'] = '1'; // 固定值
    options.headers['client'] = Platform.isAndroid
        ? 'android'
        : (Platform.isIOS ? 'ios' : 'unknown'); // 根据平台动态设置
    options.headers['version'] = '100'; // 固定版本号

    final isAuthRequest = _isAuthRequest(options.path);
    final hasAuthorization = options.headers.containsKey('Authorization');
    // 认证请求和已经显式带 token 的请求都不需要读取本地平台存储。
    // 这些调用发生在 Dio adapter 之前，平台通道异常或挂起会让请求根本
    // 到不了后端；认证请求使用系统语言作为无状态回退。
    if (isAuthRequest || hasAuthorization) {
      options.headers['Accept-Language'] =
          PlatformDispatcher.instance.locale.languageCode;
      AppLogger.d(
        '[HeaderInterceptor] ${isAuthRequest ? 'auth endpoint' : 'explicit auth'}; '
        'skipping credential reads',
      );
      handler.next(options);
      return;
    }

    // 其他请求保留原有的语言和凭据读取行为。
    final prefs = await _preferencesLoader();
    final appLanguage = prefs.getString('app_language');
    final language =
        appLanguage ?? PlatformDispatcher.instance.locale.languageCode;
    options.headers['Accept-Language'] = language;

    // 检查是否已存在Authorization头，避免重复添加
    if (!options.headers.containsKey('Authorization')) {
      // 修正：使用正确的auth_token键名
      final String? token = await _secureStorageReader('auth_token');

      // 调试：检查token是否存在
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.d('[HeaderInterceptor] 成功添加Authorization头');
      } else {
        AppLogger.d('[HeaderInterceptor] 警告: 在secure storage中未找到auth_token');
        // 尝试查找是否有备用token
        final userToken = await _secureStorageReader('user_token');
        if (userToken != null && userToken.isNotEmpty) {
          AppLogger.d('[HeaderInterceptor] 找到备用token (user_token)');
          options.headers['Authorization'] = 'Bearer $userToken';
        }
      }
    } else {
      AppLogger.d('[HeaderInterceptor] Authorization头已存在');
    }

    AppLogger.d(
      '[HeaderInterceptor] headers ready, auth='
      '${options.headers.containsKey('Authorization') ? 'present' : 'missing'}',
    );
    super.onRequest(options, handler);
  }

  bool _isAuthRequest(String path) {
    return path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/sms') ||
        path.contains('/api/common/send-code/login');
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
