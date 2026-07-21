import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dskk_flutter_refactor/core/network/network_info.dart';
import 'package:dskk_flutter_refactor/core/network/mock_network_info.dart'
    as mock;
import 'package:dskk_flutter_refactor/core/router/smart_router_utils.dart';

// Import authentication related classes
import 'package:dskk_flutter_refactor/features/auth/domain/entities/auth_status.dart';
import 'package:dskk_flutter_refactor/features/auth/domain/repositories/i_auth_repository.dart';

// Import the main shell page which will act as the navigator shell
import 'package:dskk_flutter_refactor/app/widgets/dual_mode_navigation_shell.dart';
// Import the dev menu page
import 'package:dskk_flutter_refactor/app/widgets/dev_menu_page.dart';

// Import feature routes (Merged imports)
import 'package:dskk_flutter_refactor/features/orders/presentation/routes/order_routes.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/platform_intervention_apply_page.dart';
import 'package:dskk_flutter_refactor/features/after_sales/presentation/routes/after_sales_routes.dart';
import 'package:dskk_flutter_refactor/features/ai_docs/presentation/routes/ai_docs_routes.dart';
import 'package:dskk_flutter_refactor/features/auth/presentation/routes/auth_routes.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/routes/profile_routes.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/routes/home_routes.dart';
// Import wallet related classes
import 'package:dskk_flutter_refactor/features/profile/presentation/pages/wallet_page.dart';
import 'package:dskk_flutter_refactor/features/profile/presentation/bloc/wallet_bloc.dart';
import 'package:dskk_flutter_refactor/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/profile/data/repositories/wallet_repository_impl.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/get_wallet_summary.dart';
import 'package:dskk_flutter_refactor/features/profile/domain/usecases/get_wallet_transactions.dart';
import 'package:dskk_flutter_refactor/features/favorites/presentation/routes/favorites_routes.dart';
// Import Chat Module Routes
import 'package:dskk_flutter_refactor/features/chat/presentation/routes/chat_routes.dart';
// Import Seller routes
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';
// Import Payment routes
import 'package:dskk_flutter_refactor/features/payment/presentation/routes/payment_routes.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_routes.dart';
import 'package:dskk_flutter_refactor/features/agent/presentation/agent_login_return.dart';

// Import AppMode
import 'package:dskk_flutter_refactor/app/app_mode.dart';
// Import AppRouterConfig
import 'package:dskk_flutter_refactor/app/navigation/app_router_config.dart';

// Import Shell Pages
// 使用正确的名字和路径
// 卖家 Shell

// --- 引入 Seller 模块相关的 Blocs 和 Pages ---
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_home_page.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/bloc/seller_order_list_bloc.dart'; // Seller Order List Bloc
import 'package:dskk_flutter_refactor/features/orders/presentation/seller/pages/seller_order_list_page.dart'; // Seller Order List Page
import 'package:dskk_flutter_refactor/features/common/presentation/pages/notification_list_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_edit_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_preview_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_management_page.dart'; // 导入商品管理页面
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_bloc.dart'; // 导入商品管理Bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_application_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_status_page.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart'; // Auth Info Entity
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/time_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auto_reply_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/after_sales_detail_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/order_delivery_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_statistics_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/connect_account_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/connect_account/connect_account_event.dart';
import 'package:dskk_flutter_refactor/features/seller/data/datasources/stripe_connect_remote_data_source.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/after_sales_review_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/after_sales_review/after_sales_review_bloc.dart';
import 'package:dskk_flutter_refactor/core/network/core_dio_client.dart';
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

// Import new page
import 'package:dskk_flutter_refactor/features/home/presentation/pages/seller_public_profile_page.dart';

// Import ProductManagementBloc events
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_event.dart';

// Import payment related pages and blocs
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/payment/presentation/pages/order_confirm_page.dart';

// Import mock preview page
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/mock_orders_preview_page.dart';
import 'package:dskk_flutter_refactor/features/orders/presentation/pages/test_order_display.dart';

// Import ProductDetailPage and cubit
import '../../features/home/presentation/pages/product_detail_page.dart';
import '../../features/home/presentation/pages/product_reviews_page.dart';
import '../../features/home/presentation/cubit/product_detail_cubit.dart';

