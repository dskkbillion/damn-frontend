import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/analytics/observers/analytics_bloc_observer.dart';
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart';
import 'package:dskk_flutter_refactor/core/utils/config_validator.dart';
import 'package:dskk_flutter_refactor/app/app.dart';
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart';
import 'package:dskk_flutter_refactor/core/services/profile_preloader_service.dart';
import 'package:dskk_flutter_refactor/core/services/background_refresh_service.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';

// Import all module DI configurations
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart';
import 'package:dskk_flutter_refactor/features/favorites/di/favorites_di.dart';
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';
import 'package:dskk_flutter_refactor/features/payment/di/payment_di.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/di/ai_docs_di.dart';
import 'package:dskk_flutter_refactor/features/chat/di/chat_di.dart';
import 'package:dskk_flutter_refactor/features/profile/di/profile_di.dart';
import 'package:dskk_flutter_refactor/features/credits/di/credits_di.dart';
import 'package:dskk_flutter_refactor/features/seller/di/seller_di.dart';
import 'package:dskk_flutter_refactor/core/config/region_config.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_di.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';

const String _envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');

/// 统一入口【生产版】 - 支持所有支付方式和登录方式，使用美元作为统一货币
/// 
/// 使用方法：
/// flutter run -t lib/main_unified.dart
/// flutter build apk -t lib/main_unified.dart --release
/// 
/// 特点：
/// - 使用USD（美元）作为统一货币
/// - 支持所有支付方式：支付宝、微信支付、Stripe
/// - 支持所有登录方式：微信、Google、Apple（需要实现相应的登录模块）
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppLogger.d('========================================');
  AppLogger.d('DSKK Flutter Unified Entry - Production');
  AppLogger.d('========================================');
  
  // Configure global image cache limits
  _configureImageCache();

  // 先加载.env文件
  try {
    await dotenv.load(fileName: _envFile);
    AppLogger.d('Environment file loaded successfully: $_envFile');
  } catch (e) {
    AppLogger.d('Failed to load environment file $_envFile: $e');
  }
  
  // 配置统一服设置
  RegionConfig.setRegion(RegionType.unified);
  
  // 生产环境不显示开发Tab
  AppRouterConfig.setShowDevTab(false);
  
  // 使用环境变量配置的API地址
  String? backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
  if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
    throw Exception(
      'BACKEND_BASE_URL environment variable is not set. Please configure it in $_envFile.',
    );
  }
  _guardReleaseBackendConfig(backendBaseUrl);
  
  AppLogger.d('[Unified Production] Using API: $backendBaseUrl');
  AppLogger.d('[Unified Production] Model API: ${RegionConfig.modelBaseUrl}');
  AppLogger.d('[Unified Production] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  AppLogger.d('[Unified Production] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');
  AppLogger.d('[Unified Production] Features enabled:');
  RegionConfig.features.forEach((key, value) {
    if (value) AppLogger.d('  ✓ $key');
  });

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  // 初始化依赖注入
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  AppLogger.d('[Unified Production] Core dependencies configured.');
  

  await initHomeDi();
  AppLogger.d('[Unified Production] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  AppLogger.d('[Unified Production] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  AppLogger.d('[Unified Production] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  AppLogger.d('[Unified Production] Chat module initialized.');

  await ProfileDI.init(getIt);
  AppLogger.d('[Unified Production] Profile module initialized.');

  await CreditsDI.init(getIt);
  AppLogger.d('[Unified Production] Mobile credit purchases initialized.');

  // 初始化全局 WebSocket 管理器（必须在 AuthDI 和 ChatDI 之后）
  ChatDI.initGlobalWebSocketManager(getIt);
  AppLogger.d('[Unified Production] Global WebSocket manager initialized.');
  
  SellerStatisticsDI.init(getIt);
  AppLogger.d('[Unified Production] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  AppLogger.d('[Unified Production] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  AppLogger.d('[Unified Production] Payment module initialized.');

  // 初始化分析模块
  await initAnalyticsModule();
  AppLogger.d('[Unified Production] Analytics module initialized.');

  // 配置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  AppLogger.d('[Unified Production] Analytics BLoC observer configured.');

  // 触发预加载
  _triggerPreloadingAfterDelay();

  // 启动应用
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: Builder(
        builder: (context) {
          return Consumer(
            builder: (context, ref, child) {
              // 获取GoRouter实例并注册导航服务
              final router = ref.read(goRouterProvider);
              
              // 注册真实的导航服务
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppLogger.d('[Unified Production] Registering navigation service...');
                HomeNavigationDI.registerRealNavigationService(getIt, router);
                AppLogger.d('[Unified Production] Navigation service registered successfully.');
              });
              
              return const MyApp();
            },
          );
        },
      ),
    ),
  );
}

void _guardReleaseBackendConfig(String backendBaseUrl) {
  if (!kReleaseMode) return;

  final host = Uri.tryParse(backendBaseUrl)?.host.toLowerCase();
  final isLocalBackend = _envFile == '.env.local-debug' ||
      host == 'localhost' ||
      host == '127.0.0.1' ||
      host == '0.0.0.0' ||
      host == '::1';

  if (isLocalBackend) {
    throw StateError(
      'Release build is using a local backend ($backendBaseUrl from $_envFile). '
      'Use .env.staging for TestFlight or .env for production.',
    );
  }
}


/// 延迟触发预加载，避免阻塞应用启动
void _triggerPreloadingAfterDelay() {
  Future.delayed(const Duration(seconds: 3), () async {
    // 检查登录态，未登录则跳过所有预加载
    try {
      final token = await getIt<ISecureStorageRepository>().getToken();
      if (token == null) {
        AppLogger.d('[Preloader] User not logged in, skipping preloading');
        return;
      }
    } catch (e) {
      AppLogger.d('[Preloader] Failed to check login state: $e');
      return;
    }

    try {
      final preloaderService = getIt<ProfilePreloaderService>();
      AppLogger.d('[Preloader] Starting preloading process...');

      // 并行执行核心数据预加载和 Profile 预加载
      await Future.wait([
        preloaderService.preloadCoreData(),
        preloaderService.preloadBothModes(
          priorityMode: AppMode.buyer,
          delayBetweenModes: const Duration(seconds: 3),
        ),
      ]);

      AppLogger.d('[Preloader] Preloading process completed successfully');

      // 初始化后台刷新服务
      try {
        final bgRefreshService = getIt<BackgroundRefreshService>();
        bgRefreshService.init();
        AppLogger.d('[Preloader] BackgroundRefreshService initialized');
      } catch (e) {
        AppLogger.d('[Preloader] Failed to initialize BackgroundRefreshService: $e');
      }
    } catch (e) {
      AppLogger.d('[Preloader] Failed to preload data: $e');
    }
  });
}

/// 配置全局图片缓存限制
void _configureImageCache() {
  final PaintingBinding binding = PaintingBinding.instance;
  
  // 设置图片缓存的最大数量（默认是1000）
  binding.imageCache.maximumSize = 100; // 限制缓存图片数量为100张
  
  // 设置图片缓存的最大内存大小（以字节为单位）
  // 50MB = 50 * 1024 * 1024 bytes
  binding.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 限制为50MB
  
  AppLogger.d('[Image Cache] Configured:');
  AppLogger.d('  Max images: ${binding.imageCache.maximumSize}');
  AppLogger.d('  Max memory: ${binding.imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB');
}
