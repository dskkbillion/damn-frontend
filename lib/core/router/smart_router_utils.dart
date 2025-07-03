import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 智能路由工具类
/// 
/// 提供统一的路由管理功能，包括：
/// - 动态Key生成，避免Navigator重复Key错误
/// - 智能导航检测，防止循环跳转
/// - 跨模块路由统一管理
class SmartRouterUtils {
  SmartRouterUtils._();

  static final Map<String, DateTime> _routeHistory = {};
  static final Map<String, int> _routeCounter = {};

  /// 生成唯一的路由Key
  /// 
  /// [routePath] 路由路径
  /// [params] 路由参数
  /// [source] 来源信息，用于调试
  static String generateUniqueKey(
    String routePath, {
    Map<String, String>? params,
    String? source,
  }) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final microTimestamp = now.microsecondsSinceEpoch; // 更精确的时间戳
    
    // 构建基础key
    String baseKey = routePath.replaceAll('/', '_').replaceAll(':', '');
    
    // 添加参数信息
    if (params != null && params.isNotEmpty) {
      final paramStr = params.entries
          .map((e) => '${e.key}_${e.value}')
          .join('_');
      baseKey += '_$paramStr';
    }
    
    // 添加来源信息
    if (source != null) {
      baseKey += '_from_$source';
    }
    
    // 更新计数器
    _routeCounter[baseKey] = (_routeCounter[baseKey] ?? 0) + 1;
    
    // 生成更唯一的key（使用微秒时间戳 + 随机数）
    final randomSuffix = (timestamp % 10000) + (microTimestamp % 1000);
    final uniqueKey = '${baseKey}_${microTimestamp}_${_routeCounter[baseKey]}_$randomSuffix';
    
    // 记录路由历史
    _routeHistory[uniqueKey] = now;
    
    // 检查重复（调试用）
    final existingKeys = _routeHistory.keys.where((k) => k.startsWith(baseKey)).toList();
    if (existingKeys.length > 1) {
      debugPrint('SmartRouter: 检测到相似key: $existingKeys');
    }
    
    debugPrint('SmartRouter: 生成key: $uniqueKey');
    
    return uniqueKey;
  }

  /// 智能导航 - 检测并防止循环跳转
  /// 
  /// [context] BuildContext
  /// [routePath] 目标路由路径
  /// [params] 路由参数
  /// [extra] 额外数据
  /// [source] 来源页面标识
  static void smartNavigate(
    BuildContext context,
    String routePath, {
    Map<String, String>? params,
    Object? extra,
    String? source,
  }) {
    // 检查context是否有效
    if (!context.mounted) {
      debugPrint('SmartRouter: Context未挂载，取消导航');
      return;
    }
    
    // 检查当前位置，避免重复跳转
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration;
    if (currentRoute.matches.isNotEmpty) {
      final currentPath = currentRoute.matches.last.matchedLocation;
      final targetPath = _buildFullPath(routePath, params);
      
      if (currentPath == targetPath) {
        debugPrint('SmartRouter: 避免重复跳转到相同路由 $targetPath');
        return;
      }
    }

    // 构建完整路径
    String fullPath = _buildFullPath(routePath, params);
    
    // 生成唯一key用于日志
    final uniqueKey = generateUniqueKey(routePath, params: params, source: source);
    
    debugPrint('SmartRouter: 导航到 $fullPath (key: $uniqueKey, source: $source)');
    
    // 添加短暂延迟，避免在页面构建过程中导航
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        debugPrint('SmartRouter: PostFrame时Context已销毁，取消导航');
        return;
      }
      
      try {
        if (extra != null) {
          GoRouter.of(context).push(fullPath, extra: extra);
        } else {
          GoRouter.of(context).push(fullPath);
        }
      } catch (e) {
        debugPrint('SmartRouter: 导航失败 $e');
        // 如果push失败，尝试go
        try {
          if (extra != null) {
            GoRouter.of(context).go(fullPath, extra: extra);
          } else {
            GoRouter.of(context).go(fullPath);
          }
        } catch (e2) {
          debugPrint('SmartRouter: 备用导航也失败 $e2');
        }
      }
    });
  }

  /// 构建完整路径
  static String _buildFullPath(String routePath, Map<String, String>? params) {
    if (params == null || params.isEmpty) {
      return routePath;
    }
    
    String result = routePath;
    for (final entry in params.entries) {
      result = result.replaceAll(':${entry.key}', entry.value);
    }
    return result;
  }

  /// 清理过期的路由历史记录
  static void cleanupRouteHistory() {
    final now = DateTime.now();
    final expiredKeys = _routeHistory.entries
        .where((entry) => now.difference(entry.value).inMinutes > 30)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _routeHistory.remove(key);
    }
  }

  /// 获取路由历史统计
  static Map<String, dynamic> getRouteStats() {
    return {
      'total_routes': _routeHistory.length,
      'route_counter': Map.from(_routeCounter),
      'recent_routes': _routeHistory.entries
          .where((entry) => DateTime.now().difference(entry.value).inMinutes < 5)
          .map((entry) => {
            'key': entry.key,
            'time': entry.value.toIso8601String(),
          })
          .toList(),
    };
  }
}

/// 创建页面的扩展方法，自动生成唯一Key
extension SmartPageBuilder on GoRouterState {
  /// 创建带唯一Key的MaterialPage
  MaterialPage<T> buildSmartPage<T extends Object?>(
    Widget child, {
    String? name,
    String? source,
    Object? arguments,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    // 添加额外的上下文信息确保唯一性
    final contextInfo = '${name ?? 'page'}_${hashCode}_${DateTime.now().microsecondsSinceEpoch % 100000}';
    final finalSource = source ?? name ?? contextInfo;
    
    final uniqueKey = SmartRouterUtils.generateUniqueKey(
      matchedLocation,
      params: pathParameters,
      source: finalSource,
    );
    
    debugPrint('SmartPage: 创建页面 $matchedLocation with key: $uniqueKey');
    
    return MaterialPage<T>(
      key: ValueKey(uniqueKey),
      child: child,
      name: name,
      arguments: arguments,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
} 