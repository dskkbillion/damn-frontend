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
    // Add required headers here
    // TODO: Replace hardcoded values with actual app info later
    options.headers['clienttype'] = '1';       // Example value
    options.headers['client'] = 'android';   // Example value
    options.headers['version'] = '100';      // Example value

    // Dynamically read token from secure storage using the correct key
    // IMPORTANT: Use the key that main_chat_preview.dart writes!
    final String? token = await _secureStorage.read(key: 'user_token'); 

    if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = token; // Assuming no "Bearer " prefix needed yet
    } else {
       print('[HeaderInterceptor] Warning: Token not found in secure storage using key: user_token');
    }

    print('[HeaderInterceptor] Added headers: ${options.headers}'); 
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