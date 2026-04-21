import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/analytics/observers/analytics_bloc_observer.dart';
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart';
import 'package:dskk_flutter_refactor/core/utils/config_validator.dart';
import 'package:dskk_flutter_refactor/app/app.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart';
import 'package:dskk_flutter_refactor/core/services/profile_preloader_service.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';

// Import all module DI configurations
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart';
import 'package:dskk_flutter_refactor/features/favorites/di/favorites_di.dart';
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';
import 'package:dskk_flutter_refactor/features/payment/di/payment_di.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/di/ai_docs_di.dart';
import 'package:dskk_flutter_refactor/features/chat/di/chat_di.dart';
import 'package:dskk_flutter_refactor/features/profile/di/profile_di.dart';
import 'package:dskk_flutter_refactor/features/seller/di/seller_di.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_di.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';
import 'package:dskk_flutter_refactor/core/config/config_validator.dart' as config;

/// Simplified unified entry point using the modified RegionConfig
/// 
/// Production mode:
///   flutter run -t lib/main_unified_simple.dart
/// 
/// Development mode:
///   flutter run -t lib/main_unified_simple.dart --dart-define=DEV_MODE=true
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if we're in development mode
  const bool isDev = bool.fromEnvironment('DEV_MODE', defaultValue: false);
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Set unified region
  RegionConfig.setRegion(RegionType.unified);
  
  // Get backend URL from environment
  final backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
  if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
    throw Exception('BACKEND_BASE_URL environment variable is not set. Please configure it in your .env file.');
  }
  
  final mode = isDev ? 'Development' : 'Production';
  
  print('╔══════════════════════════════════════════════════════════════════╗');
  print('║              DSKK Unified Application - $mode                  ║');
  print('╚══════════════════════════════════════════════════════════════════╝');
  print('[Unified] Using API: $backendBaseUrl');
  print('[Unified] Model API: ${RegionConfig.modelBaseUrl}');
  print('[Unified] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  print('[Unified] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');
  print('[Unified] Login methods: All enabled (WeChat, Google, Apple)');

  // Validate configuration
  ConfigValidator.printValidationReport();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize dependencies
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[Unified] Core dependencies configured.');
  
  // Initialize all modules
  await initHomeDi();
  print('[Unified] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  print('[Unified] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  print('[Unified] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  print('[Unified] Chat module initialized.');
  
  await ProfileDI.init(getIt);
  print('[Unified] Profile module initialized.');
  
  SellerStatisticsDI.init(getIt);
  print('[Unified] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  print('[Unified] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  print('[Unified] Payment module initialized.');

  // In development mode, inject test credentials
  if (isDev) {
    await _injectTestCredentials();
  }

  // Initialize analytics module
  await initAnalyticsModule();
  print('[Unified] Analytics module initialized.');

  // Configure BLoC observer
  Bloc.observer = AnalyticsBlocObserver();
  print('[Unified] Analytics BLoC observer configured.');

  // Trigger preloading
  _triggerPreloadingAfterDelay();

  // Run the application
  if (isDev) {
    // Development mode with navigation service registration
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: Builder(
          builder: (context) {
            return Consumer(
              builder: (context, ref, child) {
                final router = ref.read(goRouterProvider);
                
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  print('[Unified Dev] Registering navigation service...');
                  HomeNavigationDI.registerRealNavigationService(getIt, router);
                  print('[Unified Dev] Navigation service registered successfully.');
                });
                
                return const MyApp();
              },
            );
          },
        ),
      ),
    );
  } else {
    // Production mode
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MyApp(),
      ),
    );
  }
}

/// Inject test credentials for development mode
Future<void> _injectTestCredentials() async {
  print('[Unified Dev] Injecting test credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>();
    
    // Test account configuration
    const userToken = "PLACEHOLDER_TOKEN_FOR_DEV";
    const userId = "13819198810";
    const commonUserId = "10319";
    const referId = "10319";
    
    // Write test credentials
    await storage.write(key: 'auth_token', value: userToken);
    await storage.write(key: 'user_id', value: userId);
    await storage.write(key: 'common_user_id', value: commonUserId);
    await storage.write(key: 'referId', value: referId);
    
    print('[Unified Dev] Test credentials injected successfully.');
    print('[Unified Dev] Test User ID: $userId');
    print('[Unified Dev] Common User ID: $commonUserId');
    print('[Unified Dev] Mode: Buyer (Default)');
  } catch (e) {
    print('[Unified Dev] WARNING: Failed to inject test credentials: $e');
    print('[Unified Dev] You may need to login manually.');
  }
}

/// Trigger preloading after delay
void _triggerPreloadingAfterDelay() {
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      final preloaderService = getIt<ProfilePreloaderService>();
      print('[Preloader] Starting preloading process...');
      
      await preloaderService.preloadBothModes(
        priorityMode: AppMode.buyer,
        delayBetweenModes: const Duration(seconds: 3),
      );
      
      print('[Preloader] Preloading process completed successfully');
    } catch (e) {
      print('[Preloader] Failed to preload data: $e');
    }
  });
}