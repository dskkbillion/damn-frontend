import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

// 假设你的 DI 设置在 injection.dart 或类似文件中
// 必要时调整导入路径
import 'app/di/injection_container.dart';
// 假设你的 AppTheme 在这里定义
// 必要时调整导入路径
import 'core/config/theme/app_theme.dart';

// 导入卖家视图所需的 BLoC 和 Page (占位符 - 稍后调整)
// import 'features/orders/presentation/seller/bloc/seller_order_list_bloc.dart';
// import 'features/orders/presentation/seller/pages/seller_order_list_page.dart';

// 导入 mock repository (或创建一个卖家专属的)
// 必要时调整导入路径
import 'features/orders/data/repositories/mocks/mock_order_repository.dart';
import 'features/orders/domain/repositories/i_order_repository.dart';


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
  // TODO: 增强 MockOrderRepository 或创建一个专用的 MockSellerOrderRepository
  //       以提供真实的卖家端订单数据 (例如 awaitingConfirmation, inProgress)
  //       并模拟卖家操作 (确认、拒绝、交付)。
  // 注意：如果 getIt 已经注册了 IOrderRepository，先 unregister
  if (getIt.isRegistered<IOrderRepository>()) {
    // 使用 getIt.resetLazySingleton 替代 unregister + register
    // 或者确保在主 DI 中 IOrderRepository 是可覆盖的 (例如使用 allowReassignment: true)
    // 为简单起见，这里假设可以安全地重置或主 DI 未注册它
    // Correct usage: resetLazySingleton takes no arguments, the factory is assumed to be the same
    // If the factory changes, you need unregister + register or ensure allowReassignment is true in the main DI
    getIt.resetLazySingleton<IOrderRepository>(); // Corrected: Provide the type argument
    // If you need to provide a NEW factory function, you MUST unregister first:
    // await getIt.unregister<IOrderRepository>();
    // getIt.registerLazySingleton<IOrderRepository>(() => MockOrderRepository());
  } else {
      getIt.registerLazySingleton<IOrderRepository>(() => MockOrderRepository());
  }


  // TODO: 在这里注册卖家特定的 Blocs，注入 mock repository (或 mock UseCases)
  // 示例:
  // getIt.registerFactory(() => SellerOrderListBloc(getOrderListUseCase: getIt())); // 确保 GetOrderListUseCase 适应卖家或有 Seller 版本
  // getIt.registerFactory(() => SellerOrderDetailBloc(
  //       getOrderDetailUseCase: getIt(), // 确保 GetOrderDetailUseCase 适应卖家或有 Seller 版本
  //       confirmOrderUseCase: getIt(), // 确保这些卖家 UseCase 已注册或 mock
  //       rejectOrderUseCase: getIt(),
  //       deliverOrderUseCase: getIt(),
  //       // ... 其他卖家 use cases
  //     ));

  // 确保卖家 Pages/Blocs 需要的所有其他依赖项都已注册 (或 mock)
  // 例如 NavigationService, PaymentService (如果适用)
  // 确保你的核心 DI 设置 (configureDependencies) 已经被调用，或者在这里手动注册必要的 Core 服务
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 如果需要，加载环境变量 (例如使用 flutter_dotenv)
  // await dotenv.load(fileName: ".env");

  // 为卖家预览环境专门配置依赖项
  await configureDependenciesPreview();

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
        // TODO: 在这里使用 getIt<YourSellerBloc>() 提供卖家 BLoCs
        // 示例:
        // BlocProvider<SellerOrderListBloc>(
        //   create: (context) => getIt<SellerOrderListBloc>()..add(LoadSellerOrdersRequested()), // 触发初始加载
        // ),
        // BlocProvider<SellerOrderDetailBloc>(
        //   create: (context) => getIt<SellerOrderDetailBloc>(), // 详情 Bloc 可能在页面导航时加载
        // ),
      ],
      child: MaterialApp(
        title: 'Seller Orders Preview',
        theme: AppTheme.lightTheme, // 使用你的应用主题
        // darkTheme: AppTheme.darkTheme, // 可选的暗色主题
        // themeMode: ThemeMode.system, // 或强制 light/dark
        // TODO: 创建 SellerOrderListPage 后，将其设置为 home
        // home: const SellerOrderListPage(),
        home: Scaffold( // 在 SellerOrderListPage 准备好之前的占位符页面
          backgroundColor: Colors.deepPurple[300], // 使用不同的颜色区分
          appBar: AppBar(title: const Text('Seller Preview')),
          body: const Center(
            child: Text(
              'Seller Orders Preview\n请创建 SellerOrderListPage 并设为 home',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
        // 如果需要在预览内导航，定义路由 (例如到 SellerOrderDetailPage)
        // onGenerateRoute: (settings) {
        //   // 示例:
        //   // if (settings.name == '/seller/orders/detail') {
        //   //   final orderId = settings.arguments as int;
        //   //   return MaterialPageRoute(
        //   //     builder: (_) => BlocProvider.value(
        //   //       value: getIt<SellerOrderDetailBloc>()..add(LoadSellerOrderDetail(orderId)),
        //   //       child: const SellerOrderDetailPage(),
        //   //     ),
        //   //   );
        //   // }
        //   return null; // 对未处理的路由返回 null
        // },
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
