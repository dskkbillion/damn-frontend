import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_mode.dart';
import '../../core/router/smart_router_utils.dart';

// 导入需要的页面和Bloc
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/seller/presentation/bloc/seller_statistics/seller_statistics_bloc.dart';
import '../../features/seller/presentation/pages/seller_statistics_page.dart';
import '../../features/seller/presentation/bloc/product_management/product_management_bloc.dart';
import '../../features/seller/presentation/pages/product_management_page.dart';
import '../../features/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import '../../features/chat/presentation/pages/chat_list_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/seller/presentation/pages/seller_home_page.dart';
import '../../features/ai_docs/presentation/pages/chat_page.dart';
import '../../features/seller/presentation/bloc/product_management/product_management_event.dart';
import '../../features/chat/presentation/bloc/chat_list/chat_list_event.dart';

/// 统一路由构建器 - 根据AppMode动态创建页面内容
class UnifiedRouteBuilder {
  static final GetIt _getIt = GetIt.instance;
  
  // 页面缓存，避免重复创建
  static final Map<String, Widget> _pageCache = {};
  
  /// 获取缓存的页面或创建新页面
  static Widget _getCachedPage(String key, Widget Function() builder) {
    if (_pageCache.containsKey(key)) {
      print('[UnifiedRouteBuilder] Using cached page: $key');
      return _pageCache[key]!;
    }
    
    print('[UnifiedRouteBuilder] Creating new page: $key');
    final page = builder();
    _pageCache[key] = page;
    return page;
  }
  
  /// 清理页面缓存
  static void clearCache() {
    print('[UnifiedRouteBuilder] Clearing page cache');
    _pageCache.clear();
  }
  
  /// 构建第一个Tab的内容（AI助手/数据统计）
  static Widget buildFirstTabContent(WidgetRef ref) {
    final appMode = ref.read(appModeProvider);
    final cacheKey = 'first_tab_${appMode.name}';
    
    return _getCachedPage(cacheKey, () {
      try {
        switch (appMode) {
          case AppMode.buyer:
            return const ChatPage(); // AI助手页面
          case AppMode.seller:
            return BlocProvider(
              create: (_) {
                try {
                  return _getIt<SellerStatisticsBloc>();
                } catch (e) {
                  print('[UnifiedRouteBuilder] Error creating SellerStatisticsBloc: $e');
                  // 返回一个简单的错误页面而不是抛出异常
                  throw StateError('统计功能暂时不可用');
                }
              },
              child: const SellerStatisticsPage(),
            );
        }
      } catch (e) {
        print('[UnifiedRouteBuilder] Error building first tab: $e');
        return _ErrorPage(error: e.toString(), pageName: 'First Tab');
      }
    });
  }
  
  /// 构建第二个Tab的内容（主页/商品管理）
  static Widget buildSecondTabContent(WidgetRef ref) {
    final appMode = ref.read(appModeProvider);
    final cacheKey = 'second_tab_${appMode.name}';
    
    return _getCachedPage(cacheKey, () {
      try {
        switch (appMode) {
          case AppMode.buyer:
            return BlocProvider(
              create: (_) {
                try {
                  return _getIt<HomeBloc>();
                } catch (e) {
                  print('[UnifiedRouteBuilder] Error creating HomeBloc: $e');
                  throw StateError('主页功能暂时不可用');
                }
              },
              child: const HomePage(),
            );
          case AppMode.seller:
            return BlocProvider(
              create: (_) {
                try {
                  final bloc = _getIt<ProductManagementBloc>();
                  bloc.add(LoadProductList());
                  return bloc;
                } catch (e) {
                  print('[UnifiedRouteBuilder] Error creating ProductManagementBloc: $e');
                  throw StateError('商品管理功能暂时不可用');
                }
              },
              child: const ProductManagementPage(),
            );
        }
      } catch (e) {
        print('[UnifiedRouteBuilder] Error building second tab: $e');
        return _ErrorPage(error: e.toString(), pageName: 'Second Tab');
      }
    });
  }
  
  /// 构建第三个Tab的内容（消息 - 通用）
  static Widget buildThirdTabContent(WidgetRef ref) {
    const cacheKey = 'third_tab_messages';
    
    return _getCachedPage(cacheKey, () {
      try {
        return BlocProvider(
          create: (_) {
            try {
              final bloc = _getIt<ChatListBloc>();
              bloc.add(LoadChatRoomList());
              return bloc;
            } catch (e) {
              print('[UnifiedRouteBuilder] Error creating ChatListBloc: $e');
              throw StateError('消息功能暂时不可用');
            }
          },
          child: const ChatListPage(),
        );
      } catch (e) {
        print('[UnifiedRouteBuilder] Error building third tab: $e');
        return _ErrorPage(error: e.toString(), pageName: 'Messages');
      }
    });
  }
  
  /// 构建第四个Tab的内容（个人页面）
  static Widget buildFourthTabContent(WidgetRef ref) {
    final appMode = ref.read(appModeProvider);
    final cacheKey = 'fourth_tab_${appMode.name}';
    
    return _getCachedPage(cacheKey, () {
      try {
        switch (appMode) {
          case AppMode.buyer:
            return const ProfilePage();
          case AppMode.seller:
            return const SellerHomePage();
        }
      } catch (e) {
        print('[UnifiedRouteBuilder] Error building fourth tab: $e');
        return _ErrorPage(error: e.toString(), pageName: 'Profile');
      }
    });
  }
  
  /// 创建带错误边界的页面构建器
  static Page<T> buildPageWithErrorBoundary<T extends Object?>(
    GoRouterState state,
    Widget Function() contentBuilder, {
    required String name,
    String? source,
  }) {
    try {
      final content = contentBuilder();
      return state.buildSmartPage(
        _ErrorBoundaryWrapper(child: content),
        name: name,
        source: source ?? 'unified_route_builder',
      );
    } catch (e) {
      print('[UnifiedRouteBuilder] Error building $name: $e');
      return state.buildSmartPage(
        _ErrorPage(error: e.toString(), pageName: name),
        name: '${name}_error',
        source: 'error_boundary',
      );
    }
  }
}

/// 错误边界包装器
class _ErrorBoundaryWrapper extends StatefulWidget {
  final Widget child;
  
  const _ErrorBoundaryWrapper({required this.child});
  
  @override
  State<_ErrorBoundaryWrapper> createState() => _ErrorBoundaryWrapperState();
}

class _ErrorBoundaryWrapperState extends State<_ErrorBoundaryWrapper> {
  bool _hasError = false;
  String? _errorMessage;
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _ErrorPage(
        error: _errorMessage ?? 'Unknown error',
        pageName: 'Page',
      );
    }
    
    try {
      return widget.child;
    } catch (e) {
      print('[ErrorBoundaryWrapper] Caught error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      });
      
      return _ErrorPage(
        error: e.toString(),
        pageName: 'Page',
      );
    }
  }
}

/// 错误页面
class _ErrorPage extends StatelessWidget {
  final String error;
  final String pageName;
  
  const _ErrorPage({required this.error, required this.pageName});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面加载失败'),
        backgroundColor: Colors.red.shade50,
        foregroundColor: Colors.red.shade700,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                '$pageName 页面暂时不可用',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      '错误详情:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // 清理缓存并重试
                      UnifiedRouteBuilder.clearCache();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}