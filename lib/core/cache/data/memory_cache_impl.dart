import 'dart:async';
import 'package:collection/collection.dart';

import '../domain/interfaces/i_memory_cache.dart';
import '../domain/entities/cache_entry.dart';
import '../domain/entities/cache_stats.dart';
import '../domain/entities/cache_config.dart';
import '../utils/size_estimator.dart';

/// 内存缓存实现
class MemoryCacheImpl implements IMemoryCache {
  /// 缓存配置
  final CacheConfig config;
  
  /// 缓存存储，按组分类
  final Map<String, Map<String, CacheEntry>> _cacheGroups = {};
  
  /// 每组的统计信息
  final Map<String, CacheStats> _groupStats = {};
  
  /// 清理定时器
  Timer? _cleanupTimer;
  
  /// 当前总大小（字节）
  int _totalSizeBytes = 0;

  MemoryCacheImpl({required this.config}) {
    // 启动定期清理
    _startCleanupTimer();
  }

  @override
  CacheEntry<T>? getEntry<T>(String key, String group) {
    final groupCache = _cacheGroups[group];
    if (groupCache == null) {
      _recordMiss(group);
      return null;
    }

    final entry = groupCache[key];
    if (entry == null) {
      _recordMiss(group);
      return null;
    }

    // 检查是否过期
    if (entry.isExpired) {
      removeEntry(key, group);
      _recordMiss(group);
      return null;
    }

    // 记录访问
    entry.access();
    _recordHit(group);
    
    try {
      return entry as CacheEntry<T>;
    } catch (e) {
      if (config.enableLogging) {
        print('[MemoryCache] 类型转换错误: $e');
      }
      removeEntry(key, group);
      return null;
    }
  }

  @override
  void setEntry<T>(String key, String group, CacheEntry<T> entry) {
    // 确保组存在
    _cacheGroups[group] ??= {};
    _groupStats[group] ??= CacheStats();

    final groupCache = _cacheGroups[group]!;
    final groupConfig = config.groupConfigs[group];
    
    // 估算大小
    final estimatedSize = entry.sizeInBytes ?? SizeEstimator.estimate(entry.value);
    
    // 检查总体大小限制
    if (_totalSizeBytes + estimatedSize > config.maxMemorySize) {
      _evictGlobal();
    }
    
    // 检查组大小限制
    if (groupConfig?.maxSizeBytes != null) {
      final currentGroupSize = getGroupSize(group);
      if (currentGroupSize + estimatedSize > groupConfig!.maxSizeBytes!) {
        evict(group);
      }
    }
    
    // 检查组内数量限制
    final maxItems = groupConfig?.maxItems ?? config.maxItemsPerGroup;
    if (groupCache.length >= maxItems) {
      evict(group);
    }

    // 如果已存在，先移除旧的
    final oldEntry = groupCache[key];
    if (oldEntry != null) {
      _totalSizeBytes -= oldEntry.sizeInBytes ?? SizeEstimator.estimate(oldEntry.value);
    }

    // 添加新的
    groupCache[key] = entry;
    _totalSizeBytes += estimatedSize;
    
    // 更新统计
    _updateStats(group);
  }

  @override
  void removeEntry(String key, String group) {
    final groupCache = _cacheGroups[group];
    if (groupCache != null) {
      final entry = groupCache.remove(key);
      if (entry != null) {
        final size = entry.sizeInBytes ?? SizeEstimator.estimate(entry.value);
        _totalSizeBytes -= size;
        _updateStats(group);
      }
    }
  }

  @override
  List<String> getGroupKeys(String group) {
    return _cacheGroups[group]?.keys.toList() ?? [];
  }

  @override
  Map<String, CacheEntry> getGroupEntries(String group) {
    return Map.from(_cacheGroups[group] ?? {});
  }

  @override
  void clearGroup(String group) {
    final groupCache = _cacheGroups[group];
    if (groupCache != null) {
      // 计算要清理的大小
      int clearedSize = 0;
      for (final entry in groupCache.values) {
        clearedSize += entry.sizeInBytes ?? SizeEstimator.estimate(entry.value);
      }
      
      groupCache.clear();
      _totalSizeBytes -= clearedSize;
      
      // 重置组统计
      _groupStats[group] = CacheStats();
      _updateStats(group);
    }
  }

  @override
  void clearAll() {
    _cacheGroups.clear();
    _groupStats.clear();
    _totalSizeBytes = 0;
  }

  @override
  CacheStats? getGroupStats(String group) {
    return _groupStats[group];
  }

  @override
  Map<String, CacheStats> getAllStats() {
    return Map.from(_groupStats);
  }

  @override
  int getTotalSize() {
    return _totalSizeBytes;
  }

  @override
  int getGroupSize(String group) {
    final groupCache = _cacheGroups[group];
    if (groupCache == null) return 0;
    
    int size = 0;
    for (final entry in groupCache.values) {
      size += entry.sizeInBytes ?? SizeEstimator.estimate(entry.value);
    }
    return size;
  }

