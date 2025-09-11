import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:dskk_flutter_refactor/app/app_mode.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';

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
  
  print('========================================');
  print('DSKK Flutter Unified Entry - Production');
  print('========================================');
  
  // Configure global image cache limits
  _configureImageCache();

  // 先加载.env文件
  try {
    await dotenv.load(fileName: ".env");
    print('.env file loaded successfully.');
  } catch (e) {
    print('No .env file found, using default configuration.');
  }
  
  // 配置统一服设置
  RegionConfig.setRegion(RegionType.unified);
  
  // 生产环境不显示开发Tab
  AppRouterConfig.setShowDevTab(false);
  
  // 使用环境变量配置的API地址
  String? backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
  if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
    throw Exception('BACKEND_BASE_URL environment variable is not set. Please configure it in your .env file.');
  }
  
  print('[Unified Production] Using API: $backendBaseUrl');
  print('[Unified Production] Model API: ${RegionConfig.modelBaseUrl}');
  print('[Unified Production] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  print('[Unified Production] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');
  print('[Unified Production] Features enabled:');
  RegionConfig.features.forEach((key, value) {
    if (value) print('  ✓ $key');
  });

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 初始化依赖注入
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[Unified Production] Core dependencies configured.');
  
  // 初始化各个模块依赖
  await initHomeDi();
  print('[Unified Production] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  print('[Unified Production] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  print('[Unified Production] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  print('[Unified Production] Chat module initialized.');
  
  await ProfileDI.init(getIt);
  print('[Unified Production] Profile module initialized.');
  
  SellerStatisticsDI.init(getIt);
  print('[Unified Production] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  print('[Unified Production] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  print('[Unified Production] Payment module initialized.');

  // 初始化分析模块
  await initAnalyticsModule();
  print('[Unified Production] Analytics module initialized.');

  // 配置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[Unified Production] Analytics BLoC observer configured.');

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
                print('[Unified Production] Registering navigation service...');
                HomeNavigationDI.registerRealNavigationService(getIt, router);
                print('[Unified Production] Navigation service registered successfully.');
              });
              
              return const MyApp();
            },
          );
        },
      ),
    ),
  );
}


/// 延迟触发预加载，避免阻塞应用启动
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

/// 配置全局图片缓存限制
void _configureImageCache() {
  final PaintingBinding binding = PaintingBinding.instance;
  
  // 设置图片缓存的最大数量（默认是1000）
  binding.imageCache.maximumSize = 100; // 限制缓存图片数量为100张
  
  // 设置图片缓存的最大内存大小（以字节为单位）
  // 50MB = 50 * 1024 * 1024 bytes
  binding.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 限制为50MB
  
  print('[Image Cache] Configured:');
  print('  Max images: ${binding.imageCache.maximumSize}');
  print('  Max memory: ${binding.imageCache.maximumSizeBytes ~/ (1024 * 1024)}MB');
}