import 'package:flutter/material.dart';
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

/// 外服生产版本入口
/// 国际版本入口 - 从环境变量读取服务器地址
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 先加载.env文件
  try {
    await dotenv.load(fileName: ".env");
    print('.env file loaded successfully.');
  } catch (e) {
    print('No .env file found, using default configuration.');
  }
  
  // 配置国际服设置
  RegionConfig.setRegion(RegionType.international);
  
  // 使用环境变量配置的API地址
  // 优先使用国际服URL，如果没有配置则使用默认的BACKEND_BASE_URL
  String? backendBaseUrl = dotenv.env['INTERNATIONAL_API_URL'];
  if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
    backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
      throw Exception('BACKEND_BASE_URL environment variable is not set. Please configure it in your .env file.');
    }
  }
  print('[International Production] Using API: $backendBaseUrl');
  print('[International Production] Model API: ${RegionConfig.modelBaseUrl}');
  print('[International Production] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  print('[International Production] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 初始化依赖注入，使用外服API地址
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[International Production] Core dependencies configured.');
  
  // 初始化各个模块依赖
  await initHomeDi();
  print('[International Production] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  print('[International Production] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  print('[International Production] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  print('[International Production] Chat module initialized.');
  
  await ProfileDI.init(getIt);
  print('[International Production] Profile module initialized.');
  
  SellerStatisticsDI.init(getIt);
  print('[International Production] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  print('[International Production] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  print('[International Production] Payment module initialized.');

  // 初始化分析模块
  await initAnalyticsModule();
  print('[International Production] Analytics module initialized.');

  // 配置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[International Production] Analytics BLoC observer configured.');

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