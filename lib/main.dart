import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ProviderScope (from auth-module)
import 'package:package_info_plus/package_info_plus.dart'; // Import PackageInfo (from HEAD)
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage (from HEAD)

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import necessary for accessing the repository interface (from auth-module)
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

Future<void> main() async { // Make main async
  // Ensure Flutter binding is initialized (required for async operations before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (from auth-module)
  String? backendBaseUrl;
  try {
     await dotenv.load(fileName: ".env");
     backendBaseUrl = dotenv.env['BACKEND_BASE_URL']; // Get URL after loading
     print('.env file loaded successfully. Base URL: $backendBaseUrl');
     if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
       print('WARNING: BACKEND_BASE_URL is empty or not found in .env file.');
       backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
       print('Using fallback Base URL: $backendBaseUrl');
     }
  } catch (e) {
    print('Error loading .env file: $e. Ensure it exists in the project root.');
    backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback on error
    print('Using fallback Base URL due to error: $backendBaseUrl');
  }

  // --- Register PackageInfo (needed before configureDependencies) (from HEAD) ---
  // try {
  //   final packageInfo = await PackageInfo.fromPlatform();
  //   getIt.registerSingleton<PackageInfo>(packageInfo); // Use the global getIt instance
  //   print('[main] Registered PackageInfo: ${packageInfo.packageName} v${packageInfo.version}');
  // } catch (e) {
  //   print('[main] ERROR: Failed to get or register PackageInfo: $e');
  //   // Decide if the app can run without PackageInfo or should throw
  //   throw Exception('Failed to initialize PackageInfo');
  // }
  // Registration will be handled by @preResolve in RegisterModule
  // --------------------------------------------------------------------------

  // Initialize dependencies, passing the Base URL (from auth-module)
  await configureDependencies(backendBaseUrl: backendBaseUrl!); // Pass the non-null URL
  print('[main] Dependency injection configured.');

  // --- Manually Inject Test Token and User ID for development (from HEAD) ---
  // This is temporary until the auth module is integrated.
  print('[main] Attempting to inject test credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>();
    // Use a generic test token and ID for buyer/general use
    const testToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjMwZmZjY2YxLWFjNDUtNGM3OS04MjJiLTliNzM0MDZjZjdkYiJ9.g0FkPdnBuvpsirksABX04FrQLTjn-qgbLwRE9QLJOW6Df5syAdTGLn0IhpUYMDRaefbFQ49MWnL5wYUMRtMuiQ"; // Example Buyer/General Token
    const testUserId = "13333333333"; // Example Buyer/General ID
    await storage.write(key: 'user_token', value: testToken);
    await storage.write(key: 'user_id', value: testUserId);
    print('[main] Successfully injected test token and user ID into secure storage.');
  } catch (e) {
     print('[main] ERROR injecting test credentials: $e');
     // Consider how fatal this error should be
  }
  // -------------------------------------------------------------

  // --- TEMPORARY DEBUGGING CODE: Force logout on startup (from auth-module) ---
  // REMOVE THIS before final merge or release!
  /* // Commenting out the forced logout
  try {
    final authRepository = getIt<IAuthRepository>();
    print('DEBUG: Forcing logout on startup...');
    await authRepository.logout();
    print('DEBUG: Logout completed.');
  } catch (e) {
    print('DEBUG: Error during forced logout: $e');
  }
  */
  // --- END TEMPORARY DEBUGGING CODE ---

  // Run the application, wrapped in ProviderScope (from auth-module)
  runApp(
    ProviderScope( // Wrap the root widget with ProviderScope
      child: const MyApp(), // Use MyApp as the root widget name
    ),
  );
}
