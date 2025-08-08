import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ProviderScope (from auth-module)
import 'package:package_info_plus/package_info_plus.dart'; // Import PackageInfo (from HEAD)
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage (from HEAD)
import 'package:shared_preferences/shared_preferences.dart'; // 导入SharedPreferences
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BLoC
import 'package:dskk_flutter_refactor/core/analytics/observers/analytics_bloc_observer.dart'; // Import Analytics Observer
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart'; // 导入分析模块初始化
// 导入配置验证工具
import 'package:dskk_flutter_refactor/core/utils/config_validator.dart';
import 'package:dskk_flutter_refactor/core/config/config_validator.dart' as config;

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import necessary for accessing the repository interface (from auth-module)
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
// 导入语言提供者
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart';
// 导入ProfilePreloader服务
import 'package:dskk_flutter_refactor/core/services/profile_preloader_service.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';

Future<void> main() async { // Make main async
  // Ensure Flutter binding is initialized (required for async operations before runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
     await dotenv.load(fileName: ".env");
     print('.env file loaded successfully.');
     
     // Validate required environment variables
     config.ConfigValidator.validateRequired();
     
     // Get validated URL
     final backendBaseUrl = config.ConfigValidator.getRequired('BACKEND_BASE_URL');
     print('Backend Base URL: $backendBaseUrl');
     
     // Check optional variables and log warnings
     final warnings = config.ConfigValidator.validateOptional();
     if (warnings.isNotEmpty) {
       print('\nConfiguration warnings:');
       for (final warning in warnings) {
         print('  - $warning');
       }
     }
  } catch (e) {
    print('\n====== Configuration Error ======');
    print('$e');
    if (e is config.ConfigurationException) {
      config.ConfigValidator.printConfigurationHelp();
    }
    print('\nApplication cannot start without required configuration.');
    print('Please create a .env file with the required environment variables.');
    rethrow; // Re-throw to stop the application
  }
  
  final backendBaseUrl = config.ConfigValidator.getRequired('BACKEND_BASE_URL');

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize dependencies, passing the Base URL
  await configureDependencies(backendBaseUrl: backendBaseUrl);
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
  
  // 初始化分析模块 - 需要在IAuthRepository注册之后
  await initAnalyticsModule();
  print('[main] Analytics module initialized.');

  // Configure BLoC observer for analytics
  Bloc.observer = AnalyticsBlocObserver();
  print('[main] Analytics BLoC observer configured.');
  
  // 触发预加载（在应用启动后延迟执行，避免阻塞启动）
  _triggerPreloadingAfterDelay();

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

/// 延迟触发预加载，避免阻塞应用启动
void _triggerPreloadingAfterDelay() {
  // 延迟3秒执行预加载，确保应用完全启动后
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      final preloaderService = getIt<ProfilePreloaderService>();
      print('[Preloader] Starting preloading process...');
      
      // 默认以买家模式为优先，延迟3秒加载卖家模式
      await preloaderService.preloadBothModes(
        priorityMode: AppMode.buyer,
        delayBetweenModes: const Duration(seconds: 3),
      );
      
      print('[Preloader] Preloading process completed successfully');
    } catch (e) {
      print('[Preloader] Failed to preload data: $e');
      // 预加载失败不影响应用正常运行
    }
  });
}
