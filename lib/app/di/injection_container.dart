import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/mocks/mock_payment_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

// Import database and DAO
import 'package:dskk_flutter_refactor/core/database/app_database.dart';

// Import the generated file
import 'injection_container.config.dart' hide module; // Hide module from generated file

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'init',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies({required String backendBaseUrl}) async {
  // Register backendBaseUrl as named instance 
  getIt.registerSingleton<String>(backendBaseUrl, instanceName: 'backendBaseUrl');
  print('[DI] Registered backendBaseUrl: $backendBaseUrl');

  // Initialize injectable configurations (processes RegisterModule)
  await init(getIt); 
  print('[DI] Injectable initialization complete.');
}

@module
abstract class RegisterModule {
  // Dio factory method
  @lazySingleton
  Dio createDio(@Named('backendBaseUrl') String baseUrl) {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    print('Dio configured via RegisterModule with Base URL: ${dio.options.baseUrl}');
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.options.contentType = 'application/json';

    // ADDED LogInterceptor from profile branch logic
    dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90));
    
    return dio;
  }

  // PackageInfo factory method
  @preResolve 
  Future<PackageInfo> get packageInfo => PackageInfo.fromPlatform();

  // FlutterSecureStorage instance - UNCOMMENT
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  // Connectivity instance
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  // ADDED SharedPreferences instance
  @preResolve 
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();

  // ADDED InternetConnectionChecker instance
  @lazySingleton
  InternetConnectionChecker get connectionChecker => InternetConnectionChecker();

  // AppDatabase instance
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();

  // Navigation Service mock
  @lazySingleton
  INavigationService get navigationService => MockNavigationService();

  // Payment Service mock
  @lazySingleton
  IPaymentService get paymentService => MockPaymentService();
}
