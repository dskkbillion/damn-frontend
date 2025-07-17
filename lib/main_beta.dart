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

/// 公测入口
/// 用于用户公开测试，包含完整的注册登录流程，不预设登录状态
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  print('[main_beta] 🚀 启动公测环境...');

  // Load environment variables from .env file
  String? backendBaseUrl;
  try {
    await dotenv.load(fileName: ".env");
    backendBaseUrl = dotenv.env['BACKEND_BASE_URL'];
    print("[main_beta] ✅ 环境配置加载成功: $backendBaseUrl");
    
    if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
      print("[main_beta] ⚠️  BACKEND_BASE_URL未配置，使用生产环境地址");
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api';
    }
  } catch (e) {
    print("[main_beta] ❌ 环境配置加载失败: $e，使用生产环境地址");
    backendBaseUrl = 'https://app.duoshaokankan.com/prod-api';
  }

  // 验证支付相关配置
  print('[main_beta] 🔍 验证支付配置...');
  ConfigValidator.printValidationReport();

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('[main_beta] ✅ SharedPreferences初始化完成');
  
  // 注册SharedPreferences到GetIt容器
  getIt.registerSingleton<SharedPreferences>(prefs);
  print('[main_beta] ✅ SharedPreferences注册到DI容器');
  
  // 注册SecureStorageRepository
  if (!getIt.isRegistered<ISecureStorageRepository>()) {
    getIt.registerLazySingleton<ISecureStorageRepository>(
      () => SecureStorageRepositoryImpl(getIt<FlutterSecureStorage>()),
    );
    print('[main_beta] ✅ SecureStorageRepository注册完成');
  }

  // ==================== 依赖注入初始化 ====================
  print('[main_beta] 🔧 开始初始化所有模块依赖...');

  // 1. 初始化核心依赖（包含真实的认证服务）
  await configureDependencies(backendBaseUrl: backendBaseUrl!);
  print('[main_beta] ✅ 核心依赖配置完成（使用真实认证服务）');

  // 2. 初始化各个模块依赖
  await initHomeDi();
  print('[main_beta] ✅ Home模块依赖配置完成');

  await FavoritesDI.init(getIt);
  print('[main_beta] ✅ Favorites模块依赖配置完成');

  await AiDocsDI.init(getIt);
  print('[main_beta] ✅ AI文档模块依赖配置完成');
  
  await ChatDI.init(getIt);
  print('[main_beta] ✅ 聊天模块依赖配置完成');
  
  await ProfileDI.init(getIt);
  print('[main_beta] ✅ Profile模块依赖配置完成');

  SellerStatisticsDI.init(getIt);
  print('[main_beta] ✅ 卖家统计模块依赖配置完成');

  await SellerDI.init(getIt);
  print('[main_beta] ✅ 卖家模块依赖配置完成');

  await PaymentDI.init(getIt);
  print('[main_beta] ✅ 支付模块依赖配置完成');

  // 注意：公测版本不覆盖认证服务，使用默认的真实认证服务
  print('[main_beta] ✅ 真实认证服务已配置，用户需要进行注册/登录');

  // 3. 初始化分析模块（会自动注册core_auth.IAuthRepository适配器）
  await initAnalyticsModule();
  print('[main_beta] ✅ 分析模块依赖配置完成');
  
  // 设置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[main_beta] ✅ BLoC分析观察者配置完成');

  // ==================== 清理存储状态 ====================
  await _clearPreviousUserSession();

  // ==================== 应用配置 ====================
  print('[main_beta] ⚙️  配置应用设置...');
  
  // 公测版本不显示开发Tab
  AppRouterConfig.setShowDevTab(false);
  print('[main_beta] ✅ 应用配置完成');

  print('[main_beta] 🎉 所有初始化完成，启动公测应用...');
  print('[main_beta] 📱 用户需要通过注册/登录页面进入应用');

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
                print('[main_beta] 🧭 注册导航服务...');
                HomeNavigationDI.registerRealNavigationService(getIt, router);
                print('[main_beta] ✅ 导航服务注册完成');
              });
              
              return const MyApp();
            },
          );
        },
      ),
    ),
  );
}

/// 清理之前的用户会话
/// 确保公测用户从干净的状态开始
Future<void> _clearPreviousUserSession() async {
  print('[main_beta] 🧹 清理之前的用户会话...');
  
  try {
    final storage = getIt<FlutterSecureStorage>();
    
    // 清理所有认证相关的存储数据
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'user_id');
    await storage.delete(key: 'common_user_id');
    await storage.delete(key: 'refer_id');
    
    // 清理其他可能的用户数据
    await storage.delete(key: 'user_profile');
    await storage.delete(key: 'login_remember');
    
    print('[main_beta] ✅ 用户会话清理完成');
    print('[main_beta] 👤 用户将从登录页面开始体验');
    
  } catch (e) {
    print('[main_beta] ⚠️  用户会话清理失败: $e');
    print('[main_beta] 💡 用户可能需要手动注销或重新安装应用');
  }
} 