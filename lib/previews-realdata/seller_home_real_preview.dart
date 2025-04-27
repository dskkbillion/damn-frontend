import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider

// Import DI configuration and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import Seller Routes
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
// Import Seller Home Page and Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_home_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';

// Optional: Import other DI initializers if needed (e.g., Home DI from main_dev_preview)
// import 'package:dskk_flutter_refactor/features/home/di/home_di.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  String? backendBaseUrl;
  try {
    await dotenv.load(fileName: ".env");
    backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
    print("[seller_home_real_preview] Loaded BACKEND_BASE_URL: $backendBaseUrl");
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
      print("[seller_home_real_preview] WARNING: BACKEND_BASE_URL not found or empty. Using fallback.");
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
    }
  } catch (e) {
    print("[seller_home_real_preview] Error loading .env file: $e. Using fallback.");
    backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback on error
  }

  // Initialize dependencies using the real configuration
  try {
    await configureDependencies(backendBaseUrl: backendBaseUrl);
    print('[seller_home_real_preview] Core dependencies configured.');
    // Optional: Initialize other module dependencies if needed
    // await initHomeDi(); 
    // print('[seller_home_real_preview] Home dependencies configured.');
  } catch (e, s) {
    print('[seller_home_real_preview] ERROR configuring dependencies: $e\n$s');
    // Decide how to handle DI configuration failure
    return; // Exit if DI fails
  }

  // Manually Inject Test Token and User ID for development
  print('[seller_home_real_preview] Attempting to inject test credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>();
    // Use the same test token/ID as main_dev_preview.dart
    const testToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjFmODBjYWYxLWE5ZGEtNDNhZi1hYzNjLTZkOWFjY2I4MmVjZiJ9.kyKSBwHvo3czm-R1cVySStWQQiSDQef4zAHS5dSjQ7MPjpfCR-PyqQgVN30GhmJf5eBmeaT9jJI13gMS8pmBSA";
    const testUserId = "1";
    const testCommonUserId = "999";

    await storage.write(key: 'user_token', value: testToken);
    await storage.write(key: 'user_id', value: testUserId);
    await storage.write(key: 'common_user_id', value: testCommonUserId);

    print('[seller_home_real_preview] Successfully injected test credentials.');
  } catch (e) {
    print('[seller_home_real_preview] ERROR injecting test credentials: $e');
  }

  // Configure GoRouter for Seller module
  final GoRouter router = GoRouter(
    initialLocation: SellerRoutes.home,
    routes: [
      // Wrap the SellerHomePage route with BlocProvider
      GoRoute(
        path: SellerRoutes.home,
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<SellerHomeBloc>(), // Use GetIt to create the Bloc
          child: const SellerHomePage(),
        ),
        // Add other seller routes here if they need top-level providers specific to them,
        // otherwise let the pages handle their own BlocProviders using GetIt if needed.
        routes: SellerRoutes.routes.where((route) => route is GoRoute && route.path != SellerRoutes.home).toList(),
      ),
      // Include other seller routes directly if they manage their own state/providers
      // ...SellerRoutes.routes.where((route) => route is GoRoute && route.path != SellerRoutes.home),
    ],
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
    // Note: We are not wrapping with ProviderScope here unless needed
    // Note: No top-level BlocProvider here, pages should get Blocs via GetIt
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