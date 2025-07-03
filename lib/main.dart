import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ProviderScope (from auth-module)
import 'package:package_info_plus/package_info_plus.dart'; // Import PackageInfo (from HEAD)
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage (from HEAD)
import 'package:shared_preferences/shared_preferences.dart'; // 导入SharedPreferences
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BLoC
import 'package:dskk_flutter_refactor/core/analytics/observers/analytics_bloc_observer.dart'; // Import Analytics Observer
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart'; // 导入分析模块初始化
// 导入core/auth中的IAuthRepository
import 'package:dskk_flutter_refactor/core/auth/repositories/i_auth_repository.dart' as core_auth;
// 导入配置验证工具
import 'package:dskk_flutter_refactor/core/utils/config_validator.dart';

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import necessary for accessing the repository interface (from auth-module)
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
// 导入语言提供者
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart';

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

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();

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
    await storage.write(key: 'auth_token', value: testToken);
    await storage.write(key: 'user_id', value: testUserId);
    print('[main] Successfully injected test token and user ID into secure storage.');
  } catch (e) {
     print('[main] ERROR injecting test credentials: $e');
     // Consider how fatal this error should be
  }
  // -------------------------------------------------------------
  
  // 注册core_auth.IAuthRepository适配器
  getIt.registerLazySingleton<core_auth.IAuthRepository>(
    () => AuthRepositoryAdapter()
  );
  
  // 初始化分析模块 - 需要在IAuthRepository注册之后
  await initAnalyticsModule();
  print('[main] Analytics module initialized.');

  // Configure BLoC observer for analytics
  Bloc.observer = AnalyticsBlocObserver();
  print('[main] Analytics BLoC observer configured.');

  // Run the application, wrapped in ProviderScope (from auth-module)
  runApp(
    ProviderScope(
      overrides: [
        // 覆盖sharedPreferencesProvider
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(), // Use MyApp as the root widget name
    ),
  );
}
