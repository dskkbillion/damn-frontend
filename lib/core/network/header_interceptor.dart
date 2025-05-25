import 'package:dio/dio.dart';
// import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart'; // Temporarily removed
import 'package:get_it/get_it.dart'; 
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage directly

class HeaderInterceptor extends Interceptor {
  // Temporary: Directly use FlutterSecureStorage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Constructor no longer needs injection for this temporary fix
  // HeaderInterceptor({required this.secureStorageRepository});

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 记录进入拦截器前的Headers状态
    print('[HeaderInterceptor] 进入拦截器，当前headers: ${options.headers}');
    
    // Add required headers here
    // TODO: Replace hardcoded values with actual app info later
    options.headers['clienttype'] = '1';       // Example value
    options.headers['client'] = 'android';   // Example value
    options.headers['version'] = '100';      // Example value

    // 检查是否已存在Authorization头，避免重复添加
    if (!options.headers.containsKey('Authorization')) {
      // 修正：使用正确的auth_token键名
      final String? token = await _secureStorage.read(key: 'auth_token'); 
      
      // 调试：检查token是否存在
      if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = token; // 直接使用token，不添加Bearer前缀
          print('[HeaderInterceptor] 成功添加Authorization头: ${token.substring(0, 15)}...');
      } else {
          print('[HeaderInterceptor] 警告: 在secure storage中未找到auth_token');
          // 尝试查找是否有备用token
          final userToken = await _secureStorage.read(key: 'user_token');
          if (userToken != null && userToken.isNotEmpty) {
              print('[HeaderInterceptor] 找到备用token (user_token)');
              options.headers['Authorization'] = userToken; // 旧格式不添加Bearer
          }
      }
    } else {
      print('[HeaderInterceptor] Authorization头已存在，值为: ${options.headers['Authorization']}');
    }

    print('[HeaderInterceptor] 最终headers: ${options.headers}'); 
    super.onRequest(options, handler);
  }

  // Optionally implement onResponse and onError for logging or other actions
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // print('[HeaderInterceptor] Response received: ${response.statusCode}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // print('[HeaderInterceptor] Error occurred: ${err.message}');
    super.onError(err, handler);
  }
} 