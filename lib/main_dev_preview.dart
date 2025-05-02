import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import the IAuthRepository interface and the Mock implementation
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/mocks/mock_auth_repository.dart';
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart'; // Import Home DI
import 'package:dskk_flutter_refactor/features/favorites/di/favorites_di.dart'; // Import Favorites DI
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';
// import 'package:dskk_flutter_refactor/features/profile/di/profile_di.dart'; // 不再需要引入

/// Application entry point for running the app with the Dev Menu navigator tab.
/// Use this for convenient testing of different module entry points during development.
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  String? backendBaseUrl; // Declare variable
  try {
      await dotenv.load(fileName: ".env");
      backendBaseUrl = dotenv.env['BACKEND_BASE_URL']; // Extract URL
      print("[main_dev_preview] Loaded BACKEND_BASE_URL: $backendBaseUrl");
      if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
          print("[main_dev_preview] WARNING: BACKEND_BASE_URL not found or empty. Using fallback.");
          backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
      }
  } catch (e) {
      print("[main_dev_preview] Error loading .env file: $e. Using fallback.");
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback on error
  }

  // --- Register PackageInfo (needed by AppInfoInterceptor -> CoreDioClient) ---
  // try {
  //   final packageInfo = await PackageInfo.fromPlatform();
  //   getIt.registerSingleton<PackageInfo>(packageInfo); // Use the global getIt instance
  //   print('[main_dev_preview] Registered PackageInfo: ${packageInfo.packageName} v${packageInfo.version}');
  // } catch (e) {
  //   print('[main_dev_preview] ERROR: Failed to get or register PackageInfo: $e');
  //   // Decide if the app can run without PackageInfo or should throw
  //   throw Exception('Failed to initialize PackageInfo');
  // }
  // Registration will be handled by @preResolve in RegisterModule
  // --------------------------------------------------------------------------

  // Initialize dependencies (using the same configuration as the main app)
  // (injectable will now handle PackageInfo registration via @preResolve)
  await configureDependencies(backendBaseUrl: backendBaseUrl!);
  print('[main_dev_preview] Core dependencies configured.');

  // Initialize Home module dependencies AFTER core dependencies
  await initHomeDi();
  print('[main_dev_preview] Home dependencies configured.');

  // Initialize Favorites module dependencies
  await FavoritesDI.init(getIt);
  print('[main_dev_preview] Favorites dependencies configured.');

  // Initialize Seller Statistics module dependencies
  SellerStatisticsDI.init(getIt);
  print('[main_dev_preview] Seller Statistics dependencies configured.');

  // Initialize Profile module dependencies
  // await initProfileDi(); // <--- 删除或注释掉这一行
  // print('[main_dev_preview] Profile dependencies configured.'); // <--- 删除或注释掉这一行

  // --- Override AuthRepository with Mock for Dev Preview --- 
  print('[main_dev_preview] Overriding IAuthRepository with MockAuthRepository...');
  getIt.allowReassignment = true; // Allow overriding registrations
  getIt.registerLazySingleton<IAuthRepository>(() => MockAuthRepository());
  getIt.allowReassignment = false; // Optional: Disable reassignment after overriding
  print('[main_dev_preview] IAuthRepository overridden.');
  // ---------------------------------------------------------

  // --- Manually Inject Test Token and User ID for development --- 
  // This is temporary until the auth module is integrated.
  print('[main_dev_preview] Attempting to inject test credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>(); 
    // Use a generic test token and ID for buyer/general use
    const testToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6Ijk1NjBiODY2LWU2ZmUtNGYyOS04NjVjLTdmMjJjNDg0YjlmZCJ9.QCfx9k2Bu6H1yONyH5jGm_Pjy0DlPPGl9gP1_0p72c-4KjHwoRPIkxXrnJckC1g_UqudTufgjQvfYUCMGzNd9A"; // Example Buyer/General Token
    const testUserId = "18888888888"; // Example Buyer/General ID as String representation of an int
    const testCommonUserId = "1"; // Example Common User ID as String

    await storage.write(key: 'auth_token', value: testToken);
    await storage.write(key: 'user_id', value: testUserId);
    await storage.write(key: 'common_user_id', value: testCommonUserId); // Write common_user_id

    print('[main_dev_preview] Successfully injected test token, user ID (${testUserId}), and common_user_id (${testCommonUserId}) into secure storage.');
  } catch (e) {
     print('[main_dev_preview] ERROR injecting test credentials: $e');
     // Consider how fatal this error should be
  }
  // -------------------------------------------------------------

  // Run the main application widget
  // MyApp contains the GoRouter setup which includes the Dev Menu tab
  runApp(
    ProviderScope( // Wrap with ProviderScope to enable Riverpod providers
      child: const MyApp(),
    ),
  );
} 