  @override
  void evict(String group) {
    final groupCache = _cacheGroups[group];
    if (groupCache == null || groupCache.isEmpty) return;
    
    // 根据配置的淘汰策略执行
    switch (config.evictionPolicy) {
      case CacheEvictionPolicy.lru:
        _evictLRU(group);
        break;
      case CacheEvictionPolicy.fifo:
        _evictFIFO(group);
        break;
      case CacheEvictionPolicy.lfu:
        _evictLFU(group);
        break;
    }
  }

  @override
  void cleanupExpired() {
    for (final group in _cacheGroups.keys) {
      final groupCache = _cacheGroups[group]!;
      final expiredKeys = <String>[];
      
      groupCache.forEach((key, entry) {
        if (entry.isExpired) {
          expiredKeys.add(key);
        }
      });
      
      for (final key in expiredKeys) {
        removeEntry(key, group);
      }
    }
    
    if (config.enableLogging) {
      print('[MemoryCache] 清理过期缓存完成');
    }
  }

  /// 释放资源
  void dispose() {
    _cleanupTimer?.cancel();
    clearAll();
  }

  // === 私有方法 ===

  /// 启动清理定时器
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(config.cleanupInterval, (_) {
      cleanupExpired();
    });
  }

  /// 记录命中
  void _recordHit(String group) {
    _groupStats[group] ??= CacheStats();
    _groupStats[group]!.recordHit();
  }

  /// 记录未命中
  void _recordMiss(String group) {
    _groupStats[group] ??= CacheStats();
    _groupStats[group]!.recordMiss();
  }

  /// 更新统计信息
  void _updateStats(String group) {
    final stats = _groupStats[group] ?? CacheStats();
    final groupCache = _cacheGroups[group] ?? {};
    
    stats.updateItemCount(groupCache.length);
    stats.updateSize(getGroupSize(group));
  }

  /// LRU淘汰
  void _evictLRU(String group) {
    final groupCache = _cacheGroups[group]!;
    if (groupCache.isEmpty) return;
    
    // 找到最久未访问的项
    String? lruKey;
    CacheEntry? lruEntry;
    
    groupCache.forEach((key, entry) {
      if (lruEntry == null || entry.lastAccessTime.isBefore(lruEntry!.lastAccessTime)) {
        lruKey = key;
        lruEntry = entry;
      }
    });
    
    if (lruKey != null) {
      removeEntry(lruKey!, group);
      _groupStats[group]?.recordEviction();
      
      if (config.enableLogging) {
        print('[MemoryCache] LRU淘汰: $group:$lruKey');
      }
    }
  }

  /// FIFO淘汰
  void _evictFIFO(String group) {
    final groupCache = _cacheGroups[group]!;
    if (groupCache.isEmpty) return;
    
    // 找到最早创建的项
    String? oldestKey;
    CacheEntry? oldestEntry;
    
    groupCache.forEach((key, entry) {
      if (oldestEntry == null || entry.createTime.isBefore(oldestEntry!.createTime)) {
        oldestKey = key;
        oldestEntry = entry;
      }
    });
    
    if (oldestKey != null) {
      removeEntry(oldestKey!, group);
      _groupStats[group]?.recordEviction();
    }
  }

  /// LFU淘汰
  void _evictLFU(String group) {
    final groupCache = _cacheGroups[group]!;
    if (groupCache.isEmpty) return;
    
    // 找到访问次数最少的项
    String? lfuKey;
    CacheEntry? lfuEntry;
    
    groupCache.forEach((key, entry) {
      if (lfuEntry == null || entry.accessCount < lfuEntry!.accessCount) {
        lfuKey = key;
        lfuEntry = entry;
      }
    });
    
    if (lfuKey != null) {
      removeEntry(lfuKey!, group);
      _groupStats[group]?.recordEviction();
    }
  }

  /// 全局淘汰（跨组）
  void _evictGlobal() {
    // 找到所有组中最适合淘汰的项
    String? targetGroup;
    String? targetKey;
    CacheEntry? targetEntry;
    
    _cacheGroups.forEach((group, groupCache) {
      // 跳过持久化组
      if (config.groupConfigs[group]?.persistent == true) return;
      
      groupCache.forEach((key, entry) {
        // 根据策略选择要淘汰的项
        bool shouldEvict = false;
        
        switch (config.evictionPolicy) {
          case CacheEvictionPolicy.lru:
            shouldEvict = targetEntry == null || 
                entry.lastAccessTime.isBefore(targetEntry!.lastAccessTime);
            break;
          case CacheEvictionPolicy.fifo:
            shouldEvict = targetEntry == null || 
                entry.createTime.isBefore(targetEntry!.createTime);
            break;
          case CacheEvictionPolicy.lfu:
            shouldEvict = targetEntry == null || 
                entry.accessCount < targetEntry!.accessCount;
            break;
        }
        
        if (shouldEvict) {
          targetGroup = group;
          targetKey = key;
          targetEntry = entry;
        }
      });
    });
    
    if (targetGroup != null && targetKey != null) {
      removeEntry(targetKey!, targetGroup!);
      _groupStats[targetGroup]?.recordEviction();
      
      if (config.enableLogging) {
        print('[MemoryCache] 全局淘汰: $targetGroup:$targetKey');
      }
    }
  }
}