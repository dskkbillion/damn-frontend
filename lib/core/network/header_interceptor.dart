import 'package:dio/dio.dart';

class HeaderInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add required headers here
    // TODO: Replace hardcoded values with actual app info later
    options.headers['clienttype'] = '1';       // Example value
    options.headers['client'] = 'android';   // Example value
    options.headers['version'] = '100';      // Example value

    // Add Authorization header with the provided token
    // WARNING: Hardcoding token here is NOT recommended for production.
    // Token should ideally come from auth state/storage and be added via AuthInterceptor.
    const String token = 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjA5NjhhMDNkLTM1NzYtNDkzZi1iMjA5LTc2YWEzMzMwYzYzMCJ9.AJ_IIJypohoKS_5EJa7bpE5erREM9qqbFXNoeaTaD0tpGSDhaqcdeccjU2y4z3Y_MuXWyzBCoq24HPna6itjJQ'; // UPDATE: New Token
    options.headers['Authorization'] = token; // Assuming no "Bearer " prefix is needed based on OpenAPI examples

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