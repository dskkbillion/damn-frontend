import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 智能路由工具类 - 基础稳定版本
/// 
/// 提供统一的路由管理功能，包括：
/// - 基础稳定的Key生成策略，避免Navigator重复Key错误
/// - 防止快速重复点击
/// - 跨模块路由统一管理
class SmartRouterUtils {
  SmartRouterUtils._();

  static final Map<String, DateTime> _navigationCooldown = {};

  /// 生成基础稳定的路由Key
  /// 
  /// 核心思路：使用路径+时间戳保证唯一性，避免重复key错误
  /// [routePath] 路由路径
  /// [params] 路由参数
  /// [source] 来源信息，用于调试
  static String generateUniqueKey(
    String routePath, {
    Map<String, String>? params,
    String? source,
  }) {
    // 使用路径+参数+时间戳作为key，确保唯一性
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pathWithParams = '${routePath}_${params?.toString() ?? ''}_$timestamp';
    final finalKey = pathWithParams
        .replaceAll('/', '_')
        .replaceAll(':', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll(' ', '')
        .replaceAll(',', '_');
    
    debugPrint('SmartRouter: 生成唯一key: $finalKey (路径: $routePath)');
    
    return finalKey;
  }

  /// 智能导航 - 简化版本，只防止真正的重复
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
    if (!context.mounted) {
      debugPrint('SmartRouter: Context未挂载，取消导航');
      return;
    }

    String fullPath = _buildFullPath(routePath, params);
    
    // 只防止真正的快速重复点击（200ms内）
    final cooldownKey = '${fullPath}_${source ?? 'unknown'}';
    final now = DateTime.now();
    final lastNavigation = _navigationCooldown[cooldownKey];
    
    if (lastNavigation != null && 
        now.difference(lastNavigation).inMilliseconds < 200) { // 只防止200ms内的重复
      debugPrint('SmartRouter: 防止快速重复点击 $fullPath');
      return;
    }
    
    _navigationCooldown[cooldownKey] = now;
    
    // 检查当前位置
    final currentRoute = GoRouter.of(context).routerDelegate.currentConfiguration;
    if (currentRoute.matches.isNotEmpty) {
      final currentPath = currentRoute.matches.last.matchedLocation;
      if (currentPath == fullPath) {
        debugPrint('SmartRouter: 已在目标路由 $fullPath');
        return;
      }
    }
    
    debugPrint('SmartRouter: 导航到 $fullPath (来源: $source)');
    
    try {
      if (extra != null) {
        GoRouter.of(context).push(fullPath, extra: extra);
      } else {
        GoRouter.of(context).push(fullPath);
      }
      debugPrint('SmartRouter: 导航成功 $fullPath');
    } catch (e) {
      debugPrint('SmartRouter: 导航失败 $e');
    }
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

  /// 清理过期的冷却记录
  static void cleanupRouteHistory() {
    final now = DateTime.now();
    final expiredKeys = _navigationCooldown.entries
        .where((entry) => now.difference(entry.value).inMinutes > 5)
        .map((entry) => entry.key)
        .toList();
        
    for (final key in expiredKeys) {
      _navigationCooldown.remove(key);
    }
  }

  /// 获取路由统计
  static Map<String, dynamic> getRouteStats() {
    return {
      'navigation_cooldowns': _navigationCooldown.length,
      'active_cooldowns': _navigationCooldown.entries
          .where((entry) => DateTime.now().difference(entry.value).inSeconds < 60)
          .map((entry) => {
            'path': entry.key,
            'time': entry.value.toIso8601String(),
          })
          .toList(),
    };
  }

  /// 强制重置导航状态（紧急情况使用）
  static void forceResetNavigationState() {
    _navigationCooldown.clear();
    debugPrint('SmartRouter: 强制重置导航状态');
  }
}

/// 页面构建器扩展 - 基础稳定版本
extension SmartPageBuilder on GoRouterState {
  /// 创建页面，使用稳定key策略确保正确的页面导航动画
  MaterialPage<T> buildSmartPage<T extends Object?>(
    Widget child, {
    String? name,
    String? source,
    Object? arguments,
    bool maintainState = true,
    bool fullscreenDialog = false,
    bool forceNewInstance = false, // 新增参数：是否强制创建新实例
  }) {
    String finalKey;

    if (forceNewInstance) {
      // 只有明确需要强制创建新实例时才使用时间戳
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      finalKey = '${matchedLocation}_${pathParameters.toString()}_${uri.queryParameters.toString()}_$timestamp';
    } else {
      // 正常情况下使用稳定的key，让Flutter能正确识别和缓存页面
      finalKey = '${matchedLocation}_${pathParameters.toString()}_${uri.queryParameters.toString()}';
    }

    final cleanKey = finalKey
        .replaceAll('/', '_')
        .replaceAll(':', '')
        .replaceAll('{', '')
        .replaceAll('}', '')
        .replaceAll(' ', '')
        .replaceAll(',', '_')
        .replaceAll('?', '_')
        .replaceAll('=', '_')
        .replaceAll('&', '_');

    debugPrint('SmartPage: 创建页面 $matchedLocation (key: $cleanKey, forceNew: $forceNewInstance)');

    return MaterialPage<T>(
      key: ValueKey(cleanKey),
      child: child,
      name: name,
      arguments: arguments,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
} 