import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/mocks/mock_payment_service.dart';

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
  // Provide Dio instance - REMOVED/COMMENTED OUT as CoreDioClient manages its own Dio instance
  // @lazySingleton
  // Dio get dio => Dio(BaseOptions(
  //       baseUrl: 'https://your.api.base.url/api', // Placeholder!
  //       connectTimeout: const Duration(seconds: 5),
  //       receiveTimeout: const Duration(seconds: 3),
  //     ));

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