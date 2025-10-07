import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dskk_flutter_refactor/core/analytics/observers/analytics_bloc_observer.dart';
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart';
import 'package:dskk_flutter_refactor/core/utils/config_validator.dart';
import 'package:dskk_flutter_refactor/core/config/config_validator.dart' as config;
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

/// 国服生产版本入口
/// 国内版本入口 - 从环境变量读取服务器地址
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 配置国服设置
  RegionConfig.setRegion(RegionType.domestic);
  
  // 生产环境不显示开发Tab
  AppRouterConfig.setShowDevTab(false);
  // 从环境变量获取后端URL
  await dotenv.load(fileName: ".env");
  final backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
  if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
    throw Exception('BACKEND_BASE_URL environment variable is not set. Please configure it in your .env file.');
  }
  print('[Domestic Production] Using API: $backendBaseUrl');
  print('[Domestic Production] Model API: ${RegionConfig.modelBaseUrl}');
  print('[Domestic Production] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  print('[Domestic Production] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');

  // 尝试加载.env文件（可选，允许环境变量覆盖）
  try {
    await dotenv.load(fileName: ".env");
    print('.env file loaded successfully.');
  } catch (e) {
    print('No .env file found, using default configuration.');
  }

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  print('[Domestic Production] Flutter Downloader initialized.');

  // 初始化依赖注入，使用国服API地址
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[Domestic Production] Core dependencies configured.');
  
  // 初始化各个模块依赖
  await initHomeDi();
  print('[Domestic Production] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  print('[Domestic Production] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  print('[Domestic Production] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  print('[Domestic Production] Chat module initialized.');
  
  await ProfileDI.init(getIt);
  print('[Domestic Production] Profile module initialized.');
  
  SellerStatisticsDI.init(getIt);
  print('[Domestic Production] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  print('[Domestic Production] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  print('[Domestic Production] Payment module initialized.');

  // 初始化分析模块
  await initAnalyticsModule();
  print('[Domestic Production] Analytics module initialized.');

  // 配置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[Domestic Production] Analytics BLoC observer configured.');

  // 触发预加载
  _triggerPreloadingAfterDelay();

  // 启动应用
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
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