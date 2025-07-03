import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 路由配置 - 管理路由相关的配置选项
class AppRouterConfig {
  // 是否使用统一路由架构（替换双重Shell嵌套）
  static const bool useUnifiedRouter = false; // 默认关闭，保持兼容性
  
  // 是否启用路由性能监控
  static const bool enableRouteMonitoring = true;
  
  // 是否启用路由缓存
  static const bool enableRouteCache = true;
  
  // 路由缓存持续时间（分钟）
  static const int routeCacheDurationMinutes = 5;
  
  // 是否在开发模式显示路由日志
  static const bool showRouteLogsInDev = true;
}

/// 统一路由开关 Provider
final unifiedRouterProvider = StateProvider<bool>((ref) {
  return AppRouterConfig.useUnifiedRouter;
});

/// 开发Tab显示配置 Provider
final showDevTabProvider = StateProvider<bool>((ref) {
  return false; // 默认不显示开发Tab
});

/// 路由性能监控开关 Provider  
final routeMonitoringProvider = StateProvider<bool>((ref) {
  return AppRouterConfig.enableRouteMonitoring;
});

/// 路由缓存开关 Provider
final routeCacheProvider = StateProvider<bool>((ref) {
  return AppRouterConfig.enableRouteCache;
});

/// 路由配置状态管理器
class AppRouterConfigNotifier extends StateNotifier<AppRouterConfigState> {
  AppRouterConfigNotifier() : super(const AppRouterConfigState());
  
  /// 切换统一路由模式
  void toggleUnifiedRouter() {
    state = state.copyWith(useUnifiedRouter: !state.useUnifiedRouter);
    print('[AppRouterConfig] Unified router: ${state.useUnifiedRouter}');
  }
  
  /// 切换性能监控
  void toggleRouteMonitoring() {
    state = state.copyWith(enableRouteMonitoring: !state.enableRouteMonitoring);
    print('[AppRouterConfig] Route monitoring: ${state.enableRouteMonitoring}');
  }
  
  /// 切换路由缓存
  void toggleRouteCache() {
    state = state.copyWith(enableRouteCache: !state.enableRouteCache);
    print('[AppRouterConfig] Route cache: ${state.enableRouteCache}');
  }
  
  /// 重置为默认配置
  void resetToDefaults() {
    state = const AppRouterConfigState();
    print('[AppRouterConfig] Reset to defaults');
  }
}

/// 路由配置状态
class AppRouterConfigState {
  final bool useUnifiedRouter;
  final bool enableRouteMonitoring;
  final bool enableRouteCache;
  final bool showDevTab;
  
  const AppRouterConfigState({
    this.useUnifiedRouter = AppRouterConfig.useUnifiedRouter,
    this.enableRouteMonitoring = AppRouterConfig.enableRouteMonitoring,
    this.enableRouteCache = AppRouterConfig.enableRouteCache,
    this.showDevTab = false,
  });
  
  AppRouterConfigState copyWith({
    bool? useUnifiedRouter,
    bool? enableRouteMonitoring,
    bool? enableRouteCache,
    bool? showDevTab,
  }) {
    return AppRouterConfigState(
      useUnifiedRouter: useUnifiedRouter ?? this.useUnifiedRouter,
      enableRouteMonitoring: enableRouteMonitoring ?? this.enableRouteMonitoring,
      enableRouteCache: enableRouteCache ?? this.enableRouteCache,
      showDevTab: showDevTab ?? this.showDevTab,
    );
  }
}

/// 路由配置 Provider
final appRouterConfigProvider = StateNotifierProvider<AppRouterConfigNotifier, AppRouterConfigState>((ref) {
  return AppRouterConfigNotifier();
}); 