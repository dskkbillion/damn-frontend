# 缓存架构设计

## 概述

本文档定义了 DSKK Flutter 应用的缓存系统架构，包括缓存层次、接口设计、配置管理和集成方案。

## 缓存层次结构

```
┌─────────────────────────────────────┐
│         应用层 (Features)            │
├─────────────────────────────────────┤
│       缓存管理器 (Cache Manager)     │
├─────────────────────────────────────┤
│   内存缓存    │   HTTP缓存   │  数据库缓存
│ (MemoryCache) │ (HttpCache)  │ (Database)
└─────────────────────────────────────┘
```

## 目录结构设计

```
lib/core/cache/
├── domain/
│   ├── interfaces/
│   │   ├── i_cache_manager.dart          # 缓存管理器接口
│   │   ├── i_memory_cache.dart           # 内存缓存接口
│   │   ├── i_cache_config.dart           # 缓存配置接口
│   │   └── i_cache_stats.dart            # 缓存统计接口
│   ├── entities/
│   │   ├── cache_entry.dart              # 缓存项实体
│   │   ├── cache_config.dart             # 缓存配置实体
│   │   └── cache_stats.dart              # 缓存统计实体
│   └── policies/
│       ├── cache_policy.dart             # 缓存策略基类
│       ├── lru_policy.dart               # LRU淘汰策略
│       └── ttl_policy.dart               # TTL过期策略
├── data/
│   ├── cache_manager_impl.dart           # 缓存管理器实现
│   ├── memory_cache_impl.dart            # 内存缓存实现
│   └── cache_config_impl.dart            # 缓存配置实现
├── utils/
│   ├── cache_key_builder.dart            # 缓存键构建器
│   ├── size_estimator.dart               # 对象大小估算
│   └── cache_serializer.dart             # 缓存序列化
└── di/
    └── cache_injection.dart               # 缓存模块依赖注入
```

## 核心接口设计

### 1. 缓存管理器接口 (ICacheManager)

```dart
abstract class ICacheManager {
  // 基础操作
  Future<T?> get<T>(String key, {String? group});
  Future<void> set<T>(String key, T value, {String? group, Duration? ttl});
  Future<void> remove(String key, {String? group});
  
  // 批量操作
  Future<Map<String, T>> getMultiple<T>(List<String> keys, {String? group});
  Future<void> setMultiple<T>(Map<String, T> entries, {String? group, Duration? ttl});
  
  // 清理操作
  Future<void> clearGroup(String group);
  Future<void> clearAll();
  Future<void> clearExpired();
  
  // 统计信息
  CacheStats getStats({String? group});
  int getCurrentSize();
  
  // 配置
  void updateConfig(CacheConfig config);
  CacheConfig getConfig();
}
```

### 2. 缓存配置 (CacheConfig)

```dart
class CacheConfig {
  // 内存缓存配置
  final int maxMemorySize;           // 最大内存占用（字节）
  final int maxItemsPerGroup;        // 每组最大项数
  final Duration defaultTTL;         // 默认过期时间
  final Duration cleanupInterval;    // 清理间隔
  
  // HTTP缓存配置
  final bool enableHttpCache;        // 是否启用HTTP缓存
  final int maxHttpCacheSize;        // HTTP缓存大小
  final Duration httpCacheDuration;  // HTTP缓存时长
  
  // 策略配置
  final CacheEvictionPolicy evictionPolicy;  // 淘汰策略
  final bool enableStats;            // 是否启用统计
  
  // 分组配置
  final Map<String, GroupConfig> groupConfigs;  // 各组特定配置
}

class GroupConfig {
  final int? maxItems;
  final Duration? defaultTTL;
  final bool? persistent;  // 是否持久化
}
```

### 3. 缓存组定义

```dart
class CacheGroups {
  static const String user = 'user';              // 用户相关
  static const String product = 'product';        // 商品相关
  static const String category = 'category';      // 分类相关
  static const String order = 'order';           // 订单相关
  static const String chat = 'chat';             // 聊天相关
  static const String search = 'search';         // 搜索相关
  static const String config = 'config';         // 配置相关
  static const String temporary = 'temp';        // 临时数据
}
```

## 集成方案

### 1. 依赖注入配置

在 `lib/core/cache/di/cache_injection.dart`:

