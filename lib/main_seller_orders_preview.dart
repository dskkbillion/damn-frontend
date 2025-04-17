import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage
import 'package:flutter_dotenv/flutter_dotenv.dart'; 
import 'package:flutter/services.dart' show rootBundle;
import 'package:package_info_plus/package_info_plus.dart';

// 假设你的 DI 设置在 injection.dart 或类似文件中
// 必要时调整导入路径
import 'app/di/injection_container.dart';
// 假设你的 AppTheme 在这里定义
// 必要时调整导入路径
import 'core/config/theme/app_theme.dart';

// 导入卖家视图所需的 BLoC 和 Page
import 'features/orders/presentation/seller/bloc/seller_order_list_bloc.dart';
import 'features/orders/presentation/seller/pages/seller_order_list_page.dart';
// 导入 UseCase
import 'features/orders/domain/usecases/get_order_list_use_case.dart';
import 'features/orders/domain/usecases/confirm_order_acceptance_use_case.dart';
import 'features/orders/domain/usecases/reject_order_use_case.dart';
import 'features/orders/domain/usecases/deliver_order_use_case.dart';
import 'features/orders/domain/usecases/invite_evaluation_use_case.dart';
import 'features/orders/domain/usecases/delete_seller_record_use_case.dart';

// 导入 mock repository (或创建一个卖家专属的)
// import 'features/orders/data/repositories/mocks/mock_order_repository.dart'; // 使用下面的卖家 Mock
import 'features/orders/data/repositories/mocks/mock_seller_order_repository.dart';
import 'features/orders/domain/repositories/i_order_repository.dart';

// 导入 GoRouter 配置
import 'core/router/app_router.dart';

// 配置 GetIt 实例
final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
Future<void> configureDependenciesPreview() async {
  // 注册环境过滤器
  // 你可以重用 'dev' 环境或定义一个特定的 'seller_preview' 环境
  const env = Environment('dev');

  // 如果需要核心设置，初始化主要依赖项
  // await configureDependencies(env: env); // 调用你的主 DI 设置

  // --- 卖家视图的预览特定覆盖 ---

  // 使用适用于卖家视图的 mock 实现覆盖 IOrderRepository
  // 注意：先 unregister 再 register 是更可靠的覆盖方式
  /* 
  if (getIt.isRegistered<IOrderRepository>()) {
    print('[Preview DI] Unregistering existing IOrderRepository...');
    await getIt.unregister<IOrderRepository>(); // Unregister first
     // Register the Mock repository
    print('[Preview DI] Registering MockSellerOrderRepository...');
    getIt.registerLazySingleton<IOrderRepository>(() => MockSellerOrderRepository());
  } else {
      // If not registered by main config (should not happen now), register it here
      print('[Preview DI] IOrderRepository not found in main config, registering MockSellerOrderRepository...');
      getIt.registerLazySingleton<IOrderRepository>(() => MockSellerOrderRepository());
  }
  */

  // --- 移除以下注册，假设它们由主 configureDependencies() 处理 ---
  /* 
  getIt.registerFactory(() => GetOrderListUseCase(getIt()));
  getIt.registerFactory(() => ConfirmOrderAcceptanceUseCase(getIt()));
  getIt.registerFactory(() => RejectOrderUseCase(getIt()));
  getIt.registerFactory(() => DeliverOrderUseCase(getIt()));
  getIt.registerFactory(() => InviteEvaluationUseCase(getIt()));
  getIt.registerFactory(() => DeleteSellerRecordUseCase(getIt()));

  // Register SellerOrderListBloc, assuming it's covered by main config
  getIt.registerFactory(() => SellerOrderListBloc(
      getIt(), // GetOrderListUseCase
      getIt(), // ConfirmOrderAcceptanceUseCase
      getIt(), // RejectOrderUseCase
      getIt(), // DeliverOrderUseCase
      getIt(), // InviteEvaluationUseCase
      getIt(), // DeleteSellerRecordUseCase
      ));
  */

  // 确保卖家 Pages/Blocs 需要的所有其他依赖项都已注册 (或 mock)
  // 例如 NavigationService, PaymentService (如果适用)
  // 确保你的核心 DI 设置 (configureDependencies) 已经被调用，或者在这里手动注册必要的 Core 服务
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // --- Load .env and Register baseUrl (like in main_orders_preview) ---
  final Map<String, String> envMap = {}; 
  print('[main_seller_preview] Loading .env from assets...');
  try {
    // Load .env (ensure it's in pubspec.yaml assets)
    await dotenv.load(fileName: ".env");
    // Read manually for GetIt registration before injectable runs
    final envString = await rootBundle.loadString('.env');
    final lines = envString.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final index = line.indexOf('=');
      if (index != -1) {
        final key = line.substring(0, index).trim();
        final value = line.substring(index + 1).trim();
        if (key.isNotEmpty) {
          envMap[key] = value;
        }
      }
    }
    print('[main_seller_preview] Successfully parsed .env from assets.');
    
    // **Explicitly register the baseUrl String with the name 'baseUrl'**
    final baseUrl = envMap['BACKEND_BASE_URL'];
    if (baseUrl != null && baseUrl.isNotEmpty) {
      getIt.registerSingleton<String>(baseUrl, instanceName: 'baseUrl');
      print('[main_seller_preview] Registered baseUrl: $baseUrl with instanceName: baseUrl');
    } else {
      throw Exception('[main_seller_preview] BACKEND_BASE_URL is missing or empty in .env file');
    }
  } catch (e) {
    print('[main_seller_preview] Error loading/parsing .env or registering baseUrl: $e');
    throw Exception('Failed to load environment configuration');
  }
  // ---------------------------------------------------------------------

  // --- Register FlutterSecureStorage (like in main_orders_preview) ---
  getIt.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  print('[main_seller_preview] Registered FlutterSecureStorage as LazySingleton.');
  // ---------------------------------------------------------------------

  // --- Register PackageInfo (needed by AppInfoInterceptor -> CoreDioClient) ---
   try {
    final packageInfo = await PackageInfo.fromPlatform();
    getIt.registerSingleton<PackageInfo>(packageInfo);
    print('[main_seller_preview] Registered PackageInfo: ${packageInfo.packageName} v${packageInfo.version}');
  } catch (e) {
    print('[main_seller_preview] ERROR: Failed to get or register PackageInfo: $e');
    throw Exception('Failed to initialize PackageInfo');
  }
  // --------------------------------------------------------------------------

  // 现在运行主依赖配置，它应该能找到 baseUrl 和 FlutterSecureStorage
  await configureDependencies();

  // 然后为卖家预览环境覆盖特定依赖项（如果需要，现在是注释掉的）
  await configureDependenciesPreview();

  // --- Manually Inject Test Token and User ID for Seller Preview ---
  print('[main_seller_preview] Attempting to inject test credentials...');
  try {
    // Get FlutterSecureStorage instance from GetIt (it should be registered by configureDependencies)
    final storage = getIt<FlutterSecureStorage>();
    // Use the same test token as buyer preview for consistency, unless seller needs a different one
    const testToken = "eyJhbGciOiJIUzUxMiJ9.eyJsb2dpbl91c2VyX2tleSI6IjJhMTlhYzFmLTlmYWItNDZkYS04NTRiLTVhZTc1YWVmNTJlZiJ9.Mk1dtVBPtFhhNpIe681Z3wQxgxXH2ToQul7evMrFpIqYY5qxFPmb_6PholruRsbRtGVZv87Y2h8JOt00IP_rTA"; 
    // Use a different User ID for seller if needed, otherwise can use the same
    const testUserId = "18888888888"; // Example seller ID
    await storage.write(key: 'user_token', value: testToken);
    await storage.write(key: 'user_id', value: testUserId);
    print('[main_seller_preview] Successfully injected test token and seller user ID into secure storage.');
  } catch (e) {
     print('[main_seller_preview] ERROR injecting test credentials: $e');
     // Handle error, maybe don't run app?
  }
  // -------------------------------------------------------------------

  // 设置错误处理 (可选但推荐)
  // Bloc.observer = SimpleBlocObserver(); // 示例 observer

  runApp(const SellerOrdersPreviewApp());
}

