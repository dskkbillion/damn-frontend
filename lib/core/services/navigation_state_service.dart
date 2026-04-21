import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_mode.dart';

/// 导航状态信息
class NavigationStateInfo {
  final String location;
  final int shellIndex;
  final Map<String, dynamic> extra;
  final DateTime timestamp;
  
  NavigationStateInfo({
    required this.location,
    required this.shellIndex,
    Map<String, dynamic>? extra,
    DateTime? timestamp,
  }) : extra = extra ?? {},
        timestamp = timestamp ?? DateTime.now();
}

/// 导航状态服务，用于在模式切换时保存和恢复导航状态
class NavigationStateService {
  static final NavigationStateService _instance = NavigationStateService._internal();
  factory NavigationStateService() => _instance;
  NavigationStateService._internal();
  
  // 存储每个模式的导航状态
  final Map<AppMode, NavigationStateInfo> _navigationStates = {};
  
  // 保存导航状态
  void saveNavigationState(AppMode mode, String location, int shellIndex, [Map<String, dynamic>? extra]) {
    _navigationStates[mode] = NavigationStateInfo(
      location: location,
      shellIndex: shellIndex,
      extra: extra,
    );
  }
  
  // 获取导航状态
  NavigationStateInfo? getNavigationState(AppMode mode) {
    return _navigationStates[mode];
  }
  
  // 清除导航状态
  void clearNavigationState(AppMode mode) {
    _navigationStates.remove(mode);
  }
  
  // 清除所有导航状态
  void clearAll() {
    _navigationStates.clear();
  }
}

/// 导航状态服务Provider
final navigationStateServiceProvider = Provider<NavigationStateService>((ref) {
  return NavigationStateService();
});

/// 模式切换时的导航处理扩展
extension NavigationStateExtension on GoRouter {
  /// 切换模式并恢复导航状态
  void switchModeWithStateRestore(
    WidgetRef ref,
    AppMode targetMode,
    {String? defaultLocation}
  ) {
    final navigationStateService = ref.read(navigationStateServiceProvider);
    final currentMode = ref.read(appModeProvider);
    
    // 保存当前模式的导航状态
    final currentLocation = routerDelegate.currentConfiguration.fullPath;
    // TODO: 获取当前shell index
    navigationStateService.saveNavigationState(currentMode, currentLocation, 0);
    
    // 切换模式
    ref.read(appModeProvider.notifier).state = targetMode;
    
    // 恢复目标模式的导航状态
    final savedState = navigationStateService.getNavigationState(targetMode);
    if (savedState != null) {
      // 恢复到之前的位置
      go(savedState.location);
    } else if (defaultLocation != null) {
      // 导航到默认位置
      go(defaultLocation);
    }
  }
}