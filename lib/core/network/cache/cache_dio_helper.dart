import 'package:dio/dio.dart';
import 'package:dskk_flutter_refactor/core/utils/app_logger.dart';
import 'package:get_it/get_it.dart';
import '../core_dio_client.dart';
import '../interceptors/cache_interceptor.dart';

/// 缓存Dio辅助类
/// 
/// 提供便捷的方法来创建带缓存的HTTP请求
class CacheDioHelper {
  static final _getIt = GetIt.instance;
  
  /// 获取带缓存的Dio客户端
  static CoreDioClient get cachedClient {
    try {
      return _getIt<CoreDioClient>(instanceName: 'cachedDioClient');
    } catch (e) {
      AppLogger.d('[CacheDioHelper] 获取缓存客户端失败，使用默认客户端: $e');
      return _getIt<CoreDioClient>();
    }
  }
  
  /// 获取不带缓存的Dio客户端
  static CoreDioClient get normalClient {
    return _getIt<CoreDioClient>();
  }
  
  /// 发起带缓存的GET请求
  static Future<Response<T>> getCached<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool forceRefresh = false,
  }) {
    // 添加强制刷新标记
    final requestOptions = options ?? Options();
    requestOptions.extra ??= {};
    requestOptions.extra!['forceRefresh'] = forceRefresh;
    
    return cachedClient.get<T>(
      path,
      queryParameters: queryParameters,
      options: requestOptions,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }
  
  /// 判断是否应该使用缓存客户端
  static bool shouldUseCache(String path) {
    // 这里可以根据路径判断是否应该使用缓存
    final cachePaths = [
      '/api/user/info',
      '/api/product/list',
      '/api/product/detail',
      '/api/category',
      '/api/favorites',
      '/api/seller/info',
      '/model/chat/list',
      '/model/chat/messages',
      '/search',
    ];
    
    return cachePaths.any((pattern) => path.contains(pattern));
  }
  
  /// 清除所有HTTP缓存
  static Future<void> clearAllCache() async {
    try {
      final cacheManager = _getIt<CacheInterceptorManager>();
      await cacheManager.clearAll();
    } catch (e) {
      AppLogger.d('[CacheDioHelper] 清除缓存失败: $e');
    }
  }
}