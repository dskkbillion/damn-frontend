import '../entities/cache_entry.dart';
import '../entities/cache_stats.dart';

/// 内存缓存接口
/// 
/// 专门处理内存中的缓存操作
abstract class IMemoryCache {
  /// 获取缓存项
  CacheEntry<T>? getEntry<T>(String key, String group);
  
  /// 设置缓存项
  void setEntry<T>(String key, String group, CacheEntry<T> entry);
  
  /// 删除缓存项
  void removeEntry(String key, String group);
  
  /// 获取组内所有键
  List<String> getGroupKeys(String group);
  
  /// 获取组内所有缓存项
  Map<String, CacheEntry> getGroupEntries(String group);
  
  /// 清空指定组
  void clearGroup(String group);
  
  /// 清空所有缓存
  void clearAll();
  
  /// 获取组统计信息
  CacheStats? getGroupStats(String group);
  
  /// 获取所有统计信息
  Map<String, CacheStats> getAllStats();
  
  /// 获取当前总大小
  int getTotalSize();
  
  /// 获取组大小
  int getGroupSize(String group);
  
  /// 执行淘汰策略
  void evict(String group);
  
  /// 清理过期项
  void cleanupExpired();
}