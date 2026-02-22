import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';

/// A Dio interceptor for logging network requests, responses, and errors.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d(
        '--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}');
    AppLogger.d('Headers:');
    options.headers.forEach((k, v) => AppLogger.d('  $k: $v'));
    if (options.queryParameters.isNotEmpty) {
      AppLogger.d('queryParameters:');
      options.queryParameters.forEach((k, v) => AppLogger.d('  $k: $v'));
    }
    if (options.data != null) {
      AppLogger.d('Body: ${options.data}');
    }
    AppLogger.d('--> END ${options.method.toUpperCase()}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d(
      '<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    AppLogger.d('Headers:');
    response.headers.forEach((k, v) => AppLogger.d('  $k: $v'));
    // AppLogger.d('Response: ${response.data}'); // Be careful logging large responses
    AppLogger.d('<-- END HTTP');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.d(
      '<-- ${err.message} ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    AppLogger.d('Error type: ${err.type}');
    if (err.response != null) {
      AppLogger.d('Error response status: ${err.response?.statusCode}');
      // AppLogger.d('Error response data: ${err.response?.data}'); // Be careful logging error data
    }
    AppLogger.d('<-- END ERROR');
    return super.onError(err, handler);
  }
}

// Example of an AuthInterceptor (You would need to implement token storage/retrieval)
/*
import 'package:shared_preferences/shared_preferences.dart'; // or secure storage

class AuthInterceptor extends Interceptor {
  // final TokenStorageService tokenStorage; // Inject your token storage

  // AuthInterceptor(this.tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // final token = await tokenStorage.getToken();
    const token = "YOUR_STATIC_TOKEN_FOR_NOW"; // Replace with actual token retrieval
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      AppLogger.d('Added Authorization header');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized error, e.g., refresh token or logout
      AppLogger.d('!!! Unauthorized request - 401 !!!');
      // Example: Trigger logout event
      // getIt<AuthBloc>().add(LogoutRequested());
    }
    return super.onError(err, handler);
  }
}
*/ 