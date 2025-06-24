import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入SharedPreferences
import 'package:flutter_bloc/flutter_bloc.dart'; // 导入BLoC

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import the IAuthRepository interface and the Mock implementation
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/mocks/mock_auth_repository.dart';
// 导入安全存储仓库
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository_impl.dart';
// 订单模块依赖将通过统一的OrdersDI配置
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart'; // Import Home DI
import 'package:dskk_flutter_refactor/features/favorites/di/favorites_di.dart'; // Import Favorites DI
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';
// PaymentBloc将通过支付模块DI配置
import 'package:dskk_flutter_refactor/features/payment/di/payment_di.dart'; // 导入支付模块DI
// 导入AI文档和聊天模块的DI
import 'package:dskk_flutter_refactor/features/ai_docs/di/ai_docs_di.dart';
import 'package:dskk_flutter_refactor/features/chat/di/chat_di.dart';
// 导入Profile模块DI
import 'package:dskk_flutter_refactor/features/profile/di/profile_di.dart';
// 导入Analytics模块
import 'package:dskk_flutter_refactor/core/analytics/di/analytics_injection.dart';
import 'package:dskk_flutter_refactor/core/analytics/observers/analytics_bloc_observer.dart';
// 导入core/auth中的IAuthRepository
import 'package:dskk_flutter_refactor/core/auth/repositories/i_auth_repository.dart' as core_auth;

// 导入Home模块的导航配置
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_di.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart'; // GoRouter provider
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart'; // 导入路由配置
import 'package:dskk_flutter_refactor/app/app_mode.dart'; // 导入应用模式
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart'; // 导入语言提供者

/// 买家演示入口
/// 用于演示展示买家界面，不显示开发tab
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 设置为买家模式
  AppRouterConfig.setShowDevTab(false); // 不显示开发tab

  // Load environment variables from .env file
  String? backendBaseUrl; // Declare variable
  try {
      await dotenv.load(fileName: ".env");
      backendBaseUrl = dotenv.env['BACKEND_BASE_URL']; // Extract URL
      print("[main_buyer_preview] Loaded BACKEND_BASE_URL: $backendBaseUrl");
      if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
          print("[main_buyer_preview] WARNING: BACKEND_BASE_URL not found or empty. Using fallback.");
          backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
      }
  } catch (e) {
      print("[main_buyer_preview] Error loading .env file: $e. Using fallback.");
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback on error
  }

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('[main_buyer_preview] SharedPreferences initialized.');
  
  // 注册SharedPreferences到GetIt容器中
  getIt.registerSingleton<SharedPreferences>(prefs);
  print('[main_buyer_preview] Registered SharedPreferences to GetIt container.');
  
  // 注册SecureStorageRepository
  if (!getIt.isRegistered<ISecureStorageRepository>()) {
    getIt.registerLazySingleton<ISecureStorageRepository>(
      () => SecureStorageRepositoryImpl(getIt<FlutterSecureStorage>()),
    );
    print('[main_buyer_preview] Registered ISecureStorageRepository to GetIt container.');
  }

  // 1. 初始化核心依赖
  await configureDependencies(backendBaseUrl: backendBaseUrl!);
  print('[main_buyer_preview] Core dependencies configured.');

  // 2. 初始化Home模块依赖
  await initHomeDi();
  print('[main_buyer_preview] Home dependencies configured.');

  // 3. 初始化Favorites模块依赖
  await FavoritesDI.init(getIt);
  print('[main_buyer_preview] Favorites dependencies configured.');

  // 8. 初始化卖家统计模块
  SellerStatisticsDI.init(getIt);
  print('[main_buyer_preview] Seller Statistics dependencies configured.');
  
  // 10. 初始化支付模块依赖
  await PaymentDI.init(getIt);
  print('[main_buyer_preview] Payment dependencies configured.');
  
  // 4. 覆盖AuthRepository
  print('[main_buyer_preview] Overriding IAuthRepository with MockAuthRepository...');
  getIt.allowReassignment = true; // Allow overriding registrations
  // 传递FlutterSecureStorage到MockAuthRepository，以便它可以读取真实的token和ID
  getIt.registerLazySingleton<IAuthRepository>(
    () => MockAuthRepository(secureStorage: getIt<FlutterSecureStorage>())
  );
  // 同时注册core_auth.IAuthRepository的适配器
  getIt.registerLazySingleton<core_auth.IAuthRepository>(
    () => AuthRepositoryAdapter()
  );
  getIt.allowReassignment = false; // Optional: Disable reassignment after overriding
  print('[main_buyer_preview] IAuthRepository overridden.');
  
  // 9. 初始化分析模块依赖 - 需要在AuthRepository注册之后
  await initAnalyticsModule();
  print('[main_buyer_preview] Analytics dependencies configured.');
  
  // 设置BLoC观察者
  Bloc.observer = AnalyticsBlocObserver();
  print('[main_buyer_preview] Analytics BLoC observer configured.');
  
  // 5. 初始化AI文档模块依赖 - 卖家模块依赖于IFileUploadRepository
  await AiDocsDI.init(getIt);
  print('[main_buyer_preview] AI Docs dependencies configured.');
  
  // 6. 初始化聊天模块依赖 - 依赖于认证模块
  await ChatDI.init(getIt);
  print('[main_buyer_preview] Chat dependencies configured.');
  
  // 7. 初始化Profile模块依赖
  await ProfileDI.init(getIt);
  print('[main_buyer_preview] Profile dependencies configured.');
  
  // 11. 手动注入买家认证信息
  print('[main_buyer_preview] Injecting buyer credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>(); 
    // 使用买家测试账号
    const buyerToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjllYWQ5YWJjLWMxZmEtNGM3ZC04ODllLWJjM2EzNjg4MDQxNSJ9.GgGSkCr4YG_Hf-stG8NuYFRZeebOO24vkhYQ_i8EVZzvIj9VO3VB7PdnpV6VlM7-TBJydQSdKy1mUI9jwsaKRw"; // 买家Token
    const buyerUserId = "13819198810"; // 买家ID
    const buyerCommonUserId = "10319"; // 买家通用ID
    const buyerReferId = "10319"; // 买家referId，用于聊天模块数据匹配（对应API返回的member.referId）

    await storage.write(key: 'auth_token', value: buyerToken);
    await storage.write(key: 'user_id', value: buyerUserId);
    await storage.write(key: 'common_user_id', value: buyerCommonUserId);
    await storage.write(key: 'refer_id', value: buyerReferId); // 新增：用于聊天模块

    print('[main_buyer_preview] Successfully injected buyer credentials with referId: $buyerReferId');
  } catch (e) {
     print('[main_buyer_preview] ERROR injecting buyer credentials: $e');
  }

  // Run the main application widget
  runApp(
    ProviderScope(
      overrides: [
        // 设置为买家模式
        appModeProvider.overrideWith((ref) => AppMode.buyer),
        // 添加SharedPreferences提供者覆盖
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
                print('[main_buyer_preview] 开始注册实际的导航服务...');
                HomeNavigationDI.registerRealNavigationService(getIt, router);
                print('[main_buyer_preview] 导航服务注册完成');
              });
              
              return const MyApp();
            },
          );
        },
      ),
    ),
  );
} 