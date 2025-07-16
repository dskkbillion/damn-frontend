import '../entities/cache_config.dart';
import '../entities/cache_stats.dart';

/// 缓存管理器接口
/// 
/// 提供统一的缓存管理功能，包括内存缓存、持久化缓存等
abstract class ICacheManager {
  // === 基础操作 ===
  
  /// 获取缓存值
  /// 
  /// [key] 缓存键
  /// [group] 缓存组，默认为 'default'
  /// 
  /// 返回缓存的值，如果不存在或已过期则返回 null
  Future<T?> get<T>(String key, {String? group});
  
  /// 设置缓存值
  /// 
  /// [key] 缓存键
  /// [value] 要缓存的值
  /// [group] 缓存组
  /// [ttl] 生存时间，如果不指定则使用配置的默认值
  Future<void> set<T>(String key, T value, {String? group, Duration? ttl});
  
  /// 删除指定缓存
  Future<void> remove(String key, {String? group});
  
  /// 检查缓存是否存在
  Future<bool> contains(String key, {String? group});
  
  // === 批量操作 ===
  
  /// 批量获取缓存
  Future<Map<String, T>> getMultiple<T>(List<String> keys, {String? group});
  
  /// 批量设置缓存
  Future<void> setMultiple<T>(Map<String, T> entries, {String? group, Duration? ttl});
  
  /// 批量删除缓存
  Future<void> removeMultiple(List<String> keys, {String? group});
  
  // === 清理操作 ===
  
  /// 清空指定组的缓存
  Future<void> clearGroup(String group);
  
  /// 清空所有缓存
  Future<void> clearAll();
  
  /// 清理过期缓存
  Future<void> clearExpired();
  
  /// 清理用户相关的缓存（用于登出等场景）
  Future<void> clearUserRelatedCache();
  
  // === 统计信息 ===
  
  /// 获取缓存统计信息
  /// 
  /// [group] 如果指定，只返回该组的统计信息
  CacheStats getStats({String? group});
  
  /// 获取所有组的统计信息
  Map<String, CacheStats> getAllStats();
  
  /// 获取当前缓存大小（字节）
  int getCurrentSize();
  
  /// 获取缓存大小信息
  Map<String, dynamic> getSizeInfo();
  
  // === 配置管理 ===
  
  /// 更新缓存配置
  void updateConfig(CacheConfig config);
  
  /// 获取当前配置
  CacheConfig getConfig();
  
  // === 生命周期 ===
  
  /// 初始化缓存管理器
  Future<void> initialize();
  
  /// 释放资源
  void dispose();
}