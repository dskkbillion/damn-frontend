import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dskk_flutter_refactor/features/seller/domain/entities/seller_authentication_info.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_home_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/product_edit_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_application_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auth_status_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/time_management_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/auto_reply_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/notification_list_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/order_delivery_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/after_sales_review_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/after_sales_detail_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/pages/seller_statistics_page.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_home/seller_home_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/product_management/product_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/after_sales_review/after_sales_review_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/blocs/auth_management/auth_management_bloc.dart';
import 'package:dskk_flutter_refactor/features/seller/presentation/bloc/seller_statistics/seller_statistics_bloc.dart';

/// 卖家模块路由配置
class SellerRoutes {
  /// 路由基础路径
  static const String basePath = '/seller';
  
  /// 路由路径定义
  static const String home = basePath;
  static const String products = '$basePath/products';
  static const String productCreate = '$basePath/products/create';
  static const String productEdit = '$basePath/products/:id/edit';
  static const String authentication = '$basePath/authentication';
  static const String authenticationApply = '$basePath/authentication/:type/apply';
  static const String authenticationDetail = '$basePath/authentication/:type/detail';
  static const String timeManagement = '$basePath/time';
  static const String autoReply = '$basePath/auto-reply';
  static const String notifications = '$basePath/notifications';
  static const String afterSalesReview = '$basePath/after-sales';
  static const String afterSalesDetail = '$basePath/after-sales/:id';
  static const String storeSettings = '$basePath/settings';
  static const String statistics = '$basePath/statistics';
  
  /// 获取卖家模块路由
  static List<RouteBase> get routes => [
    GoRoute(
      path: home,
      name: 'seller_home',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: BlocProvider(
          create: (context) => GetIt.I<SellerHomeBloc>(), 
          child: const SellerHomePage(),
        ),
      ),
      routes: [
        // 商品管理
        GoRoute(
          path: 'products',
          name: 'seller_products',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => GetIt.I<ProductManagementBloc>(),
              child: const ProductManagementPage(),
            ),
          ),
          routes: [
            // 创建商品
            GoRoute(
              path: 'create',
              name: 'seller_product_create',
              pageBuilder: (context, state) => _buildPage(
                const ProductEditPage(),
                title: '创建商品',
                state: state,
              ),
            ),
            // 编辑商品
            GoRoute(
              path: ':id/edit',
              name: 'seller_product_edit',
              pageBuilder: (context, state) => _buildPage(
                ProductEditPage(
                  productId: state.pathParameters['id'],
                ),
                title: '编辑商品',
                state: state,
              ),
            ),
          ],
        ),
        
        // 认证管理
        GoRoute(
          path: 'authentication',
          name: 'seller_authentication',
          pageBuilder: (context, state) {
            return MaterialPage(
              key: state.pageKey,
              child: AuthManagementPage(),
            );
          },
          routes: [
            // 认证申请
            GoRoute(
              path: ':type/apply',
              name: 'seller_authentication_apply',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: AuthApplicationPage(
                  type: state.pathParameters['type'] ?? 'other',
                  authInfo: state.extra as SellerAuthenticationInfo?,
                ),
              ),
            ),
            // 认证详情
            GoRoute(
              path: ':type/detail',
              name: 'seller_authentication_detail',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: AuthStatusPage(
                  authInfo: state.extra as SellerAuthenticationInfo,
                ),
              ),
            ),
          ],
        ),
        
        // 时间管理
        GoRoute(
          path: 'time',
          name: 'seller_time_management',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const TimeManagementPage(),
          ),
        ),
        
        // 自动回复
        GoRoute(
          path: 'auto-reply',
          name: 'seller_auto_reply',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AutoReplyPage(),
          ),
        ),
        
        // 通知列表
        GoRoute(
          path: 'notifications',
          name: 'seller_notifications',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const NotificationListPage(),
          ),
        ),
        
        // 售后审核
        GoRoute(
          path: 'after-sales',
          name: 'seller_after_sales',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: BlocProvider<AfterSalesReviewBloc>(
              create: (context) => GetIt.I<AfterSalesReviewBloc>(), 
              child: const AfterSalesReviewPage(),
            ),
          ),
          routes: [
            // 售后详情
            GoRoute(
              path: ':id',
              name: 'seller_after_sales_detail',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: AfterSalesDetailPage(
                  id: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
                ),
              ),
            ),
          ],
        ),
        
        // 店铺设置
        GoRoute(
          path: 'settings',
          name: 'seller_store_settings',
          pageBuilder: (context, state) => _buildPage(
            const Placeholder(
              color: Colors.blueGrey,
              child: Center(child: Text('店铺设置', style: TextStyle(color: Colors.white))),
            ),
            title: '店铺设置',
            state: state,
          ),
        ),

        // 订单交付页面
        GoRoute(
          path: 'orders/:id/delivery',
          name: 'seller_order_delivery',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: OrderDeliveryPage(
              orderId: int.parse(state.pathParameters['id'] ?? '0'),
              orderSn: state.extra != null ? (state.extra as Map<String, dynamic>)['orderSn'] as String? : null,
            ),
          ),
        ),

        // 统计页面路由
        GoRoute(
          path: 'statistics',
          name: 'seller_statistics',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: BlocProvider(
              create: (context) => GetIt.I<SellerStatisticsBloc>(),
              child: const SellerStatisticsPage(),
            ),
          ),
        ),
      ],
    ),
  ];
  
  /// 构建页面
  static Page<dynamic> _buildPage(
    Widget child, {
    required String title,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: child,
      ),
    );
  }
  
  /// 根据路径和参数构建完整路径
  static String buildPath(String path, {Map<String, String>? params}) {
    if (params == null || params.isEmpty) {
      return path;
    }
    
    String result = path;
    for (final entry in params.entries) {
      result = result.replaceAll(':${entry.key}', entry.value);
    }
    return result;
  }
} 