import 'package:flutter/material.dart'; // 导入Flutter Material包
import 'package:go_router/go_router.dart';
import '../pages/profile_page.dart'; // 引入 ProfilePage
import '../pages/account_security_page.dart'; // 引入账号与安全页面
import '../pages/wallet_page.dart'; // 引入钱包页面
import '../bloc/wallet_bloc.dart'; // 引入钱包相关的Bloc
import '../bloc/wallet_event.dart'; // 引入钱包事件
import '../bloc/wallet_state.dart'; // 引入钱包状态
import '../../domain/usecases/get_wallet_summary.dart'; // 引入获取钱包摘要用例
import '../../domain/usecases/get_wallet_transactions.dart'; // 引入获取钱包交易记录用例
import '../../data/repositories/wallet_repository_impl.dart'; // 引入钱包仓库实现
import '../../data/datasources/profile_remote_data_source.dart'; // 引入远程数据源
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart'; // 引入GetIt
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 引入安全存储
import '../../../../core/network/network_info.dart'; // 引入网络信息服务
import '../../../../core/network/mock_network_info.dart' as mock_network; // 引入模拟网络信息服务并添加前缀
import '../pages/language_settings_page.dart'; // 引入语言设置页面
// import '../pages/simple_profile_page.dart'; // 不再需要 SimpleProfilePage
// import '../pages/edit_profile_page.dart'; // 如果有其他页面

// 添加订单相关导入
import '../../../orders/presentation/pages/order_list_page.dart';
import '../../../orders/presentation/bloc/order_list_bloc.dart';
import '../../../orders/domain/entities/order_status.dart';

class ProfileRoutes {
  ProfileRoutes._(); // 私有构造函数，防止实例化

  // 通过静态 getter 暴露路由列表
  static List<RouteBase> get routes => _routes;

  // 定义常量路径，方便复用和引用
  static const String profilePath = '/profile';
  static const String accountSecurityPath = '/profile/account-security';
  static const String walletPath = '/profile/wallet';
  static const String languageSettingsPath = '/profile/language-settings';
  static const String ordersPath = '/profile/orders'; // 添加订单路径常量

  // 模块内部路由定义
  static final List<RouteBase> _routes = [
    GoRoute(
      path: profilePath, 
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
      routes: [
        // 子路由：账号与安全页面
        GoRoute(
          path: 'account-security',
          name: 'accountSecurity',
          builder: (context, state) => const AccountSecurityPage(),
        ),
        // 子路由：钱包页面 - 使用GetIt获取主应用的依赖
        GoRoute(
          path: 'wallet',
          name: 'wallet',
          builder: (context, state) {
            // 获取主应用的GetIt实例
            final getIt = GetIt.instance;
            
            try {
              // 尝试从GetIt获取主应用的Dio实例
              final dio = getIt<Dio>();
              
              // 获取主应用的其他必要依赖
              final secureStorage = getIt<FlutterSecureStorage>();
              
              // 创建网络信息服务 - 优先尝试获取已注册的，如果没有则创建模拟服务
              NetworkInfo networkInfo;
              try {
                networkInfo = getIt<NetworkInfo>();
              } catch (e) {
                print('NetworkInfo not found in GetIt, using mock: $e');
                networkInfo = mock_network.MockNetworkInfo();
              }
              
              // 创建远程数据源
              final remoteDataSource = ProfileRemoteDataSourceImpl(
                dio: dio,
                storage: secureStorage,
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
              );
              
              print('Successfully created WalletBloc with app dependencies');
              
              // 返回带BlocProvider的WalletPage
              return BlocProvider<WalletBloc>(
                create: (context) => walletBloc,
                child: const WalletPage(),
              );
            } catch (e) {
              // 如果从GetIt获取依赖失败，打印错误并返回一个简单的错误提示页面
              print('Error creating WalletBloc with app dependencies: $e');
              return Scaffold(
                appBar: AppBar(title: const Text('钱包')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('初始化钱包页面失败'),
                      const SizedBox(height: 16),
                      Text('错误: $e', style: const TextStyle(fontSize: 12, color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('返回'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        // 添加语言设置页面路由
        GoRoute(
          path: 'language-settings',
          name: 'languageSettings',
          builder: (context, state) => const LanguageSettingsPage(),
        ),
        // 添加订单页面路由
        GoRoute(
          path: 'orders',
          name: 'profileOrders',
          builder: (context, state) {
            // 提取status查询参数
            final statusString = state.uri.queryParameters['status'];
            print('[ProfileRoutes] Orders route - status param: $statusString');
            
            // 解析status
            OrderStatus? parsedStatus;
            if (statusString != null) {
              try {
                parsedStatus = OrderStatus.values.firstWhere(
                  (e) => e.toString().split('.').last == statusString,
                );
              } catch (e) {
                print('[ProfileRoutes] Failed to parse status: $statusString');
              }
            }
            
            return BlocProvider(
              create: (_) => GetIt.instance<OrderListBloc>()
                ..add(LoadOrders(status: parsedStatus)),
              child: OrderListPage(initialStatus: statusString),
            );
          },
        ),
      ],
    ),
    // GoRoute(
    //   path: '/profile/edit', 
    //   name: 'editProfile',
    //   builder: (context, state) => const EditProfilePage(),
    // ),
    // ... 其他 profile 模块路由 ...
  ];
} 