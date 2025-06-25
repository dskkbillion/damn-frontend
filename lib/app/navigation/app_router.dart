import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/network/mock_network_info.dart' as mock;
import 'package:shared_preferences/shared_preferences.dart';

// Import authentication related classes
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

// Import the main shell page which will act as the navigator shell
import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart';
// Import the dev menu page
import 'package:dskk_flutter_refactor/app/widgets/dev_menu_page.dart';

// Import feature routes (Merged imports)
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart';
import 'package:dskk_flutter_refactor/features/after_sales/presentation/routes/after_sales_routes.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/routes/ai_docs_routes.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/routes/auth_routes.dart'; 
import 'package:dskk_flutter_refactor/features/profile/presentation/routes/profile_routes.dart'; 
import 'package:dskk_flutter_refactor/features/home/presentation/routes/home_routes.dart';
import 'package:dskk_flutter_refactor/features/favorites/presentation/routes/favorites_routes.dart';
// Import Chat Module Routes
import 'package:dskk_flutter_refactor/features/chat/presentation/routes/chat_routes.dart';
// Import Seller routes
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
// Import Payment routes
import 'package:dskk_flutter_refactor/features/payment/presentation/routes/payment_routes.dart';

// Import AppMode
import 'package:dskk_flutter_refactor/app/app_mode.dart';
// Import AppRouterConfig
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';

// Import Shell Pages
import 'package:dskk_flutter_refactor/app/widgets/main_shell_page.dart'; // 使用正确的名字和路径
import 'package:dskk_flutter_refactor/features/seller/presentation/widgets/seller_shell_page.dart'; // 卖家 Shell

// --- 引入 Seller 模块相关的 Blocs 和 Pages --- 
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_home_page.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/bloc/seller_order_list_bloc.dart'; // Seller Order List Bloc
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/pages/seller_order_list_page.dart'; // Seller Order List Page
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/notification_list_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_edit_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_management_page.dart'; // 导入商品管理页面
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_bloc.dart'; // 导入商品管理Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_application_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_status_page.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart'; // Auth Info Entity
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/time_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auto_reply_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/order_delivery_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_statistics_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_bloc.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/pages/chat_list_page.dart';
import 'package:dskk_flutter_refactor/features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';

// 导入卖家模块相关依赖
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_dashboard_data_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_store_profile_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_product_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_draft_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/update_product_status_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/delete_product_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_repository.dart';

// Import necessary classes
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/notification_list/notification_list_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_notification_list_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_unread_notification_count_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/data/repositories/seller_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_remote_data_source_impl.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/seller_local_data_source_impl.dart';

// Import new page
import 'package:dskk_flutter_refactor/features/home/presentation/pages/seller_public_profile_page.dart';

// Import ProductManagementBloc events
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_event.dart';

// Import payment related pages and blocs
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/payment/presentation/pages/order_confirm_page.dart';
import '../../features/payment/presentation/pages/payment_result_page.dart';

// Import ProductDetailPage and cubit
import '../../features/home/presentation/pages/product_detail_page.dart';
import '../../features/home/presentation/cubit/product_detail_cubit.dart';

// Import seller statistics related classes
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_upgrade_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_index_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_percent_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_statistics_repository.dart';

// Import analytics observers
import 'package:dskk_flutter_refactor/core/analytics/observers/router_analytics_observer.dart';

// Placeholder page (defined once) - Only used if a module's routes aren't ready
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar if you want titles per section
      // appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

