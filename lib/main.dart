import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:package_info_plus/package_info_plus.dart'; // Import PackageInfo
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt

Future<void> main() async { // Make main async
  // Ensure Flutter binding is initialized (required for async operations before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  // --- Register PackageInfo (needed by AppInfoInterceptor -> CoreDioClient) ---
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    getIt.registerSingleton<PackageInfo>(packageInfo); // Use the global getIt instance
    print('[main] Registered PackageInfo: ${packageInfo.packageName} v${packageInfo.version}');
  } catch (e) {
    print('[main] ERROR: Failed to get or register PackageInfo: $e');
    // Decide if the app can run without PackageInfo or should throw
    throw Exception('Failed to initialize PackageInfo');
  }
  // --------------------------------------------------------------------------

  // Initialize dependencies (will now find PackageInfo)
  await configureDependencies(); // Assuming configureDependencies handles environment based on some logic or default

  // --- Manually Inject Test Token and User ID for development --- 
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

  // Remove ProviderScope as Riverpod is not actively used
  runApp(const MyApp()); // Run MyApp directly
}
