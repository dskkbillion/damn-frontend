import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart';
// Import the IAuthRepository interface and the Mock implementation
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/mocks/mock_auth_repository.dart';

// Import all module DI configurations
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart';
import 'package:dskk_flutter_refactor/features/favorites/di/favorites_di.dart';
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';
import 'package:dskk_flutter_refactor/features/payment/di/payment_di.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/di/ai_docs_di.dart';
import 'package:dskk_flutter_refactor/features/chat/di/chat_di.dart';
import 'package:dskk_flutter_refactor/features/profile/di/profile_di.dart';
import 'package:dskk_flutter_refactor/features/seller/di/seller_di.dart';

// Import storage repository
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository_impl.dart';

// Import Analytics
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart';
import 'package:dskk_flutter_refactor/core/analytics/observers/analytics_bloc_observer.dart';

// Import core auth adapter
import 'package:dskk_flutter_refactor/core/auth/repositories/i_auth_repository.dart' as core_auth;
// 导入配置验证工具
import 'package:dskk_flutter_refactor/core/utils/config_validator.dart';

// Import navigation and app configuration
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_di.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';
import 'package:dskk_flutter_refactor/app/app_mode.dart';
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart';

/// 上线前测试入口
/// 用于Production-ready测试，包含完整功能和测试用户账号
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  print('[main_dev_VC] 🚀 启动上线前测试环境...');

  // Load environment variables from .env file
  String? backendBaseUrl;
  try {
    await dotenv.load(fileName: ".env");
    backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
    print("[main_dev_VC] ✅ 环境配置加载成功: $backendBaseUrl");
    
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
      print("[main_dev_VC] ⚠️  BACKEND_BASE_URL未配置，使用生产环境地址");
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api';
    }
  } catch (e) {
    print("[main_dev_VC] ❌ 环境配置加载失败: $e，使用生产环境地址");
    backendBaseUrl = 'https://app.duoshaokankan.com/prod-api';
  }

  // 验证支付相关配置
  print('[main_dev_VC] 🔍 验证支付配置...');
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('[main_dev_VC] ✅ SharedPreferences初始化完成');
  
  // 注册SharedPreferences到GetIt容器
  getIt.registerSingleton<SharedPreferences>(prefs);
  print('[main_dev_VC] ✅ SharedPreferences注册到DI容器');
  
  // 注册SecureStorageRepository
  if (!getIt.isRegistered<ISecureStorageRepository>()) {
    getIt.registerLazySingleton<ISecureStorageRepository>(
      () => SecureStorageRepositoryImpl(getIt<FlutterSecureStorage>()),
    );
    print('[main_dev_VC] ✅ SecureStorageRepository注册完成');
  }

  // ==================== 依赖注入初始化 ====================
  print('[main_dev_VC] 🔧 开始初始化所有模块依赖...');

  // 1. 初始化核心依赖
  await configureDependencies(backendBaseUrl: backendBaseUrl!);
  print('[main_dev_VC] ✅ 核心依赖配置完成');

  // 2. 初始化各个模块依赖
  await initHomeDi();
  print('[main_dev_VC] ✅ Home模块依赖配置完成');

  await FavoritesDI.init(getIt);
  print('[main_dev_VC] ✅ Favorites模块依赖配置完成');

  await AiDocsDI.init(getIt);
  print('[main_dev_VC] ✅ AI文档模块依赖配置完成');
  
  await ChatDI.init(getIt);
  print('[main_dev_VC] ✅ 聊天模块依赖配置完成');
  
  await ProfileDI.init(getIt);
  print('[main_dev_VC] ✅ Profile模块依赖配置完成');

  SellerStatisticsDI.init(getIt);
  print('[main_dev_VC] ✅ 卖家统计模块依赖配置完成');

  await SellerDI.init(getIt);
  print('[main_dev_VC] ✅ 卖家模块依赖配置完成');

  await PaymentDI.init(getIt);
  print('[main_dev_VC] ✅ 支付模块依赖配置完成');

  // 3. 覆盖AuthRepository为Mock版本（便于测试）
  print('[main_dev_VC] 🔄 配置测试认证服务...');
  getIt.allowReassignment = true;
  getIt.registerLazySingleton<IAuthRepository>(
    () => MockAuthRepository(secureStorage: getIt<FlutterSecureStorage>())
  );
  getIt.registerLazySingleton<core_auth.IAuthRepository>(
    () => AuthRepositoryAdapter()
  );
  getIt.allowReassignment = false;
  print('[main_dev_VC] ✅ 测试认证服务配置完成');

  // 4. 初始化分析模块
  await initAnalyticsModule();
  print('[main_dev_VC] ✅ 分析模块依赖配置完成');
  
  // 设置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[main_dev_VC] ✅ BLoC分析观察者配置完成');

  // ==================== 测试用户账号注入 ====================
  await _injectTestUserCredentials();

  // ==================== 应用配置 ====================
  print('[main_dev_VC] ⚙️  配置应用设置...');
  
  // 上线前测试不需要开发Tab
  AppRouterConfig.setShowDevTab(false);
  print('[main_dev_VC] ✅ 应用配置完成');

  print('[main_dev_VC] 🎉 所有初始化完成，启动应用...');

  // Run the main application
  runApp(
    ProviderScope(
      overrides: [
        // 默认使用买家模式，支持所有功能
        appModeProvider.overrideWith((ref) => AppMode.buyer),
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
                print('[main_dev_VC] 🧭 注册导航服务...');
                HomeNavigationDI.registerRealNavigationService(getIt, router);
                print('[main_dev_VC] ✅ 导航服务注册完成');
              });
              
              return const MyApp();
            },
          );
        },
      ),
    ),
  );
}

/// 注入测试用户账号信息
/// 使用通用测试用户，支持所有功能模块
Future<void> _injectTestUserCredentials() async {
  print('[main_dev_VC] 💳 注入测试User账号信息...');
  
  try {
    final storage = getIt<FlutterSecureStorage>();
    
    // ==================== 测试用户账号 ====================
    const userToken = "PLACEHOLDER_TOKEN_FOR_DEV";
    const userId = "13819198810";
    const commonUserId = "10319";
    const referId = "10319";

    await storage.write(key: 'auth_token', value: userToken);
    await storage.write(key: 'user_id', value: userId);
    await storage.write(key: 'common_user_id', value: commonUserId);
    await storage.write(key: 'refer_id', value: referId);

    print('[main_dev_VC] ✅ 测试User账号注入完成');
    print('[main_dev_VC] 👤 UserID: $userId');
    print('[main_dev_VC] 🆔 CommonUserID: $commonUserId');
    print('[main_dev_VC] 🔗 ReferID: $referId');
    print('[main_dev_VC] 💡 可使用所有功能模块进行测试');
    
  } catch (e) {
    print('[main_dev_VC] ❌ 测试用户账号注入失败: $e');
  }
}