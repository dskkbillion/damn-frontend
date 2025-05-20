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
// 导入安全存储仓库
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository.dart';
import 'package:dskk_flutter_refactor/core/storage/secure_storage_repository_impl.dart';
// 导入订单相关类
import 'package:dskk_flutter_refactor/features/orders/domain/repositories/i_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/data/repositories/mocks/mock_order_repository.dart';
import 'package:dskk_flutter_refactor/features/orders/domain/usecases/create_order_use_case.dart';
import 'package:dskk_flutter_refactor/features/home/di/home_di.dart'; // Import Home DI
import 'package:dskk_flutter_refactor/features/favorites/di/favorites_di.dart'; // Import Favorites DI
import 'package:dskk_flutter_refactor/features/seller/di/seller_statistics_di.dart';
import 'package:dskk_flutter_refactor/features/payment/presentation/bloc/payment_bloc.dart'; // 导入PaymentBloc
import 'package:dskk_flutter_refactor/core/payment/services/i_payment_service.dart'; // 导入IPaymentService
import 'package:dskk_flutter_refactor/features/payment/di/payment_di.dart'; // 导入支付模块DI
// import 'package:dskk_flutter_refactor/features/profile/di/profile_di.dart'; // 不再需要引入

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
  
  // 注册订单相关依赖
  if (!getIt.isRegistered<IOrderRepository>()) {
    getIt.registerLazySingleton<IOrderRepository>(() => MockOrderRepository());
    print('[main_buyer_preview] Registered IOrderRepository to GetIt container.');
  }
  
  if (!getIt.isRegistered<CreateOrderUseCase>()) {
    getIt.registerLazySingleton<CreateOrderUseCase>(
      () => CreateOrderUseCase(getIt<IOrderRepository>()),
    );
    print('[main_buyer_preview] Registered CreateOrderUseCase to GetIt container.');
  }

  // 注册PaymentBloc
  if (!getIt.isRegistered<PaymentBloc>()) {
    getIt.registerFactory<PaymentBloc>(() => PaymentBloc(
      createOrderUseCase: getIt<CreateOrderUseCase>(),
      paymentService: getIt<IPaymentService>(),
    ));
    print('[main_buyer_preview] Registered PaymentBloc to GetIt container.');
  }

  // Initialize dependencies (using the same configuration as the main app)
  await configureDependencies(backendBaseUrl: backendBaseUrl!);
  print('[main_buyer_preview] Core dependencies configured.');

  // Initialize Home module dependencies AFTER core dependencies
  await initHomeDi();
  print('[main_buyer_preview] Home dependencies configured.');

  // Initialize Favorites module dependencies
  await FavoritesDI.init(getIt);
  print('[main_buyer_preview] Favorites dependencies configured.');

  // Initialize Seller Statistics module dependencies
  SellerStatisticsDI.init(getIt);
  print('[main_buyer_preview] Seller Statistics dependencies configured.');
  
  // 初始化支付模块依赖
  await PaymentDI.init(getIt);
  print('[main_buyer_preview] Payment dependencies configured.');

  // --- Override AuthRepository with Mock for Preview --- 
  print('[main_buyer_preview] Overriding IAuthRepository with MockAuthRepository...');
  getIt.allowReassignment = true; // Allow overriding registrations
  // 传递FlutterSecureStorage到MockAuthRepository，以便它可以读取真实的token和ID
  getIt.registerLazySingleton<IAuthRepository>(
    () => MockAuthRepository(secureStorage: getIt<FlutterSecureStorage>())
  );
  getIt.allowReassignment = false; // Optional: Disable reassignment after overriding
  print('[main_buyer_preview] IAuthRepository overridden.');
  // ---------------------------------------------------------

  // --- Manually Inject Buyer Token and User ID --- 
  print('[main_buyer_preview] Injecting buyer credentials...');
  try {
    final storage = getIt<FlutterSecureStorage>(); 
    // 使用买家测试账号
    const buyerToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjBiYjgzYmIwLTIxNTEtNGMyNC1iYmJlLWIwZjY0YzdhY2Y1NSJ9.XxzKc2VTTYE3GKjRYH53jBwGPzrGfmvppayKy31dkzu-XQdFiCDlZXFLgELOLCF0UGdxhoJTkSG-8MNMToIEww"; // 买家Token
    const buyerUserId = "13819198810"; // 买家ID
    const buyerCommonUserId = "10319"; // 买家通用ID

    await storage.write(key: 'auth_token', value: buyerToken);
    await storage.write(key: 'user_id', value: buyerUserId);
    await storage.write(key: 'common_user_id', value: buyerCommonUserId);

    print('[main_buyer_preview] Successfully injected buyer credentials.');
  } catch (e) {
     print('[main_buyer_preview] ERROR injecting buyer credentials: $e');
  }
  // -------------------------------------------------------------

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