import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// HTTP缓存配置
/// 
/// 定义不同API的缓存策略
class HttpCacheConfig {
  /// 获取指定路径的缓存策略
  static CachePolicy? getCachePolicyForPath(String path, {bool forceRefresh = false}) {
    // 强制刷新时不使用缓存
    if (forceRefresh) {
      return CachePolicy.refresh;
    }
    
    // 根据路径判断缓存策略
    if (_shouldCache(path)) {
      return CachePolicy.request;
    }
    
    // 不应该缓存的接口
    if (_shouldNotCache(path)) {
      return CachePolicy.noCache;
    }
    
    // 默认不缓存
    return CachePolicy.noCache;
  }
  
  /// 获取指定路径的缓存时长
  static Duration? getCacheDurationForPath(String path) {
    // 用户信息 - 30分钟
    if (path.contains('/api/user/info')) {
      return const Duration(minutes: 30);
    }
    
    // 商品列表 - 5分钟
    if (path.contains('/api/product/list')) {
      return const Duration(minutes: 5);
    }
    
    // 商品详情 - 10分钟
    if (path.contains('/api/product/detail')) {
      return const Duration(minutes: 10);
    }
    
    // 商品分类 - 60分钟
    if (path.contains('/api/category')) {
      return const Duration(minutes: 60);
    }
    
    // 收藏列表 - 10分钟
    if (path.contains('/api/favorites')) {
      return const Duration(minutes: 10);
    }
    
    // 卖家信息 - 20分钟
    if (path.contains('/api/seller/info')) {
      return const Duration(minutes: 20);
    }
    
    // AI对话列表 - 5分钟
    if (path.contains('/model/chat/list')) {
      return const Duration(minutes: 5);
    }
    
    // AI历史消息
    if (path.contains('/model/chat/messages')) {
      // TODO: 根据消息时间判断缓存时长
      // 暂时统一2分钟
      return const Duration(minutes: 2);
    }
    
    // 搜索结果 - 5分钟
    if (path.contains('/search')) {
      return const Duration(minutes: 5);
    }
    
    // 默认不缓存
    return null;
  }
  
  /// 判断路径是否应该缓存
  static bool _shouldCache(String path) {
    // 需要缓存的路径模式
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
  
  /// 判断路径是否不应该缓存
  static bool _shouldNotCache(String path) {
    // 明确不应该缓存的路径模式
    final noCachePaths = [
      // AI推荐服务
      '/recsys/conversation/recommend',
      // AI聊天流
      '/model/chat',
      // AI服务分配
      '/model/chat/allocate',
      // 订单相关
      '/order/status',
      '/order/update',
      '/order/create',
      // 支付相关
      '/payment',
      '/pay/',
      // 实时数据
      '/websocket',
      '/ws/',
      // 认证相关
      '/auth/',
      '/login',
      '/logout',
      // 文件上传
      '/upload',
      // 统计数据
      '/analytics',
      '/track',
    ];
    
    return noCachePaths.any((pattern) => path.contains(pattern));
  }
  
  /// 判断是否是GET请求（只缓存GET请求）
  static bool shouldCacheMethod(String method) {
    return method.toUpperCase() == 'GET';
  }
}