import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_mode.dart';

/// 缓存的导航 Shell 容器
/// 在模式切换时保持页面状态
class CachedNavigationShell extends ConsumerStatefulWidget {
  final Widget Function(BuildContext, GoRouterState, StatefulNavigationShell) builder;
  final StatefulNavigationShell navigationShell;
  final GoRouterState state;
  final AppMode mode;
  
  const CachedNavigationShell({
    Key? key,
    required this.builder,
    required this.navigationShell,
    required this.state,
    required this.mode,
  }) : super(key: key);
  
  @override
  ConsumerState<CachedNavigationShell> createState() => _CachedNavigationShellState();
}

class _CachedNavigationShellState extends ConsumerState<CachedNavigationShell>
    with AutomaticKeepAliveClientMixin {
  Widget? _cachedShell;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // 只在第一次或模式匹配时创建 Shell
    final currentMode = ref.watch(appModeProvider);
    if (_cachedShell == null || currentMode == widget.mode) {
      _cachedShell = widget.builder(context, widget.state, widget.navigationShell);
    }
    
    // 返回缓存的 Shell
    return _cachedShell!;
  }
}

/// 全局页面缓存管理器
class PageCacheManager {
  static final PageCacheManager _instance = PageCacheManager._internal();
  factory PageCacheManager() => _instance;
  PageCacheManager._internal();
  
  // 缓存的页面 widgets
  final Map<String, Widget> _pageCache = {};
  
  // 获取或创建缓存的页面
  Widget getCachedPage(String key, Widget Function() builder) {
    return _pageCache.putIfAbsent(key, builder);
  }
  
  // 清除特定页面缓存
  void clearPageCache(String key) {
    _pageCache.remove(key);
  }
  
  // 清除所有缓存
  void clearAllCache() {
    _pageCache.clear();
  }
  
  // 根据模式清除缓存
  void clearCacheByMode(AppMode mode) {
    _pageCache.removeWhere((key, _) => key.startsWith(mode.name));
  }
}

/// 页面缓存管理器 Provider
final pageCacheManagerProvider = Provider<PageCacheManager>((ref) {
  return PageCacheManager();
});