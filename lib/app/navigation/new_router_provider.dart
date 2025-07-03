import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'unified_router_config.dart';

/// 新的路由Provider，支持统一路由架构和传统架构的切换
final newGoRouterProvider = Provider<GoRouter>((ref) {
  // 监听配置变化，自动重建路由
  return UnifiedRouterConfig.createRouter(ref);
});

/// 路由配置管理器Provider，提供简单的API来控制路由行为
final routeManagerProvider = Provider<RouteManager>((ref) {
  return RouteManager(ref);
});

/// 路由管理器，提供简化的路由操作API
class RouteManager {
  final Ref _ref;
  
  RouteManager(this._ref);
  
  /// 切换到统一路由模式
  void enableUnifiedRouter() {
    _ref.read(unifiedRouterProvider.notifier).state = true;
    print('[RouteManager] Switched to unified router');
  }
  
  /// 切换到传统路由模式
  void enableLegacyRouter() {
    _ref.read(unifiedRouterProvider.notifier).state = false;
    print('[RouteManager] Switched to legacy router');
  }
  
  /// 切换路由模式
  void toggleRouterMode() {
    final current = _ref.read(unifiedRouterProvider);
    _ref.read(unifiedRouterProvider.notifier).state = !current;
    print('[RouteManager] Toggled router mode to: ${!current ? "unified" : "legacy"}');
  }
  
  /// 获取当前路由模式
  bool get isUnifiedMode => _ref.read(unifiedRouterProvider);
  
  /// 切换开发Tab显示
  void toggleDevTab() {
    final current = _ref.read(appRouterConfigProvider);
    _ref.read(appRouterConfigProvider.notifier).state = 
        current.copyWith(showDevTab: !current.showDevTab);
    print('[RouteManager] Dev tab: ${!current.showDevTab}');
  }
  
  /// 切换性能监控
  void togglePerformanceMonitoring() {
    _ref.read(appRouterConfigProvider.notifier).toggleRouteMonitoring();
  }
  
  /// 切换路由缓存
  void toggleRouteCache() {
    _ref.read(appRouterConfigProvider.notifier).toggleRouteCache();
  }
  
  /// 重置所有配置为默认值
  void resetToDefaults() {
    _ref.read(appRouterConfigProvider.notifier).resetToDefaults();
    _ref.read(unifiedRouterProvider.notifier).state = false;
    print('[RouteManager] Reset all configurations to defaults');
  }
  
  /// 获取路由配置状态
  AppRouterConfigState get config => _ref.read(appRouterConfigProvider);
}