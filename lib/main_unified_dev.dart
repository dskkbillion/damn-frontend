import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

/// 统一入口【开发版】 - 支持所有支付方式和登录方式，使用美元作为统一货币
/// 包含测试账号自动登录功能
/// 
/// 使用方法：
/// flutter run -t lib/main_unified_dev.dart
/// 
/// 特点：
/// - 使用USD（美元）作为统一货币
/// - 支持所有支付方式：支付宝、微信支付、Stripe
/// - 支持所有登录方式：微信、Google、Apple（需要实现相应的登录模块）
/// - 自动注入测试账号，免登录
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('========================================');
  print('DSKK Flutter Unified Entry - Development');
  print('========================================');

  // 先加载.env文件
  try {
    await dotenv.load(fileName: ".env");
    print('.env file loaded successfully.');
  } catch (e) {
    print('No .env file found, using default configuration.');
  }
  
  // 配置统一服设置
  RegionConfig.setRegion(RegionType.unified);
  
  // 使用环境变量配置的API地址
  String? backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
  if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
    throw Exception('BACKEND_BASE_URL environment variable is not set. Please configure it in your .env file.');
  }
  
  print('[Unified Dev] Using API: $backendBaseUrl');
  print('[Unified Dev] Model API: ${RegionConfig.modelBaseUrl}');
  print('[Unified Dev] Currency: ${RegionConfig.defaultCurrency.code} (${RegionConfig.currencySymbol})');
  print('[Unified Dev] Payment methods: ${RegionConfig.supportedPaymentMethods.map((m) => m.displayName).join(', ')}');
  print('[Unified Dev] Features enabled:');
  RegionConfig.features.forEach((key, value) {
    if (value) print('  ✓ $key');
  });

  // 验证支付相关配置
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 初始化依赖注入
  await configureDependencies(backendBaseUrl: backendBaseUrl);
  print('[Unified Dev] Core dependencies configured.');
  
  // 初始化各个模块依赖
  await initHomeDi();
  print('[Unified Dev] Home module initialized.');
  
  await FavoritesDI.init(getIt);
  print('[Unified Dev] Favorites module initialized.');
  
  await AiDocsDI.init(getIt);
  print('[Unified Dev] AI Docs module initialized.');
  
  await ChatDI.init(getIt);
  print('[Unified Dev] Chat module initialized.');
  
  await ProfileDI.init(getIt);
  print('[Unified Dev] Profile module initialized.');
  
  SellerStatisticsDI.init(getIt);
  print('[Unified Dev] Seller Statistics module initialized.');
  
  await SellerDI.init(getIt);
  print('[Unified Dev] Seller module initialized.');
  
  await PaymentDI.init(getIt);
  print('[Unified Dev] Payment module initialized.');

  // 开发环境：注入测试账号
  await _injectTestCredentials();

  // 初始化分析模块
  await initAnalyticsModule();
  print('[Unified Dev] Analytics module initialized.');

  // 配置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[Unified Dev] Analytics BLoC observer configured.');

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

/// 开发环境注入测试账号
Future<void> _injectTestCredentials() async {
  print('[Development] Injecting test credentials...');
  
  // 测试账号信息（硬编码）
  const userToken = "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiIxMzgxOTE5ODgxMCIsImNyZWF0ZWQiOjE3MzQ0MjAzMjk0MzAsImV4cCI6MTczNzAxMjMyOX0.P9WBtjeM2VJQHKw0fRHEcTaFdJdCelQKT-9lfBu17lrz3VzJ78VVT-dmnwXnfXy3W4CRn3PJSF1RlP7EzW-GJA";
  const userId = "13819198810";
  const userName = "ccc";
  const phoneNumber = "13819198810";
  const hasSecondaryPassword = "true";
  const hasShop = "true";
  const shopImage = "https://duoshaokankan.oss-cn-hangzhou.aliyuncs.com/DuoShaoKanKan/2023-11-28/1701137879809_th.jpg";
  const shopName = "mcccccccccc_1号店";
  const shopProductDisplay = "grid";
  const shopScore = "5.0";
  const shopId = "1464884047606677506";
  const userStatus = "Normal";
  const gender = "male";

  final prefs = await SharedPreferences.getInstance();
  const storage = FlutterSecureStorage();
  
  // 保存用户数据到SharedPreferences
  await prefs.setString('USER_TOKEN_KEY', userToken);
  await prefs.setString('USER_ID', userId);
  await prefs.setString('USER_NAME', userName);
  await prefs.setString('PHONE_NUMBER', phoneNumber);
  await prefs.setString('USER_HAS_SECONDARY_PASSWORD', hasSecondaryPassword);
  await prefs.setString('USER_HAS_SHOP', hasShop);
  await prefs.setString('USER_SHOP_IMAGE', shopImage);
  await prefs.setString('USER_SHOP_NAME', shopName);
  await prefs.setString('USER_SHOP_PRODUCT_DISPLAY', shopProductDisplay);
  await prefs.setString('USER_SHOP_SCORE', shopScore);
  await prefs.setString('USER_SHOP_ID', shopId);
  await prefs.setString('USER_STATUS', userStatus);
  await prefs.setString('USER_GENDER', gender);
  
  // 保存到secure storage
  await storage.write(key: 'USER_TOKEN_KEY', value: userToken);

  print('[Development] Test credentials injected successfully');
  print('  User ID: $userId');
  print('  User Name: $userName');
  print('  Shop Name: $shopName');
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