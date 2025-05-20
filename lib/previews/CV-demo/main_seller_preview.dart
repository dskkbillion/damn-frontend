import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 导入SharedPreferences

// Import the root App Widget
import 'package:dskk_flutter_refactor/app/app.dart';
// Import the DI configuration function and GetIt instance
import 'package:dskk_flutter_refactor/app/di/injection_container.dart'; // Exports getIt
// Import the IAuthRepository interface and the Mock implementation
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dskk_flutter_refactor/core/auth/repositories/mocks/mock_auth_repository.dart';
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart'; // Import Home DI
import 'package:dskk_flutter_refactor/features/favorites/di/favorites_di.dart'; // Import Favorites DI
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';
import 'package:dskk_flutter_refactor/features/payment/di/payment_di.dart'; // 导入支付模块DI
// 导入安全存储仓库
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository_impl.dart';
// import 'package:dskk_flutter_refactor/features/profile/di/profile_di.dart'; // 不再需要引入

// 导入Home模块的导航配置
import 'package:dskk_flutter_refactor/features/home/presentation/navigation/home_navigation_di.dart';
import 'package:dskk_flutter_refactor/app/navigation/app_router.dart'; // GoRouter provider
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart'; // 导入路由配置
import 'package:dskk_flutter_refactor/app/app_mode.dart'; // 导入应用模式
import 'package:dskk_flutter_refactor/core/config/locale_provider.dart'; // 导入语言提供者

/// 卖家演示入口
/// 用于演示展示卖家界面
Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  String? backendBaseUrl; // Declare variable
  try {
      await dotenv.load(fileName: ".env");
      backendBaseUrl = dotenv.env['BACKEND_BASE_URL']; // Extract URL
      print("[main_seller_preview] Loaded BACKEND_BASE_URL: $backendBaseUrl");
      if (backendBaseUrl == null || backendBaseUrl.isEmpty) {
          print("[main_seller_preview] WARNING: BACKEND_BASE_URL not found or empty. Using fallback.");
          backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback
      }
  } catch (e) {
      print("[main_seller_preview] Error loading .env file: $e. Using fallback.");
      backendBaseUrl = 'https://app.duoshaokankan.com/prod-api'; // Fallback on error
  }

  // 初始化SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('[main_seller_preview] SharedPreferences initialized.');
  
  // 注册SharedPreferences到GetIt容器中
  getIt.registerSingleton<SharedPreferences>(prefs);
  print('[main_seller_preview] Registered SharedPreferences to GetIt container.');
  
  // 注册SecureStorageRepository
  if (!getIt.isRegistered<ISecureStorageRepository>()) {
    getIt.registerLazySingleton<ISecureStorageRepository>(
      () => SecureStorageRepositoryImpl(getIt<FlutterSecureStorage>()),
    );
    print('[main_seller_preview] Registered ISecureStorageRepository to GetIt container.');
  }

  // Initialize dependencies (using the same configuration as the main app)
  await configureDependencies(backendBaseUrl: backendBaseUrl!);
  print('[main_seller_preview] Core dependencies configured.');

  // Initialize Home module dependencies AFTER core dependencies
  await initHomeDi();
  print('[main_seller_preview] Home dependencies configured.');

  // Initialize Favorites module dependencies
  await FavoritesDI.init(getIt);
  print('[main_seller_preview] Favorites dependencies configured.');

  // Initialize Seller Statistics module dependencies
  SellerStatisticsDI.init(getIt);
  print('[main_seller_preview] Seller Statistics dependencies configured.');

  // Initialize Payment module dependencies
  await PaymentDI.init(getIt);
  print('[main_seller_preview] Payment dependencies configured.');

  // --- Override AuthRepository with Mock for Preview --- 
  print('[main_seller_preview] Overriding IAuthRepository with MockAuthRepository...');
  getIt.allowReassignment = true; // Allow overriding registrations
  // 传递FlutterSecureStorage到MockAuthRepository，以便它可以读取真实的token和ID
  getIt.registerLazySingleton<IAuthRepository>(
    () => MockAuthRepository(secureStorage: getIt<FlutterSecureStorage>())
  );
  getIt.allowReassignment = false; // Optional: Disable reassignment after overriding
  print('[main_seller_preview] IAuthRepository overridden.');
  // ---------------------------------------------------------

  // --- Manually Inject Seller Token and User ID --- 
  print('[main_seller_preview] Injecting seller credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>(); 
    // 使用卖家测试账号
    const sellerToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjdkMjg0MjkzLTVjNzYtNDc0Mi05ZmI4LTIzODdhZjI3ODkzZCJ9.Yp0qHMGlHjShMwnf1LQJ4wCzqakG-fZn7-xpQ2P0GpZ_60fk4_WmIPZ63QpAISbyRrO_-_g8rwoqH86iVGdQtA"; // 卖家Token
    const sellerUserId = "18888888888"; // 卖家ID
    const sellerCommonUserId = "1"; // 卖家通用ID

    await storage.write(key: 'auth_token', value: sellerToken);
    await storage.write(key: 'user_id', value: sellerUserId);
    await storage.write(key: 'common_user_id', value: sellerCommonUserId);

    print('[main_seller_preview] Successfully injected seller credentials.');
  } catch (e) {
     print('[main_seller_preview] ERROR injecting seller credentials: $e');
  }
  // -------------------------------------------------------------

  // Run the main application widget
  runApp(
    ProviderScope(
      overrides: [
        // 设置为卖家模式
        appModeProvider.overrideWith((ref) => AppMode.seller),
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
                print('[main_seller_preview] 开始注册实际的导航服务...');
                HomeNavigationDI.registerRealNavigationService(getIt, router);
                print('[main_seller_preview] 导航服务注册完成');
              });
              
              return const MyApp();
            },
          );
        },
      ),
    ),
  );
} 