```dart
class CacheInjection {
  static void init(GetIt sl) {
    // 注册缓存配置
    sl.registerSingleton<CacheConfig>(
      CacheConfig(
        maxMemorySize: 50 * 1024 * 1024,  // 50MB
        maxItemsPerGroup: 100,
        defaultTTL: Duration(minutes: 30),
        cleanupInterval: Duration(minutes: 5),
        enableHttpCache: true,
        maxHttpCacheSize: 100 * 1024 * 1024,  // 100MB
        httpCacheDuration: Duration(hours: 1),
        evictionPolicy: CacheEvictionPolicy.lru,
        enableStats: true,
        groupConfigs: {
          CacheGroups.user: GroupConfig(
            defaultTTL: Duration(hours: 2),
            persistent: false,
          ),
          CacheGroups.product: GroupConfig(
            maxItems: 200,
            defaultTTL: Duration(minutes: 15),
          ),
          CacheGroups.category: GroupConfig(
            defaultTTL: Duration(hours: 24),
            persistent: true,
          ),
        },
      ),
    );
    
    // 注册内存缓存
    sl.registerSingleton<IMemoryCache>(
      MemoryCacheImpl(config: sl<CacheConfig>()),
    );
    
    // 注册缓存管理器
    sl.registerSingleton<ICacheManager>(
      CacheManagerImpl(
        memoryCache: sl<IMemoryCache>(),
        database: sl<AppDatabase>(),
        config: sl<CacheConfig>(),
      ),
    );
  }
}
```

### 2. 在主 DI 容器中注册

修改 `lib/app/di/injection_container.dart`:

```dart
import 'package:dskk_flutter_refactor/core/cache/di/cache_injection.dart';

Future<void> registerCoreDependencies(GetIt getIt, String backendUrl) async {
  // ... 现有代码 ...
  
  // 注册缓存系统
  CacheInjection.init(getIt);
  print('[DI] Registered Cache System');
}
```

## 使用示例

### 1. 在 Repository 中使用

```dart
class UserRepositoryImpl implements IUserRepository {
  final IUserRemoteDataSource remoteDataSource;
  final ICacheManager cacheManager;
  
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheManager,
  });
  
  @override
  Future<Either<Failure, UserInfo>> getUserInfo(int userId) async {
    // 先检查缓存
    final cacheKey = 'user_info_$userId';
    final cachedUser = await cacheManager.get<UserInfo>(
      cacheKey, 
      group: CacheGroups.user,
    );
    
    if (cachedUser != null) {
      return Right(cachedUser);
    }
    
    // 缓存未命中，从远程获取
    try {
      final userInfo = await remoteDataSource.getUserInfo(userId);
      
      // 存入缓存
      await cacheManager.set(
        cacheKey,
        userInfo,
        group: CacheGroups.user,
        ttl: Duration(minutes: 30),
      );
      
      return Right(userInfo);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
```

### 2. 在 BLoC 中清理缓存

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogoutUseCase logoutUseCase;
  final ICacheManager cacheManager;
  
  // 登出时清理用户相关缓存
  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await logoutUseCase();
    await cacheManager.clearGroup(CacheGroups.user);
    await cacheManager.clearGroup(CacheGroups.order);
    emit(LoggedOutState());
  }
}
```

## HTTP 缓存集成

### 1. 配置 Dio 拦截器

```dart
class CacheInterceptor extends Interceptor {
  final ICacheManager cacheManager;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 检查是否需要缓存
    if (options.method == 'GET' && _shouldCache(options.path)) {
      // 尝试从缓存获取
      final cacheKey = _buildCacheKey(options);
      final cached = cacheManager.get<Response>(cacheKey, group: CacheGroups.http);
      
      if (cached != null) {
        return handler.resolve(cached);
      }
    }
    
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 缓存成功的响应
    if (_shouldCache(response.requestOptions.path)) {
      final cacheKey = _buildCacheKey(response.requestOptions);
      cacheManager.set(
        cacheKey,
        response,
        group: CacheGroups.http,
        ttl: _getCacheDuration(response.requestOptions.path),
      );
    }
    
    super.onResponse(response, handler);
  }
}
```

## 监控和调试

### 1. 缓存统计面板

创建一个开发工具页面显示缓存统计：

```dart
class CacheStatsPage extends StatelessWidget {
  final ICacheManager cacheManager;
  
  @override
  Widget build(BuildContext context) {
    final stats = cacheManager.getStats();
    final sizeInfo = cacheManager.getCurrentSize();
    
    return Scaffold(
      appBar: AppBar(title: Text('缓存统计')),
      body: ListView(
        children: [
          _buildGroupStats(stats),
          _buildSizeInfo(sizeInfo),
          _buildActions(),
        ],
      ),
    );
  }
}
```

## 注意事项

1. **敏感数据不使用内存缓存**：Token、密码等继续使用 SecureStorage
2. **缓存一致性**：数据更新时主动清理相关缓存
3. **内存管理**：监控内存使用，避免 OOM
4. **错误处理**：缓存操作失败不应影响主流程
5. **测试覆盖**：为缓存逻辑编写单元测试