// Import seller statistics related classes
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_upgrade_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_index_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/usecases/get_seller_percent_statistics_usecase.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/repositories/i_seller_statistics_repository.dart';

// Import analytics observers
import 'package:dskk_flutter_refactor/core/analytics/observers/router_analytics_observer.dart';

// Import l10n
import 'package:dskk_flutter_refactor/generated/app_localizations.dart';

// Import home related classes
import 'package:dskk_flutter_refactor/features/home/presentation/bloc/home_bloc.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/pages/home_page.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/pages/search_page.dart';
import 'package:dskk_flutter_refactor/features/home/presentation/pages/search_results_page.dart';

// Import ImageCompressService
import 'package:dskk_flutter_refactor/core/services/image_compress_service.dart';

// Import auth application page and bloc
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/auth_application/auth_application_bloc.dart';

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

/// 全局 root navigator key，供 GlobalMessageNotification / AppToast 等使用
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Provider for the GoRouter instance (from HEAD/auth-module)
final goRouterProvider = Provider<GoRouter>((ref) {
  // 读取是否显示开发tab的配置
  final showDevTab = ref.watch(showDevTabProvider);

  final authRepository = GetIt.instance<IAuthRepository>();
  // Navigation keys for ShellRoutes
  final buyerShellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'buyer_shell');
  final sellerShellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'seller_shell');

  // Helper function to filter routes by path prefix
  List<RouteBase> filterRoutes(List<RouteBase> routes, List<String> paths) {
    return routes.where((route) {
      if (route is GoRoute) {
        return paths.contains(route.path);
      }
      return false; // Keep it simple for now, ignore ShellRoutes within feature routes
    }).toList();
  }

  // Helper function to get routes NOT matching specific paths (for top-level)
  List<RouteBase> filterNonShellRoutes(
      List<RouteBase> allRoutes, List<String> shellPaths) {
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
  ];

  // 获取卖家相关依赖
  final getIt = GetIt.instance;

  // Define Seller Shell Branch Routes explicitly
  final sellerDashboardRoute = GoRoute(
    path: '/seller/dashboard',
    pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: BlocProvider(
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
    ),
  );

  final sellerOrdersRoute = GoRoute(
    path: '/seller/orders',
    pageBuilder: (context, state) {
      // 提取status查询参数
      final statusString = state.uri.queryParameters['status'];
      print('[GoRoute /seller/orders] Received status param: $statusString');

      // 解析status为OrderStatus枚举
      final parsedStatus = OrderStatusExtension.fromString(statusString);

      return state.buildSmartPage(
        BlocProvider(
          create: (_) => GetIt.I<SellerOrderListBloc>()
            ..add(LoadSellerOrdersRequested(statusFilter: parsedStatus)),
          child: SellerOrderListPage(initialStatus: statusString),
        ),
        name: 'sellerOrders',
        source: 'app_navigation_seller_shell',
      );
    },
  );

  // 定义商品管理路由
  final sellerProductsRoute = GoRoute(
    path: '/seller/products',
    pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: BlocProvider(
        create: (_) {
          try {
            // 优先使用GetIt工厂获取ProductManagementBloc
            return GetIt.I<ProductManagementBloc>()
              ..add(const LoadProductList());
          } catch (e) {
            print('[GoRouter] 无法从GetIt获取ProductManagementBloc，创建新实例: $e');
            // 如果从GetIt获取失败，则手动创建
            final sellerRepository = GetIt.I<ISellerRepository>();
            return ProductManagementBloc(
              GetSellerProductListUseCase(sellerRepository),
              GetSellerDraftListUseCase(sellerRepository),
              UpdateProductStatusUseCase(sellerRepository),
              DeleteProductUseCase(sellerRepository),
            )..add(const LoadProductList());
          }
        },
        child: const ProductManagementPage(),
      ),
    ),
  );

  // 直接定义卖家聊天列表路由
  final sellerChatRoute = GoRoute(
    path: '/seller/chat', // 使用聊天路径
    pageBuilder: (context, state) {
      // 使用 BlocProvider.value 避免 dispose 时 close singleton
      final chatListBloc = GetIt.I<ChatListBloc>()..add(LoadChatRoomList());
      return NoTransitionPage(
        key: state.pageKey,
        child: BlocProvider.value(
          value: chatListBloc,
          child: const ChatListPage(),
        ),
      );
    },
    // 卖家模式下的聊天室子路由，复用 ChatRoutes 共享逻辑
    routes: ChatRoutes.chatRoomSubRoutes(namePrefix: 'seller_'),
  );

  // 定义卖家主页路由
  final sellerHomeRoute = GoRoute(
    path: SellerRoutes.home,
    name: 'seller_home',
    pageBuilder: (context, state) => NoTransitionPage(
      key: state.pageKey,
      child: BlocProvider(
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
    ),
  );

  // 定义 Seller Non-Shell Routes (包含完整的卖家路由)
  final sellerNonShellRoutes = <RouteBase>[
    // 添加卖家订单路由到非Shell路由，以便从其他地方（如卖家主页）访问
    sellerOrdersRoute,
    GoRoute(
      path: SellerRoutes.notifications,
      pageBuilder: (context, state) => state.buildSmartPage(
        const NotificationListPage(),
        name: 'sellerNotifications',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.productCreate,
      pageBuilder: (context, state) => state.buildSmartPage(
        const ProductEditPage(),
        name: 'sellerProductCreate',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.productEdit,
      pageBuilder: (context, state) => state.buildSmartPage(
        ProductEditPage(
          productId: state.pathParameters['id'],
          isPreviewMode: state.uri.queryParameters['preview'] == 'true',
        ),
        name: 'sellerProductEdit',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.productPreview,
      pageBuilder: (context, state) => state.buildSmartPage(
        ProductPreviewPage(
          productId: state.pathParameters['id'],
        ),
        name: 'sellerProductPreview',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.authentication,
      pageBuilder: (context, state) => state.buildSmartPage(
        const AuthManagementPage(),
        name: 'sellerAuthentication',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.authenticationApply,
      name: 'sellerAuthenticationApply',
      pageBuilder: (context, state) => state.buildSmartPage(
        BlocProvider(
          create: (context) => GetIt.I<AuthApplicationBloc>(),
          child: AuthApplicationPage(
              type: state.pathParameters['type'] ?? 'other',
              authInfo: state.extra as SellerAuthenticationInfo?),
        ),
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.authenticationDetail,
      name: 'sellerAuthenticationDetail',
      pageBuilder: (context, state) => state.buildSmartPage(
        AuthStatusPage(authInfo: state.extra as SellerAuthenticationInfo),
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.timeManagement,
      pageBuilder: (context, state) => state.buildSmartPage(
        const TimeManagementPage(),
        name: 'sellerTimeManagement',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.autoReply,
      pageBuilder: (context, state) => state.buildSmartPage(
        const AutoReplyPage(),
        name: 'sellerAutoReply',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.storeSettings,
      pageBuilder: (context, state) => state.buildSmartPage(
        Placeholder(
            child: Center(
                child: Text(AppLocalizations.of(context).app_store_settings))),
        name: 'sellerStoreSettings',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    GoRoute(
      path: SellerRoutes.statistics,
      pageBuilder: (context, state) => state.buildSmartPage(
        BlocProvider(
          create: (context) => GetIt.I<SellerStatisticsBloc>(),
          child: const SellerStatisticsPage(),
        ),
        name: 'sellerStatistics',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    // 添加卖家钱包路由 - 修复 seller_wallet 路由问题
    GoRoute(
      path: SellerRoutes.wallet,
      name: 'seller_wallet',
      pageBuilder: (context, state) {
        try {
          // 获取主应用的GetIt实例
          final getIt = GetIt.I;

          // 尝试从GetIt获取主应用的Dio实例
          final dio = getIt<Dio>();

          // 获取主应用的其他必要依赖
          final secureStorage = getIt<FlutterSecureStorage>();

          // 创建网络信息服务
          NetworkInfo networkInfo;
          try {
            networkInfo = getIt<NetworkInfo>();
          } catch (e) {
            print('NetworkInfo not found in GetIt, using mock');
            networkInfo = mock.MockNetworkInfo();
          }

          // 创建远程数据源
          final remoteDataSource = ProfileRemoteDataSourceImpl(
            dio: dio,
            storage: secureStorage,
            imageCompressService: getIt<ImageCompressService>(),
          );

          // 创建钱包仓库
          final walletRepository = WalletRepositoryImpl(
            remoteDataSource: remoteDataSource,
            networkInfo: networkInfo,
          );

          // 创建用例
          final getWalletSummary = GetWalletSummary(walletRepository);
          final getWalletTransactions = GetWalletTransactions(walletRepository);

          // 创建BLoC
          final walletBloc = WalletBloc(
            getWalletSummary: getWalletSummary,
            getWalletTransactions: getWalletTransactions,
            walletRepository: walletRepository,
          );

          return state.buildSmartPage(
            BlocProvider(
              create: (context) => walletBloc,
              child: const WalletPage(),
            ),
            name: 'sellerWallet',
            source: 'app_navigation_seller_non_shell',
          );
        } catch (e) {
          print('Error creating WalletBloc: $e');
          final l10n = AppLocalizations.of(context);
          return state.buildSmartPage(
            Scaffold(
              appBar: AppBar(title: Text(l10n.app_wallet)),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.app_wallet_init_failed),
                    const SizedBox(height: 16),
                    Text('${l10n.app_error_label}: $e',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.app_go_back),
                    ),
                  ],
                ),
              ),
            ),
            name: 'sellerWalletError',
            source: 'app_navigation_seller_non_shell',
          );
        }
      },
    ),
    // 卖家收款账户绑定路由
    GoRoute(
      path: SellerRoutes.connectAccount,
      name: 'seller_connect_account',
      pageBuilder: (context, state) {
        try {
          final getIt = GetIt.I;
          final dio = getIt<CoreDioClient>().dio;
          final dataSource = StripeConnectRemoteDataSourceImpl(dio);
          final bloc = ConnectAccountBloc(dataSource: dataSource)
            ..add(CheckConnectAccountStatus());

          return state.buildSmartPage(
            BlocProvider(
              create: (_) => bloc,
              child: const ConnectAccountPage(),
            ),
            name: 'sellerConnectAccount',
            source: 'app_navigation_seller_non_shell',
          );
        } catch (e) {
          return state.buildSmartPage(
            Scaffold(
              appBar: AppBar(title: const Text('收款账户')),
              body: Center(child: Text('初始化失败: $e')),
            ),
            name: 'sellerConnectAccountError',
            source: 'app_navigation_seller_non_shell',
          );
        }
      },
    ),
    GoRoute(
      path: 'orders/:id/delivery',
      pageBuilder: (context, state) => state.buildSmartPage(
        OrderDeliveryPage(
            orderId: int.parse(state.pathParameters['id'] ?? '0')),
        name: 'sellerOrderDelivery',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    // 售后审核列表路由
    GoRoute(
      path: SellerRoutes.afterSalesReview,
      name: 'sellerAfterSalesReview',
      pageBuilder: (context, state) => state.buildSmartPage(
        BlocProvider(
          create: (_) => GetIt.I<AfterSalesReviewBloc>(),
          child: const AfterSalesReviewPage(),
        ),
        name: 'sellerAfterSalesReview',
        source: 'app_navigation_seller_non_shell',
      ),
    ),
    // 确保所有非 Shell 路由都在这里或者在其父路由的 sub-routes 中
  ];

  // 买家通知页面路由
  final buyerNotificationRoute = GoRoute(
    path: '/notifications',
    name: 'buyerNotifications',
    pageBuilder: (context, state) => state.buildSmartPage(
      const NotificationListPage(), // 复用卖家的通知页面
      name: 'buyerNotifications',
      source: 'app_navigation_buyer_non_shell',
    ),
  );

  // Define Buyer Order Detail Route
  final buyerOrderDetailRoute = OrderRoutes.routes
      .firstWhere((r) => r is GoRoute && r.path == '/orderDetail/:orderId');

  // Define Seller Order Detail Route
  final sellerOrderDetailRoute = OrderRoutes.routes
      .firstWhere((r) => r is GoRoute && r.path == '/seller/orders/:orderId');

  // Define Evaluation Route
  final evaluationRoute = OrderRoutes.routes
      .firstWhere((r) => r is GoRoute && r.path == '/evaluation/:orderId');

  // Create the GoRouter instance
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/ai_chat', // AI 助手为默认首页
    // Route URIs can contain short-lived Agent codes. GoRouter diagnostics
    // print the full URI, so keep them disabled in every build flavor.
    debugLogDiagnostics: false,
    refreshListenable: GoRouterRefreshStream(authRepository.authStatus),
    observers: [
      RouterAnalyticsObserver(), // Add analytics observer
    ],

    routes: [
      // --- 统一的 Shell Route，包含买家和卖家所有分支 ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // 使用双模式导航 Shell，保持页面状态
          return DualModeNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // === 买家模式分支 ===
          // Branch 0: AI Chat (Path: /ai_chat)
          StatefulShellBranch(
            routes: AiDocsRoutes.routes,
          ),
          // Branch 1: 主页 (Path: /home)
          StatefulShellBranch(
            routes: [
              // 买家主页路由 - 使用最简单的页面创建方式
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: BlocProvider<HomeBloc>(
                    create: (_) => getIt<HomeBloc>(),
                    child: const HomePage(),
                  ),
                ),
                routes: [
                  // 搜索路由
                  GoRoute(
                    path: 'search',
                    name: 'search',
                    pageBuilder: (context, state) => state.buildSmartPage(
                      const SearchPage(),
                      name: 'search',
                      source: 'buyer_shell_home',
                    ),
                  ),

                  // 搜索结果路由
                  GoRoute(
                    path: 'search-results',
                    name: 'searchResults',
                    pageBuilder: (context, state) {
                      final keyword =
                          state.uri.queryParameters['keyword'] ?? '';
                      return state.buildSmartPage(
                        SearchResultsPage(keyword: keyword),
                        name: 'searchResults',
                        source: 'buyer_shell_home',
                      );
                    },
                  ),
                ],
              ),
            ],
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
          if (showDevTab)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dev_menu',
                  pageBuilder: (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const DevMenuPage(),
                  ),
                ),
              ],
            ),

          // === 卖家模式分支 ===
          // Branch 5 (或4): 卖家数据
          StatefulShellBranch(
            routes: [sellerDashboardRoute],
          ),
          // Branch 6 (或5): 商品管理
          StatefulShellBranch(
            routes: [sellerProductsRoute],
          ),
          // Branch 7 (或6): 卖家消息
          StatefulShellBranch(
            routes: [sellerChatRoute],
          ),
          // Branch 8 (或7): 卖家我的
          StatefulShellBranch(
            routes: [sellerHomeRoute],
          ),
        ],
      ),

      // --- Top-level routes (No Shell) ---
      ...AuthRoutes.routes, // Login etc.
      buyerOrderDetailRoute,
      sellerOrderDetailRoute, // 添加卖家订单详情路由
      evaluationRoute, // 添加评价路由
      buyerNotificationRoute, // 添加买家通知页面路由
      ...AfterSalesRoutes.routes,
      ...FavoritesRoutes.routes,
      ...sellerNonShellRoutes,
      ...PaymentRoutes.routes, // 添加支付模块路由
      ...AgentRoutes.routes,

      // Platform Intervention Route
      GoRoute(
        path: '/platform-intervention/:orderId',
        name: 'platformIntervention',
        pageBuilder: (context, state) {
          final orderId = state.pathParameters['orderId'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          final orderSn = extra?['orderSn'];

          return state.buildSmartPage(
            PlatformInterventionApplyPage(
              orderId: orderId,
              orderSn: orderSn,
            ),
            name: 'platformIntervention',
            source: 'app_navigation_orders',
          );
        },
      ),

      // Seller After-Sales Detail Route - with String ID fix
      GoRoute(
        path: '/seller/after-sales/:id',
        name: 'sellerAfterSalesDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';

          return state.buildSmartPage(
            AfterSalesDetailPage(id: id),
            name: 'sellerAfterSalesDetail',
            source: 'app_navigation_seller',
          );
        },
      ),

      // Mock预览路由 - 用于测试各种订单状态
      GoRoute(
        path: '/mock/orders',
        name: 'mockOrdersPreview',
        pageBuilder: (context, state) => state.buildSmartPage(
          const MockOrdersPreviewPage(),
          name: 'mockOrdersPreview',
          source: 'app_navigation_mock',
        ),
      ),

      // 测试订单显示路由
      GoRoute(
        path: '/test/order/:orderId',
        name: 'testOrderDisplay',
        pageBuilder: (context, state) {
          final orderId = int.parse(state.pathParameters['orderId'] ?? '1001');
          return state.buildSmartPage(
            TestOrderDisplayPage(orderId: orderId),
            name: 'testOrderDisplay',
            source: 'app_navigation_test',
          );
        },
      ),

      // 添加卖家主页路由 - 使用最简单的页面创建方式
      GoRoute(
        path: '/seller-profile/:id',
        name: 'sellerPublicProfile',
        pageBuilder: (context, state) {
          final sellerId = int.parse(state.pathParameters['id'] ?? '0');
          return state.buildSmartPage(
            SellerPublicProfilePage(sellerId: sellerId),
            name: 'sellerPublicProfile',
            source: 'app_navigation_public_profile',
          );
        },
      ),

      // 产品详情路由 - 顶层路由，不属于任何 Shell
      // 避免从卖家/聊天等模块跳转后返回键跳错到买家首页 (#297)
      GoRoute(
        path: '/product/:productId',
        name: 'productDetail',
        pageBuilder: (context, state) {
          final productId = state.pathParameters['productId'] ?? '';
          return state.buildSmartPage(
            BlocProvider(
              create: (context) => getIt<ProductDetailCubit>(),
              child: ProductDetailPage(productId: productId),
            ),
            name: 'productDetail',
            source: 'app_navigation_product_detail',
          );
        },
        routes: [
          // 产品评论子路由
          GoRoute(
            path: 'reviews',
            name: 'productReviews',
            pageBuilder: (context, state) {
              final productId = state.pathParameters['productId'] ?? '';
              final productIdInt = int.tryParse(productId) ?? 0;
              return state.buildSmartPage(
                ProductReviewsPage(productId: productIdInt),
                name: 'productReviews',
                source: 'app_navigation_product_reviews',
              );
            },
          ),
        ],
      ),

      // 支付专用路由 - 使用智能路由系统
      GoRoute(
        path: '/product-payment/:id/confirm',
        name: 'productPaymentConfirm',
        pageBuilder: (context, state) {
          final productId = int.parse(state.pathParameters['id'] ?? '0');
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};

          print(
              '[Router] productPaymentConfirm - productId: $productId, extra: $extra');

          return state.buildSmartPage(
            Builder(
              builder: (context) {
                print('[Router] Building OrderConfirmPage widget');
                return BlocProvider(
                  create: (_) {
                    print('[Router] Creating PaymentBloc instance');
                    try {
                      final bloc = getIt<PaymentBloc>();
                      print('[Router] PaymentBloc created successfully');
                      return bloc;
                    } catch (e) {
                      print('[Router] Error creating PaymentBloc: $e');
                      rethrow;
                    }
                  },
                  child: OrderConfirmPage(
                    productId: productId,
                    variantId: extra['variantId'] ?? 0,
                    quantity: extra['quantity'] ?? 1,
                    sellerId: extra['sellerId'] ?? 0,
                    price: extra['price'] ?? 0.0,
                    productName: extra['productName'] ?? '',
                    imageUrl: extra['imageUrl'],
                  ),
                );
              },
            ),
            name: 'productPaymentConfirm',
            source: 'app_navigation_payment',
          );
        },
      ),
    ],

    // errorBuilder from HEAD/auth-module
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.app_page_not_found)),
        body: Center(
            child: Text(
                '${l10n.app_path_error}: ${state.uri}\n${l10n.app_error_generic}: ${state.error}')),
      );
    },

    // redirect logic from HEAD/auth-module
    redirect: (context, state) {
      final loginStatus = authRepository.getLoggedInUserSync().fold(
            (failure) => const Unauthenticated(),
            (user) =>
                user != null ? Authenticated(user) : const Unauthenticated(),
          );
      final isLoggingIn = state.matchedLocation == AuthRoutes.loginPath;
      final isUnknown = loginStatus is AuthUnknown;
      final currentMode = ref.read(appModeProvider); // Use read for redirect

      // `loginStatus.toString()` includes the authenticated user object and
      // therefore its bearer token. Keep route diagnostics credential-free.
      print(
          'Redirect Check: Location: ${state.matchedLocation}, Login: ${loginStatus.runtimeType}, Mode: $currentMode, Logging In: $isLoggingIn');

      if (isUnknown) return null;

      if (loginStatus is Unauthenticated && !isLoggingIn) {
        print('Redirect: Not logged in -> ${AuthRoutes.loginPath}');
        if (AgentLoginReturn.captureMatchedRoute(
          matchedLocation: state.matchedLocation,
          sourceUri: state.uri,
        )) {
          // Keep Agent codes out of the login URL, analytics, and route logs.
          return '${AuthRoutes.loginPath}?intent=agent';
        }
        final from = Uri.encodeComponent(state.uri.toString());
        return '${AuthRoutes.loginPath}?from=$from';
      }
      if (loginStatus is Authenticated && isLoggingIn) {
        if (state.uri.queryParameters['intent'] == 'agent' &&
            AgentLoginReturn.hasPending()) {
          // SmsLoginSuccess is the single owner that consumes this state. This
          // avoids racing the auth stream before credential persistence returns.
          return null;
        }
        final from = state.uri.queryParameters['from'];
        if (from != null && from.startsWith('/') && !from.startsWith('//')) {
          print('Redirect: Logged in -> returning to previous app route');
          return from;
        }
        print(
            'Redirect: Logged in but on login page -> ${HomeRoutes.homePath}');
        return HomeRoutes.homePath;
      }

      final location = state.matchedLocation;
      // Account security and Agent sessions belong to the signed-in account,
      // not to the buyer/seller operating mode. Keep these pages reachable
      // while the user is in seller mode as well.
      final isAccountLevelLocation =
          location == ProfileRoutes.accountSecurityPath ||
              location == ProfileRoutes.connectedAgentsPath ||
              location == ProfileRoutes.agentRequestsPath ||
              location == '/agent/connect';
      final List<String> buyerPaths = [
        HomeRoutes.homePath,
        '/ai_chat',
        '/chat',
        '/profile',
        '/dev_menu',
        '/notifications', // 添加买家通知路径
        '/product-payment', // 添加支付路径
        '/payment/result' // 添加支付结果路径
      ];
      // 更新卖家 Shell 路径列表
      final List<String> sellerPaths = [
        '/seller/dashboard',
        '/seller/orders',
        '/seller/chat',
        SellerRoutes.home,
        SellerRoutes.statistics, // 添加新的统计路由路径
        SellerRoutes.notifications, // 添加通知路径
        SellerRoutes.wallet, // 添加钱包路径
        SellerRoutes.timeManagement, // 添加时间管理路径
        SellerRoutes.authentication, // 添加认证路径
        SellerRoutes.autoReply, // 添加自动回复路径
      ];

      // 特殊情况：卖家主页路径（公共路径，不应受模式限制）
      const String sellerPublicProfilePathPrefix = '/seller-profile/'; // 更新路径前缀

      bool isBuyerShellLocation =
          buyerPaths.any((p) => location.startsWith(p)) &&
              !isAccountLevelLocation;
      // 排除卖家主页路径（检查是否匹配 /seller-profile/{id} 模式）
      // 允许 buyer 模式访问收款账户绑定页面（提现时需要）
      bool isSellerShellLocation =
          sellerPaths.any((p) => location.startsWith(p)) &&
              !location.startsWith(sellerPublicProfilePathPrefix) &&
              !location.startsWith(SellerRoutes.connectAccount);

      if (currentMode == AppMode.buyer && isSellerShellLocation) {
        print(
            'Redirect: In Buyer Mode, tried to access Seller Shell ($location) -> ${HomeRoutes.homePath}');
        return HomeRoutes.homePath;
      }
      if (currentMode == AppMode.seller && isBuyerShellLocation) {
        print(
            'Redirect: In Seller Mode, tried to access Buyer Shell ($location) -> ${SellerRoutes.home}');
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
