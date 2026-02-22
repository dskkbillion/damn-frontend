import '../domain/interfaces/i_cache_manager.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import '../domain/interfaces/i_memory_cache.dart';
import '../domain/entities/cache_config.dart';
import '../domain/entities/cache_stats.dart';
import '../domain/entities/cache_entry.dart';
import '../domain/entities/cache_groups.dart';
import '../utils/size_estimator.dart';
import 'memory_cache_impl.dart';

/// 缓存管理器实现
/// 
/// 提供统一的缓存管理接口，协调内存缓存和持久化缓存
class CacheManagerImpl implements ICacheManager {
  /// 内存缓存
  final IMemoryCache memoryCache;
  
  /// 缓存配置
  CacheConfig _config;
  
  /// 是否已初始化
  bool _initialized = false;

  CacheManagerImpl({
    required this.memoryCache,
    required CacheConfig config,
  }) : _config = config;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    
    // 初始化内存缓存
    // 未来可以在这里初始化持久化缓存等
    
    _initialized = true;
    
    if (_config.enableLogging) {
      AppLogger.d('[CacheManager] 初始化完成');
    }
  }

  @override
  Future<T?> get<T>(String key, {String? group}) async {
    final groupName = group ?? 'default';
    
    // 先尝试从内存缓存获取
    final entry = memoryCache.getEntry<T>(key, groupName);
    if (entry != null) {
      return entry.value;
    }
    
    // 未来可以从持久化缓存获取
    
    return null;
  }

  @override
  Future<void> set<T>(String key, T value, {String? group, Duration? ttl}) async {
    final groupName = group ?? 'default';
    final groupConfig = _config.groupConfigs[groupName];
    
    // 确定TTL
    Duration? finalTTL = ttl;
    finalTTL ??= groupConfig?.defaultTTL;
    finalTTL ??= _config.defaultTTL;
    
    // 创建缓存项
    final entry = CacheEntry<T>(
      value: value,
      createTime: DateTime.now(),
      ttl: finalTTL,
      sizeInBytes: SizeEstimator.estimate(value),
    );
    
    // 存入内存缓存
    memoryCache.setEntry(key, groupName, entry);
    
    // 如果配置为持久化，未来可以存入持久化缓存
    if (groupConfig?.persistent == true) {
      // TODO: 存入持久化缓存
    }
  }

  @override
  Future<void> remove(String key, {String? group}) async {
    final groupName = group ?? 'default';
    
    // 从内存缓存删除
    memoryCache.removeEntry(key, groupName);
    
    // 未来也从持久化缓存删除
  }

  @override
  Future<bool> contains(String key, {String? group}) async {
    final groupName = group ?? 'default';
    
    // 检查内存缓存
    final entry = memoryCache.getEntry(key, groupName);
    if (entry != null) return true;
    
    // 未来检查持久化缓存
    
    return false;
  }

  @override
  Future<Map<String, T>> getMultiple<T>(List<String> keys, {String? group}) async {
    final groupName = group ?? 'default';
    final result = <String, T>{};
    
    for (final key in keys) {
      final value = await get<T>(key, group: groupName);
      if (value != null) {
        result[key] = value;
      }
    }
    
    return result;
  }

  @override
  Future<void> setMultiple<T>(Map<String, T> entries, {String? group, Duration? ttl}) async {
    for (final entry in entries.entries) {
      await set(entry.key, entry.value, group: group, ttl: ttl);
    }
  }

  @override
  Future<void> removeMultiple(List<String> keys, {String? group}) async {
    for (final key in keys) {
      await remove(key, group: group);
    }
  }

  @override
  Future<void> clearGroup(String group) async {
    // 清空内存缓存
    memoryCache.clearGroup(group);
    
    // 未来清空持久化缓存
    
    if (_config.enableLogging) {
      AppLogger.d('[CacheManager] 清空缓存组: $group');
    }
  }

  @override
  Future<void> clearAll() async {
    // 清空所有内存缓存
    memoryCache.clearAll();
    
    // 未来清空所有持久化缓存
    
    if (_config.enableLogging) {
      AppLogger.d('[CacheManager] 清空所有缓存');
    }
  }

  @override
  Future<void> clearExpired() async {
    // 清理内存缓存中的过期项
    memoryCache.cleanupExpired();
    
    // 未来清理持久化缓存中的过期项
  }

  @override
  Future<void> clearUserRelatedCache() async {
    // 清理用户相关的缓存组
    for (final group in CacheGroups.userRelatedGroups) {
      await clearGroup(group);
    }
    
    if (_config.enableLogging) {
      AppLogger.d('[CacheManager] 清理用户相关缓存完成');
    }
  }

  @override
  CacheStats getStats({String? group}) {
    if (group != null) {
      return memoryCache.getGroupStats(group) ?? CacheStats();
    }
    
    // 合并所有组的统计
    final allStats = memoryCache.getAllStats();
    final combined = CacheStats();
    
    for (final stats in allStats.values) {
      combined.hitCount += stats.hitCount;
      combined.missCount += stats.missCount;
      combined.evictionCount += stats.evictionCount;
      combined.itemCount += stats.itemCount;
      combined.sizeInBytes += stats.sizeInBytes;
    }
    
    return combined;
  }

  @override
  Map<String, CacheStats> getAllStats() {
    return memoryCache.getAllStats();
  }

  @override
  int getCurrentSize() {
    return memoryCache.getTotalSize();
  }

  @override
  Map<String, dynamic> getSizeInfo() {
    final currentSize = getCurrentSize();
    final stats = getAllStats();
    
    return {
      'currentSizeBytes': currentSize,
      'currentSizeMB': SizeEstimator.formatSize(currentSize),
      'maxSizeMB': SizeEstimator.formatSize(_config.maxMemorySize),
      'usagePercent': '${((currentSize / _config.maxMemorySize) * 100).toStringAsFixed(2)}%',
      'groupCount': stats.length,
      'totalItems': stats.values.fold<int>(0, (sum, s) => sum + s.itemCount),
    };
  }

  @override
  void updateConfig(CacheConfig config) {
    _config = config;
    
    // 如果是内存缓存实现，可能需要更新其配置
    // 例如重新设置清理定时器等
    
    if (_config.enableLogging) {
      AppLogger.d('[CacheManager] 配置已更新');
    }
  }

  @override
  CacheConfig getConfig() {
    return _config;
  }

  @override
  void dispose() {
    // 释放内存缓存资源
    if (memoryCache is MemoryCacheImpl) {
      (memoryCache as MemoryCacheImpl).dispose();
    }
    
    _initialized = false;
  }
}