import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // No longer needed here
// Remove direct imports for FlutterSecureStorage and Connectivity as they are handled by the module
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';

// Import the generated file
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'init', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
// Modify function to accept the Base URL
Future<void> configureDependencies({required String backendBaseUrl}) async {
  // --- Remove manual registration for Connectivity and FlutterSecureStorage ---
  // These are now handled by RegisterModule and injectable generator
  // getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  // getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Configure and register Dio (using the passed Base URL)
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio();
    // Use the Base URL passed from main.dart
    dio.options.baseUrl = backendBaseUrl;
    print('Dio configured with Base URL: $backendBaseUrl'); // Log the used URL

    dio.options.connectTimeout = const Duration(seconds: 15); // Example timeout
    dio.options.receiveTimeout = const Duration(seconds: 15);

    // Example: Add an interceptor to include Auth token in headers
    // dio.interceptors.add(InterceptorsWrapper(
    //   onRequest: (options, handler) async {
    //     // Retrieve token from secure storage (using GetIt to resolve the repository)
    //     final storage = getIt<ISecureStorageRepository>();
    //     final token = await storage.getToken();
    //     if (token != null) {
    //       options.headers['Authorization'] = 'Bearer $token';
    //     }
    //     return handler.next(options); //continue
    //   },
    // ));

    return dio;
  });

  // Initialize injectable configurations (this will now also process the RegisterModule)
  init(getIt);
}


// Ensure your main.dart calls dotenv.load() before configureDependencies()
// Example in main.dart:
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load(fileName: ".env"); // Load .env file
//   await configureDependencies(); // Setup DI
//   runApp(MyApp());
// }

// Later, you will register your modules/services like this:
// @module
// abstract class RegisterModule {
//   @lazySingleton
//   MyService get myService => MyServiceImpl();
// }
