import 'package:dskk_flutter_refactor/core/network/interceptors/safe_network_log_interceptor.dart';

/// A Dio interceptor for logging network requests, responses, and errors.
class LoggingInterceptor extends SafeNetworkLogInterceptor {}

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