// Provider for the GoRouter instance (from HEAD/auth-module)
final goRouterProvider = Provider<GoRouter>((ref) {  
  // 读取是否显示开发tab的配置  
  final showDevTab = ref.watch(showDevTabProvider);    
  
  final authRepository = GetIt.instance<IAuthRepository>();  
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');  
  // Navigation keys for ShellRoutes  
  final buyerShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'buyer_shell');  
  final sellerShellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'seller_shell');

  // Helper function to filter routes by path prefix
  List<RouteBase> _filterRoutes(List<RouteBase> routes, List<String> paths) {
      return routes.where((route) {
          if (route is GoRoute) {
              return paths.contains(route.path);
          }
          return false; // Keep it simple for now, ignore ShellRoutes within feature routes
      }).toList();
  }

  // Helper function to get routes NOT matching specific paths (for top-level)
  List<RouteBase> _filterNonShellRoutes(List<RouteBase> allRoutes, List<String> shellPaths) {
     List<RouteBase> nonShell = [];
     for (var route in allRoutes) {
        if (route is GoRoute && !shellPaths.contains(route.path)) {
            // If it's a GoRoute and not a shell path, add it.
            // We might need a more sophisticated way to handle nested routes if needed.
            nonShell.add(route);
        }
        // Potentially handle nested routes if they can be non-shell
     }
     return nonShell;
  }

  // Define paths for Seller Shell
  const sellerShellPaths = [
      SellerRoutes.home, 
      SellerRoutes.products, // Or maybe just /seller/orders ? Check SellerNav Bar
      '/seller/chat', // Placeholder
      '/seller/profile' // Placeholder
  ];

  // 获取卖家相关依赖，用于手动创建BLoC
  final getIt = GetIt.instance;
  final sellerRepository = getIt<ISellerRepository>();

  final productManagementBloc = ProductManagementBloc(
    GetSellerProductListUseCase(sellerRepository),
    GetSellerDraftListUseCase(sellerRepository),
    UpdateProductStatusUseCase(sellerRepository),
    DeleteProductUseCase(sellerRepository),
  );

  // Define Seller Shell Branch Routes explicitly
  final sellerDashboardRoute = GoRoute(
    path: '/seller/dashboard', 
    builder: (context, state) => BlocProvider(
      create: (context) {
        try {
          // 尝试从GetIt获取
          return GetIt.I<SellerStatisticsBloc>();
        } catch (e) {
          print('[GoRouter] 无法从GetIt获取SellerStatisticsBloc，创建新实例: $e');
          // 如果从GetIt获取失败，则手动创建
          try {
            // 尝试获取仓库和usecase
            final repo = GetIt.I<ISellerStatisticsRepository>();
            final upgradeUseCase = GetSellerUpgradeStatisticsUseCase(repo);
            final indexUseCase = GetSellerIndexStatisticsUseCase(repo);
            final percentUseCase = GetSellerPercentStatisticsUseCase(repo);
            
            return SellerStatisticsBloc(
              upgradeUseCase,
              indexUseCase,
              percentUseCase,
            );
          } catch (e2) {
            print('[GoRouter] 无法创建SellerStatisticsBloc的依赖: $e2');
            // 回退使用GetIt获取
            return GetIt.I<SellerStatisticsBloc>();
          }
        }
      },
      child: const SellerStatisticsPage(),
    ),
  );
  
  final sellerOrdersRoute = GoRoute(
      path: '/seller/orders', 
      builder: (context, state) {
        // 提取status查询参数
        final statusString = state.uri.queryParameters['status'];
        print('[GoRoute /seller/orders] Received status param: $statusString');
        
        // 解析status为OrderStatus枚举
        final parsedStatus = OrderStatusExtension.fromString(statusString);
        
        return BlocProvider(
          create: (_) => GetIt.I<SellerOrderListBloc>()
            ..add(LoadSellerOrdersRequested(statusFilter: parsedStatus)),
          child: SellerOrderListPage(initialStatus: statusString),
        );
      },
  );
  
  // 定义商品管理路由
  final sellerProductsRoute = GoRoute(
    path: '/seller/products',
    builder: (context, state) => BlocProvider(
      create: (_) => productManagementBloc..add(LoadProductList()),
      child: const ProductManagementPage(),
    ),
  );
  
  // 直接定义卖家聊天列表路由
  final sellerChatRoute = GoRoute(
      path: '/seller/chat', // 使用聊天路径
      builder: (context, state) => BlocProvider(
        create: (_) => GetIt.I<ChatListBloc>()..add(LoadChatRoomList()), // 使用ChatListBloc
        child: const ChatListPage(), // 使用ChatListPage
      ), 
  );
  
  // 定义卖家主页路由
  final sellerHomeRoute = GoRoute(
    path: SellerRoutes.home,
    name: 'seller_home',
    builder: (context, state) => BlocProvider(
      create: (context) {
        try {
          // 使用GetIt工厂获取SellerHomeBloc，而不是使用手动创建的实例
          return GetIt.I<SellerHomeBloc>();
        } catch (e) {
          print('[GoRouter] 无法从GetIt获取SellerHomeBloc: $e');
          // 仅在获取失败时备用的手动创建方法
          final repo = GetIt.I<ISellerRepository>();
          return SellerHomeBloc(
            GetSellerDashboardDataUseCase(repo),
            GetStoreProfileUseCase(repo),
          );
        }
      },
      child: const SellerHomePage(),
    ),
  );
  
  // 定义 Seller Non-Shell Routes (保持不变或根据需要调整)
  final sellerNonShellRoutes = <RouteBase>[
      // 添加卖家订单路由到非Shell路由，以便从其他地方（如卖家主页）访问
      sellerOrdersRoute,
      GoRoute(
        path: SellerRoutes.notifications, 
        builder: (context, state) => const NotificationListPage(),
      ),
      GoRoute(path: SellerRoutes.productCreate, builder: (context, state) => const ProductEditPage()),
      GoRoute(path: SellerRoutes.productEdit, builder: (context, state) => ProductEditPage(productId: state.pathParameters['id'])), 
      GoRoute(path: SellerRoutes.authentication, builder: (context, state) => AuthManagementPage()), 
      GoRoute(path: SellerRoutes.authenticationApply, builder: (context, state) => AuthApplicationPage(type: state.pathParameters['type'] ?? 'other', authInfo: state.extra as SellerAuthenticationInfo?)), 
      GoRoute(path: SellerRoutes.authenticationDetail, builder: (context, state) => AuthStatusPage(authInfo: state.extra as SellerAuthenticationInfo)), 
      GoRoute(path: SellerRoutes.timeManagement, builder: (context, state) => const TimeManagementPage()), 
      GoRoute(path: SellerRoutes.autoReply, builder: (context, state) => const AutoReplyPage()), 
      GoRoute(path: SellerRoutes.storeSettings, builder: (context, state) => const Placeholder(child: Center(child: Text('店铺设置')))), 
      GoRoute(path: 'orders/:id/delivery', builder: (context, state) => OrderDeliveryPage(orderId: int.parse(state.pathParameters['id'] ?? '0'))), 
      // 确保所有非 Shell 路由都在这里或者在其父路由的 sub-routes 中
      // 例如，'/seller/products' 本身可能不需要在这里，因为它可以通过 '/seller' 访问
  ];

  // 买家通知页面路由
  final buyerNotificationRoute = GoRoute(
    path: '/notifications',
    name: 'buyerNotifications',
    builder: (context, state) => const NotificationListPage(), // 复用卖家的通知页面
  );

  // Define Buyer Order Detail Route
  final buyerOrderDetailRoute = OrderRoutes.routes.firstWhere((r) => r is GoRoute && r.path == '/orderDetail/:orderId'); 
  
  // Define Seller Order Detail Route
  final sellerOrderDetailRoute = OrderRoutes.routes.firstWhere((r) => r is GoRoute && r.path == '/seller/orders/:orderId');
  
  // Create the GoRouter instance
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home', // Initial location
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authRepository.authStatus),
    observers: [
      RouterAnalyticsObserver(), // Add analytics observer
    ],

    routes: [
      // --- Buyer Shell Route --- 
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // 使用 MainShellPage 作为买家 Shell
          return MainShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: AI Chat (Path: /ai_chat)
          StatefulShellBranch(
             routes: AiDocsRoutes.routes, 
          ),
          // Branch 1: 主页 (Path: /home)
          StatefulShellBranch(
             routes: HomeRoutes.routes, 
          ),
          // Branch 2: 消息 (Path: /chat)
          StatefulShellBranch(
            routes: ChatRoutes.routes,
          ),
          // Branch 3: 我的 (Path: /profile)
          StatefulShellBranch(
            routes: ProfileRoutes.routes, 
          ),
          // Branch 4: 开发 (Path: /dev_menu) - 根据配置决定是否显示
          if (showDevTab) StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dev_menu',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DevMenuPage(),
                ),
              ),
            ],
          ),
        ],
      ),

      // --- Seller Shell Route (using explicitly defined routes) --- 
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SellerShellPage(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: 卖家数据
          StatefulShellBranch(
            routes: [ sellerDashboardRoute ], 
          ),
          // Branch 1: 商品管理（修复：原来错误地使用了订单路由）
          StatefulShellBranch(
             routes: [ sellerProductsRoute ], 
          ),
          // Branch 2: 卖家消息 (聊天)
          StatefulShellBranch(
            routes: [ sellerChatRoute ], // 使用聊天路由而不是通知路由
          ),
          // Branch 3: 卖家我的
          StatefulShellBranch(
            routes: [ sellerHomeRoute ], // 使用手动创建的路由替代从SellerRoutes.routes获取的路由
          ),
        ],
      ),

      // --- Top-level routes (No Shell) ---
      ...AuthRoutes.routes, // Login etc.
      buyerOrderDetailRoute, 
      sellerOrderDetailRoute,  // 添加卖家订单详情路由
      buyerNotificationRoute, // 添加买家通知页面路由
      ...AfterSalesRoutes.routes,
      ...FavoritesRoutes.routes, 
      ...sellerNonShellRoutes, 
      ...PaymentRoutes.routes, // 添加支付模块路由

      // 添加卖家主页路由
      GoRoute(
        path: '/seller/:id/profile',
        builder: (context, state) => SellerPublicProfilePage(
          sellerId: int.parse(state.pathParameters['id'] ?? '0'),
        ),
      ),

      // 商品详情路由
      GoRoute(
        path: '/products/:id',
        builder: (context, state) => BlocProvider(
          create: (context) => GetIt.I<ProductDetailCubit>(),
          child: ProductDetailPage(productId: state.pathParameters['id']!),
        ),
      ),

    ],

    // errorBuilder from HEAD/auth-module
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: Center(child: Text('路径错误: ${state.uri}\n错误: ${state.error}')),
    ),

    // redirect logic from HEAD/auth-module
    redirect: (context, state) {
      final loginStatus = authRepository.getLoggedInUserSync().fold(
        (failure) => const Unauthenticated(),
        (user) => user != null ? Authenticated(user) : const Unauthenticated(),
      );
      final isLoggingIn = state.matchedLocation == AuthRoutes.loginPath;
      final isUnknown = loginStatus is AuthUnknown;
      final currentMode = ref.read(appModeProvider); // Use read for redirect

      print('Redirect Check: Location: ${state.matchedLocation}, Login: $loginStatus, Mode: $currentMode, Logging In: $isLoggingIn');

      if (isUnknown) return null;

      if (loginStatus is Unauthenticated && !isLoggingIn) {
        print('Redirect: Not logged in -> ${AuthRoutes.loginPath}');
        return AuthRoutes.loginPath;
      }
      if (loginStatus is Authenticated && isLoggingIn) {
         print('Redirect: Logged in but on login page -> ${HomeRoutes.homePath}');
         return HomeRoutes.homePath; 
      }

      final location = state.matchedLocation;
      final List<String> buyerPaths = [
          HomeRoutes.homePath, 
          '/ai_chat', 
          '/chat', 
          '/profile', 
          '/dev_menu',
          '/notifications' // 添加买家通知路径
      ]; 
      // 更新卖家 Shell 路径列表
      final List<String> sellerPaths = [
          '/seller/dashboard', 
          '/seller/orders', 
          '/seller/chat',
          SellerRoutes.home, 
          SellerRoutes.statistics,  // 添加新的统计路由路径
          SellerRoutes.notifications,  // 添加通知路径
      ]; 
      
      // 特殊情况：卖家主页路径（公共路径，不应受模式限制）
      final String sellerPublicProfilePathPrefix = '/seller/';
      final String sellerPublicProfilePathSuffix = '/profile';
      
      bool isBuyerShellLocation = buyerPaths.any((p) => location.startsWith(p));
      // 排除卖家主页路径（检查是否匹配 /seller/{id}/profile 模式）
      bool isSellerShellLocation = sellerPaths.any((p) => location.startsWith(p)) && 
          !(location.startsWith(sellerPublicProfilePathPrefix) && location.endsWith(sellerPublicProfilePathSuffix) && 
             location.split('/').length == 4); // 确保路径格式为 /seller/{id}/profile
      
      if (currentMode == AppMode.buyer && isSellerShellLocation) {
        print('Redirect: In Buyer Mode, tried to access Seller Shell ($location) -> ${HomeRoutes.homePath}');
        return HomeRoutes.homePath; 
      }
      if (currentMode == AppMode.seller && isBuyerShellLocation) {
         print('Redirect: In Seller Mode, tried to access Buyer Shell ($location) -> ${SellerRoutes.home}');
         return SellerRoutes.home; // Redirect to seller "My" tab content
      }

      print('Redirect: No redirect needed.');
      return null; 
    },
  );

  // Removed GoRouter registration to GetIt

  return router;
}); 

// GoRouterRefreshStream helper class (from HEAD/auth-module)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
} 