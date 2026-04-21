import 'package:flutter/material.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:get_it/get_it.dart';
import '../analytics_manager.dart';

/// 路由分析观察器
/// 自动记录页面浏览和停留时间事件
class RouterAnalyticsObserver extends NavigatorObserver {
  final AnalyticsManager _analytics;
  final Map<Route, DateTime> _routeEnterTimes = {};
  
  RouterAnalyticsObserver() : _analytics = GetIt.instance<AnalyticsManager>();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.d('[RouterAnalyticsObserver] 页面被推入: ${route.settings.name} (从 ${previousRoute?.settings.name ?? "无"})');
    _handleRouteEnter(route);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.d('[RouterAnalyticsObserver] 页面被替换: ${oldRoute?.settings.name ?? "无"} -> ${newRoute?.settings.name ?? "无"}');
    if (oldRoute != null) {
      _handleRouteLeave(oldRoute);
    }
    if (newRoute != null) {
      _handleRouteEnter(newRoute);
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.d('[RouterAnalyticsObserver] 页面被弹出: ${route.settings.name} (返回到 ${previousRoute?.settings.name ?? "无"})');
    _handleRouteLeave(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    AppLogger.d('[RouterAnalyticsObserver] 页面被移除: ${route.settings.name}');
    _handleRouteLeave(route);
  }

  /// 处理路由进入
  void _handleRouteEnter(Route route) {
    _routeEnterTimes[route] = DateTime.now();
    
    final routeName = route.settings.name;
    if (routeName != null && routeName.isNotEmpty) {
      AppLogger.d('[RouterAnalyticsObserver] 记录页面进入埋点: $routeName');
      
      final pageType = _getPageType(routeName);
      final businessId = _extractBusinessId(routeName);
      
      AppLogger.d('[RouterAnalyticsObserver] 页面类型: $pageType, 业务ID: $businessId');
      
      _analytics.trackPageView(
        path: routeName,
        pageType: pageType,
        businessId: businessId,
        additionalData: {
          'enter_timestamp': DateTime.now().millisecondsSinceEpoch,
          'route_type': route.runtimeType.toString(),
        },
      );
    } else {
      AppLogger.d('[RouterAnalyticsObserver] 跳过记录页面进入埋点: 路由名称为空 (${route.runtimeType})');
    }
  }

  /// 处理路由离开
  void _handleRouteLeave(Route route) {
    final enterTime = _routeEnterTimes.remove(route);
    if (enterTime != null) {
      final stayDuration = DateTime.now().difference(enterTime).inSeconds;
      final routeName = route.settings.name;
      
      // 只记录停留时间大于1秒的页面
      if (routeName != null && routeName.isNotEmpty && stayDuration > 1) {
        AppLogger.d('[RouterAnalyticsObserver] 记录页面离开埋点: $routeName, 停留时长: $stayDuration秒');
        
        final pageType = _getPageType(routeName);
        final businessId = _extractBusinessId(routeName);
        
        AppLogger.d('[RouterAnalyticsObserver] 页面类型: $pageType, 业务ID: $businessId');
        
        _analytics.trackPageView(
          path: routeName,
          pageType: pageType,
          businessId: businessId,
          stayDuration: stayDuration,
          additionalData: {
            'action': 'leave',
            'leave_timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      } else {
        AppLogger.d('[RouterAnalyticsObserver] 跳过记录页面离开埋点: ${routeName ?? "无名称"}, 停留时长: $stayDuration秒 (小于阈值)');
      }
    } else {
      AppLogger.d('[RouterAnalyticsObserver] 跳过记录页面离开埋点: 未找到进入时间记录 (${route.settings.name})');
    }
  }

  /// 根据路由名称获取页面类型
  String _getPageType(String routeName) {
    if (routeName.contains('/product/')) {
      return 'product_detail';
    } else if (routeName.contains('/seller/')) {
      return 'seller_page';
    } else if (routeName.contains('/chat')) {
      return 'chat_page';
    } else if (routeName.contains('/orders')) {
      return 'order_page';
    } else if (routeName.contains('/home')) {
      return 'home_page';
    } else if (routeName.contains('/search')) {
      return 'search_page';
    } else if (routeName.contains('/profile')) {
      return 'profile_page';
    } else if (routeName.contains('/auth') || routeName.contains('/login')) {
      return 'auth_page';
    } else if (routeName.contains('/after-sales')) {
      return 'after_sales_page';
    } else if (routeName.contains('/payment')) {
      return 'payment_page';
    } else {
      return 'other_page';
    }
  }

  /// 从路由名称中提取业务ID
  int? _extractBusinessId(String routeName) {
    // 尝试从路由中提取数字ID
    final RegExp idRegExp = RegExp(r'/(\d+)(?:/|$)');
    final match = idRegExp.firstMatch(routeName);
    
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    
    return null;
  }
} 