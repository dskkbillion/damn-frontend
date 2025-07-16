/// 缓存淘汰策略
enum CacheEvictionPolicy {
  /// 最近最少使用
  lru,
  /// 先进先出
  fifo,
  /// 最少访问
  lfu,
}

/// 分组配置
class GroupConfig {
  /// 最大项数
  final int? maxItems;
  
  /// 默认TTL
  final Duration? defaultTTL;
  
  /// 是否持久化
  final bool? persistent;
  
  /// 最大缓存大小（字节）
  final int? maxSizeBytes;

  const GroupConfig({
    this.maxItems,
    this.defaultTTL,
    this.persistent,
    this.maxSizeBytes,
  });
}

/// 缓存配置
class CacheConfig {
  // === 内存缓存配置 ===
  
  /// 最大内存占用（字节）
  final int maxMemorySize;
  
  /// 每组最大项数（默认值）
  final int maxItemsPerGroup;
  
  /// 默认过期时间
  final Duration defaultTTL;
  
  /// 清理间隔
  final Duration cleanupInterval;
  
  // === HTTP缓存配置 ===
  
  /// 是否启用HTTP缓存
  final bool enableHttpCache;
  
  /// HTTP缓存大小
  final int maxHttpCacheSize;
  
  /// HTTP缓存时长
  final Duration httpCacheDuration;
  
  // === 策略配置 ===
  
  /// 淘汰策略
  final CacheEvictionPolicy evictionPolicy;
  
  /// 是否启用统计
  final bool enableStats;
  
  /// 是否启用日志
  final bool enableLogging;
  
  // === 分组配置 ===
  
  /// 各组特定配置
  final Map<String, GroupConfig> groupConfigs;

  const CacheConfig({
    this.maxMemorySize = 50 * 1024 * 1024, // 50MB
    this.maxItemsPerGroup = 100,
    this.defaultTTL = const Duration(minutes: 30),
    this.cleanupInterval = const Duration(minutes: 5),
    this.enableHttpCache = true,
    this.maxHttpCacheSize = 100 * 1024 * 1024, // 100MB
    this.httpCacheDuration = const Duration(hours: 1),
    this.evictionPolicy = CacheEvictionPolicy.lru,
    this.enableStats = true,
    this.enableLogging = false, // 生产环境建议关闭
    this.groupConfigs = const {},
  });
  
  /// 创建一个修改后的配置副本
  CacheConfig copyWith({
    int? maxMemorySize,
    int? maxItemsPerGroup,
    Duration? defaultTTL,
    Duration? cleanupInterval,
    bool? enableHttpCache,
    int? maxHttpCacheSize,
    Duration? httpCacheDuration,
    CacheEvictionPolicy? evictionPolicy,
    bool? enableStats,
    bool? enableLogging,
    Map<String, GroupConfig>? groupConfigs,
  }) {
    return CacheConfig(
      maxMemorySize: maxMemorySize ?? this.maxMemorySize,
      maxItemsPerGroup: maxItemsPerGroup ?? this.maxItemsPerGroup,
      defaultTTL: defaultTTL ?? this.defaultTTL,
      cleanupInterval: cleanupInterval ?? this.cleanupInterval,
      enableHttpCache: enableHttpCache ?? this.enableHttpCache,
      maxHttpCacheSize: maxHttpCacheSize ?? this.maxHttpCacheSize,
      httpCacheDuration: httpCacheDuration ?? this.httpCacheDuration,
      evictionPolicy: evictionPolicy ?? this.evictionPolicy,
      enableStats: enableStats ?? this.enableStats,
      enableLogging: enableLogging ?? this.enableLogging,
      groupConfigs: groupConfigs ?? this.groupConfigs,
    );
  }
}