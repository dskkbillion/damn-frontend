import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt

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
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    getIt.registerSingleton<PackageInfo>(packageInfo); // Use the global getIt instance
    print('[main_dev_preview] Registered PackageInfo: ${packageInfo.packageName} v${packageInfo.version}');
  } catch (e) {
    print('[main_dev_preview] ERROR: Failed to get or register PackageInfo: $e');
    // Decide if the app can run without PackageInfo or should throw
    throw Exception('Failed to initialize PackageInfo');
  }
  // --------------------------------------------------------------------------

  // Initialize dependencies (using the same configuration as the main app)
  // (will now find PackageInfo)
  await configureDependencies(backendBaseUrl: backendBaseUrl!);

  // --- Manually Inject Test Token and User ID for development --- 
  // This is temporary until the auth module is integrated.
  print('[main_dev_preview] Attempting to inject test credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>(); 
    // Use a generic test token and ID for buyer/general use
    const testToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjFmODBjYWYxLWE5ZGEtNDNhZi1hYzNjLTZkOWFjY2I4MmVjZiJ9.kyKSBwHvo3czm-R1cVySStWQQiSDQef4zAHS5dSjQ7MPjpfCR-PyqQgVN30GhmJf5eBmeaT9jJI13gMS8pmBSA"; // Example Buyer/General Token
    const testUserId = "1"; // Example Buyer/General ID as String representation of an int
    await storage.write(key: 'user_token', value: testToken);
    await storage.write(key: 'user_id', value: testUserId);
    print('[main_dev_preview] Successfully injected test token and user ID (${testUserId}) into secure storage.');
  } catch (e) {
     print('[main_dev_preview] ERROR injecting test credentials: $e');
     // Consider how fatal this error should be
  }
  // -------------------------------------------------------------

  // Run the main application widget
  // MyApp contains the GoRouter setup which includes the Dev Menu tab
  runApp(const MyApp());
} 