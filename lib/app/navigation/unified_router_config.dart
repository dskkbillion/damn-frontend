import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import existing route configurations
import '../../features/orders/presentation/routes/order_routes.dart';
import '../../features/after_sales/presentation/routes/after_sales_routes.dart';
import '../../features/ai_docs/presentation/routes/ai_docs_routes.dart';
import '../../features/auth/presentation/routes/auth_routes.dart'; 
import '../../features/profile/presentation/routes/profile_routes.dart'; 
import '../../features/home/presentation/routes/home_routes.dart';
import '../../features/favorites/presentation/routes/favorites_routes.dart';
import '../../features/chat/presentation/routes/chat_routes.dart';
import '../../features/seller/presentation/routes/seller_routes.dart';
import '../../features/payment/presentation/routes/payment_routes.dart';

// Import unified components
import '../widgets/unified_shell_page.dart';
import 'unified_route_builder.dart';
import '../debug/route_test_page.dart';
import 'app_router_config.dart';
import '../app_mode.dart';

// Import auth classes
import '../../features/auth/domain/entities/auth_status.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';

// Import legacy shell pages
import '../widgets/main_shell_page.dart';
import '../../features/seller/presentation/widgets/seller_shell_page.dart';
import '../widgets/dev_menu_page.dart';

// Import analytics
import '../../core/analytics/observers/router_analytics_observer.dart';

/// 统一路由配置器 - 根据开关选择使用统一Shell还是双重Shell架构
class UnifiedRouterConfig {
  
  /// 创建路由配置
  static GoRouter createRouter(WidgetRef ref) {
    final useUnifiedRouter = ref.watch(unifiedRouterProvider);
    final routeConfig = ref.watch(appRouterConfigProvider);
    
    print('[UnifiedRouterConfig] Creating router - unified: $useUnifiedRouter');
    
    if (useUnifiedRouter) {
      return _createUnifiedRouter(ref, routeConfig);
    } else {
      return _createLegacyRouter(ref, routeConfig);
    }
  }
  
  /// 创建统一Shell路由配置
  static GoRouter _createUnifiedRouter(WidgetRef ref, AppRouterConfigState config) {
    final authRepository = GetIt.instance<IAuthRepository>();
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'unified_root');
    
    print('[UnifiedRouterConfig] Creating unified router configuration');
    
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      debugLogDiagnostics: config.showDevTab,
      refreshListenable: GoRouterRefreshStream(authRepository.authStatus),
      observers: config.enableRouteMonitoring ? [RouterAnalyticsObserver()] : [],
      
