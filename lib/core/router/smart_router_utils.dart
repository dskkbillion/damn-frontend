import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 智能路由工具扩展
extension SmartRouterUtils on GoRouterState {
  /// 构建智能页面，包含统一的错误处理和日志记录
  Page<T> buildSmartPage<T extends Object?>(
    Widget child, {
    required String name,
    String? source,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool allowSnapshotting = true,
  }) {
    // 记录页面构建日志
    final timestamp = DateTime.now().toIso8601String();
    print('[SmartPage] Building page: $name (source: ${source ?? 'unknown'}) at $timestamp');
    
    // 性能监控
    final stopwatch = Stopwatch()..start();
    
    final page = CustomTransitionPage<T>(
      key: ValueKey('${name}_${uri}_$source'),
      name: name,
      child: _SmartPageWrapper(
        pageName: name,
        source: source,
        buildTime: stopwatch,
        child: child,
      ),
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      allowSnapshotting: allowSnapshotting,
      transitionsBuilder: _buildPageTransition,
    );
    
    stopwatch.stop();
    print('[SmartPage] Page built in ${stopwatch.elapsedMilliseconds}ms: $name');
    
    return page;
  }
  
  /// 构建带缓存的智能页面
  Page<T> buildCachedPage<T extends Object?>(
    Widget child, {
    required String name,
    String? source,
    Duration cacheDuration = const Duration(minutes: 5),
  }) {
    return buildSmartPage<T>(
      _CachedPageWrapper(
        cacheKey: '${name}_${uri}',
        cacheDuration: cacheDuration,
        child: child,
      ),
      name: name,
      source: '${source ?? 'unknown'}_cached',
    );
  }
}

/// 页面转场动画构建器
Widget _buildPageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: animation.drive(
      Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(
        CurveTween(curve: Curves.easeInOut),
      ),
    ),
    child: child,
  );
}

/// 智能页面包装器，提供错误边界和性能监控
class _SmartPageWrapper extends StatefulWidget {
  final String pageName;
  final String? source;
  final Stopwatch buildTime;
  final Widget child;
  
  const _SmartPageWrapper({
    required this.pageName,
    required this.source,
    required this.buildTime,
    required this.child,
  });
  
  @override
  State<_SmartPageWrapper> createState() => _SmartPageWrapperState();
}

class _SmartPageWrapperState extends State<_SmartPageWrapper> {
  bool _hasError = false;
  String? _errorMessage;
  DateTime? _mountTime;
  
  @override
  void initState() {
    super.initState();
    _mountTime = DateTime.now();
    print('[SmartPageWrapper] Page mounted: ${widget.pageName}');
  }
  
  @override
  void dispose() {
    if (_mountTime != null) {
      final duration = DateTime.now().difference(_mountTime!);
      print('[SmartPageWrapper] Page disposed: ${widget.pageName} (lived ${duration.inSeconds}s)');
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _buildErrorPage();
    }
    
    try {
      return widget.child;
    } catch (e, stackTrace) {
      print('[SmartPageWrapper] Error in ${widget.pageName}: $e');
      print('[SmartPageWrapper] Stack trace: $stackTrace');
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = e.toString();
          });
        }
      });
      
      return _buildErrorPage();
    }
  }
  
  Widget _buildErrorPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面错误'),
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
                '${widget.pageName} 页面出现错误',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage != null) ...[
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
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _errorMessage = null;
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('重试'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
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

/// 缓存页面包装器
class _CachedPageWrapper extends StatefulWidget {
  final String cacheKey;
  final Duration cacheDuration;
  final Widget child;
  
  const _CachedPageWrapper({
    required this.cacheKey,
    required this.cacheDuration,
    required this.child,
  });
  
  @override
  State<_CachedPageWrapper> createState() => _CachedPageWrapperState();
}

class _CachedPageWrapperState extends State<_CachedPageWrapper> {
  static final Map<String, _CacheEntry> _cache = {};
  
  @override
  Widget build(BuildContext context) {
    final cacheEntry = _cache[widget.cacheKey];
    
    // 检查缓存是否存在且未过期
    if (cacheEntry != null && !cacheEntry.isExpired) {
      print('[CachedPageWrapper] Using cached content for ${widget.cacheKey}');
      return cacheEntry.widget;
    }
    
    // 缓存页面内容
    print('[CachedPageWrapper] Caching content for ${widget.cacheKey}');
    _cache[widget.cacheKey] = _CacheEntry(
      widget: widget.child,
      timestamp: DateTime.now(),
      duration: widget.cacheDuration,
    );
    
    // 清理过期缓存
    _cleanExpiredCache();
    
    return widget.child;
  }
  
  static void _cleanExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, entry) {
      final isExpired = entry.isExpired;
      if (isExpired) {
        print('[CachedPageWrapper] Removing expired cache: $key');
      }
      return isExpired;
    });
  }
  
  /// 清理所有缓存
  static void clearAllCache() {
    print('[CachedPageWrapper] Clearing all cache (${_cache.length} entries)');
    _cache.clear();
  }
}

/// 缓存条目
class _CacheEntry {
  final Widget widget;
  final DateTime timestamp;
  final Duration duration;
  
  _CacheEntry({
    required this.widget,
    required this.timestamp,
    required this.duration,
  });
  
  bool get isExpired => DateTime.now().difference(timestamp) > duration;
}