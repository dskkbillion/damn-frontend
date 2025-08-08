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

/// 国服开发版本入口
/// 使用国内服务器地址：https://app.duoshaokankan.com/prod-api
/// 包含测试账号自动登录功能
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 配置国服设置
  RegionConfig.setRegion(RegionType.domestic);
  const String backendBaseUrl = 'https://app.duoshaokankan.com/prod-api';
  print('[Domestic Dev] Using API: $backendBaseUrl');
  print('[Domestic Dev] Model API: ${RegionConfig.modelBaseUrl}');
  print('[Domestic Dev] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  print('[Domestic Dev] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');

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

  // 初始化依赖注入，使用国服API地址
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[Domestic Dev] Core dependencies configured.');
  
  // 初始化各个模块依赖
  await initHomeDi();
  print('[Domestic Dev] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  print('[Domestic Dev] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  print('[Domestic Dev] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  print('[Domestic Dev] Chat module initialized.');
  
  await ProfileDI.init(getIt);
  print('[Domestic Dev] Profile module initialized.');
  
  SellerStatisticsDI.init(getIt);
  print('[Domestic Dev] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  print('[Domestic Dev] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  print('[Domestic Dev] Payment module initialized.');

  // 开发环境：注入测试账号
  await _injectTestCredentials();

  // 初始化分析模块
  await initAnalyticsModule();
  print('[Domestic Dev] Analytics module initialized.');

  // 配置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[Domestic Dev] Analytics BLoC observer configured.');

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

/// 注入测试账号凭证（仅用于开发环境）
Future<void> _injectTestCredentials() async {
  print('[Domestic Dev] Injecting test credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>();
    
    // 测试账号配置（与main_dev_VC相同）
    const userToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjllYWQ5YWJjLWMxZmEtNGM3ZC04ODllLWJjM2EzNjg4MDQxNSJ9.GgGSkCr4YG_Hf-stG8NuYFRZeebOO24vkhYQ_i8EVZzvIj9VO3VB7PdnpV6VlM7-TBJydQSdKy1mUI9jwsaKRw";
    const userId = "13819198810";
    const commonUserId = "10319";
    const referId = "10319";
    
    // 写入测试账号凭证
    await storage.write(key: 'auth_token', value: userToken);
    await storage.write(key: 'user_id', value: userId);
    await storage.write(key: 'common_user_id', value: commonUserId);
    await storage.write(key: 'referId', value: referId);
    
    print('[Domestic Dev] Test credentials injected successfully.');
    print('[Domestic Dev] Test User ID: $userId');
    print('[Domestic Dev] Common User ID: $commonUserId');
    print('[Domestic Dev] Mode: Buyer (Default)');
  } catch (e) {
    print('[Domestic Dev] WARNING: Failed to inject test credentials: $e');
    print('[Domestic Dev] You may need to login manually.');
  }
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