class SellerOrdersPreviewApp extends StatelessWidget {
  const SellerOrdersPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 在这里使用 getIt<YourSellerBloc>() 提供卖家 BLoCs
        BlocProvider<SellerOrderListBloc>(
          create: (context) => getIt<SellerOrderListBloc>()..add(const LoadSellerOrdersRequested()), // 触发初始加载
        ),
        // BlocProvider<SellerOrderDetailBloc>(\r
        //   create: (context) => getIt<SellerOrderDetailBloc>(), // 详情 Bloc 可能在页面导航时加载\r
        // ),\r
      ],
      // Change MaterialApp to MaterialApp.router
      child: MaterialApp.router(
        title: 'Seller Orders Preview',
        theme: AppTheme.lightTheme, // 使用你的应用主题
        // darkTheme: AppTheme.darkTheme, // 可选的暗色主题
        // themeMode: ThemeMode.system, // 或强制 light/dark

        // Configure GoRouter
        routeInformationProvider: AppRouter.router.routeInformationProvider,
        routeInformationParser: AppRouter.router.routeInformationParser,
        routerDelegate: AppRouter.router.routerDelegate,

        // NOTE: GoRouter's initialLocation defaults to '/' if not specified in GoRouter constructor.
        // If AppRouter.router sets a different initialLocation, it will be used.
        // If we want this preview to *always* start at /seller/orders, 
        // we might need to adjust the GoRouter instance itself or use a redirect.
        // For now, assuming AppRouter's config is sufficient or defaults correctly.
        // Let's ensure AppRouter is configured with initialLocation: '/seller/orders' for this preview.
        // We will modify AppRouter.dart for this.

        // Remove home property as GoRouter handles the initial route
        // home: const SellerOrderListPage(),
        
        // onGenerateRoute is not used with GoRouter
        // onGenerateRoute: (settings) { ... },
      ),
    );
  }
}

// 示例 SimpleBlocObserver (可选 - 用于调试)
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter/material.dart';

// class SimpleBlocObserver extends BlocObserver {
//   @override
//   void onChange(BlocBase bloc, Change change) {
//     super.onChange(bloc, change);
//     debugPrint('${bloc.runtimeType} $change');
//   }
//
//   @override
//   void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
//     debugPrint('${bloc.runtimeType} $error $stackTrace');
//     super.onError(bloc, error, stackTrace);
//   }
// }