      routes: [
        // --- 统一Shell路由 ---
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return UnifiedShellPage(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: 第一个Tab（AI助手/数据统计）
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tab1',
                  name: 'unified_tab1',
                  pageBuilder: (context, state) {
                    return UnifiedRouteBuilder.buildPageWithErrorBoundary<void>(
                      state,
                      () => Consumer(
                        builder: (context, ref, child) {
                          return UnifiedRouteBuilder.buildFirstTabContent(ref);
                        },
                      ),
                      name: 'unified_tab1',
                      source: 'unified_router',
                    );
                  },
                ),
              ],
            ),
            
            // Branch 1: 第二个Tab（主页/商品管理）
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tab2',
                  name: 'unified_tab2',
                  pageBuilder: (context, state) {
                    return UnifiedRouteBuilder.buildPageWithErrorBoundary<void>(
                      state,
                      () => Consumer(
                        builder: (context, ref, child) {
                          return UnifiedRouteBuilder.buildSecondTabContent(ref);
                        },
                      ),
                      name: 'unified_tab2',
                      source: 'unified_router',
                    );
                  },
                ),
              ],
            ),
            
            // Branch 2: 第三个Tab（消息 - 通用）
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tab3',
                  name: 'unified_tab3',
                  pageBuilder: (context, state) {
                    return UnifiedRouteBuilder.buildPageWithErrorBoundary<void>(
                      state,
                      () => Consumer(
                        builder: (context, ref, child) {
                          return UnifiedRouteBuilder.buildThirdTabContent(ref);
                        },
                      ),
                      name: 'unified_tab3',
                      source: 'unified_router',
                    );
                  },
                ),
              ],
            ),
            
            // Branch 3: 第四个Tab（个人页面）
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/tab4',
                  name: 'unified_tab4',
                  pageBuilder: (context, state) {
                    return UnifiedRouteBuilder.buildPageWithErrorBoundary<void>(
                      state,
                      () => Consumer(
                        builder: (context, ref, child) {
                          return UnifiedRouteBuilder.buildFourthTabContent(ref);
                        },
                      ),
                      name: 'unified_tab4',
                      source: 'unified_router',
                    );
                  },
                ),
              ],
            ),
            
            // Branch 4: 开发Tab（可选）
            if (config.showDevTab) StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/dev_menu',
                  name: 'unified_dev',
                  pageBuilder: (context, state) => const NoTransitionPage(
                    child: DevMenuPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
        
        // 路由测试页面
        GoRoute(
          path: '/route_test',
          name: 'route_test',
          builder: (context, state) => const RouteTestPage(),
        ),
        
        // 继承现有的顶级路由
        ...AuthRoutes.routes,
        ...OrderRoutes.routes,
        ...AfterSalesRoutes.routes,
        ...FavoritesRoutes.routes,
        ...PaymentRoutes.routes,
        ..._getSellerNonShellRoutes(),
      ],
      
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('页面未找到')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text('路径错误: ${state.uri}'),
              const SizedBox(height: 8),
              Text('错误: ${state.error}', style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/tab2'),
                child: const Text('返回主页'),
              ),
            ],
          ),
        ),
      ),
      
      redirect: (context, state) => _handleUnifiedRedirect(context, state, ref, authRepository),
    );
  }
  
  /// 创建传统双重Shell路由配置（保持现有架构）
  static GoRouter _createLegacyRouter(WidgetRef ref, AppRouterConfigState config) {
    // 这里使用现有的路由配置逻辑
    return _createLegacyRouterImplementation(ref, config);
  }
  
  /// 处理统一路由的重定向逻辑
  static String? _handleUnifiedRedirect(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
    IAuthRepository authRepository,
  ) {
    final loginStatus = authRepository.getLoggedInUserSync().fold(
      (failure) => const Unauthenticated(),
      (user) => user != null ? Authenticated(user) : const Unauthenticated(),
    );
    
    final isLoggingIn = state.matchedLocation == AuthRoutes.loginPath;
    final isUnknown = loginStatus is AuthUnknown;
    final currentMode = ref.read(appModeProvider);
    
    print('[UnifiedRouter] Redirect check: ${state.matchedLocation}, auth: $loginStatus, mode: $currentMode');
    
    if (isUnknown) return null;
    
    // 未登录用户重定向到登录页
    if (loginStatus is Unauthenticated && !isLoggingIn) {
      print('[UnifiedRouter] Redirecting to login');
      return AuthRoutes.loginPath;
    }
    
    // 已登录用户在登录页时重定向到主页
    if (loginStatus is Authenticated && isLoggingIn) {
      print('[UnifiedRouter] Redirecting authenticated user to home');
      return '/tab2'; // 统一路由的主页Tab
    }
    
    // 处理初始页面重定向
    final location = state.matchedLocation;
    if (location == '/home') {
      return '/tab2'; // 重定向到统一路由的主页Tab
    }
    if (location == '/ai_chat') {
      return '/tab1'; // 重定向到统一路由的AI Tab
    }
    if (location == '/chat') {
      return '/tab3'; // 重定向到统一路由的消息Tab
    }
    if (location == '/profile') {
      return '/tab4'; // 重定向到统一路由的个人Tab
    }
    
    return null;
  }
  
  /// 获取卖家非Shell路由（复用现有逻辑）
  static List<RouteBase> _getSellerNonShellRoutes() {
    // 这里返回现有的卖家路由，但排除Shell内的路由
    return SellerRoutes.routes.where((route) {
      if (route is GoRoute) {
        // 排除Shell内的主要Tab路径
        final shellPaths = ['/seller/dashboard', '/seller/products', '/seller/chat', '/seller/home'];
        return !shellPaths.contains(route.path);
      }
      return true;
    }).toList();
  }
  
  /// 传统路由实现（保持现有逻辑）
  static GoRouter _createLegacyRouterImplementation(WidgetRef ref, AppRouterConfigState config) {
    final authRepository = GetIt.instance<IAuthRepository>();
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'legacy_root');
    
    print('[UnifiedRouterConfig] Creating legacy router configuration');
    
    // 这里基本复制现有的app_router.dart中的goRouterProvider逻辑
    // 为了保持兼容性，暂时返回一个简化版本
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/home',
      debugLogDiagnostics: config.showDevTab,
      refreshListenable: GoRouterRefreshStream(authRepository.authStatus),
      observers: config.enableRouteMonitoring ? [RouterAnalyticsObserver()] : [],
      
      routes: [
        // 买家Shell路由
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShellPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: AiDocsRoutes.routes),
            StatefulShellBranch(routes: HomeRoutes.routes),
            StatefulShellBranch(routes: ChatRoutes.routes),
            StatefulShellBranch(routes: ProfileRoutes.routes),
            if (config.showDevTab) StatefulShellBranch(
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
        
        // 卖家Shell路由
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return SellerShellPage(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/seller/dashboard',
                builder: (context, state) => const Placeholder(child: Center(child: Text('卖家统计'))),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/seller/products',
                builder: (context, state) => const Placeholder(child: Center(child: Text('商品管理'))),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/seller/chat',
                builder: (context, state) => const Placeholder(child: Center(child: Text('卖家消息'))),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: SellerRoutes.home,
                builder: (context, state) => const Placeholder(child: Center(child: Text('卖家我的'))),
              ),
            ]),
          ],
        ),
        
        // 其他顶级路由
        ...AuthRoutes.routes,
        
        // 路由测试页面
        GoRoute(
          path: '/route_test',
          name: 'route_test',
          builder: (context, state) => const RouteTestPage(),
        ),
      ],
      
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('页面未找到')),
        body: Center(child: Text('路径错误: ${state.uri}\n错误: ${state.error}')),
      ),
      
      redirect: (context, state) => _handleLegacyRedirect(context, state, ref, authRepository),
    );
  }
  
  /// 处理传统路由的重定向逻辑
  static String? _handleLegacyRedirect(
    BuildContext context,
    GoRouterState state,
    WidgetRef ref,
    IAuthRepository authRepository,
  ) {
    final loginStatus = authRepository.getLoggedInUserSync().fold(
      (failure) => const Unauthenticated(),
      (user) => user != null ? Authenticated(user) : const Unauthenticated(),
    );
    
    final isLoggingIn = state.matchedLocation == AuthRoutes.loginPath;
    final isUnknown = loginStatus is AuthUnknown;
    
    print('[LegacyRouter] Redirect check: ${state.matchedLocation}, auth: $loginStatus');
    
    if (isUnknown) return null;
    
    if (loginStatus is Unauthenticated && !isLoggingIn) {
      print('[LegacyRouter] Redirecting to login');
      return AuthRoutes.loginPath;
    }
    
    if (loginStatus is Authenticated && isLoggingIn) {
      print('[LegacyRouter] Redirecting authenticated user to home');
      return HomeRoutes.homePath;
    }
    
    return null;
  }
}

/// GoRouter刷新流辅助类
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

