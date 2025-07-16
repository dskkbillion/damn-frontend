import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import '../cache/http_cache_config.dart';

/// HTTP缓存拦截器
/// 
/// 提供智能的HTTP响应缓存功能
@lazySingleton
class CacheInterceptorManager {
  DioCacheInterceptor? _interceptor;
  CacheStore? _cacheStore;
  bool _initialized = false;
  
  /// 获取缓存拦截器实例
  Future<DioCacheInterceptor> get interceptor async {
    if (!_initialized) {
      await _initialize();
    }
    return _interceptor!;
  }
  
  /// 初始化缓存
  Future<void> _initialize() async {
    if (_initialized) return;
    
    try {
      // 获取应用文档目录
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = '${dir.path}/dio_cache';
      
      // 创建Hive缓存存储
      _cacheStore = HiveCacheStore(
        cacheDir,
        hiveBoxName: 'dio_http_cache',
      );
      
      // 创建缓存选项
      final options = CacheOptions(
        store: _cacheStore,
        // 默认缓存策略
        policy: CachePolicy.request,
        // 默认缓存时长
        maxStale: const Duration(minutes: 5),
        // 缓存键生成器
        keyBuilder: (request) => _buildCacheKey(request),
        // 允许POST缓存（用于某些特殊场景）
        allowPostMethod: false,
      );
      
      // 创建拦截器
      _interceptor = DioCacheInterceptor(options: options);
      _initialized = true;
      
      print('[CacheInterceptor] 初始化完成，缓存目录：$cacheDir');
    } catch (e) {
      print('[CacheInterceptor] 初始化失败：$e');
      // 失败时创建一个内存缓存作为降级方案
      _cacheStore = MemCacheStore();
      final options = CacheOptions(
        store: _cacheStore,
        policy: CachePolicy.noCache, // 降级时默认不缓存
      );
      _interceptor = DioCacheInterceptor(options: options);
      _initialized = true;
    }
  }
  
  /// 构建缓存键
  String _buildCacheKey(RequestOptions request) {
    // 基础键：方法 + 路径
    var key = '${request.method}:${request.path}';
    
    // 添加查询参数
    if (request.queryParameters.isNotEmpty) {
      final sortedParams = request.queryParameters.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      final paramString = sortedParams
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      key += '?$paramString';
    }
    
    // 对于POST请求，可以选择性地包含body的hash
    // 但目前我们不缓存POST请求
    
    return key;
  }
  
  /// 清除所有缓存
  Future<void> clearAll() async {
    await _cacheStore?.clean();
    print('[CacheInterceptor] 所有缓存已清除');
  }
  
  /// 清除特定路径的缓存
  Future<void> clearByPath(String path) async {
    // 遍历并删除匹配的缓存
    // 注意：这需要cacheStore支持按键遍历
    print('[CacheInterceptor] 清除路径缓存：$path');
  }
  
  /// 获取缓存统计信息
  Future<Map<String, dynamic>> getCacheStats() async {
    // 返回缓存统计信息
    return {
      'initialized': _initialized,
      'storeType': _cacheStore?.runtimeType.toString() ?? 'None',
      // 可以添加更多统计信息
    };
  }
  
  /// 释放资源
  Future<void> dispose() async {
    await _cacheStore?.close();
    _initialized = false;
    print('[CacheInterceptor] 资源已释放');
  }
}

/// 自定义缓存拦截器
/// 
/// 直接使用 DioCacheInterceptor 的包装器
@injectable
class SmartCacheInterceptor extends Interceptor {
  DioCacheInterceptor? _cacheInterceptor;
  CacheStore? _cacheStore;
  
  SmartCacheInterceptor();
  
  Future<void> _ensureInitialized() async {
    if (_cacheInterceptor != null) return;
    
    try {
      // 获取应用文档目录
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = '${dir.path}/dio_cache';
      
      // 创建Hive缓存存储
      _cacheStore = HiveCacheStore(
        cacheDir,
        hiveBoxName: 'dio_http_cache',
      );
      
      // 创建缓存选项
      final options = CacheOptions(
        store: _cacheStore,
        policy: CachePolicy.request,
        maxStale: const Duration(minutes: 5),
        keyBuilder: (request) => _buildCacheKey(request),
        allowPostMethod: false,
      );
      
      _cacheInterceptor = DioCacheInterceptor(options: options);
      print('[SmartCacheInterceptor] 初始化完成');
    } catch (e) {
      print('[SmartCacheInterceptor] 初始化失败：$e');
      // 失败时创建一个不缓存的拦截器
      _cacheStore = MemCacheStore();
      final options = CacheOptions(
        store: _cacheStore,
        policy: CachePolicy.noCache,
      );
      _cacheInterceptor = DioCacheInterceptor(options: options);
    }
  }
  
  String _buildCacheKey(RequestOptions request) {
    var key = '${request.method}:${request.path}';
    if (request.queryParameters.isNotEmpty) {
      final sortedParams = request.queryParameters.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      final paramString = sortedParams
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      key += '?$paramString';
    }
    return key;
  }
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 只对GET请求应用缓存
    if (!HttpCacheConfig.shouldCacheMethod(options.method)) {
      return handler.next(options);
    }
    
    // 获取路径特定的缓存策略
    final cachePolicy = HttpCacheConfig.getCachePolicyForPath(
      options.path,
      forceRefresh: options.extra['forceRefresh'] == true,
    );
    
    if (cachePolicy == CachePolicy.noCache) {
      return handler.next(options);
    }
    
    // 获取缓存时长
    final cacheDuration = HttpCacheConfig.getCacheDurationForPath(options.path);
    
    // 确保初始化
    await _ensureInitialized();
    
    // 为这个请求创建特定的缓存选项
    if (cachePolicy != null || cacheDuration != null) {
      final requestOptions = CacheOptions(
        store: _cacheStore,
        policy: cachePolicy ?? CachePolicy.request,
        maxStale: cacheDuration ?? const Duration(minutes: 5),
        keyBuilder: (request) => _buildCacheKey(request),
      );
      
      // 创建新的拦截器实例用于这个请求
      final requestInterceptor = DioCacheInterceptor(options: requestOptions);
      requestInterceptor.onRequest(options, handler);
    } else {
      _cacheInterceptor!.onRequest(options, handler);
    }
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    await _ensureInitialized();
    _cacheInterceptor!.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    await _ensureInitialized();
    _cacheInterceptor!.onError(err, handler);
  }
}