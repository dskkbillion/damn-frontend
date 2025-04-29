import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart'; // <--- 添加 BlocProvider 的 import
// import 'package:flutter_bloc/flutter_bloc.dart'; // Seems unused now

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
// Import Seller routes
import 'package:dskk_flutter_refactor/features/seller/presentation/routes/seller_routes.dart';

// Import AppMode
import 'package:dskk_flutter_refactor/app/app_mode.dart';

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
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_application_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_status_page.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart'; // Auth Info Entity
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/time_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auto_reply_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/order_delivery_page.dart';
// -----------------------------------------------

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

  // Define Seller Shell Branch Routes explicitly
  final sellerDashboardRoute = GoRoute(path: '/seller/dashboard', builder: (context, state) => const PlaceholderPage(title: '卖家数据'));
  final sellerOrdersRoute = GoRoute(
      path: '/seller/orders', 
      builder: (context, state) => BlocProvider(
        create: (_) => GetIt.I<SellerOrderListBloc>(), // <--- 确保 SellerOrderListBloc 被注册
        child: const SellerOrderListPage(),
      ),
  );
  final sellerNotificationsRoute = GoRoute(
      path: SellerRoutes.notifications, 
      builder: (context, state) => const NotificationListPage(),
  );
  final sellerMyRoute = GoRoute(
      path: SellerRoutes.home, 
      builder: (context, state) => BlocProvider(
        create: (context) => GetIt.I<SellerHomeBloc>(), // <--- 确保 SellerHomeBloc 被注册
        child: const SellerHomePage(),
      ),
  );
  
  // Define Seller Non-Shell Routes 
  final sellerNonShellRoutes = <RouteBase>[
      GoRoute(path: SellerRoutes.productCreate, builder: (context, state) => const ProductEditPage()), // TODO: Add BlocProvider if needed
      GoRoute(path: SellerRoutes.productEdit, builder: (context, state) => ProductEditPage(productId: state.pathParameters['id'])), // TODO: Add BlocProvider if needed
      GoRoute(path: SellerRoutes.authentication, builder: (context, state) => AuthManagementPage()), // Assuming Page handles Bloc
      GoRoute(path: SellerRoutes.authenticationApply, builder: (context, state) => AuthApplicationPage(type: state.pathParameters['type'] ?? 'other', authInfo: state.extra as SellerAuthenticationInfo?)), // TODO: Add BlocProvider if needed
      GoRoute(path: SellerRoutes.authenticationDetail, builder: (context, state) => AuthStatusPage(authInfo: state.extra as SellerAuthenticationInfo)), // TODO: Add BlocProvider if needed
      GoRoute(path: SellerRoutes.timeManagement, builder: (context, state) => const TimeManagementPage()), // Assuming Page handles Bloc
      GoRoute(path: SellerRoutes.autoReply, builder: (context, state) => const AutoReplyPage()), // Assuming Page handles Bloc
      GoRoute(path: SellerRoutes.storeSettings, builder: (context, state) => const Placeholder(child: Center(child: Text('店铺设置')))), 
      GoRoute(path: 'orders/:id/delivery', builder: (context, state) => OrderDeliveryPage(orderId: int.parse(state.pathParameters['id'] ?? '0'))), // TODO: Add BlocProvider if needed
      // Add other non-shell routes from SellerRoutes.routes here
      // Example for after-sales detail:
      // GoRoute(path: SellerRoutes.afterSalesDetail, builder: (context, state) => AfterSalesDetailPage(id: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0)),
  ];

  // Define Buyer Order Detail Route
  final buyerOrderDetailRoute = OrderRoutes.routes.firstWhere((r) => r is GoRoute && r.path == '/orderDetail/:orderId'); // Keep this one for now

  // Create the GoRouter instance
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home', // Initial location
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authRepository.authStatus),

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
            routes: [
              GoRoute(
                path: '/chat',
                pageBuilder: (context, state) => const NoTransitionPage(
                  // TODO: Replace with actual Chat page if available
                  child: PlaceholderPage(title: '消息'),
                ),
              ),
            ],
          ),
          // Branch 3: 我的 (Path: /profile)
          StatefulShellBranch(
            routes: ProfileRoutes.routes, 
          ),
          // Branch 4: 开发 (Path: /dev_menu)
          StatefulShellBranch(
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
          // Branch 0: 卖家数据 (Path: /seller/dashboard)
          StatefulShellBranch(
            routes: [ sellerDashboardRoute ], 
          ),
          // Branch 1: 卖家订单 (Path: /seller/orders)
          StatefulShellBranch(
             routes: [ sellerOrdersRoute ], 
          ),
          // Branch 2: 卖家消息 (Path: /seller/notifications)
          StatefulShellBranch(
            routes: [ sellerNotificationsRoute ],
          ),
          // Branch 3: 卖家我的 (Path: /seller)
          StatefulShellBranch(
            routes: [ sellerMyRoute ], 
          ),
        ],
      ),

      // --- Top-level routes (No Shell) ---
      ...AuthRoutes.routes, // Login etc.
      buyerOrderDetailRoute, 
      ...AfterSalesRoutes.routes,
      ...FavoritesRoutes.routes, 
      // Add non-shell seller routes directly
      ...sellerNonShellRoutes, 

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
      // Define buyer and seller SHELL entry paths
      final List<String> buyerPaths = [
          HomeRoutes.homePath, 
          '/ai_chat', 
          '/chat', 
          '/profile', 
          '/dev_menu'
      ]; 
      final List<String> sellerPaths = [
          '/seller/dashboard', 
          '/seller/orders', 
          SellerRoutes.notifications, 
          SellerRoutes.home, 
      ]; 
      
      bool isBuyerShellLocation = buyerPaths.any((p) => location.startsWith(p));
      bool isSellerShellLocation = sellerPaths.any((p) => location.startsWith(p)); 
      
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