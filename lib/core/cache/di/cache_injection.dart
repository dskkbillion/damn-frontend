import 'package:get_it/get_it.dart';

import '../domain/entities/cache_config.dart';
import '../domain/entities/cache_groups.dart';
import '../domain/interfaces/i_cache_manager.dart';
import '../domain/interfaces/i_memory_cache.dart';
import '../data/memory_cache_impl.dart';
import '../data/cache_manager_impl.dart';

/// 缓存模块依赖注入
class CacheInjection {
  static void init(GetIt sl) {
    // 注册缓存配置
    sl.registerSingleton<CacheConfig>(
      _createDefaultConfig(),
    );
    
    // 注册内存缓存
    sl.registerSingleton<IMemoryCache>(
      MemoryCacheImpl(config: sl<CacheConfig>()),
    );
    
    // 注册缓存管理器
    sl.registerSingleton<ICacheManager>(
      CacheManagerImpl(
        memoryCache: sl<IMemoryCache>(),
        config: sl<CacheConfig>(),
      ),
    );
  }
  
  /// 创建默认配置
  static CacheConfig _createDefaultConfig() {
    return const CacheConfig(
      maxMemorySize: 50 * 1024 * 1024,  // 50MB
      maxItemsPerGroup: 100,
      defaultTTL: Duration(minutes: 30),
      cleanupInterval: Duration(minutes: 5),
      enableHttpCache: true,
      maxHttpCacheSize: 100 * 1024 * 1024,  // 100MB
      httpCacheDuration: Duration(hours: 1),
      evictionPolicy: CacheEvictionPolicy.lru,
      enableStats: true,
      enableLogging: false, // 生产环境建议关闭
      groupConfigs: {
        // 用户相关缓存配置
        CacheGroups.user: GroupConfig(
          defaultTTL: Duration(hours: 2),
          maxItems: 50,
          persistent: false,
        ),
        
        // 商品缓存配置
        CacheGroups.product: GroupConfig(
          maxItems: 200,
          defaultTTL: Duration(minutes: 15),
          maxSizeBytes: 10 * 1024 * 1024, // 10MB
        ),
        
        // 分类缓存配置（长时间缓存）
        CacheGroups.category: GroupConfig(
          defaultTTL: Duration(hours: 24),
          persistent: true,
          maxItems: 50,
        ),
        
        // 搜索结果缓存（短时间）
        CacheGroups.search: GroupConfig(
          defaultTTL: Duration(minutes: 5),
          maxItems: 30,
        ),
        
        // 配置缓存（长时间）
        CacheGroups.config: GroupConfig(
          defaultTTL: Duration(hours: 12),
          persistent: true,
        ),
        
        // 临时缓存（短时间）
        CacheGroups.temporary: GroupConfig(
          defaultTTL: Duration(minutes: 5),
          maxItems: 20,
        ),
        
        // HTTP响应缓存
        CacheGroups.http: GroupConfig(
          defaultTTL: Duration(minutes: 10),
          maxItems: 100,
          maxSizeBytes: 20 * 1024 * 1024, // 20MB
        ),
        
        // AI相关缓存
        CacheGroups.ai: GroupConfig(
          defaultTTL: Duration(minutes: 2),
          maxItems: 20,
        ),
      },
    );
  }
}