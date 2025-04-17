import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/mocks/mock_payment_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import database and DAO
import 'package:dskk_flutter_refactor/core/database/app_database.dart';
// import 'package:dskk_flutter_refactor/core/database/daos/order_dao.dart'; // No need to import DAO directly here

// Import the generated file
import 'injection_container.config.dart'; 

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'init', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependencies() async => init(getIt);

// --- Register Module for Third Party Libs and Core Services ---
@module
abstract class RegisterModule {
  // Provide baseUrl as a named instance from .env
  @Named('baseUrl')
  @lazySingleton
  String get baseUrl {
    final url = dotenv.env['BACKEND_BASE_URL']; // Assuming key is BACKEND_BASE_URL
    if (url == null || url.isEmpty) {
      throw Exception('BACKEND_BASE_URL not found or empty in .env file');
    }
    print('[RegisterModule] Providing baseUrl: $url');
    return url;
  }

  // Provide FlutterSecureStorage instance
  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  // Provide AppDatabase instance as a singleton
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();

  // REMOVED: OrderDao registration - Drift handles DAO access via AppDatabase instance
  // @lazySingleton 
  // OrderDao get orderDao => OrderDao(getIt<AppDatabase>()); 

  // Provide Navigation Service implementation (using Mock)
  @lazySingleton
  INavigationService get navigationService => MockNavigationService();

  // Provide Payment Service implementation (using Mock)
  @lazySingleton
  IPaymentService get paymentService => MockPaymentService();
}

// Later, you will register your modules/services like this:
// @module
// abstract class RegisterModule {
//   @lazySingleton
//   MyService get myService => MyServiceImpl();
// } 