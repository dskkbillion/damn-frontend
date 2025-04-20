import 'package:dio/dio.dart';

/// A Dio interceptor for logging network requests, responses, and errors.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(
        '--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}');
    print('Headers:');
    options.headers.forEach((k, v) => print('  $k: $v'));
    if (options.queryParameters.isNotEmpty) {
      print('queryParameters:');
      options.queryParameters.forEach((k, v) => print('  $k: $v'));
    }
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    print('--> END ${options.method.toUpperCase()}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    print('Headers:');
    response.headers.forEach((k, v) => print('  $k: $v'));
    // print('Response: ${response.data}'); // Be careful logging large responses
    print('<-- END HTTP');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      '<-- ${err.message} ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}',
    );
    print('Error type: ${err.type}');
    if (err.response != null) {
      print('Error response status: ${err.response?.statusCode}');
      // print('Error response data: ${err.response?.data}'); // Be careful logging error data
    }
    print('<-- END ERROR');
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
      print('Added Authorization header');
    }
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized error, e.g., refresh token or logout
      print('!!! Unauthorized request - 401 !!!');
      // Example: Trigger logout event
      // getIt<AuthBloc>().add(LogoutRequested());
    }
    return super.onError(err, handler);
  }
}
*/ 