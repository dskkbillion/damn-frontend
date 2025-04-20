import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/config/app_config.dart'; // Assuming AppConfig holds the base API URL
import '../../core/network/dio_interceptor.dart'; // Assuming you have/will create interceptors

// Import the generated file
import 'injection_container.config.dart'; 

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'init', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async => init(getIt);

// Register Connectivity using a top-level function
@lazySingleton
Connectivity get connectivity => Connectivity();

// Register Dio using a top-level function (Simplified for debugging)
@lazySingleton
Dio get dio {
  print('--- Creating Simple Dio Instance (Top-Level) --- '); // Add log
  // Return a very basic Dio instance, without AppConfig or interceptors
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://placeholder.base.url', // Use a placeholder
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );
  // Temporarily remove interceptors
  // dio.interceptors.add(LoggingInterceptor());
  print('--- Simple Dio Instance (Top-Level) Created --- ');
  return dio;
}

// You might need to create interceptor files like:
// lib/core/network/dio_interceptor.dart
/*
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    return super.onError(err, handler);
  }
}
*/

// Later, you will register your modules/services like this:
// @module
// abstract class RegisterModule {
//   @lazySingleton
//   MyService get myService => MyServiceImpl();
// } 