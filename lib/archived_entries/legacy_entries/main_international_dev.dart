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

/// 外服开发版本入口
/// 国际开发版本入口 - 从环境变量读取服务器地址
/// 包含测试账号自动登录功能
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
  print('[International Dev] Using API: $backendBaseUrl');
  print('[International Dev] Model API: ${RegionConfig.modelBaseUrl}');
  print('[International Dev] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  print('[International Dev] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 初始化依赖注入，使用外服API地址
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[International Dev] Core dependencies configured.');
  
  // 初始化各个模块依赖
  await initHomeDi();
  print('[International Dev] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  print('[International Dev] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  print('[International Dev] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  print('[International Dev] Chat module initialized.');
  
  await ProfileDI.init(getIt);
  print('[International Dev] Profile module initialized.');
  
  SellerStatisticsDI.init(getIt);
  print('[International Dev] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  print('[International Dev] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  print('[International Dev] Payment module initialized.');

  // 开发环境：注入测试账号
  await _injectTestCredentials();

  // 初始化分析模块
  await initAnalyticsModule();
  print('[International Dev] Analytics module initialized.');

  // 配置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[International Dev] Analytics BLoC observer configured.');

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
                print('[International Dev] Registering navigation service...');
                HomeNavigationDI.registerRealNavigationService(getIt, router);
                print('[International Dev] Navigation service registered successfully.');
              });
              
              return const MyApp();
            },
          );
        },
      ),
    ),
  );
}

/// 注入测试账号凭证（仅用于开发环境）
Future<void> _injectTestCredentials() async {
  print('[International Dev] Injecting test credentials...');
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
    
    print('[International Dev] Test credentials injected successfully.');
    print('[International Dev] Test User ID: $userId');
    print('[International Dev] Common User ID: $commonUserId');
    print('[International Dev] Mode: Buyer (Default)');
  } catch (e) {
    print('[International Dev] WARNING: Failed to inject test credentials: $e');
    print('[International Dev] You may need to login manually.');
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