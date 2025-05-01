import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// Import DI configuration and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import Seller Routes
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
// Import Seller Home Page and Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_home_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';

// Optional: Import other DI initializers if needed (e.g., Home DI from main_dev_preview)
// import 'package:dskk_flutter_refactor/features/home/di/home_di.dart';

/// Injects hardcoded or environment-based test credentials into secure storage.
/// WARNING: Hardcoding credentials is NOT recommended for production or shared code.
/// Use environment variables (`--dart-define`) for better security and flexibility.
Future<void> _injectTestCredentials(GetIt getIt) async {
  final secureStorage = getIt<FlutterSecureStorage>();
  try {
    // Read credentials from environment variables (RECOMMENDED for real testing)
    // const userIdStr = String.fromEnvironment('TEST_USER_ID');
    // const authToken = String.fromEnvironment('TEST_AUTH_TOKEN');
    // const commonUserId = String.fromEnvironment('TEST_COMMON_USER_ID');

    // Or use Hardcoded values (LESS SECURE, use only temporarily if needed)
    const userIdStr = '18888888888'; // Replace with actual ID (as String)
    const authToken = 'eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6Ijk1NjBiODY2LWU2ZmUtNGYyOS04NjVjLTdmMjJjNDg0YjlmZCJ9.QCfx9k2Bu6H1yONyH5jGm_Pjy0DlPPGl9gP1_0p72c-4KjHwoRPIkxXrnJckC1g_UqudTufgjQvfYUCMGzNd9A'; // Replace with actual token
    const commonUserId = '1'; // Replace if needed

    final userId = int.tryParse(userIdStr);

    if (userId != null && authToken.isNotEmpty && !authToken.startsWith('请替换')) {
      await secureStorage.write(key: 'user_id', value: userIdStr);
      await secureStorage.write(key: 'auth_token', value: authToken);
      if (commonUserId.isNotEmpty && !commonUserId.startsWith('请替换')) {
         await secureStorage.write(key: 'common_user_id', value: commonUserId);
      }
      print('[seller_home_real_preview] Successfully injected test credentials.');
    } else {
      print('[seller_home_real_preview] WARNING: Hardcoded test credentials not filled or invalid. Using potentially stale stored credentials.');
      // Optionally, clear storage if you want to force unauthenticated state
      // await secureStorage.deleteAll();
      // print('[seller_home_real_preview] Cleared secure storage.');
    }
  } catch (e) {
    print('[seller_home_real_preview] Error injecting test credentials: $e');
  }
}

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  String? backendBaseUrl;
  try {
    await dotenv.load(fileName: ".env");
    backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
    print('[seller_home_real_preview] Loaded BACKEND_BASE_URL: $backendBaseUrl');
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
       print("[seller_home_real_preview] WARNING: BACKEND_BASE_URL not found or empty. Using fallback.");
       backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
    }
  } catch (e) {
     print("[seller_home_real_preview] Error loading .env file: $e. Using fallback.");
     backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback on error
  }

  // Configure GetIt dependency injection using the loaded base URL
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[seller_home_real_preview] Core dependencies configured.');

  // ---- Inject Test Credentials ----
  print('[seller_home_real_preview] Attempting to inject test credentials...');
  await _injectTestCredentials(GetIt.instance);
  // ---- End Inject Test Credentials ----

  // Configure GoRouter for Seller module
  final GoRouter router = GoRouter(
    initialLocation: SellerRoutes.home, // Start at the seller home page
    // Directly use the routes defined in SellerRoutes,
    // which already contains the /seller root and its sub-routes.
    routes: SellerRoutes.routes,
    debugLogDiagnostics: true,
  );

  // Run the app using MaterialApp.router
  runApp(SellerRealPreviewApp(router: router));
}

class SellerRealPreviewApp extends StatelessWidget {
  final GoRouter router;

  const SellerRealPreviewApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    // The BlocProvider for SellerHomeBloc needs to be above SellerHomePage.
    // Since SellerHomePage is the builder for the '/' route within SellerRoutes,
    // we might need to ensure the provider is added there or wrap the MaterialApp.
    // For simplicity in preview, wrapping MaterialApp might be easier if needed,
    // but ideally, the provider is closer to where it's used (handled in SellerRoutes definition is best).
    
    // Let's check if SellerRoutes's builder for '/' already includes the provider.
    // Assuming SellerRoutes.routes already handles the BlocProvider correctly for SellerHomePage.
    
    return MaterialApp.router(
      title: 'Seller Module Real API Preview',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // TODO: Introduce project theme
      ),
      routerConfig: router,
    );
  }
} 