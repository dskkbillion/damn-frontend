import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/app_mode.dart';

/// 页面状态信息
class PageStateInfo {
  final String routePath;
  final AppMode mode;
  final ScrollController? scrollController;
  final Map<String, dynamic> formData;
  final DateTime lastAccess;
  
  PageStateInfo({
    required this.routePath,
    required this.mode,
    this.scrollController,
    Map<String, dynamic>? formData,
    DateTime? lastAccess,
  }) : formData = formData ?? {},
        lastAccess = lastAccess ?? DateTime.now();
  
  void updateLastAccess() {
    // 更新最后访问时间
  }
}

/// 页面状态管理服务
class PageStateManager {
  static final PageStateManager _instance = PageStateManager._internal();
  factory PageStateManager() => _instance;
  PageStateManager._internal();
  
  // 存储页面状态
  final Map<String, PageStateInfo> _pageStates = {};
  
  // 保存页面状态
  void savePageState(String key, PageStateInfo state) {
    _pageStates[key] = state;
    // 清理过期状态（超过30分钟未访问）
    _cleanupOldStates();
  }
  
  // 获取页面状态
  PageStateInfo? getPageState(String key) {
    final state = _pageStates[key];
    state?.updateLastAccess();
    return state;
  }
  
  // 清理旧状态
  void _cleanupOldStates() {
    final now = DateTime.now();
    _pageStates.removeWhere((key, state) {
      return now.difference(state.lastAccess).inMinutes > 30;
    });
  }
  
  // 清除所有状态
  void clearAll() {
    _pageStates.clear();
  }
  
  // 清除特定模式的状态
  void clearByMode(AppMode mode) {
    _pageStates.removeWhere((key, state) => state.mode == mode);
  }
}

/// 页面状态管理Provider
final pageStateManagerProvider = Provider<PageStateManager>((ref) {
  return PageStateManager();
});

/// 带状态保持的页面包装器
class StatefulPageWrapper extends ConsumerStatefulWidget {
  final String pageKey;
  final Widget Function(BuildContext context, PageStateInfo? savedState) builder;
  final bool saveScrollPosition;
  final bool saveFormData;
  
  const StatefulPageWrapper({
    Key? key,
    required this.pageKey,
    required this.builder,
    this.saveScrollPosition = true,
    this.saveFormData = false,
  }) : super(key: key);
  
  @override
  ConsumerState<StatefulPageWrapper> createState() => _StatefulPageWrapperState();
}

class _StatefulPageWrapperState extends ConsumerState<StatefulPageWrapper>
    with AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;
  PageStateInfo? _savedState;
  
  @override
  void initState() {
    super.initState();
    
    // 恢复保存的状态
    final manager = ref.read(pageStateManagerProvider);
    _savedState = manager.getPageState(widget.pageKey);
    
    if (widget.saveScrollPosition) {
      _scrollController = _savedState?.scrollController ?? ScrollController();
      
      // 恢复滚动位置
      if (_savedState?.scrollController != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController!.hasClients) {
            _scrollController!.jumpTo(_savedState!.scrollController!.offset);
          }
        });
      }
    }
  }
  
  @override
  void dispose() {
    // 在 dispose 之前保存状态，避免在 super.dispose() 之后访问 ref
    try {
      final currentMode = ref.read(appModeProvider);
      final manager = ref.read(pageStateManagerProvider);
      
      manager.savePageState(
        widget.pageKey,
        PageStateInfo(
          routePath: widget.pageKey,
          mode: currentMode,
          scrollController: _scrollController,
          formData: _savedState?.formData ?? {},
        ),
      );
    } catch (e) {
      // 如果 widget 已经被 dispose，忽略错误
    }
    
    // 不要释放 ScrollController，因为我们要保持它
    // _scrollController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // 注入滚动控制器
    if (_scrollController != null) {
      return PrimaryScrollController(
        controller: _scrollController!,
        child: widget.builder(context, _savedState),
      );
    }
    
    return widget.builder(context, _savedState);
  }
  
  @override
  bool get wantKeepAlive => true;
}

/// IndexedStack 页面缓存包装器
/// 
/// 使用 IndexedStack 来缓存多个页面，避免重新构建
class CachedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration inactiveDuration;
  
  const CachedIndexedStack({
    Key? key,
    required this.index,
    required this.children,
    this.inactiveDuration = const Duration(minutes: 5),
  }) : super(key: key);
  
  @override
  State<CachedIndexedStack> createState() => _CachedIndexedStackState();
}

class _CachedIndexedStackState extends State<CachedIndexedStack> {
  final Map<int, DateTime> _lastActiveTime = {};
  late List<Widget?> _cachedChildren;
  
  @override
  void initState() {
    super.initState();
    _cachedChildren = List.filled(widget.children.length, null);
    _updateCache();
  }
  
  @override
  void didUpdateWidget(CachedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _updateCache();
    }
  }
  
  void _updateCache() {
    final now = DateTime.now();
    _lastActiveTime[widget.index] = now;
    
    // 构建当前页面
    _cachedChildren[widget.index] = widget.children[widget.index];
    
    // 清理超时的缓存页面
    for (int i = 0; i < _cachedChildren.length; i++) {
      if (i != widget.index && _cachedChildren[i] != null) {
        final lastActive = _lastActiveTime[i];
        if (lastActive == null || now.difference(lastActive) > widget.inactiveDuration) {
          setState(() {
            _cachedChildren[i] = null;
          });
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: _cachedChildren.map((child) {
        return child ?? const SizedBox.shrink();
      }).toList(),
    );
  }
}