import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_mode.dart';

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

// 导入use cases
import '../../features/seller/domain/usecases/get_seller_product_list_usecase.dart';
import '../../features/seller/domain/usecases/get_seller_draft_list_usecase.dart';
import '../../features/seller/domain/usecases/update_product_status_usecase.dart';
import '../../features/seller/domain/usecases/delete_product_usecase.dart';
import '../../features/seller/domain/repositories/i_seller_repository.dart';
import '../../features/seller/presentation/bloc/product_management/product_management_event.dart';
import '../../features/chat/presentation/bloc/chat_list/chat_list_event.dart';

/// 统一路由构建器 - 根据AppMode动态创建页面内容
class UnifiedRouteBuilder {
  static final GetIt _getIt = GetIt.instance;
  
  /// 构建第一个Tab的内容（AI助手/数据统计）
  static Widget buildFirstTabContent(WidgetRef ref) {
    final appMode = ref.read(appModeProvider);
    
    switch (appMode) {
      case AppMode.buyer:
        return const ChatPage(); // AI助手页面
      case AppMode.seller:
        return BlocProvider(
          create: (_) => _getIt<SellerStatisticsBloc>(),
          child: const SellerStatisticsPage(),
        );
    }
  }
  
  /// 构建第二个Tab的内容（主页/商品管理）
  static Widget buildSecondTabContent(WidgetRef ref) {
    final appMode = ref.read(appModeProvider);
    
    switch (appMode) {
      case AppMode.buyer:
        return BlocProvider(
          create: (_) => _getIt<HomeBloc>(),
          child: const HomePage(),
        );
      case AppMode.seller:
        try {
          final sellerRepository = _getIt<ISellerRepository>();
          final productManagementBloc = ProductManagementBloc(
            GetSellerProductListUseCase(sellerRepository),
            GetSellerDraftListUseCase(sellerRepository),
            UpdateProductStatusUseCase(sellerRepository),
            DeleteProductUseCase(sellerRepository),
          );
          
          return BlocProvider(
            create: (_) => productManagementBloc..add(LoadProductList()),
            child: const ProductManagementPage(),
          );
        } catch (e) {
          print('[UnifiedRouteBuilder] Error creating ProductManagementBloc: $e');
          return _ErrorPage(error: e.toString(), pageName: 'Product Management');
        }
    }
  }
  
  /// 构建第三个Tab的内容（消息 - 通用）
  static Widget buildThirdTabContent(WidgetRef ref) {
    return BlocProvider(
      create: (_) => _getIt<ChatListBloc>()..add(LoadChatRoomList()),
      child: const ChatListPage(),
    );
  }
  
  /// 构建第四个Tab的内容（个人页面）
  static Widget buildFourthTabContent(WidgetRef ref) {
    final appMode = ref.read(appModeProvider);
    
    switch (appMode) {
      case AppMode.buyer:
        return const ProfilePage();
      case AppMode.seller:
        return const SellerHomePage();
    }
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
      return _buildSmartPage(
        state,
        _ErrorBoundaryWrapper(child: content),
        name: name,
        source: source ?? 'unified_route_builder',
      );
    } catch (e) {
      print('[UnifiedRouteBuilder] Error building $name: $e');
      return _buildSmartPage(
        state,
        _ErrorPage(error: e.toString(), pageName: name),
        name: '${name}_error',
        source: 'error_boundary',
      );
    }
  }
  
  /// 构建智能页面（使用MaterialPage作为默认实现）
  static Page<T> _buildSmartPage<T extends Object?>(
    GoRouterState state,
    Widget child, {
    required String name,
    String? source,
  }) {
    return MaterialPage<T>(
      key: ValueKey('${name}_${state.uri}'),
      name: name,
      child: child,
    );
  }
}

/// 错误边界包装器
class _ErrorBoundaryWrapper extends StatelessWidget {
  final Widget child;
  
  const _ErrorBoundaryWrapper({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return child;
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
      appBar: AppBar(title: Text('页面加载失败')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('$pageName 页面暂时不可用'),
            const SizedBox(height: 8),
            Text('错误: $error', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
}