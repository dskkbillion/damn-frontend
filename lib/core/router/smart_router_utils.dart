import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

/// 智能路由工具类 - 简化版本
/// 
/// 提供统一的路由管理功能，包括：
/// - 稳定的Key生成策略，避免Navigator重复Key错误
/// - 防止快速重复点击
/// - 跨模块路由统一管理
class SmartRouterUtils {
  SmartRouterUtils._();

  static final Map<String, DateTime> _navigationCooldown = {}; 
  static final Random _random = Random();

  /// 生成简洁且唯一的路由Key
  /// 
  /// 核心思路：使用路径+参数的哈希值，而不是复杂的时间戳
  /// [routePath] 路由路径
  /// [params] 路由参数
  /// [source] 来源信息，用于调试
  static String generateUniqueKey(
    String routePath, {
    Map<String, String>? params,
    String? source,
  }) {
    // 构建基础路径标识符
    String baseKey = routePath.replaceAll('/', '_').replaceAll(':', '');
    
    // 添加参数信息
    if (params != null && params.isNotEmpty) {
      final paramStr = params.entries
          .map((e) => '${e.key}_${e.value}')
          .join('_');
      baseKey += '_$paramStr';
    }
    
    // 使用路径+参数的稳定哈希，而不是随机数
    final pathHash = '${routePath}_${params?.toString() ?? ''}'.hashCode.abs();
    
    // 添加少量随机性防止极端情况下的冲突
    final minorRandom = _random.nextInt(999);
    
    final finalKey = '${baseKey}_h${pathHash}_r${minorRandom}';
    
    debugPrint('SmartRouter: 生成简洁key: $finalKey (路径: $routePath)');
    
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

/// 页面构建器扩展 - 简化版本
extension SmartPageBuilder on GoRouterState {
  /// 创建页面，使用简洁的key策略
  MaterialPage<T> buildSmartPage<T extends Object?>(
    Widget child, {
    String? name,
    String? source,
    Object? arguments,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    // 使用路径和参数的稳定哈希作为key
    // 这避免了Go Router多次调用pageBuilder时产生不同key的问题
    final pathWithParams = '${matchedLocation}_${pathParameters.toString()}';
    final stableHash = pathWithParams.hashCode.abs();
    
    // 只在真正需要区分的时候添加来源信息
    final keySource = source ?? name ?? 'page';
    final finalKey = 'page_${stableHash}_${keySource}';
    
    debugPrint('SmartPage: 创建页面 $matchedLocation (key: $finalKey)');
    
    return MaterialPage<T>(
      key: ValueKey(finalKey),
      child: child,
      name: name,
      arguments: arguments,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
} 