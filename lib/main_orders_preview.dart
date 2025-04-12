import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Import the injectable setup
import 'package:dskk_flutter_refactor/core/aftersale/repositories/i_aftersale_repository.dart';
import 'package:dskk_flutter_refactor/core/aftersale/repositories/mocks/mock_aftersale_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/mocks/mock_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/logistics/repositories/i_logistics_repository.dart';
import 'package:dskk_flutter_refactor/core/logistics/repositories/mocks/mock_logistics_repository.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/i_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/navigation/services/mocks/mock_navigation_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart';
import 'package:dskk_flutter_refactor/core/payment/services/mocks/mock_payment_service.dart';
import 'package:dskk_flutter_refactor/core/rating/repositories/i_rating_repository.dart';
import 'package:dskk_flutter_refactor/core/rating/repositories/mocks/mock_rating_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/data/repositories/mocks/mock_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/cancel_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/confirm_order_receipt_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/delete_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_detail_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/get_order_list_use_case.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/bloc/order_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/order_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/config/theme/app_theme.dart';
import 'package:dskk_flutter_refactor/core/router/app_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
import 'package:flutter/services.dart' show rootBundle; // Import rootBundle
import 'package:get_it/get_it.dart'; // Import GetIt
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dskk_flutter_refactor/app/app.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Import package_info_plus

// Remove GetIt instance creation here, rely on the one from injection_container.dart
// final sl = GetIt.instance;

/// Orders 模块的独立预览入口点。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- Load .env from assets and parse into a local Map --- 
  final Map<String, String> envMap = {}; // Local map to store env variables
  print('[main_orders_preview] Loading .env from assets...');
  try {
    await dotenv.load(fileName: ".env");
    final envString = await rootBundle.loadString('.env');
    final lines = envString.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final index = line.indexOf('=');
      if (index != -1) {
        final key = line.substring(0, index).trim();
        final value = line.substring(index + 1).trim();
        if (key.isNotEmpty) {
          envMap[key] = value; // Populate the local map
        }
      }
    }
    print('[main_orders_preview] Successfully parsed .env from assets into local map.');
    print('[main_orders_preview] BACKEND_BASE_URL from envMap: ${envMap['BACKEND_BASE_URL']}'); 
  } catch (e) {
    print('[main_orders_preview] Error loading or parsing .env from assets: $e');
    // Consider fallback or error handling
  }
  // --- End Loading .env --- 

  // --- Register the env Map with GetIt BEFORE configuring dependencies --- 
  // Use an instance name to avoid type conflicts if Map<String, String> is used elsewhere
  GetIt.instance.registerSingleton<Map<String, String>>(envMap, instanceName: 'envVariables');
  print('[main_orders_preview] Registered envMap with GetIt (instanceName: envVariables).');

  // **Explicitly register the baseUrl String with the name 'baseUrl'**
  final baseUrl = envMap['BACKEND_BASE_URL'];
  if (baseUrl != null && baseUrl.isNotEmpty) {
    GetIt.instance.registerSingleton<String>(baseUrl, instanceName: 'baseUrl');
    print('[main_orders_preview] Registered baseUrl: $baseUrl with instanceName: baseUrl');
  } else {
    print('[main_orders_preview] ERROR: BACKEND_BASE_URL not found or empty in envMap. Cannot register baseUrl.');
    // Optionally throw an error or handle this case appropriately
    throw Exception('BACKEND_BASE_URL is missing or empty in .env file');
  }

  // **Register FlutterSecureStorage BEFORE configuring dependencies**
  GetIt.instance.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  print('[main_orders_preview] Registered FlutterSecureStorage as LazySingleton.');

  // **Get and Register PackageInfo**
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    GetIt.instance.registerSingleton<PackageInfo>(packageInfo);
    print('[main_orders_preview] Registered PackageInfo: ${packageInfo.packageName} v${packageInfo.version}');
  } catch (e) {
    print('[main_orders_preview] ERROR: Failed to get or register PackageInfo: $e');
    throw Exception('Failed to initialize PackageInfo');
  }

  // --- Configure dependencies using injectable --- 
  // injectable's generated code will now be able to find the registered map if needed
  await configureDependencies();

  // --- Manually Inject Test Token and User ID for Preview ---
  print('[main_orders_preview] Attempting to inject test credentials...');
  try {
    const storage = FlutterSecureStorage();
    const testToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjY5MGJkODk1LTJmNjUtNDUyMy05NDVlLTEyNTJhMmUxZTRjNSJ9.Spe4i8mvObH1YRlVKrKoehxi381XV8c0MMxvWpe5aNUVT9Mcdh5kFr0OrUWY5p8hunkJmpqTyQN8vaqWcbHseA"; 
    const testUserId = "18888888888";
    await storage.write(key: 'user_token', value: testToken);
    await storage.write(key: 'user_id', value: testUserId);
    print('[main_orders_preview] Successfully injected provided test token and user ID into secure storage.');
  } catch (e) {
     print('[main_orders_preview] ERROR injecting test credentials: $e');
  }

  // --- Override IOrderRepository with Mock for Preview (Commented out) ---
  // Allow GetIt to override the previous registration
  // getIt.allowReassignment = true; // Commented out
  // getIt.registerLazySingleton<IOrderRepository>(() => MockOrderRepository(), dispose: null); // Commented out

  // print('[main_orders_preview] Overrode IOrderRepository with MockOrderRepository.'); // Commented out

  runApp(const OrdersPreviewApp());
}

// Optional helper to remove quotes, if your values might have them
// String _stripQuotes(String value) {
//   if ((value.startsWith(''') && value.endsWith(''')) || (value.startsWith('"') && value.endsWith('"'))) {
//     return value.substring(1, value.length - 1);
//   }
//   return value;
// }

class OrdersPreviewApp extends StatelessWidget {
  const OrdersPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderListBloc>(
          // Use getIt from the imported injection_container.dart
          create: (_) => getIt<OrderListBloc>()..add(const LoadOrders()),
        ),
        // TODO: Add BlocProvider for AfterSalesBloc if needed globally for preview?
        // Or provide it locally in pages like AfterSalesDetailPage
      ],
      child: MaterialApp.router(
        title: 'Orders Module Preview',
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme, // Optional dark theme
        // Use the main AppRouter configuration
        routeInformationProvider: AppRouter.router.routeInformationProvider,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routerDelegate: AppRouter.router.routerDelegate,
        // routerConfig: _previewRouter, // OLD: Using local router
      ),
    );
  }
} 