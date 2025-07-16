/// 缓存键构建器
/// 
/// 用于生成标准化的缓存键
class CacheKeyBuilder {
  /// 构建缓存键
  /// 
  /// 示例：
  /// - buildKey('user', ['123']) => 'user:123'
  /// - buildKey('product', ['456', 'detail']) => 'product:456:detail'
  static String buildKey(String prefix, List<String> parts) {
    final allParts = [prefix, ...parts];
    return allParts.where((p) => p.isNotEmpty).join(':');
  }
  
  /// 构建用户相关的缓存键
  static String userKey(int userId, String suffix) {
    return buildKey('user', [userId.toString(), suffix]);
  }
  
  /// 构建商品相关的缓存键
  static String productKey(int productId, [String? suffix]) {
    final parts = [productId.toString()];
    if (suffix != null) parts.add(suffix);
    return buildKey('product', parts);
  }
  
  /// 构建订单相关的缓存键
  static String orderKey(int orderId, [String? suffix]) {
    final parts = [orderId.toString()];
    if (suffix != null) parts.add(suffix);
    return buildKey('order', parts);
  }
  
  /// 构建搜索相关的缓存键
  static String searchKey(String keyword, {int? page}) {
    final parts = [keyword];
    if (page != null) parts.add('page$page');
    return buildKey('search', parts);
  }
  
  /// 构建HTTP请求的缓存键
  static String httpKey(String url, [Map<String, dynamic>? params]) {
    final parts = [Uri.encodeComponent(url)];
    if (params != null && params.isNotEmpty) {
      final paramStr = params.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      parts.add(Uri.encodeComponent(paramStr));
    }
    return buildKey('http', parts);
  }
  
  /// 解析缓存键
  static List<String> parseKey(String key) {
    return key.split(':');
  }
  
  /// 获取缓存键的前缀
  static String getPrefix(String key) {
    final parts = parseKey(key);
    return parts.isNotEmpty ? parts.first : '';
  }
}